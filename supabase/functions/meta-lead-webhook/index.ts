import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Token de verificação para o webhook do Meta (defina no .env do Supabase)
const META_VERIFY_TOKEN = Deno.env.get("META_VERIFY_TOKEN") || "globalreal_meta_webhook_2026";

// Client compartilhado (usado pelo handler e pelo envio de push)
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req: Request) => {
  // =============================
  // GET — Verificação do webhook (Meta envia GET pra validar)
  // =============================
  if (req.method === "GET") {
    const url = new URL(req.url);
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token");
    const challenge = url.searchParams.get("hub.challenge");

    if (mode === "subscribe" && token === META_VERIFY_TOKEN) {
      console.log("✅ Webhook verificado pelo Meta");
      return new Response(challenge, { status: 200 });
    }

    return new Response("Forbidden", { status: 403 });
  }

  // =============================
  // POST — Receber leads do Meta
  // =============================
  if (req.method === "POST") {
    try {
      const body = await req.json();
      console.log("📩 Webhook recebido:", JSON.stringify(body));

      const supabase = supabaseAdmin;

      // O Meta envia no formato: { entry: [{ changes: [{ value: { ... } }] }] }
      const entries = body.entry || [];

      for (const entry of entries) {
        const changes = entry.changes || [];

        for (const change of changes) {
          if (change.field === "leadgen") {
            const leadgenId = change.value?.leadgen_id;
            const formId = change.value?.form_id;
            const pageId = change.value?.page_id;
            const createdTime = change.value?.created_time;

            // Buscar dados completos do lead via Graph API
            const leadData = await fetchLeadData(leadgenId);

            if (leadData) {
              // Mapear campos do Meta pro formato da tabela market_leads
              const lead = mapMetaLeadToMarketLead(leadData, formId, createdTime);

              // Inserir no Supabase (upsert evita duplicar se o Meta reenviar o mesmo lead)
              const { error } = await supabase
                .from("market_leads")
                .upsert(lead, { onConflict: "meta_lead_id" });

              if (error) {
                console.error("❌ Erro ao inserir lead:", error);
              } else {
                console.log("✅ Lead inserido:", lead.name);
                // Notificar assessores via push (FCM)
                await sendPushToAll(lead.name || "Novo lead", lead.interest || "Meta Ads");
              }
            }
          }
        }
      }

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      console.error("❌ Erro no webhook:", error);
      return new Response(JSON.stringify({ error: "Internal error" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }
  }

  return new Response("Method not allowed", { status: 405 });
});

// =============================
// Buscar dados do lead via Graph API
// =============================
async function fetchLeadData(leadgenId: string): Promise<any | null> {
  const accessToken = Deno.env.get("META_PAGE_ACCESS_TOKEN");

  if (!accessToken) {
    console.error("❌ META_PAGE_ACCESS_TOKEN não configurado");
    return null;
  }

  try {
    const res = await fetch(
      `https://graph.facebook.com/v19.0/${leadgenId}?access_token=${accessToken}`
    );

    if (!res.ok) {
      console.error("❌ Erro ao buscar lead do Meta:", await res.text());
      return null;
    }

    return await res.json();
  } catch (e) {
    console.error("❌ Erro na requisição ao Meta:", e);
    return null;
  }
}

// =============================
// Mapear campos do Meta → market_leads
// =============================
function mapMetaLeadToMarketLead(leadData: any, formId: string, createdTime: number) {
  // Extrair campos do formulário
  const fields: Record<string, string> = {};
  for (const field of leadData.field_data || []) {
    fields[field.name] = field.values?.[0] || "";
  }

  // Mapear interesse baseado na pergunta personalizada
  const interest = fields["oque_te_atrai_ao_investir_em_são_paulo?"] ||
                   fields["interest"] ||
                   "Investimento imobiliário";

  // Mapear budget baseado na faixa de investimento
  const budgetStr = fields["qual_valor_médio_pretende_investir_em_são_paulo?"] || "";
  const budget = parseBudget(budgetStr);

  return {
    market: "sao_paulo",
    name: fields["full_name"] || fields["nome_completo"] || "",
    email: fields["email"] || "",
    phone: fields["phone_number"] || fields["telefone"] || "",
    company: "",
    interest: formatInterest(interest),
    budget: budget,
    status: "new",
    notes: `Via Meta Lead Ads | Form: ${formId}`,
    ai_score: 30, // Score inicial para leads do Meta
    ai_summary: `Lead captado via anúncio Meta. Interesse: ${formatInterest(interest)}. Faixa: ${budgetStr}`,
    source: "meta_lead_ads",
    meta_lead_id: leadData.id || "",
    created_at: createdTime
      ? new Date(createdTime * 1000).toISOString()
      : new Date().toISOString(),
  };
}

// =============================
// Helpers
// =============================
function parseBudget(budgetStr: string): number | null {
  // "de_r$550_a_r$699_mil" → 550000
  const match = budgetStr.match(/r\$(\d+)/i);
  if (match) {
    const value = parseInt(match[1]);
    // Se contém "mil", multiplica por 1000
    if (budgetStr.includes("mil")) {
      return value * 1000;
    }
    return value;
  }
  return null;
}

function formatInterest(raw: string): string {
  // "renda_mensal_com_aluguel" → "Renda mensal com aluguel"
  return raw
    .replace(/_/g, " ")
    .replace(/^\w/, (c) => c.toUpperCase());
}

// =============================
// Push notification para os assessores (FCM V1)
// =============================
async function sendPushToAll(leadName: string, interest: string) {
  try {
    const FCM_PRIVATE_KEY = Deno.env.get("FCM_PRIVATE_KEY") || "";
    if (!FCM_PRIVATE_KEY) {
      console.warn("⚠️ FCM_PRIVATE_KEY não configurado, pulando push");
      return;
    }

    const FCM_CLIENT_EMAIL = "firebase-adminsdk-fbsvc@globalreal-app.iam.gserviceaccount.com";
    const FCM_PROJECT_ID = "globalreal-app";

    const accessToken = await getAccessToken(FCM_CLIENT_EMAIL, FCM_PRIVATE_KEY);
    if (!accessToken) {
      console.warn("⚠️ Não foi possível gerar access token FCM");
      return;
    }

    const { data: tokens } = await supabaseAdmin.from("push_tokens").select("token");

    if (!tokens || tokens.length === 0) {
      console.log("📲 Nenhum token de push registrado");
      return;
    }

    for (const { token } of tokens) {
      await fetch(`https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: token,
            notification: {
              title: "🔥 Novo lead: " + leadName,
              body: interest,
            },
            data: {
              route: "/leads",
              type: "new_lead",
            },
          },
        }),
      });
    }

    console.log(`📲 Push enviado para ${tokens.length} dispositivos`);
  } catch (error) {
    console.error("❌ Erro ao enviar push:", error);
  }
}

// Gerar OAuth2 access token usando JWT com Service Account
async function getAccessToken(clientEmail: string, privateKeyPem: string): Promise<string | null> {
  try {
    const now = Math.floor(Date.now() / 1000);
    const header = { alg: "RS256", typ: "JWT" };
    const payload = {
      iss: clientEmail,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    };

    const encoder = new TextEncoder();
    const headerB64 = btoa(JSON.stringify(header)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
    const payloadB64 = btoa(JSON.stringify(payload)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
    const signInput = `${headerB64}.${payloadB64}`;

    const pemContent = privateKeyPem
      .replace(/\\n/g, "\n")
      .replace(/-----BEGIN PRIVATE KEY-----/, "")
      .replace(/-----END PRIVATE KEY-----/, "")
      .replace(/\s/g, "");
    const binaryKey = Uint8Array.from(atob(pemContent), (c) => c.charCodeAt(0));

    const key = await crypto.subtle.importKey(
      "pkcs8",
      binaryKey,
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["sign"]
    );

    const signature = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, encoder.encode(signInput));
    const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

    const jwt = `${signInput}.${signatureB64}`;

    const response = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
    });

    const data = await response.json();
    return data.access_token || null;
  } catch (error) {
    console.error("❌ Erro ao gerar access token:", error);
    return null;
  }
}

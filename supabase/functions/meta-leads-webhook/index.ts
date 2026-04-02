import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const META_VERIFY_TOKEN = Deno.env.get("META_VERIFY_TOKEN") || "globalreal_leads_2024";
const META_APP_SECRET = Deno.env.get("META_APP_SECRET") || "";
const META_ACCESS_TOKEN = Deno.env.get("META_ACCESS_TOKEN") || "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  // ─── GET: Verificação do webhook pela Meta ───
  if (req.method === "GET") {
    const url = new URL(req.url);
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token");
    const challenge = url.searchParams.get("hub.challenge");

    if (mode === "subscribe" && token === META_VERIFY_TOKEN) {
      console.log("✅ Webhook verificado pela Meta");
      return new Response(challenge, { status: 200 });
    }
    return new Response("Forbidden", { status: 403 });
  }

  // ─── POST: Receber leads ───
  if (req.method === "POST") {
    try {
      const body = await req.json();
      console.log("📩 Meta webhook recebido:", JSON.stringify(body));

      const entries = body.entry ?? [];

      for (const entry of entries) {
        const changes = entry.changes ?? [];

        for (const change of changes) {
          if (change.field !== "leadgen") continue;

          const leadgenId = change.value?.leadgen_id;
          const formId = change.value?.form_id;

          if (!leadgenId) continue;

          // Buscar dados completos do lead na Graph API
          const leadData = await fetchLeadFromMeta(leadgenId);
          if (!leadData) continue;

          // Mapear campos do formulário da Meta
          const fields = parseLeadFields(leadData.field_data ?? []);

          // Determinar mercado pelo form_id ou campo customizado
          const market = detectMarket(fields, formId);

          // Inserir na tabela market_leads
          const { error } = await supabase.from("market_leads").insert({
            market,
            name: fields.name || "Lead Meta",
            email: fields.email || "",
            phone: fields.phone || "",
            company: fields.company || "",
            interest: fields.interest || "",
            budget: fields.budget ? parseFloat(fields.budget.replace(/\D/g, "")) : null,
            status: "new",
            notes: `Meta Lead ID: ${leadgenId} | Form: ${formId}`,
          });

          if (error) {
            console.error("❌ Erro ao inserir lead:", error.message);
          } else {
            console.log(`✅ Lead inserido: ${fields.name} (${market})`);
          }
        }
      }

      return new Response(JSON.stringify({ received: true }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (err) {
      console.error("❌ Erro no webhook:", err);
      return new Response(JSON.stringify({ error: "Internal error" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }
  }

  return new Response("Method not allowed", { status: 405 });
});

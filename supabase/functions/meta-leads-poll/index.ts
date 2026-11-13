// Edge Function: meta-leads-poll
//
// Consulta periodicamente os leads dos formulários configurados (Graph API,
// endpoint /{form_id}/leads), grava os novos em market_leads e dispara push.
//
// Por que existe: o webhook em tempo real exige inscrever a página no app, o que
// requer acesso de admin na página. Esta função só precisa de acesso a leads
// (leads_retrieval), que já temos. Atraso típico: ~1 minuto (cron).
//
// Segurança: exige o header `x-poll-secret` igual ao secret POLL_SECRET.
//
// Parâmetros opcionais (query string):
//   lookback_hours  janela de busca (padrão 48). Use valor alto para backfill manual.
//   dry_run=1       não grava nem envia push, só mostra o que faria.
//
// Deploy: supabase functions deploy meta-leads-poll --no-verify-jwt

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendPushToAll } from "../_shared/push.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const POLL_SECRET = Deno.env.get("POLL_SECRET") || "";

const GRAPH = "https://graph.facebook.com/v19.0";

// Só envia push para leads criados nos últimos N minutos (evita avalanche de
// notificações quando fazemos backfill de leads antigos).
const PUSH_MAX_AGE_MIN = 20;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

interface PollTarget {
  pageId: string;
  partner: string;
  market: string;
  tokenSecret: string;
  formIds: string[];
}

// Páginas/formulários monitorados. Para adicionar outro formulário, inclua o ID.
const POLL_TARGETS: PollTarget[] = [
  {
    pageId: "1332301046632644", // Leandro Nascimento Investimento Imobiliário Estruturado
    partner: "Global",
    market: "sao_paulo",
    tokenSecret: "META_TOKEN_LEANDRO",
    formIds: ["2197738357822760"],
  },
];

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

// Meta devolve "2026-10-30T17:57:38+0000"; normaliza para ISO com ":" no offset.
function parseMetaDate(s: string): Date {
  return new Date(s.replace(/([+-]\d{2})(\d{2})$/, "$1:$2"));
}

function pretty(raw: string): string {
  const t = raw.replace(/_/g, " ").trim();
  return t.charAt(0).toUpperCase() + t.slice(1);
}

function parseBudget(raw: string): number | null {
  const m = raw.match(/(\d+)/);
  if (!m) return null;
  const v = parseInt(m[1]);
  return raw.includes("mil") ? v * 1000 : v;
}

// deno-lint-ignore no-explicit-any
function mapLead(lead: any, t: PollTarget, formId: string) {
  const f: Record<string, string> = {};
  for (const fd of lead.field_data ?? []) f[fd.name] = (fd.values?.[0] ?? "").toString();

  const profession = f["qual_a_sua_profissão?"] ?? "";
  const entradaRaw = f["quanto_você_tem_disponível_para_a_entrada?"] ?? "";
  const entradaLabel = entradaRaw ? pretty(entradaRaw) : "";
  const verified = f["phone_number_verified"];

  const interest = entradaLabel ? `Entrada: ${entradaLabel}` : "Investimento imobiliário";

  const noteParts = [
    `Via Meta Lead Ads (consulta) | Parceiro: ${t.partner} | Form: ${formId}`,
    profession ? `Profissão: ${pretty(profession)}` : "",
    entradaLabel ? `Entrada: ${entradaLabel}` : "",
    verified ? `Telefone verificado: ${verified === "true" ? "sim" : "não"}` : "",
  ].filter(Boolean);

  return {
    market: t.market,
    name: (f["nome_completo"] || f["full_name"] || "").trim(),
    email: f["email"] || "",
    phone: f["telefone"] || f["phone_number"] || "",
    company: "",
    interest,
    budget: parseBudget(entradaRaw),
    status: "new",
    notes: noteParts.join(" | "),
    ai_score: 30,
    ai_summary: `Lead captado via anúncio Meta (${t.partner}). ${entradaLabel ? "Entrada: " + entradaLabel + "." : ""}${profession ? " Profissão: " + pretty(profession) + "." : ""}`.trim(),
    source: "meta_lead_ads",
    meta_lead_id: String(lead.id),
    partner: t.partner,
    created_at: parseMetaDate(lead.created_time).toISOString(),
  };
}

async function resolveToken(t: PollTarget): Promise<string | null> {
  // 1) token guardado via Facebook Login (se o dono da página autorizou)
  const { data: row } = await supabase
    .from("meta_page_tokens")
    .select("access_token")
    .eq("page_id", t.pageId)
    .maybeSingle();
  if (row?.access_token) return row.access_token as string;
  // 2) secret fixo
  return Deno.env.get(t.tokenSecret) || null;
}

Deno.serve(async (req: Request) => {
  if (!POLL_SECRET || req.headers.get("x-poll-secret") !== POLL_SECRET) {
    return json({ error: "unauthorized" }, 401);
  }

  const url = new URL(req.url);

  // Diagnóstico: envia uma notificação de teste para os dispositivos registrados
  // (não depende de nenhum lead). Útil para validar FCM/APNs.
  if (url.searchParams.get("test_push") === "1") {
    const result = await sendPushToAll(
      supabase,
      "🔔 Teste Global Real",
      "Se você está vendo isto, o push de leads está funcionando.",
    );
    return json({ testPush: result });
  }

  const lookbackHours = Number(url.searchParams.get("lookback_hours") || "48");
  const dryRun = url.searchParams.get("dry_run") === "1";
  const cutoff = Date.now() - lookbackHours * 3600 * 1000;

  const summary = {
    dryRun,
    lookbackHours,
    forms: [] as unknown[],
    inserted: 0,
    pushed: 0,
    // deno-lint-ignore no-explicit-any
    push: null as any,
  };

  for (const t of POLL_TARGETS) {
    const token = await resolveToken(t);
    if (!token) {
      summary.forms.push({ pageId: t.pageId, error: `sem token (secret ${t.tokenSecret})` });
      continue;
    }

    for (const formId of t.formIds) {
      const res = await fetch(
        `${GRAPH}/${formId}/leads?fields=id,created_time,field_data&limit=50&access_token=${token}`,
      );
      const body = await res.json();

      if (!res.ok || body.error) {
        const code = body.error?.code;
        summary.forms.push({
          formId,
          error: body.error?.message || `HTTP ${res.status}`,
          hint: code === 190 ? "token expirado ou inválido — gerar token de longa duração" : undefined,
        });
        console.error("❌ Erro ao ler leads do form", formId, body.error);
        continue;
      }

      // deno-lint-ignore no-explicit-any
      const all: any[] = body.data ?? [];
      const recent = all.filter((l) => parseMetaDate(l.created_time).getTime() >= cutoff);
      const ids = recent.map((l) => String(l.id));

      let existing = new Set<string>();
      if (ids.length > 0) {
        const { data: rows } = await supabase
          .from("market_leads")
          .select("meta_lead_id")
          .in("meta_lead_id", ids);
        existing = new Set((rows ?? []).map((r: { meta_lead_id: string }) => r.meta_lead_id));
      }

      const fresh = recent.filter((l) => !existing.has(String(l.id)));
      summary.forms.push({
        formId,
        returned: all.length,
        inWindow: recent.length,
        new: fresh.length,
      });

      if (dryRun) continue;

      for (const lead of fresh) {
        const row = mapLead(lead, t, formId);
        const { error } = await supabase.from("market_leads").insert(row);
        if (error) {
          console.error("❌ Erro ao inserir lead:", error);
          continue;
        }
        summary.inserted++;

        const ageMin = (Date.now() - parseMetaDate(lead.created_time).getTime()) / 60000;
        if (ageMin <= PUSH_MAX_AGE_MIN) {
          summary.push = await sendPushToAll(
            supabase,
            "🔥 Novo lead: " + (row.name || "Meta Ads"),
            row.interest,
          );
          summary.pushed++;
        }
      }
    }
  }

  return json(summary);
});

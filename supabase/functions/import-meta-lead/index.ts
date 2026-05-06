import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Chave simples de autenticação pra proteger o endpoint
const API_SECRET = Deno.env.get("IMPORT_API_SECRET") || "globalreal_import_secret_2026";

serve(async (req: Request) => {
  // Apenas POST
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // Verificar autenticação
  const authHeader = req.headers.get("Authorization");
  if (authHeader !== `Bearer ${API_SECRET}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  try {
    const body = await req.json();
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Aceita um lead ou array de leads
    const leads = Array.isArray(body) ? body : [body];
    const results = [];

    for (const lead of leads) {
      const mapped = {
        market: lead.market || "sao_paulo",
        name: lead.full_name || lead.name || "",
        email: lead.email || "",
        phone: lead.phone_number || lead.phone || "",
        company: lead.company || "",
        interest: formatInterest(
          lead.interest ||
          lead["oque_te_atrai_ao_investir_em_são_paulo?"] ||
          "Investimento imobiliário"
        ),
        budget: parseBudget(
          lead.budget ||
          lead["qual_valor_médio_pretende_investir_em_são_paulo?"] ||
          ""
        ),
        status: "new",
        notes: lead.notes || `Importado via API | Campanha: ${lead.campaign_name || "N/A"}`,
        ai_score: 30,
        ai_summary: `Lead importado. Plataforma: ${lead.platform || "N/A"}`,
        source: lead.source || "meta_lead_ads",
        meta_lead_id: lead.id || lead.meta_lead_id || "",
        created_at: lead.created_time || new Date().toISOString(),
      };

      const { data, error } = await supabase
        .from("market_leads")
        .upsert(mapped, { onConflict: "meta_lead_id" })
        .select();

      if (error) {
        results.push({ name: mapped.name, error: error.message });
      } else {
        results.push({ name: mapped.name, success: true });
      }
    }

    return new Response(
      JSON.stringify({ imported: results.length, results }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

function parseBudget(budgetStr: string): number | null {
  if (!budgetStr) return null;
  const match = budgetStr.match(/r?\$?(\d+)/i);
  if (match) {
    const value = parseInt(match[1]);
    if (budgetStr.includes("mil")) return value * 1000;
    return value;
  }
  return null;
}

function formatInterest(raw: string): string {
  return raw
    .replace(/_/g, " ")
    .replace(/^\w/, (c) => c.toUpperCase());
}

import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") || "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { lead_id } = await req.json();
    if (!lead_id) {
      return new Response(JSON.stringify({ error: "lead_id required" }), { status: 400 });
    }

    // 1. Buscar dados do lead
    const { data: lead, error: leadErr } = await supabase
      .from("market_leads")
      .select("*")
      .eq("id", lead_id)
      .single();

    if (leadErr || !lead) {
      return new Response(JSON.stringify({ error: "Lead not found" }), { status: 404 });
    }

    // 2. Buscar catálogo de investimentos abertos
    const { data: catalog } = await supabase
      .from("investment_catalog")
      .select("*")
      .eq("status", "open");

    const catalogText = catalog && catalog.length > 0
      ? catalog.map((p: any) =>
          `- ${p.name} (${p.spe_name}) | Categoria: ${p.category} | Retorno alvo: ${p.target_return_pct}% | Retorno proposto: ${p.proposed_return_pct}% | Investimento mínimo: R$ ${p.min_investment} | ID: ${p.id}`
        ).join("\n")
      : "Nenhum produto disponível no catálogo";

    // 3. Buscar histórico de interações
    const { data: interactions } = await supabase
      .from("lead_interactions")
      .select("event_type, points, created_at")
      .eq("lead_id", lead_id)
      .order("created_at", { ascending: false })
      .limit(20);

    const interactionSummary = interactions && interactions.length > 0
      ? interactions.map((i: any) => `${i.event_type} (+${i.points}pts)`).join(", ")
      : "Nenhuma interação registrada";

    const totalInteractionPoints = interactions
      ? interactions.reduce((sum: number, i: any) => sum + (i.points || 0), 0)
      : 0;

    // 4. Qualificar com Claude + recomendar produtos
    const prompt = `Você é um assistente de qualificação de leads imobiliários da Global Real Estate.

TAREFA 1 - QUALIFICAÇÃO:
Analise o lead e dê um score de qualidade.

TAREFA 2 - RECOMENDAÇÃO DE PRODUTOS:
Com base no perfil, interesse e budget do lead, recomende os produtos do catálogo que mais combinam.
Para cada produto recomendado, dê um match_score (0-100) e uma razão curta.

Retorne um JSON com:
- "score": número de 1 a 100 (qualidade do lead)
- "summary": resumo em português de 1-2 frases sobre o perfil
- "suggested_message": mensagem personalizada em português para o assessor enviar ao lead, mencionando os produtos recomendados
- "recommendations": array de objetos com { "catalog_id": "id do produto", "name": "nome", "match_score": número, "reason": "razão em português" }

DADOS DO LEAD:
- Nome: ${lead.name}
- Email: ${lead.email}
- Telefone: ${lead.phone}
- Empresa: ${lead.company || "Não informado"}
- Interesse: ${lead.interest || "Não informado"}
- Budget: ${lead.budget ? `R$ ${lead.budget}` : "Não informado"}
- Mercado: ${lead.market === "sao_paulo" ? "São Paulo" : "Florida"}
- Interações: ${interactionSummary}
- Pontos acumulados: ${totalInteractionPoints}

CATÁLOGO DE INVESTIMENTOS DISPONÍVEIS:
${catalogText}

REGRAS:
- Só recomende produtos cujo investimento mínimo seja <= budget do lead (se informado)
- Ordene por match_score decrescente
- Máximo 3 recomendações
- Se o budget não foi informado, recomende os de menor investimento mínimo
- Considere o interesse declarado para priorizar categorias compatíveis

Responda APENAS com o JSON, sem markdown.`;

    const aiResponse = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-20250514",
        max_tokens: 600,
        messages: [{ role: "user", content: prompt }],
        temperature: 0.3,
      }),
    });

    const aiData = await aiResponse.json();
    const content = aiData.content?.[0]?.text || "";

    let score = 50;
    let summary = "Qualificação automática indisponível";
    let suggestedMessage = "";
    let recommendations: any[] = [];

    try {
      const parsed = JSON.parse(content);
      score = parsed.score || 50;
      summary = parsed.summary || summary;
      suggestedMessage = parsed.suggested_message || "";
      recommendations = parsed.recommendations || [];
    } catch {
      console.error("Erro ao parsear resposta da IA:", content);
    }

    // Score final: base IA (até 50) + interações (até 50)
    const aiBase = Math.min(Math.round(score / 2), 50);
    const interactionPts = Math.min(totalInteractionPoints, 50);
    const finalScore = Math.min(aiBase + interactionPts, 100);

    // 5. Atualizar lead com score, resumo e recomendações
    await supabase
      .from("market_leads")
      .update({
        ai_score: finalScore,
        ai_summary: summary,
        ai_recommendations: recommendations,
      })
      .eq("id", lead_id);

    // 6. Inserir mensagem sugerida pela IA no chat
    if (suggestedMessage) {
      await supabase.from("chat_messages").insert({
        lead_id,
        sender_type: "ai",
        sender_id: "system",
        message: suggestedMessage,
      });
    }

    return new Response(
      JSON.stringify({ score: finalScore, summary, suggestedMessage, recommendations }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Erro na qualificação:", err);
    return new Response(JSON.stringify({ error: "Internal error" }), { status: 500 });
  }
});

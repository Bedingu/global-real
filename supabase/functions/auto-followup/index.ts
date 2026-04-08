import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") || "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  // Aceitar GET (cron) e POST (manual)
  if (req.method !== "GET" && req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    // 1. Buscar leads com status 'new' criados há mais de 24h
    const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

    const { data: staleLeads, error } = await supabase
      .from("market_leads")
      .select("*")
      .eq("status", "new")
      .lt("created_at", cutoff);

    if (error) {
      console.error("Erro ao buscar leads:", error.message);
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    if (!staleLeads || staleLeads.length === 0) {
      return new Response(JSON.stringify({ message: "Nenhum lead pendente de follow-up", count: 0 }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    let followupCount = 0;

    for (const lead of staleLeads) {
      // 2. Verificar se já existe follow-up automático pra esse lead
      const { data: existingFollowup } = await supabase
        .from("chat_messages")
        .select("id")
        .eq("lead_id", lead.id)
        .eq("sender_id", "auto-followup")
        .limit(1);

      if (existingFollowup && existingFollowup.length > 0) continue;

      // 3. Verificar se já houve qualquer contato do assessor
      const { data: advisorMessages } = await supabase
        .from("chat_messages")
        .select("id")
        .eq("lead_id", lead.id)
        .eq("sender_type", "advisor")
        .limit(1);

      if (advisorMessages && advisorMessages.length > 0) continue;

      // 4. Gerar mensagem de follow-up com Claude
      const prompt = `Você é um assistente da Global Real Estate. Um lead se cadastrou há mais de 24 horas e ainda não foi contatado por nenhum assessor.

Gere uma mensagem de follow-up amigável e profissional em português para ser enviada ao lead no chat do app. A mensagem deve:
- Ser acolhedora e não invasiva
- Mencionar o interesse do lead (se disponível)
- Oferecer ajuda e disponibilidade
- Ser curta (2-3 frases)

Dados do lead:
- Nome: ${lead.name}
- Interesse: ${lead.interest || "investimentos imobiliários"}
- Mercado: ${lead.market === "sao_paulo" ? "São Paulo" : "Florida"}
- Budget: ${lead.budget ? `R$ ${lead.budget}` : "não informado"}

Responda APENAS com a mensagem, sem JSON, sem aspas, sem markdown.`;

      const aiResponse = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": ANTHROPIC_API_KEY,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model: "claude-sonnet-4-20250514",
          max_tokens: 150,
          messages: [{ role: "user", content: prompt }],
          temperature: 0.5,
        }),
      });

      const aiData = await aiResponse.json();
      const message = aiData.content?.[0]?.text || "";

      if (!message) continue;

      // 5. Inserir mensagem de follow-up no chat
      await supabase.from("chat_messages").insert({
        lead_id: lead.id,
        sender_type: "ai",
        sender_id: "auto-followup",
        message: `⏰ Follow-up automático:\n\n${message}`,
      });

      // 6. Registrar interação para scoring
      try {
        await supabase.from("lead_interactions").insert({
          lead_id: lead.id,
          event_type: "auto_followup",
          points: 0,
          event_data: { trigger: "24h_no_contact" },
        });
      } catch {
        // Silencioso
      }

      followupCount++;
      console.log(`✅ Follow-up enviado para: ${lead.name}`);
    }

    return new Response(
      JSON.stringify({ message: `Follow-up enviado para ${followupCount} lead(s)`, count: followupCount }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Erro no auto-followup:", err);
    return new Response(JSON.stringify({ error: "Internal error" }), { status: 500 });
  }
});

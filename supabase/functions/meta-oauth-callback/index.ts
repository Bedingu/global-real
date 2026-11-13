// Edge Function: meta-oauth-callback
// Recebe o callback do Facebook Login (OAuth), troca o code por token,
// pega o token da Página escolhida, inscreve a Página no webhook de leadgen
// e guarda o token da Página para o webhook de leads usar depois.
//
// Fluxo:
//   1. A página web (conectar-facebook.html) manda o Leandro pro dialog OAuth do Meta.
//   2. O Meta redireciona de volta pra ESTA função com ?code=...
//   3. Trocamos code -> user access token (short) -> long-lived.
//   4. Listamos as páginas do usuário (/me/accounts) e pegamos o token da Página.
//   5. Inscrevemos a Página no app (subscribed_apps?subscribed_fields=leadgen).
//   6. Guardamos o token da Página na tabela meta_page_tokens.
//
// Deploy: supabase functions deploy meta-oauth-callback --no-verify-jwt

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// App "Global Real Leads 2"
const META_APP_ID = Deno.env.get("META_OAUTH_APP_ID") || "1624464932759283";
const META_APP_SECRET = Deno.env.get("META_OAUTH_APP_SECRET") || "";

// Precisa bater EXATAMENTE com o redirect_uri usado no dialog OAuth e
// cadastrado em "Valid OAuth Redirect URIs" no painel do app Meta.
const REDIRECT_URI =
  Deno.env.get("META_OAUTH_REDIRECT_URI") ||
  "https://pcbwbndrnnqptxdbrqnm.supabase.co/functions/v1/meta-oauth-callback";

const GRAPH = "https://graph.facebook.com/v19.0";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

function htmlPage(title: string, body: string): Response {
  return new Response(
    `<!DOCTYPE html><html lang="pt-BR"><head><meta charset="utf-8"/>
     <meta name="viewport" content="width=device-width, initial-scale=1"/>
     <title>${title}</title>
     <style>body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;
     background:#0B1220;color:#E6E9EF;display:flex;min-height:100vh;align-items:center;
     justify-content:center;margin:0;padding:24px}
     .card{max-width:520px;text-align:center}
     h1{color:#FFC107;font-size:22px} p{color:#9AA4B2;line-height:1.6}
     .ok{color:#22C55E} .err{color:#EF4444}</style></head>
     <body><div class="card">${body}</div></body></html>`,
    { status: 200, headers: { "Content-Type": "text/html; charset=utf-8" } }
  );
}

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const code = url.searchParams.get("code");
  const error = url.searchParams.get("error");

  if (error) {
    return htmlPage(
      "Autorização cancelada",
      `<h1 class="err">Autorização cancelada</h1>
       <p>O login do Facebook não foi concluído (${error}). Você pode fechar esta janela e tentar de novo.</p>`
    );
  }

  if (!code) {
    return htmlPage(
      "Link inválido",
      `<h1 class="err">Link inválido</h1><p>Faltou o código de autorização. Abra o link de conexão de novo.</p>`
    );
  }

  if (!META_APP_SECRET) {
    console.error("❌ META_OAUTH_APP_SECRET não configurado");
    return htmlPage(
      "Configuração pendente",
      `<h1 class="err">Configuração pendente</h1><p>O app ainda não está pronto para conectar. Avise o administrador.</p>`
    );
  }

  try {
    // 1) code -> user access token (short-lived)
    const tokenRes = await fetch(
      `${GRAPH}/oauth/access_token?client_id=${META_APP_ID}` +
        `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}` +
        `&client_secret=${META_APP_SECRET}&code=${code}`
    );
    const tokenData = await tokenRes.json();
    if (!tokenData.access_token) {
      console.error("❌ Falha ao trocar code por token:", tokenData);
      return htmlPage("Erro", `<h1 class="err">Não foi possível conectar</h1><p>Falha ao obter o token. Tente novamente.</p>`);
    }
    const shortToken = tokenData.access_token;

    // 2) short-lived -> long-lived user token
    const longRes = await fetch(
      `${GRAPH}/oauth/access_token?grant_type=fb_exchange_token` +
        `&client_id=${META_APP_ID}&client_secret=${META_APP_SECRET}` +
        `&fb_exchange_token=${shortToken}`
    );
    const longData = await longRes.json();
    const userToken = longData.access_token || shortToken;

    // 3) listar páginas do usuário
    const pagesRes = await fetch(
      `${GRAPH}/me/accounts?fields=id,name,access_token&access_token=${userToken}`
    );
    const pagesData = await pagesRes.json();
    const pages = pagesData.data || [];

    if (pages.length === 0) {
      return htmlPage(
        "Nenhuma página",
        `<h1 class="err">Nenhuma página encontrada</h1><p>Sua conta não tem páginas disponíveis para conectar.</p>`
      );
    }

    // 4) para cada página: inscrever no webhook + guardar token
    const results: string[] = [];
    for (const page of pages) {
      const pageId = page.id as string;
      const pageName = page.name as string;
      const pageToken = page.access_token as string;

      // inscreve a página no app para receber leadgen
      const subRes = await fetch(
        `${GRAPH}/${pageId}/subscribed_apps?subscribed_fields=leadgen&access_token=${pageToken}`,
        { method: "POST" }
      );
      const subData = await subRes.json();
      const ok = subData.success === true;

      // guarda/atualiza o token da página
      await supabase.from("meta_page_tokens").upsert(
        {
          page_id: pageId,
          page_name: pageName,
          access_token: pageToken,
          subscribed: ok,
          updated_at: new Date().toISOString(),
        },
        { onConflict: "page_id" }
      );

      results.push(`${pageName}: ${ok ? "conectada ✅" : "falha ao inscrever ⚠️"}`);
      console.log(`Página ${pageName} (${pageId}) — inscrita: ${ok}`, subData);
    }

    return htmlPage(
      "Conectado!",
      `<h1 class="ok">Tudo certo!</h1>
       <p>Suas páginas foram conectadas ao app de leads:</p>
       <p>${results.join("<br/>")}</p>
       <p>Pode fechar esta janela. Os próximos leads vão cair direto no app.</p>`
    );
  } catch (e) {
    console.error("❌ Erro no callback OAuth:", e);
    return htmlPage("Erro", `<h1 class="err">Algo deu errado</h1><p>Tente abrir o link de conexão novamente.</p>`);
  }
});

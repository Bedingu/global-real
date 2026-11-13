-- =============================================
-- TABELA: meta_page_tokens
-- Guarda o Page Access Token de cada página conectada via Facebook Login
-- (fluxo OAuth em que o dono da página autoriza o app).
-- O webhook de leads usa esse token para buscar os dados do lead.
-- =============================================
CREATE TABLE IF NOT EXISTS public.meta_page_tokens (
  page_id TEXT PRIMARY KEY,
  page_name TEXT DEFAULT '',
  access_token TEXT NOT NULL,
  subscribed BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.meta_page_tokens ENABLE ROW LEVEL SECURITY;

-- Só a service role (edge functions) acessa. Bloqueia clientes.
REVOKE ALL ON public.meta_page_tokens FROM anon, authenticated;

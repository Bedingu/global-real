-- =============================================
-- TABELA: app_config
-- Configurações dinâmicas do app (chave -> valor),
-- editáveis sem recompilar. Ex.: link de agendamento da
-- videoconferência de qualificação de associado.
-- =============================================
CREATE TABLE IF NOT EXISTS public.app_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- Leitura liberada para qualquer usuário autenticado (config pública do app).
DROP POLICY IF EXISTS "Anyone can read app_config" ON public.app_config;
CREATE POLICY "Anyone can read app_config"
  ON public.app_config
  FOR SELECT USING (true);

-- Escrita só via service role (painel/admin). Bloqueia insert/update de clientes.
REVOKE INSERT, UPDATE, DELETE ON public.app_config FROM anon, authenticated;

-- Semente: chave do link de agendamento (vazia até o Leandro mandar o link).
INSERT INTO public.app_config (key, value)
VALUES ('associate_scheduling_url', '')
ON CONFLICT (key) DO NOTHING;

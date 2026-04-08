-- =============================================
-- TABELA: chat_messages
-- Mensagens entre assessor e lead
-- =============================================
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id UUID NOT NULL REFERENCES public.market_leads(id) ON DELETE CASCADE,
  sender_type TEXT NOT NULL CHECK (sender_type IN ('advisor', 'lead', 'ai')),
  sender_id TEXT DEFAULT '',
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read chat messages"
  ON public.chat_messages
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert chat messages"
  ON public.chat_messages
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE INDEX idx_chat_messages_lead ON public.chat_messages(lead_id);
CREATE INDEX idx_chat_messages_created ON public.chat_messages(created_at);

-- =============================================
-- Adicionar colunas de IA na tabela market_leads
-- =============================================
ALTER TABLE public.market_leads
  ADD COLUMN IF NOT EXISTS ai_score INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ai_summary TEXT DEFAULT '';

-- =============================================
-- TRIGGER: qualificar lead com IA ao inserir
-- =============================================
CREATE OR REPLACE FUNCTION notify_new_lead()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := current_setting('app.settings.supabase_url') || '/functions/v1/qualify-lead',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
    ),
    body := jsonb_build_object('lead_id', NEW.id)
  );
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_qualify_new_lead ON public.market_leads;
CREATE TRIGGER trg_qualify_new_lead
  AFTER INSERT ON public.market_leads
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_lead();

-- =============================================
-- Habilitar Realtime para chat_messages
-- =============================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;

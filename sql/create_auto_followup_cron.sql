-- =============================================
-- Habilitar extensão pg_cron (se não estiver)
-- =============================================
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- =============================================
-- Adicionar evento auto_followup nas regras de scoring
-- =============================================
INSERT INTO public.scoring_rules (event_type, points, description)
VALUES ('auto_followup', 0, 'Follow-up automático enviado pela IA')
ON CONFLICT (event_type) DO NOTHING;

-- =============================================
-- Cron job: rodar auto-followup a cada 6 horas
-- =============================================
SELECT cron.schedule(
  'auto-followup-leads',
  '0 */6 * * *',  -- a cada 6 horas
  $$
  SELECT net.http_post(
    url := current_setting('app.settings.supabase_url') || '/functions/v1/auto-followup',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
    ),
    body := '{}'::jsonb
  );
  $$
);

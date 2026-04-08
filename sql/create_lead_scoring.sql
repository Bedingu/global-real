-- =============================================
-- TABELA: lead_interactions
-- Rastreia cada interação do lead para scoring
-- =============================================
CREATE TABLE IF NOT EXISTS public.lead_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id UUID NOT NULL REFERENCES public.market_leads(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  event_data JSONB DEFAULT '{}',
  points INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.lead_interactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read interactions"
  ON public.lead_interactions
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert interactions"
  ON public.lead_interactions
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE INDEX idx_lead_interactions_lead ON public.lead_interactions(lead_id);
CREATE INDEX idx_lead_interactions_event ON public.lead_interactions(event_type);

-- =============================================
-- Tabela de regras de pontuação
-- =============================================
CREATE TABLE IF NOT EXISTS public.scoring_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT UNIQUE NOT NULL,
  points INTEGER NOT NULL DEFAULT 0,
  description TEXT DEFAULT ''
);

ALTER TABLE public.scoring_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read scoring rules"
  ON public.scoring_rules
  FOR SELECT USING (auth.role() = 'authenticated');

-- Regras padrão de pontuação
INSERT INTO public.scoring_rules (event_type, points, description) VALUES
  ('signup', 10, 'Lead se cadastrou no app'),
  ('login', 2, 'Lead fez login no app'),
  ('view_development', 5, 'Visualizou um empreendimento'),
  ('favorite_development', 8, 'Favoritou um empreendimento'),
  ('view_investment', 10, 'Visualizou detalhes de investimento'),
  ('use_calculator', 12, 'Usou a calculadora de investimentos'),
  ('click_whatsapp', 7, 'Clicou no botão de WhatsApp'),
  ('reply_chat', 15, 'Respondeu no chat do app'),
  ('open_email', 3, 'Abriu um email'),
  ('click_email_link', 6, 'Clicou em link do email'),
  ('return_visit', 4, 'Voltou ao app após 24h'),
  ('share_content', 5, 'Compartilhou conteúdo do app'),
  ('watch_video', 6, 'Assistiu vídeo educacional'),
  ('download_material', 8, 'Baixou material/documento'),
  ('request_contact', 20, 'Solicitou contato com assessor'),
  ('advisor_contacted', 5, 'Assessor entrou em contato'),
  ('status_qualified', 15, 'Lead foi qualificado pelo assessor')
ON CONFLICT (event_type) DO NOTHING;

-- =============================================
-- Function: recalcular score do lead
-- Combina score da IA + pontos de interações
-- =============================================
CREATE OR REPLACE FUNCTION recalculate_lead_score(p_lead_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_ai_base INTEGER;
  v_interaction_points INTEGER;
  v_final_score INTEGER;
BEGIN
  -- Score base da IA (máx 50 pontos, normalizado)
  SELECT LEAST(COALESCE(ai_score, 0), 100) / 2
  INTO v_ai_base
  FROM market_leads
  WHERE id = p_lead_id;

  -- Soma dos pontos de interações (máx 50 pontos)
  SELECT LEAST(COALESCE(SUM(points), 0), 50)
  INTO v_interaction_points
  FROM lead_interactions
  WHERE lead_id = p_lead_id;

  -- Score final = base IA (até 50) + interações (até 50) = máx 100
  v_final_score := LEAST(v_ai_base + v_interaction_points, 100);

  -- Atualizar o score no lead
  UPDATE market_leads
  SET ai_score = v_final_score
  WHERE id = p_lead_id;

  RETURN v_final_score;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Trigger: recalcular score ao inserir interação
-- =============================================
CREATE OR REPLACE FUNCTION trg_recalculate_on_interaction()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM recalculate_lead_score(NEW.lead_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_score_on_interaction ON public.lead_interactions;
CREATE TRIGGER trg_score_on_interaction
  AFTER INSERT ON public.lead_interactions
  FOR EACH ROW
  EXECUTE FUNCTION trg_recalculate_on_interaction();

-- =============================================
-- Adicionar coluna de recomendações da IA
-- =============================================
ALTER TABLE public.market_leads
  ADD COLUMN IF NOT EXISTS ai_recommendations JSONB DEFAULT '[]';

-- JSONB vai armazenar array de objetos:
-- [
--   {
--     "catalog_id": "uuid",
--     "name": "Residencial Alto Padrão SP",
--     "match_score": 92,
--     "reason": "Budget compatível, interesse alinhado"
--   }
-- ]

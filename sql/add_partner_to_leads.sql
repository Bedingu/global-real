-- =============================================
-- Suporte multi-parceiro nos leads (campanha cooperada)
-- Adiciona a coluna `partner` em market_leads para identificar de qual
-- associado/parceiro (página do Meta) o lead veio. Ex.: 'Global', 'UmQue'.
-- =============================================
ALTER TABLE public.market_leads
  ADD COLUMN IF NOT EXISTS partner TEXT DEFAULT '';

-- Índice para filtrar/agrupar leads por parceiro no app.
CREATE INDEX IF NOT EXISTS idx_market_leads_partner
  ON public.market_leads(partner);

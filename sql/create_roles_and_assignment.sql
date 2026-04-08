-- =============================================
-- Adicionar role e display_name na tabela profiles
-- =============================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'advisor', 'master')),
  ADD COLUMN IF NOT EXISTS display_name TEXT DEFAULT '';

-- =============================================
-- Adicionar assigned_to na tabela market_leads
-- (qual assessor é responsável pelo lead)
-- =============================================
ALTER TABLE public.market_leads
  ADD COLUMN IF NOT EXISTS assigned_to UUID REFERENCES auth.users(id);

CREATE INDEX IF NOT EXISTS idx_market_leads_assigned ON public.market_leads(assigned_to);

-- =============================================
-- RLS: assessor vê só seus leads, master vê todos
-- =============================================

-- Remover policies antigas de leitura
DROP POLICY IF EXISTS "Authenticated users can read leads" ON public.market_leads;

-- Master vê todos os leads
CREATE POLICY "Master can read all leads"
  ON public.market_leads
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'master'
    )
  );

-- Assessor vê só leads atribuídos a ele
CREATE POLICY "Advisor can read assigned leads"
  ON public.market_leads
  FOR SELECT USING (
    assigned_to = auth.uid()
    OR assigned_to IS NULL
  );

-- Remover policy antiga de update
DROP POLICY IF EXISTS "Authenticated users can update lead status" ON public.market_leads;

-- Master pode atualizar qualquer lead
CREATE POLICY "Master can update all leads"
  ON public.market_leads
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'master'
    )
  );

-- Assessor pode atualizar seus leads
CREATE POLICY "Advisor can update assigned leads"
  ON public.market_leads
  FOR UPDATE USING (
    assigned_to = auth.uid()
    OR assigned_to IS NULL
  );

-- =============================================
-- View: lista de assessores (para atribuição)
-- =============================================
CREATE OR REPLACE VIEW public.advisors_list AS
SELECT
  p.id,
  p.display_name,
  p.role,
  (SELECT COUNT(*) FROM public.market_leads ml WHERE ml.assigned_to = p.id) AS lead_count
FROM public.profiles p
WHERE p.role IN ('advisor', 'master');

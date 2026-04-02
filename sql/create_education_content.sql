-- =============================================
-- TABELA: education_content
-- Vídeos, aulas e materiais de capacitação
-- =============================================
CREATE TABLE IF NOT EXISTS public.education_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  category TEXT NOT NULL DEFAULT 'video'
    CHECK (category IN ('video', 'article', 'course')),
  video_url TEXT,
  thumbnail_url TEXT,
  duration_minutes INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.education_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read education content"
  ON public.education_content
  FOR SELECT
  USING (auth.role() = 'authenticated');

REVOKE INSERT, UPDATE, DELETE ON public.education_content FROM authenticated;
REVOKE ALL ON public.education_content FROM anon;

-- =============================================
-- DADOS DE EXEMPLO
-- =============================================
INSERT INTO public.education_content (title, description, category, duration_minutes) VALUES
('Como apresentar imóveis para investidores', 'Técnicas de abordagem e argumentação para o perfil investidor.', 'video', 18),
('Análise de rentabilidade: ADR, Yield e ROI', 'Entenda as métricas essenciais para avaliar um investimento imobiliário.', 'course', 45),
('Tendências do mercado imobiliário 2026', 'Panorama das oportunidades e riscos no cenário atual.', 'article', 12);

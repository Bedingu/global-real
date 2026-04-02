-- =============================================
-- TABELA: investment_catalog
-- Catálogo de produtos SPE com rentabilidade
-- =============================================
CREATE TABLE IF NOT EXISTS public.investment_catalog (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  spe_name TEXT DEFAULT '',
  category TEXT DEFAULT '',
  target_return_pct NUMERIC(6,2) DEFAULT 0,
  proposed_return_pct NUMERIC(6,2) DEFAULT 0,
  min_investment NUMERIC(14,2) DEFAULT 0,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed')),
  description TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.investment_catalog ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read catalog"
  ON public.investment_catalog
  FOR SELECT USING (auth.role() = 'authenticated');

REVOKE INSERT, UPDATE, DELETE ON public.investment_catalog FROM authenticated;
REVOKE ALL ON public.investment_catalog FROM anon;

-- Dados de exemplo
INSERT INTO public.investment_catalog (name, spe_name, category, target_return_pct, proposed_return_pct, min_investment, status) VALUES
('Residencial Alto Padrão SP', 'SPE Jardins 01', 'Residencial', 15.5, 18.2, 250000, 'open'),
('Logística Guarulhos', 'SPE Log GRU', 'Logística', 12.0, 14.8, 500000, 'open'),
('Flat Hoteleiro Faria Lima', 'SPE FL 22', 'Hotelaria', 10.5, 13.0, 180000, 'open'),
('Loteamento Litoral Norte', 'SPE Litoral 05', 'Loteamento', 20.0, 24.5, 100000, 'closed');

-- =============================================
-- TABELA: market_leads
-- Leads de investidores por mercado (SP / FL)
-- =============================================
CREATE TABLE IF NOT EXISTS public.market_leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  market TEXT NOT NULL CHECK (market IN ('sao_paulo', 'florida')),
  name TEXT NOT NULL,
  email TEXT DEFAULT '',
  phone TEXT DEFAULT '',
  company TEXT DEFAULT '',
  interest TEXT DEFAULT '',
  budget NUMERIC(14,2),
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'closed')),
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.market_leads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read leads"
  ON public.market_leads
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update lead status"
  ON public.market_leads
  FOR UPDATE USING (auth.role() = 'authenticated');

REVOKE INSERT, DELETE ON public.market_leads FROM authenticated;
REVOKE ALL ON public.market_leads FROM anon;

CREATE INDEX idx_market_leads_market ON public.market_leads(market);
CREATE INDEX idx_market_leads_status ON public.market_leads(status);

-- Dados de exemplo
INSERT INTO public.market_leads (market, name, email, phone, company, interest, budget, status) VALUES
('sao_paulo', 'Carlos Mendes', 'carlos@exemplo.com', '(11) 99999-0001', 'Mendes Investimentos', 'Residencial alto padrão', 800000, 'new'),
('sao_paulo', 'Ana Ferreira', 'ana@exemplo.com', '(11) 99999-0002', 'AF Capital', 'Flat hoteleiro', 350000, 'contacted'),
('sao_paulo', 'Roberto Lima', 'roberto@exemplo.com', '(11) 99999-0003', '', 'Loteamento', 150000, 'qualified'),
('florida', 'John Smith', 'john@example.com', '+1 305-555-0101', 'Smith Realty', 'Condo Miami Beach', 450000, 'new'),
('florida', 'Maria Garcia', 'maria@example.com', '+1 786-555-0202', 'MG Investments', 'Vacation home', 600000, 'contacted');

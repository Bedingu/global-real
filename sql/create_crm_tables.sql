-- =============================================
-- CRM Imobiliário — Tabelas de Gestão
-- =============================================

-- 1. Imóveis cadastrados pelo assessor
CREATE TABLE IF NOT EXISTS crm_properties (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  address TEXT,
  city TEXT,
  neighborhood TEXT,
  property_type TEXT DEFAULT 'apartment',
  bedrooms INT DEFAULT 0,
  bathrooms INT DEFAULT 0,
  area_m2 NUMERIC,
  price NUMERIC,
  status TEXT DEFAULT 'pending_approval',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Propostas
CREATE TABLE IF NOT EXISTS crm_proposals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  property_id UUID REFERENCES crm_properties(id),
  lead_id UUID REFERENCES market_leads(id),
  
  advisor_id UUID REFERENCES auth.users(id),
  proposed_value NUMERIC NOT NULL,
  status TEXT DEFAULT 'active',
  due_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Contratos
CREATE TABLE IF NOT EXISTS crm_contracts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  proposal_id UUID REFERENCES crm_proposals(id),
  property_id UUID REFERENCES crm_properties(id),
  lead_id UUID REFERENCES market_leads(id),
  advisor_id UUID REFERENCES auth.users(id),
  contract_type TEXT DEFAULT 'sale',
  value NUMERIC NOT NULL,
  start_date DATE,
  end_date DATE,
  status TEXT DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Chaves (controle de retirada/devolução)
CREATE TABLE IF NOT EXISTS crm_keys (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  property_id UUID REFERENCES crm_properties(id),
  person_name TEXT NOT NULL,
  withdrawn_at TIMESTAMPTZ DEFAULT NOW(),
  returned_at TIMESTAMPTZ,
  status TEXT DEFAULT 'withdrawn',
  notes TEXT
);

-- 5. Atividades (tarefas/agenda do assessor)
CREATE TABLE IF NOT EXISTS crm_activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  advisor_id UUID REFERENCES auth.users(id),
  lead_id UUID REFERENCES market_leads(id),
  property_id UUID REFERENCES crm_properties(id),
  activity_type TEXT DEFAULT 'task',
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMPTZ,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Aluguéis
CREATE TABLE IF NOT EXISTS crm_rentals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  property_id UUID REFERENCES crm_properties(id),
  tenant_name TEXT NOT NULL,
  tenant_email TEXT,
  tenant_phone TEXT,
  monthly_value NUMERIC NOT NULL,
  start_date DATE,
  end_date DATE,
  status TEXT DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- RLS
-- =============================================
ALTER TABLE crm_properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_rentals ENABLE ROW LEVEL SECURITY;

-- Properties: owner ou master vê
CREATE POLICY "Users can manage own properties" ON crm_properties
  FOR ALL USING (
    owner_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'master')
  );

-- Proposals: advisor ou master
CREATE POLICY "Advisors manage proposals" ON crm_proposals
  FOR ALL USING (
    advisor_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'master')
  );

-- Contracts: advisor ou master
CREATE POLICY "Advisors manage contracts" ON crm_contracts
  FOR ALL USING (
    advisor_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'master')
  );

-- Keys: qualquer autenticado
CREATE POLICY "Authenticated manage keys" ON crm_keys
  FOR ALL USING (auth.role() = 'authenticated');

-- Activities: advisor ou master
CREATE POLICY "Advisors manage activities" ON crm_activities
  FOR ALL USING (
    advisor_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'master')
  );

-- Rentals: qualquer autenticado
CREATE POLICY "Authenticated manage rentals" ON crm_rentals
  FOR ALL USING (auth.role() = 'authenticated');


-- 7. Condomínios
CREATE TABLE IF NOT EXISTS crm_condominiums (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  neighborhood TEXT,
  developer TEXT,
  builder TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE crm_condominiums ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage condominiums" ON crm_condominiums
  FOR ALL USING (
    owner_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'master')
  );

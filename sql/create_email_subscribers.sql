-- Tabela para captura de emails da landing page
CREATE TABLE IF NOT EXISTS email_subscribers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT,
  source TEXT DEFAULT 'landing_page',
  language TEXT DEFAULT 'pt',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index para busca por email
CREATE INDEX IF NOT EXISTS idx_subscribers_email ON email_subscribers(email);

-- RLS: permitir INSERT público (anon), SELECT só autenticado
ALTER TABLE email_subscribers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can subscribe"
  ON email_subscribers FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can read subscribers"
  ON email_subscribers FOR SELECT
  TO authenticated
  USING (true);

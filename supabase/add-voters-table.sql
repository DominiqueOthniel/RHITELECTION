-- ============================================
-- AJOUT DE LA TABLE VOTERS
-- ============================================
-- Ce script ajoute la table voters pour stocker les informations complètes des votants

-- Table voters
CREATE TABLE IF NOT EXISTS voters (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  vote_code VARCHAR(255) UNIQUE NOT NULL,
  has_voted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les codes de vote
CREATE INDEX IF NOT EXISTS idx_voters_vote_code ON voters(vote_code);
CREATE INDEX IF NOT EXISTS idx_voters_student_id ON voters(student_id);
CREATE INDEX IF NOT EXISTS idx_voters_email ON voters(email);

-- Ajouter la colonne voter_id à voter_codes si elle n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'voter_codes' AND column_name = 'voter_id'
  ) THEN
    ALTER TABLE voter_codes ADD COLUMN voter_id UUID REFERENCES voters(id) ON DELETE CASCADE;
    CREATE INDEX IF NOT EXISTS idx_voter_codes_voter_id ON voter_codes(voter_id);
  END IF;
END $$;

-- Activer RLS sur la table voters
ALTER TABLE voters ENABLE ROW LEVEL SECURITY;

-- Politiques pour voters
CREATE POLICY "Voters are viewable by authenticated users"
  ON voters FOR SELECT
  USING (true); -- À ajuster selon votre système d'authentification

CREATE POLICY "Voters can be inserted by authenticated users"
  ON voters FOR INSERT
  WITH CHECK (true); -- À ajuster selon votre système d'authentification

CREATE POLICY "Voters can be updated by authenticated users"
  ON voters FOR UPDATE
  USING (true); -- À ajuster selon votre système d'authentification

CREATE POLICY "Voters can be deleted by authenticated users"
  ON voters FOR DELETE
  USING (true); -- À ajuster selon votre système d'authentification


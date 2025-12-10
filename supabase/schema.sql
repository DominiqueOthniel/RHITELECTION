-- ============================================
-- SCHEMA SQL POUR RHIT ELECTIONS
-- ============================================

-- Extension pour générer des UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: candidates
-- ============================================
CREATE TABLE IF NOT EXISTS candidates (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  "position" VARCHAR(255) NOT NULL,
  description TEXT,
  bio TEXT,
  year VARCHAR(255),
  program TEXT[] DEFAULT '{}',
  experience TEXT[] DEFAULT '{}',
  image TEXT,
  initials VARCHAR(10) NOT NULL,
  social_links JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_candidates_position ON candidates("position");
CREATE INDEX IF NOT EXISTS idx_candidates_created_at ON candidates(created_at);

-- ============================================
-- TABLE: elections
-- ============================================
CREATE TABLE IF NOT EXISTS elections (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) NOT NULL DEFAULT 'Élection RHIT',
  start_date TIMESTAMPTZ DEFAULT NOW(),
  end_date TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les élections actives
CREATE INDEX IF NOT EXISTS idx_elections_is_active ON elections(is_active);
CREATE INDEX IF NOT EXISTS idx_elections_end_date ON elections(end_date);

-- ============================================
-- TABLE: voters
-- ============================================
CREATE TABLE IF NOT EXISTS voters (
  id VARCHAR(255) PRIMARY KEY,
  student_id VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  vote_code VARCHAR(255) UNIQUE NOT NULL,
  has_voted BOOLEAN DEFAULT false,
  whatsapp VARCHAR(255),
  year VARCHAR(255),
  field VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les codes de vote
CREATE INDEX IF NOT EXISTS idx_voters_vote_code ON voters(vote_code);
CREATE INDEX IF NOT EXISTS idx_voters_student_id ON voters(student_id);
CREATE INDEX IF NOT EXISTS idx_voters_email ON voters(email);

-- ============================================
-- TABLE: voter_codes
-- ============================================
CREATE TABLE IF NOT EXISTS voter_codes (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(255) UNIQUE NOT NULL,
  is_used BOOLEAN DEFAULT false,
  used_at TIMESTAMPTZ,
  election_id VARCHAR(255) REFERENCES elections(id) ON DELETE CASCADE,
  voter_id VARCHAR(255) REFERENCES voters(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les codes de vote
CREATE INDEX IF NOT EXISTS idx_voter_codes_code ON voter_codes(code);
CREATE INDEX IF NOT EXISTS idx_voter_codes_is_used ON voter_codes(is_used);
CREATE INDEX IF NOT EXISTS idx_voter_codes_election_id ON voter_codes(election_id);

-- ============================================
-- TABLE: votes
-- ============================================
CREATE TABLE IF NOT EXISTS votes (
  id VARCHAR(255) PRIMARY KEY,
  candidate_id VARCHAR(255) NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  voter_code VARCHAR(255) NOT NULL,
  election_id VARCHAR(255) REFERENCES elections(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  -- Contrainte pour éviter les votes multiples avec le même code
  UNIQUE(voter_code, election_id)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_votes_candidate_id ON votes(candidate_id);
CREATE INDEX IF NOT EXISTS idx_votes_voter_code ON votes(voter_code);
CREATE INDEX IF NOT EXISTS idx_votes_election_id ON votes(election_id);
CREATE INDEX IF NOT EXISTS idx_votes_created_at ON votes(created_at);

-- ============================================
-- TRIGGERS: Mise à jour automatique de updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_candidates_updated_at ON candidates;
CREATE TRIGGER update_candidates_updated_at
  BEFORE UPDATE ON candidates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_elections_updated_at ON elections;
CREATE TRIGGER update_elections_updated_at
  BEFORE UPDATE ON elections
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- TRIGGER: Marquer le code comme utilisé lors d'un vote
-- ============================================
CREATE OR REPLACE FUNCTION mark_voter_code_as_used()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE voter_codes
  SET is_used = true, used_at = NOW()
  WHERE code = NEW.voter_code AND election_id = NEW.election_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS mark_code_used_on_vote ON votes;
CREATE TRIGGER mark_code_used_on_vote
  AFTER INSERT ON votes
  FOR EACH ROW
  EXECUTE FUNCTION mark_voter_code_as_used();

-- ============================================
-- VIEWS: Vues utiles pour les statistiques
-- ============================================

-- Vue pour les résultats des votes par candidat
DROP VIEW IF EXISTS vote_results CASCADE;
CREATE OR REPLACE VIEW vote_results AS
SELECT 
  c.id as candidate_id,
  c.name,
  c."position",
  c.initials,
  COUNT(v.id) as vote_count,
  ROUND(
    CASE 
      WHEN (SELECT COUNT(*) FROM votes) > 0 
      THEN (COUNT(v.id)::DECIMAL / (SELECT COUNT(*) FROM votes)::DECIMAL) * 100 
      ELSE 0 
    END, 
    2
  ) as vote_percentage
FROM candidates c
LEFT JOIN votes v ON c.id = v.candidate_id
GROUP BY c.id, c.name, c."position", c.initials
ORDER BY vote_count DESC;

-- Vue pour les statistiques d'élection
DROP VIEW IF EXISTS election_stats CASCADE;
CREATE OR REPLACE VIEW election_stats AS
SELECT 
  e.id as election_id,
  e.name,
  e.start_date,
  e.end_date,
  e.is_active,
  COUNT(DISTINCT v.id) as total_votes,
  COUNT(DISTINCT vc.id) as total_codes,
  COUNT(DISTINCT CASE WHEN vc.is_used THEN vc.id END) as used_codes,
  COUNT(DISTINCT c.id) as total_candidates
FROM elections e
LEFT JOIN votes v ON e.id = v.election_id
LEFT JOIN voter_codes vc ON e.id = vc.election_id
LEFT JOIN candidates c ON c.id = v.candidate_id
GROUP BY e.id, e.name, e.start_date, e.end_date, e.is_active;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Activer RLS sur toutes les tables
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE elections ENABLE ROW LEVEL SECURITY;
ALTER TABLE voter_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- Politiques pour candidates (lecture publique, écriture admin)
CREATE POLICY "Candidates are viewable by everyone"
  ON candidates FOR SELECT
  USING (true);

CREATE POLICY "Candidates can be inserted by authenticated users"
  ON candidates FOR INSERT
  WITH CHECK (true); -- À ajuster selon votre système d'authentification

CREATE POLICY "Candidates can be updated by authenticated users"
  ON candidates FOR UPDATE
  USING (true); -- À ajuster selon votre système d'authentification

CREATE POLICY "Candidates can be deleted by authenticated users"
  ON candidates FOR DELETE
  USING (true); -- À ajuster selon votre système d'authentification

-- Politiques pour elections
CREATE POLICY "Elections are viewable by everyone"
  ON elections FOR SELECT
  USING (true);

CREATE POLICY "Elections can be managed by authenticated users"
  ON elections FOR ALL
  USING (true); -- À ajuster selon votre système d'authentification

-- Politiques pour voter_codes (lecture limitée)
CREATE POLICY "Voter codes are viewable by authenticated users"
  ON voter_codes FOR SELECT
  USING (true); -- À ajuster selon votre système d'authentification

CREATE POLICY "Voter codes can be inserted by authenticated users"
  ON voter_codes FOR INSERT
  WITH CHECK (true); -- À ajuster selon votre système d'authentification

-- Politiques pour votes (lecture publique pour résultats, écriture limitée)
CREATE POLICY "Votes are viewable by everyone"
  ON votes FOR SELECT
  USING (true);

CREATE POLICY "Votes can be inserted by anyone"
  ON votes FOR INSERT
  WITH CHECK (true);

-- ============================================
-- FONCTIONS UTILITAIRES
-- ============================================

-- Fonction pour vérifier si un code de voteur est valide
CREATE OR REPLACE FUNCTION is_voter_code_valid(
  p_code VARCHAR(255),
  p_election_id VARCHAR(255)
)
RETURNS BOOLEAN AS $$
DECLARE
  v_code_exists BOOLEAN;
  v_code_used BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM voter_codes WHERE code = p_code AND election_id = p_election_id)
  INTO v_code_exists;
  
  IF NOT v_code_exists THEN
    RETURN false;
  END IF;
  
  SELECT is_used INTO v_code_used
  FROM voter_codes
  WHERE code = p_code AND election_id = p_election_id;
  
  RETURN NOT v_code_used;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour obtenir les résultats d'une élection
CREATE OR REPLACE FUNCTION get_election_results(p_election_id VARCHAR(255))
RETURNS TABLE (
  candidate_id VARCHAR(255),
  candidate_name VARCHAR(255),
  "position" VARCHAR(255),
  vote_count BIGINT,
  vote_percentage NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c."position",
    COUNT(v.id)::BIGINT as votes,
    ROUND(
      CASE 
        WHEN (SELECT COUNT(*) FROM votes WHERE election_id = p_election_id) > 0 
        THEN (COUNT(v.id)::DECIMAL / (SELECT COUNT(*) FROM votes WHERE election_id = p_election_id)::DECIMAL) * 100 
        ELSE 0 
      END, 
      2
    ) as percentage
  FROM candidates c
  LEFT JOIN votes v ON c.id = v.candidate_id AND v.election_id = p_election_id
  GROUP BY c.id, c.name, c."position"
  ORDER BY votes DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- DONNÉES PAR DÉFAUT (Optionnel)
-- ============================================

-- Créer une élection par défaut
INSERT INTO elections (name, is_active)
VALUES ('Élection RHIT 2025', true)
ON CONFLICT DO NOTHING;


-- ============================================
-- SCRIPT COMPLET POUR RECRÉER TOUTES LES TABLES SUPABASE
-- ============================================
-- Ce script recrée toutes les tables, contraintes, triggers, vues et politiques RLS
-- Exécutez ce script dans l'éditeur SQL de Supabase

-- ============================================
-- SUPPRESSION DES OBJETS EXISTANTS (si nécessaire)
-- ============================================

-- Supprimer les vues en premier (elles dépendent des tables)
DROP VIEW IF EXISTS election_stats CASCADE;
DROP VIEW IF EXISTS vote_results CASCADE;
DROP VIEW IF EXISTS expired_vote_codes CASCADE;

-- Supprimer les triggers
DROP TRIGGER IF EXISTS mark_code_used_on_vote ON votes;
DROP TRIGGER IF EXISTS mark_voter_as_voted_trigger ON votes;
DROP TRIGGER IF EXISTS update_candidates_updated_at ON candidates;
DROP TRIGGER IF EXISTS update_elections_updated_at ON elections;

-- Supprimer les fonctions
DROP FUNCTION IF EXISTS mark_voter_code_as_used() CASCADE;
DROP FUNCTION IF EXISTS mark_voter_as_voted() CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS is_voter_code_valid(VARCHAR, VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS get_election_results(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS validate_and_mark_vote_code(VARCHAR, VARCHAR) CASCADE;

-- Supprimer les tables (dans l'ordre pour respecter les foreign keys)
DROP TABLE IF EXISTS votes CASCADE;
DROP TABLE IF EXISTS voter_codes CASCADE;
DROP TABLE IF EXISTS voters CASCADE;
DROP TABLE IF EXISTS candidates CASCADE;
DROP TABLE IF EXISTS elections CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;

-- ============================================
-- EXTENSIONS
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: elections
-- ============================================
CREATE TABLE elections (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) NOT NULL DEFAULT 'Élection RHIT',
  start_date TIMESTAMPTZ DEFAULT NOW(),
  end_date TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les élections actives
CREATE INDEX idx_elections_is_active ON elections(is_active);
CREATE INDEX idx_elections_end_date ON elections(end_date);

-- ============================================
-- TABLE: candidates
-- ============================================
CREATE TABLE candidates (
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
CREATE INDEX idx_candidates_position ON candidates("position");
CREATE INDEX idx_candidates_created_at ON candidates(created_at);

-- ============================================
-- TABLE: voters
-- ============================================
CREATE TABLE voters (
  id VARCHAR(255) PRIMARY KEY,
  student_id VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  name VARCHAR(255) NOT NULL,
  vote_code VARCHAR(255) UNIQUE NOT NULL,
  has_voted BOOLEAN DEFAULT false,
  whatsapp VARCHAR(255),
  year VARCHAR(255),
  field VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les codes de vote
CREATE INDEX idx_voters_vote_code ON voters(vote_code);
CREATE INDEX idx_voters_student_id ON voters(student_id);
CREATE INDEX idx_voters_email ON voters(email);
CREATE INDEX idx_voters_vote_code_has_voted ON voters(vote_code, has_voted) WHERE has_voted = true;

-- ============================================
-- TABLE: voter_codes
-- ============================================
CREATE TABLE voter_codes (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(255) UNIQUE NOT NULL,
  is_used BOOLEAN DEFAULT false,
  used_at TIMESTAMPTZ,
  election_id VARCHAR(255) REFERENCES elections(id) ON DELETE CASCADE,
  voter_id VARCHAR(255) REFERENCES voters(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les codes de vote
CREATE INDEX idx_voter_codes_code ON voter_codes(code);
CREATE INDEX idx_voter_codes_is_used ON voter_codes(is_used);
CREATE INDEX idx_voter_codes_election_id ON voter_codes(election_id);

-- ============================================
-- TABLE: votes
-- ============================================
CREATE TABLE votes (
  id VARCHAR(255) PRIMARY KEY,
  candidate_id VARCHAR(255) NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  voter_code VARCHAR(255) NOT NULL,
  election_id VARCHAR(255) REFERENCES elections(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  -- Contrainte pour éviter les votes multiples avec le même code
  UNIQUE(voter_code, election_id)
);

-- Index pour améliorer les performances
CREATE INDEX idx_votes_candidate_id ON votes(candidate_id);
CREATE INDEX idx_votes_voter_code ON votes(voter_code);
CREATE INDEX idx_votes_election_id ON votes(election_id);
CREATE INDEX idx_votes_created_at ON votes(created_at);
CREATE INDEX idx_votes_voter_code_election_id ON votes(voter_code, election_id);

-- ============================================
-- TABLE: admin_users
-- ============================================
CREATE TABLE admin_users (
  id VARCHAR(255) PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour l'authentification
CREATE INDEX idx_admin_users_username ON admin_users(username);
CREATE INDEX idx_admin_users_is_active ON admin_users(is_active);

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

CREATE TRIGGER update_candidates_updated_at
  BEFORE UPDATE ON candidates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

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
  WHERE code = NEW.voter_code AND (election_id = NEW.election_id OR election_id IS NULL);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER mark_code_used_on_vote
  AFTER INSERT ON votes
  FOR EACH ROW
  EXECUTE FUNCTION mark_voter_code_as_used();

-- ============================================
-- TRIGGER: Marquer le votant comme ayant voté
-- ============================================
CREATE OR REPLACE FUNCTION mark_voter_as_voted()
RETURNS TRIGGER AS $$
BEGIN
  -- Marquer le votant comme ayant voté
  UPDATE voters
  SET has_voted = true
  WHERE vote_code = NEW.voter_code;
  
  -- Marquer le code dans voter_codes comme utilisé
  UPDATE voter_codes
  SET is_used = true, used_at = NOW()
  WHERE code = NEW.voter_code 
  AND (election_id = NEW.election_id OR election_id IS NULL);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER mark_voter_as_voted_trigger
  AFTER INSERT ON votes
  FOR EACH ROW
  EXECUTE FUNCTION mark_voter_as_voted();

-- ============================================
-- VIEWS: Vues utiles pour les statistiques
-- ============================================

-- Vue pour les résultats des votes par candidat
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

-- Vue pour voir les codes expirés (utilisés)
CREATE OR REPLACE VIEW expired_vote_codes AS
SELECT 
  vc.code,
  vc.is_used,
  vc.used_at,
  v.name as voter_name,
  v.student_id,
  v.has_voted,
  e.name as election_name
FROM voter_codes vc
LEFT JOIN voters v ON v.vote_code = vc.code
LEFT JOIN elections e ON e.id = vc.election_id
WHERE vc.is_used = true
ORDER BY vc.used_at DESC;

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
  SELECT EXISTS(SELECT 1 FROM voter_codes WHERE code = p_code AND (election_id = p_election_id OR election_id IS NULL))
  INTO v_code_exists;
  
  IF NOT v_code_exists THEN
    RETURN false;
  END IF;
  
  SELECT is_used INTO v_code_used
  FROM voter_codes
  WHERE code = p_code AND (election_id = p_election_id OR election_id IS NULL);
  
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

-- Fonction pour valider et marquer un code de vote
CREATE OR REPLACE FUNCTION validate_and_mark_vote_code(
  p_voter_code VARCHAR(255),
  p_election_id VARCHAR(255)
)
RETURNS BOOLEAN AS $$
DECLARE
  v_voter_exists BOOLEAN;
  v_has_voted BOOLEAN;
  v_code_exists BOOLEAN;
  v_code_used BOOLEAN;
BEGIN
  -- Vérifier que le votant existe
  SELECT EXISTS(
    SELECT 1 FROM voters WHERE vote_code = p_voter_code
  ) INTO v_voter_exists;
  
  IF NOT v_voter_exists THEN
    RAISE EXCEPTION 'Code de vote invalide';
  END IF;
  
  -- Vérifier si le votant a déjà voté
  SELECT has_voted INTO v_has_voted
  FROM voters
  WHERE vote_code = p_voter_code;
  
  IF v_has_voted THEN
    RAISE EXCEPTION 'Ce code a déjà été utilisé pour voter';
  END IF;
  
  -- Vérifier si un vote existe déjà avec ce code pour cette élection
  SELECT EXISTS(
    SELECT 1 FROM votes 
    WHERE voter_code = p_voter_code 
    AND (election_id = p_election_id OR (election_id IS NULL AND p_election_id IS NULL))
  ) INTO v_code_exists;
  
  IF v_code_exists THEN
    RAISE EXCEPTION 'Un vote existe déjà avec ce code pour cette élection';
  END IF;
  
  -- Vérifier dans voter_codes si le code est utilisé
  SELECT is_used INTO v_code_used
  FROM voter_codes
  WHERE code = p_voter_code 
  AND (election_id = p_election_id OR election_id IS NULL);
  
  IF v_code_used THEN
    RAISE EXCEPTION 'Ce code a déjà été utilisé';
  END IF;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Activer RLS sur toutes les tables
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE elections ENABLE ROW LEVEL SECURITY;
ALTER TABLE voter_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE voters ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Politiques pour candidates (lecture publique, écriture admin)
DROP POLICY IF EXISTS "Candidates are viewable by everyone" ON candidates;
CREATE POLICY "Candidates are viewable by everyone"
  ON candidates FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Candidates can be inserted by authenticated users" ON candidates;
CREATE POLICY "Candidates can be inserted by authenticated users"
  ON candidates FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Candidates can be updated by authenticated users" ON candidates;
CREATE POLICY "Candidates can be updated by authenticated users"
  ON candidates FOR UPDATE
  USING (true);

DROP POLICY IF EXISTS "Candidates can be deleted by authenticated users" ON candidates;
CREATE POLICY "Candidates can be deleted by authenticated users"
  ON candidates FOR DELETE
  USING (true);

-- Politiques pour elections
DROP POLICY IF EXISTS "Elections are viewable by everyone" ON elections;
CREATE POLICY "Elections are viewable by everyone"
  ON elections FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Elections can be managed by authenticated users" ON elections;
CREATE POLICY "Elections can be managed by authenticated users"
  ON elections FOR ALL
  USING (true);

-- Politiques pour voters
DROP POLICY IF EXISTS "Voters are viewable by authenticated users" ON voters;
CREATE POLICY "Voters are viewable by authenticated users"
  ON voters FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Voters can be inserted by authenticated users" ON voters;
CREATE POLICY "Voters can be inserted by authenticated users"
  ON voters FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Voters can be updated by authenticated users" ON voters;
CREATE POLICY "Voters can be updated by authenticated users"
  ON voters FOR UPDATE
  USING (true);

DROP POLICY IF EXISTS "Voters can be deleted by authenticated users" ON voters;
CREATE POLICY "Voters can be deleted by authenticated users"
  ON voters FOR DELETE
  USING (true);

-- Politiques pour voter_codes (lecture limitée)
DROP POLICY IF EXISTS "Voter codes are viewable by authenticated users" ON voter_codes;
CREATE POLICY "Voter codes are viewable by authenticated users"
  ON voter_codes FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Voter codes can be inserted by authenticated users" ON voter_codes;
CREATE POLICY "Voter codes can be inserted by authenticated users"
  ON voter_codes FOR INSERT
  WITH CHECK (true);

-- Politiques pour votes (lecture publique pour résultats, écriture limitée)
DROP POLICY IF EXISTS "Votes are viewable by everyone" ON votes;
CREATE POLICY "Votes are viewable by everyone"
  ON votes FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Votes can be inserted by anyone" ON votes;
CREATE POLICY "Votes can be inserted by anyone"
  ON votes FOR INSERT
  WITH CHECK (true);

-- Politiques pour admin_users
DROP POLICY IF EXISTS "Admin users are viewable by authenticated users" ON admin_users;
CREATE POLICY "Admin users are viewable by authenticated users"
  ON admin_users FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Admin users can be managed by authenticated users" ON admin_users;
CREATE POLICY "Admin users can be managed by authenticated users"
  ON admin_users FOR ALL
  USING (true);

-- ============================================
-- DONNÉES PAR DÉFAUT
-- ============================================

-- Créer une élection par défaut
INSERT INTO elections (id, name, is_active)
VALUES ('election-2025', 'Élection RHIT 2025', true)
ON CONFLICT (id) DO NOTHING;

-- Message de confirmation
DO $$
BEGIN
  RAISE NOTICE '✅ Toutes les tables ont été recréées avec succès!';
  RAISE NOTICE '✅ Tous les triggers, vues et fonctions ont été créés!';
  RAISE NOTICE '✅ Les politiques RLS ont été configurées!';
  RAISE NOTICE '✅ Une élection par défaut a été créée!';
END $$;



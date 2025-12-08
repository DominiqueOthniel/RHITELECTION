-- ============================================
-- MIGRATION : Changer les types UUID en VARCHAR(255)
-- ============================================
-- Ce script migre toutes les colonnes ID de UUID vers VARCHAR(255)
-- pour correspondre aux UUIDs générés côté client

-- Étape 1 : Supprimer les vues qui dépendent des colonnes ID
DROP VIEW IF EXISTS vote_results CASCADE;
DROP VIEW IF EXISTS election_stats CASCADE;

-- Étape 2 : Supprimer les triggers existants
DROP TRIGGER IF EXISTS update_candidates_updated_at ON candidates;
DROP TRIGGER IF EXISTS update_elections_updated_at ON elections;
DROP TRIGGER IF EXISTS mark_code_used_on_vote ON votes;

-- Étape 3 : Supprimer les fonctions (elles seront recréées)
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS mark_voter_code_as_used() CASCADE;
DROP FUNCTION IF EXISTS is_voter_code_valid(VARCHAR, UUID) CASCADE;
DROP FUNCTION IF EXISTS get_election_results(UUID) CASCADE;

-- Étape 4 : Modifier les types de colonnes
-- Note: On doit d'abord supprimer les contraintes de clés étrangères
ALTER TABLE votes DROP CONSTRAINT IF EXISTS votes_candidate_id_fkey;
ALTER TABLE votes DROP CONSTRAINT IF EXISTS votes_election_id_fkey;
ALTER TABLE voter_codes DROP CONSTRAINT IF EXISTS voter_codes_election_id_fkey;
ALTER TABLE voter_codes DROP CONSTRAINT IF EXISTS voter_codes_voter_id_fkey;

-- Modifier les types (dans l'ordre : d'abord les tables référencées, puis les tables qui référencent)
ALTER TABLE candidates ALTER COLUMN id TYPE VARCHAR(255);
ALTER TABLE elections ALTER COLUMN id TYPE VARCHAR(255);
ALTER TABLE voters ALTER COLUMN id TYPE VARCHAR(255);
ALTER TABLE votes ALTER COLUMN id TYPE VARCHAR(255);
ALTER TABLE votes ALTER COLUMN candidate_id TYPE VARCHAR(255);
ALTER TABLE votes ALTER COLUMN election_id TYPE VARCHAR(255);
ALTER TABLE voter_codes ALTER COLUMN id TYPE VARCHAR(255);
ALTER TABLE voter_codes ALTER COLUMN election_id TYPE VARCHAR(255);
ALTER TABLE voter_codes ALTER COLUMN voter_id TYPE VARCHAR(255);

-- Recréer les contraintes de clés étrangères
ALTER TABLE votes 
  ADD CONSTRAINT votes_candidate_id_fkey 
  FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE;

ALTER TABLE votes 
  ADD CONSTRAINT votes_election_id_fkey 
  FOREIGN KEY (election_id) REFERENCES elections(id) ON DELETE CASCADE;

ALTER TABLE voter_codes 
  ADD CONSTRAINT voter_codes_election_id_fkey 
  FOREIGN KEY (election_id) REFERENCES elections(id) ON DELETE CASCADE;

ALTER TABLE voter_codes 
  ADD CONSTRAINT voter_codes_voter_id_fkey 
  FOREIGN KEY (voter_id) REFERENCES voters(id) ON DELETE CASCADE;

-- Étape 5 : Recréer les fonctions
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mark_voter_code_as_used()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE voter_codes
  SET is_used = true, used_at = NOW()
  WHERE code = NEW.voter_code AND election_id = NEW.election_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

-- Étape 6 : Recréer les triggers
CREATE TRIGGER update_candidates_updated_at
  BEFORE UPDATE ON candidates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_elections_updated_at
  BEFORE UPDATE ON elections
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER mark_code_used_on_vote
  AFTER INSERT ON votes
  FOR EACH ROW
  EXECUTE FUNCTION mark_voter_code_as_used();

-- Étape 7 : Recréer les vues
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

-- Vérification
SELECT 'Migration terminée avec succès!' as status;


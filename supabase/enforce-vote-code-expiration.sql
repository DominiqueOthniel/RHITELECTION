-- ============================================
-- SCRIPT POUR RENFORCER L'EXPIRATION DES CODES DE VOTE
-- ============================================
-- Ce script s'assure qu'un code de vote ne peut être utilisé qu'une seule fois
-- et expire automatiquement après utilisation

-- 1. Vérifier que la contrainte UNIQUE existe sur (voter_code, election_id)
-- Si elle n'existe pas, l'ajouter
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM pg_constraint 
    WHERE conname = 'votes_voter_code_election_id_key'
  ) THEN
    ALTER TABLE votes 
    ADD CONSTRAINT votes_voter_code_election_id_key 
    UNIQUE (voter_code, election_id);
  END IF;
END $$;

-- 2. Créer une fonction pour vérifier et marquer un code comme utilisé
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
    AND election_id = p_election_id
  ) INTO v_code_exists;
  
  IF v_code_exists THEN
    RAISE EXCEPTION 'Un vote existe déjà avec ce code pour cette élection';
  END IF;
  
  -- Vérifier dans voter_codes si le code est utilisé
  SELECT is_used INTO v_code_used
  FROM voter_codes
  WHERE code = p_voter_code 
  AND election_id = p_election_id;
  
  IF v_code_used THEN
    RAISE EXCEPTION 'Ce code a déjà été utilisé';
  END IF;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- 3. Créer un trigger pour marquer automatiquement has_voted après insertion d'un vote
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

-- Supprimer le trigger existant s'il existe
DROP TRIGGER IF EXISTS mark_voter_as_voted_trigger ON votes;

-- Créer le trigger
CREATE TRIGGER mark_voter_as_voted_trigger
  AFTER INSERT ON votes
  FOR EACH ROW
  EXECUTE FUNCTION mark_voter_as_voted();

-- 4. Créer une vue pour voir les codes expirés (utilisés)
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

-- 5. Créer un index pour améliorer les performances de vérification
CREATE INDEX IF NOT EXISTS idx_votes_voter_code_election_id 
ON votes(voter_code, election_id);

CREATE INDEX IF NOT EXISTS idx_voters_vote_code_has_voted 
ON voters(vote_code, has_voted) 
WHERE has_voted = true;

-- Message de confirmation
DO $$
BEGIN
  RAISE NOTICE 'Script d''expiration des codes de vote exécuté avec succès';
  RAISE NOTICE 'Les codes de vote expirent maintenant automatiquement après utilisation';
END $$;


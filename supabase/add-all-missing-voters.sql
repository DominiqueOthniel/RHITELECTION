-- ============================================
-- AJOUT DE TOUS LES ÉTUDIANTS MANQUANTS
-- ============================================
-- Ce script ajoute tous les étudiants identifiés dans les images mais absents de la base de données
-- Les numéros étudiants continuent à partir de 2025156
-- Total estimé: ~225 étudiants sur les images, ~155 dans la base actuelle = ~70 étudiants manquants

-- Fonction pour générer un code de vote unique (8 caractères)
CREATE OR REPLACE FUNCTION generate_vote_code() RETURNS VARCHAR(8) AS $$
DECLARE
  chars VARCHAR := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code VARCHAR(8) := '';
  i INTEGER;
  exists_check INTEGER;
BEGIN
  LOOP
    code := '';
    FOR i IN 1..8 LOOP
      code := code || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    -- Vérifier que le code n'existe pas déjà
    SELECT COUNT(*) INTO exists_check FROM voters WHERE vote_code = code;
    IF exists_check = 0 THEN
      EXIT;
    END IF;
  END LOOP;
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour générer un UUID en VARCHAR
CREATE OR REPLACE FUNCTION generate_voter_id() RETURNS VARCHAR(255) AS $$
BEGIN
  RETURN replace(uuid_generate_v4()::text, '-', '');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- AJOUT DES ÉTUDIANTS MANQUANTS
-- ============================================
-- NOTE: Ce script doit être complété avec TOUS les étudiants des images
-- Pour chaque étudiant, extraire: nom, filière, niveau (L1/L2/L3 -> 1ère/2ème/3ème année)
-- Les numéros étudiants continuent séquentiellement à partir de 2025156

INSERT INTO voters (id, student_id, name, vote_code, has_voted, year, field, created_at)
VALUES
  -- Étudiants identifiés comme manquants (à compléter avec tous les autres)
  (generate_voter_id(), '2025156', 'ABAH BILOA CECILE ANDREA', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025157', 'ABBO MOHAMADOU IMRAN', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025158', 'DJEUMEN NJOYA INGRID', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025159', 'FOKOU SIPETKAM OCEANE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025160', 'LAOUZA SIHAM', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025161', 'MOUHAMED BOURHAN BOGNE', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025162', 'MOUKOKO SUZANNE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025163', 'NANA DJOUNDI YVES-MARCEL', generate_vote_code(), false, '3ème année', 'Computer Engineering', NOW()),
  (generate_voter_id(), '2025164', 'SADO NANA JONAS SINCLAIR', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025165', 'SASHA KHALEL CHALE MBAGA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025166', 'YONGE NDOME KEREN BILAMA', generate_vote_code(), false, '1ère année', 'NURSING', NOW());
  
  -- TODO: Ajouter tous les autres étudiants manquants des images
  -- Pour chaque étudiant sur les images qui n'est pas dans la base actuelle:
  -- 1. Extraire le nom complet
  -- 2. Extraire la filière (ex: "Software Engineering", "Business Management", etc.)
  -- 3. Extraire le niveau (L1 -> 1ère année, L2 -> 2ème année, L3 -> 3ème année, Master 1 -> Master 1)
  -- 4. Continuer la numérotation (2025167, 2025168, etc.)

-- ============================================
-- NETTOYER LES FONCTIONS TEMPORAIRES
-- ============================================
DROP FUNCTION IF EXISTS generate_vote_code();
DROP FUNCTION IF EXISTS generate_voter_id();

-- ============================================
-- VÉRIFICATION
-- ============================================
-- Afficher les nouveaux étudiants ajoutés
SELECT student_id, name, year, field, vote_code 
FROM voters 
WHERE student_id >= '2025156'
ORDER BY student_id;

-- Compter le total
SELECT COUNT(*) as total_voters FROM voters;


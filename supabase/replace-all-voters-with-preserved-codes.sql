-- ============================================
-- REMPLACEMENT COMPLET DES VOTANTS AVEC PRÉSERVATION DES CODES DE VOTE
-- ============================================
-- Ce script supprime tous les votants existants et ajoute les 225 étudiants du PDF
-- Les codes de vote existants sont préservés pour les étudiants qui étaient déjà dans la base
-- De nouveaux codes sont générés pour les nouveaux étudiants

-- ============================================
-- ÉTAPE 1: SAUVEGARDER LES CODES DE VOTE EXISTANTS
-- ============================================
-- Créer une table temporaire pour sauvegarder les codes de vote existants
CREATE TEMP TABLE IF NOT EXISTS existing_vote_codes AS
SELECT student_id, name, vote_code
FROM voters
WHERE vote_code IS NOT NULL AND vote_code != '';

-- ============================================
-- ÉTAPE 2: SUPPRIMER TOUS LES VOTANTS ET VOTES
-- ============================================
-- Supprimer d'abord les votes associés (pour éviter les erreurs de clé étrangère)
DELETE FROM votes;

-- Supprimer tous les codes de vote utilisés
DELETE FROM voter_codes;

-- Supprimer tous les votants
DELETE FROM voters;

-- ============================================
-- ÉTAPE 3: FONCTIONS POUR GÉNÉRER LES CODES
-- ============================================
-- Fonction pour obtenir un code de vote existant ou en générer un nouveau
CREATE OR REPLACE FUNCTION get_or_generate_vote_code(p_student_id VARCHAR, p_name VARCHAR) RETURNS VARCHAR(8) AS $$
DECLARE
  existing_code VARCHAR(8);
  chars VARCHAR := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code VARCHAR(8) := '';
  i INTEGER;
  exists_check INTEGER;
BEGIN
  -- Chercher un code existant pour cet étudiant (par student_id ou nom)
  SELECT vote_code INTO existing_code
  FROM existing_vote_codes
  WHERE student_id = p_student_id
     OR (name = p_name AND student_id IS NOT NULL)
  LIMIT 1;
  
  -- Si un code existe, le retourner
  IF existing_code IS NOT NULL THEN
    RETURN existing_code;
  END IF;
  
  -- Sinon, générer un nouveau code
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
-- ÉTAPE 4: AJOUTER TOUS LES 225 ÉTUDIANTS DU PDF
-- ============================================
-- Les étudiants sont organisés par filière et niveau selon le PDF
-- Conversion des niveaux: L1 -> 1ère année, L2 -> 2ème année, L3 -> 3ème année
-- Master 1 -> Master 1, Prepa L1 -> Prepa (1ère année), Prepa L2 -> Prepa (2ème année)
-- Licence 3 -> 3ème année, Bachelor of Engineering -> Bachelor

INSERT INTO voters (id, student_id, name, vote_code, has_voted, year, field, created_at)
VALUES
  -- COMPUTER AND ELECTRONICS ENGINEERING L1 (37 étudiants du PDF)
  (generate_voter_id(), '2025001', 'AKAMA HARRY NEBA', get_or_generate_vote_code('2025001', 'AKAMA HARRY NEBA'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025002', 'ALIATH ORLAMIDE', get_or_generate_vote_code('2025002', 'ALIATH ORLAMIDE'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025003', 'AYAKEY AMARANTA MEREDITH NDIM', get_or_generate_vote_code('2025003', 'AYAKEY AMARANTA MEREDITH'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025004', 'BEBEY EBOLO PIERRE HELTON', get_or_generate_vote_code('2025004', 'BEBEY EBOLO PIERRE HELTON'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025005', 'BUZUAH STELMON-LYDIA NGENDAP', get_or_generate_vote_code('2025005', 'BUZUAH STELMON-LYDIA NGENDAP'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025006', 'CHEUDJOU MANSSA JAMES CABREL', get_or_generate_vote_code('2025006', 'CHEUDIOU MANSSA JAMES CABREL'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025007', 'CIELENOU LOMA HELENE GLORIA', get_or_generate_vote_code('2025007', 'CIELENOU LOMA HELENE GLORIA'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025008', 'DJEUMO JUNIOR ETHAN OJANI', get_or_generate_vote_code('2025008', 'DJEUMO JUNIOR ETHAN OJANI'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025009', 'DOUALLA DIBIE YANN WILFRIED', get_or_generate_vote_code('2025009', 'DOUALLA DIBIE YANN WILFRIED'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025010', 'ENTCHEU STEVE GEOVANNI', get_or_generate_vote_code('2025010', 'ENTCHEU STEVE GEOVANNI'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025011', 'FOKOUA KENNE FRANCK WILFRIED', get_or_generate_vote_code('2025011', 'FOKOUA KENNE FRANCK'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025012', 'HAPPI TCHOKONTE PAULE MARTIALE', get_or_generate_vote_code('2025012', 'HAPPI TCHOKONTE PAULE M.'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025013', 'HENDEL EMMANUEL LEVY', get_or_generate_vote_code('2025013', 'HENDEL EMMANUEL LEVY'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025014', 'IBRAHIM TOUKOUR', get_or_generate_vote_code('2025014', 'IBRAHIM TOUKOUR'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025015', 'KEMDIB TCHAKOUNTIO EMMANUEL JUNIOR', get_or_generate_vote_code('2025015', 'KEMDIB TCHAKOUNTIO EMMANUEL'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025016', 'KOUNG A BITANG DAVID IGOR', get_or_generate_vote_code('2025016', 'KOUNG A BITANG DAVID IGOR'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025017', 'KPOUMIE LINA MARIAM', get_or_generate_vote_code('2025017', 'KPOUMIE LINA MARIAM'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025018', 'MAPTUE FOTSO LAURE MORGAN', get_or_generate_vote_code('2025018', 'MAPTUE FOTSO LAURE MORGAN'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025019', 'MASSO MANDENG CINDY NOELLE', get_or_generate_vote_code('2025019', 'MASSO MANDENG CINDY NOELLE'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025020', 'MBAKOP FAVOUR BRANDY', get_or_generate_vote_code('2025020', 'MBAKOP FAVOUR BRANDY'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025021', 'MPANJO LOBE MARC STEPHANE', get_or_generate_vote_code('2025021', 'MPANJO LOBE MARC STEPHANE'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025022', 'MUMA RYAN WENTEH', get_or_generate_vote_code('2025022', 'MUMA RYAN WENTEH'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025023', 'NANA GILBERT JUNIOR PETTANG', get_or_generate_vote_code('2025023', 'NANA GILBERT JUNIOR PETTANG'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025024', 'NDEFFO FOTIE DURICK ORLIAN', get_or_generate_vote_code('2025024', 'NDEFFO FOTIE DURICK ORLIAN'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025025', 'NJOYA AHMED RYAN', get_or_generate_vote_code('2025025', 'NJOYA AHMED RYAN'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025026', 'NLOMBO ELEPI MARTINE FABRICE', get_or_generate_vote_code('2025026', 'NLOMBO ELEPI MARTINE FABRICE'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025027', 'OBEN KELLY SMITH AGBOR', get_or_generate_vote_code('2025027', 'OBEN KELLY SMITH AGBOR'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025028', 'OMBIONO MYSTERE EMILE', get_or_generate_vote_code('2025028', 'OMBIONO MYSTERE EMILE'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025029', 'PAMSY LYDIA', get_or_generate_vote_code('2025029', 'PAMSY LYDIA'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025030', 'PAUL SIEVERT TANG', get_or_generate_vote_code('2025030', 'PAUL SIEVERT TANG'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025031', 'SIHNO HOVETO MAGLOIRE ESPOIR KEVIN', get_or_generate_vote_code('2025031', 'SIHNO HOVETO MAGLOIRE E.'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025032', 'SIMB NAG ARTHUR', get_or_generate_vote_code('2025032', 'SIMB NAG ARTHUR'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025033', 'SIMO GASTON DARYL', get_or_generate_vote_code('2025033', 'SIMO GASTON DARYL'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025034', 'TAKOU KENGNE MERVEILLE ASHLEY', get_or_generate_vote_code('2025034', 'TAKOU KENGNE MERVEILLE A.'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025035', 'TATCHOU YMTCHI NOEMIE PHARELLE', get_or_generate_vote_code('2025035', 'TATCHOU YMTCHI NOEMIE P.'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025036', 'TCHEUMEN KOUNTCHOU KATHEL ERWIN', get_or_generate_vote_code('2025036', 'TCHEUMEN KOUNTCHOU KATHEL'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025037', 'VICTORINE NKOME NDJEM LAFLEURE', get_or_generate_vote_code('2025037', 'VICTORINE NKOME NDJEM L.'), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- CIVIL ENGINEERING L1 (3 étudiants)
  (generate_voter_id(), '2025038', 'DOUALA BWEGNE OLIVIA SHELSY', get_or_generate_vote_code('2025038', 'DOUALA BWEGNE OLIVIA SHELSY'), false, '1ère année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025039', 'LATIFAH DALIL', get_or_generate_vote_code('2025039', 'LATIFAH DALIL'), false, '1ère année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025040', 'NGOUAH GNEMABE HOUOMTELE AXEL BRYAN', get_or_generate_vote_code('2025040', 'NGOUAH GNEMABE HOUOMTELE'), false, '1ère année', 'Civil Engineering', NOW()),
  
  -- ACCOUNTANCY L1 (12 étudiants)
  (generate_voter_id(), '2025041', 'AISHATOU SALI YASMINE YOUCHAOU', get_or_generate_vote_code('2025041', 'AISHATOU SALI YASMINE Y.'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025042', 'ALEXANDER ONUHA FRANKLIN NICK', get_or_generate_vote_code('2025042', 'ALEXANDER ONUHA FRANKLIN N.'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025043', 'FEUTSEU NEGUEM ALBIN BALDES', get_or_generate_vote_code('2025043', 'FEUTSEU NEGUEM ALBIN BALDES'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025044', 'IBRAHIM OUMAROU DAH', get_or_generate_vote_code('2025044', 'IBRAHIM OUMAROU DAH'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025045', 'IMRANE .', get_or_generate_vote_code('2025045', 'IMRANE IMRANE'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025046', 'L''KENFACK JOHN KENDRICK', get_or_generate_vote_code('2025046', 'L''KENFACK JOHN KENDRICK'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025047', 'MONKAM HAROLD BRYAN', get_or_generate_vote_code('2025047', 'MONKAM HAROLD BRYAN'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025048', 'NGUELA NDEMBI SAMIRA THESA SHANICE', get_or_generate_vote_code('2025048', 'NGUELA NDEMBI SAMIRA THESA S.'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025049', 'NOLACK LOICE INGRID SAAH', get_or_generate_vote_code('2025049', 'NOLACK LOICE INGRID SAAH'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025050', 'IMELE EVA KAREN', get_or_generate_vote_code('2025050', 'IMELE EVA KAREN'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025051', 'NOUBISSI TCHOUAMO PIERRETTE RICHINELLE', get_or_generate_vote_code('2025051', 'NOUBISSI TCHOUAMO PIERRETTE RICHINELLE'), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025052', 'SADO NANA JONAS SINCLAIR', get_or_generate_vote_code('2025052', 'SADO NANA JONAS SINCLAIR'), false, '1ère année', 'Accountancy', NOW()),
  
  -- BUSINESS/PROJECT MANAGEMENT L1 (36 étudiants)
  (generate_voter_id(), '2025053', 'AISSATOU NOURIATOU HAMADOU', get_or_generate_vote_code('2025053', 'AISSATOU NOURIATOU HAMADOU'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025054', 'ALVINE GRACE MESSINA DANIELLE', get_or_generate_vote_code('2025054', 'ALVINE GRACE MESSINA DANIELLE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025055', 'ATSAMO IMANIE', get_or_generate_vote_code('2025055', 'ATSAMO IMANIE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025056', 'BEBEY GILLES HARRY', get_or_generate_vote_code('2025056', 'BEBEY GILLES HARRY'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025057', 'EDDY ANTOINE DAVID TOUTOU DIDI BISSA', get_or_generate_vote_code('2025057', 'EDDY ANTOINE DAVID TOUTOU D.'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025058', 'FALMATA MAMAT', get_or_generate_vote_code('2025058', 'FALMATA MAMAT'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025059', 'FATIA ALAGBALA OMOLARA', get_or_generate_vote_code('2025059', 'FATIA ALAGBALA OMOLARA'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025060', 'FONGANG RODNEY SHARLEY', get_or_generate_vote_code('2025060', 'FONGANG RODNEY SHARLEY'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025061', 'KAMDEM KOUAM DANIEL', get_or_generate_vote_code('2025061', 'KAMDEM KOUAM DANIEL'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025062', 'KAMGNA JASON MARC AUREL', get_or_generate_vote_code('2025062', 'KAMGNA JASON MARC AUREL'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025063', 'KEMAYOU NGATCHOU ASHLEY PRISKA', get_or_generate_vote_code('2025063', 'KEMAYOU NGATCHOU ASHLEY P.'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025064', 'KENDRA MBITA NANA FOUMO KEPONDJOU', get_or_generate_vote_code('2025064', 'KENDRA MBITA NANA FOUMO K.'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025065', 'KENGNE KAMOGNE GLORY HERMAN', get_or_generate_vote_code('2025065', 'KENGNE KAMOGNE GLORY H.'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025066', 'KHADIDJA ADOUM MAHAMAT', get_or_generate_vote_code('2025066', 'KHADIDJA ADOUM MAHAMAT'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025067', 'LEILA KAWAS ISSA OUMAROU', get_or_generate_vote_code('2025067', 'LEILA KAWAS ISSA OUMAROU'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025068', 'L''KENFACK MIKE TOMMY', get_or_generate_vote_code('2025068', 'L''KENFACK MIKE TOMMY'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025069', 'MARCELINE ANIETIE ANGE', get_or_generate_vote_code('2025069', 'MARCELINE ANIETIE ANGE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025070', 'MVONDO NSANGOU BEN HERVE', get_or_generate_vote_code('2025070', 'MVONDO NSANGOU BEN HERVE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025071', 'NDZINGA NGOUMOU ARIEL BRANDON', get_or_generate_vote_code('2025071', 'NDZINGA NGOUMOU ARIEL B.'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025072', 'NGABA TCHOUAMEN ANDRE DELPHINE', get_or_generate_vote_code('2025072', 'NGABA TCHOUAMEN ANDRE D.'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025073', 'NGANDJO NGOMEGE JESSICA', get_or_generate_vote_code('2025073', 'NGANDJO NGOMEGE JESSICA'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025074', 'NGANDJUI YOSSA KARL DAVE', get_or_generate_vote_code('2025074', 'NGANDJUI YOSSA KARL DAVE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025075', 'NKEMELO WAMBA DARRYL JUNIOR', get_or_generate_vote_code('2025075', 'NKEMELO WAMBA DARRYL JUNIOR'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025076', 'NKWINKE NKOUENKEU LYVIE', get_or_generate_vote_code('2025076', 'NKWINKE NKOUENKEU LYVIE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025077', 'NOUBAYOUO NGANGOM BRUNEL', get_or_generate_vote_code('2025077', 'NOUBAYOUO NGANGOM BRUNEL'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025078', 'OLOU''OU MVONDO SAME KOLLE GIOVANY', get_or_generate_vote_code('2025078', 'OLOU''OU MVONDO SAME KOLLE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025079', 'OYONO MINLO JOSEPH', get_or_generate_vote_code('2025079', 'OYONO MINLO JOSEPH'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025080', 'PETSOKO MAEL WILFRIED', get_or_generate_vote_code('2025080', 'PETSOKO MAEL WILFRIED'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025081', 'PHARAH MVOGO YTEMBE SERENA PETRA', get_or_generate_vote_code('2025081', 'PHARAH MVOGO YTEMBE SERENA'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025082', 'SOSSO KINGUE ALAIN STEVE', get_or_generate_vote_code('2025082', 'SOSSO KINGUE ALAIN STEVE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025083', 'TASHA KONGNSO DAVID KURTIS', get_or_generate_vote_code('2025083', 'TASHA KONGNSO DAVID KURTIS'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025084', 'TCHATO NKENYOU YANN', get_or_generate_vote_code('2025084', 'TCHATO NKENYOU YANN'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025085', 'TCHUINKAM KOM ERICA CHARONE', get_or_generate_vote_code('2025085', 'TCHUINKAM KOM ERICA CHARONE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025086', 'TIOMA XAVIER JOHN', get_or_generate_vote_code('2025086', 'TIOMA XAVIER JOHN'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025087', 'TOWO DE SAMAGA ANGE CHLOE', get_or_generate_vote_code('2025087', 'TOWO DE SAMAGA ANGE CHLOE'), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025088', 'WATAT WATAT DYLAN JORDAN', get_or_generate_vote_code('2025088', 'WATAT WA...'), false, '1ère année', 'Business/Project Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1 (étudiants supplémentaires du PDF)
  (generate_voter_id(), '2025089', 'ALEXANDRA ZEH ANNETTE ROGER', get_or_generate_vote_code('2025089', 'ALEXANDRA ZEH ANNETTE ROGER'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025090', 'ABBO MOHAMADOU IMRAN', get_or_generate_vote_code('2025090', 'ABBO MOHAMADOU IMRAN'), false, '3ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025091', 'KETCHA MASSA ALEX STEPHIE', get_or_generate_vote_code('2025091', 'KETCHA MASSA ALEX STEPHIE'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025092', 'LAOUZA SIHAM', get_or_generate_vote_code('2025092', 'LAOUZA SIHAM'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025093', 'NGONO GBANMI SABINE CYNTHIA', get_or_generate_vote_code('2025093', 'NGONO GBANMI SABINE CYNTHIA'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025094', 'NJI ACHU RAYAN KLIEN', get_or_generate_vote_code('2025094', 'NJI ACHU RAYAN KLIEN'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025095', 'NJITOYAP NJIKAM ARCHANGE DE PHILIPPE', get_or_generate_vote_code('2025095', 'NJITOYAP NJIKAM ARCHANGE DE PHILIPPE'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025096', 'NJOCK HUGUES ALEXANDRE', get_or_generate_vote_code('2025096', 'NJOCK HUGUES ALEXANDRE'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025097', 'OKON II URSULE SERENA', get_or_generate_vote_code('2025097', 'OKON II URSULE SERENA'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025098', 'SADO NDOLO DENZEL', get_or_generate_vote_code('2025098', 'SADO NDOLO DENZEL'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025099', 'SOMGUI KARL TERRANCE', get_or_generate_vote_code('2025099', 'SOMGUI KARL TERRANCE'), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025100', 'WETIE KELMAN SERIVANT', get_or_generate_vote_code('2025100', 'WETIE KELMAN SERIVANT'), false, '1ère année', 'Business Management', NOW()),
  
  -- NURSING L1 (40 étudiants du PDF)
  (generate_voter_id(), '2025101', 'EYENGA SASSOM CHRISTY MAELICE', get_or_generate_vote_code('2025101', 'EYENGA SASSOM CHRISTY M.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025102', 'EYOMBWE MOUNA NGANGUE JEMEDI GRACE', get_or_generate_vote_code('2025102', 'EYOMBWE MOUNA NGANGUE J.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025103', 'FEUPA NYAMSI JACK IVAN', get_or_generate_vote_code('2025103', 'FEUPA NYAMSI JACK IVAN'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025104', 'FOUDA NGOMO MAXIME ROGER', get_or_generate_vote_code('2025104', 'FOUDA NGOMO MAXIME ROGER'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025105', 'GLORY TINA EVELYNE CASSANDRA', get_or_generate_vote_code('2025105', 'GLORY TINA EVELYNE CASSANDRA'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025106', 'GONGANG TCHANA GLORY GILLES', get_or_generate_vote_code('2025106', 'GONGANG TCHANA GLORY GILLES'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025107', 'HAPPI ANASTASIE CHLOE', get_or_generate_vote_code('2025107', 'HAPPI ANASTASIE CHLOE'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025108', 'HARRY CHRISTOPHER CLAUDE NEKUIE HAPPI', get_or_generate_vote_code('2025108', 'HARRY CHRISTOPHER CLAUDE N.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025109', 'KAMYUM SOKOUDJOU STEPHANE MAGLOIRE', get_or_generate_vote_code('2025109', 'KAMYUM SOKOUDJOU STEPHANE'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025110', 'KWAPNANG HAPPI CHARLINE PIERRETTE', get_or_generate_vote_code('2025110', 'KWAPNANG HAPPI CHARLINE P.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025111', 'LOBE TAKWA MANDENGUE M.', get_or_generate_vote_code('2025111', 'LOBE TAKWA MANDENGUE M.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025112', 'MAKAMTA ANGE SORAYA', get_or_generate_vote_code('2025112', 'MAKAMTA ANGE SORAYA'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025113', 'MBA COEURTISSE NOEL', get_or_generate_vote_code('2025113', 'MBA COEURTISSE NOEL'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025114', 'MBARGA KIE ALLAN THIBAUT', get_or_generate_vote_code('2025114', 'MBARGA KIE ALLAN THIBAUT'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025115', 'MBATCHOU MEGHUS SHALOM C.', get_or_generate_vote_code('2025115', 'MBATCHOU MEGHUS SHALOM C.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025116', 'MBEI NJE JOHANES CHRIST PATTY', get_or_generate_vote_code('2025116', 'MBEI NJE JOHANES CHRIST PATTY'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025117', 'MBIADA KAREL DAPHNE', get_or_generate_vote_code('2025117', 'MBIADA KAREL DAPHNE'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025118', 'MOUYEMGA CHRIST SHALOM M.', get_or_generate_vote_code('2025118', 'MOUYEMGA CHRIST SHALOM M.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025119', 'MOYOU FOM CHRYS HARREL', get_or_generate_vote_code('2025119', 'MOYOU FOM CHRYS HARREL'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025120', 'NDONGO BWELLE MAUDE E.', get_or_generate_vote_code('2025120', 'NDONGO BWELLE MAUDE E.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025121', 'NIMENI JOVANNY KEVINE', get_or_generate_vote_code('2025121', 'NIMENI JOVANNY KEVINE'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025122', 'NWAL A NNOKO ANGE ALAIN', get_or_generate_vote_code('2025122', 'NWAL A NNOXO ANGE ALAIN'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025123', 'PEFOURA JAMEL RAMZY', get_or_generate_vote_code('2025123', 'PEFOURA JAMEL'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025124', 'PENPEN MBOUEKAM SERGINE LAETICIA', get_or_generate_vote_code('2025124', 'PENPEN MBOUEKAM SERGINE L.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025125', 'PISSEU TAKEDO MARWIN CASSIDY', get_or_generate_vote_code('2025125', 'PISSEU TAKEDO MARWIN CASSIDY'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025126', 'SOPPI MBALLA GEORGES CASSANDRA', get_or_generate_vote_code('2025126', 'SOPPI MBALLA GEORGES C.'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025127', 'TAMNO KUATE BRUNEL MISAEL', get_or_generate_vote_code('2025127', 'TAMNO KUATE BRUNEL MISAEL'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025128', 'TEDJOUONG II CHRISTIAN AURORE', get_or_generate_vote_code('2025128', 'TEDJOUONG II CHRISTIAN AURORE'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025129', 'TONFO KEMDJI JEASON', get_or_generate_vote_code('2025129', 'TONFO KEMDJI JEASON'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025130', 'ASTA DJAM IBRAHIM', get_or_generate_vote_code('2025130', 'ASTA DJAM IBRAHIM'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025131', 'DIANE DAOULA MOKAM', get_or_generate_vote_code('2025131', 'DIANE DAOULA MOKAM'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025132', 'SASHA KHALEL CHALE MBAGA', get_or_generate_vote_code('2025132', 'SASHA KHALEL CHALE MBAGA'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025133', 'TIENTE GRACIELLA TIPHAINE KENZA', get_or_generate_vote_code('2025133', 'TIENTE GRACIELLA TIPHAINE KENZA'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025134', 'YIMEN TCHOUNKE FRANCK STEVE', get_or_generate_vote_code('2025134', 'YIMEN TCHOUNKE FRANCK STEVE'), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025135', 'YONGE NDOME KEREN BILAMA', get_or_generate_vote_code('2025135', 'YONGE NDOME KEREN BILAMA'), false, '1ère année', 'NURSING', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L2 (2 étudiants)
  (generate_voter_id(), '2025136', 'KANJE CHARLES TCHUNDENU JUNIOR', get_or_generate_vote_code('2025136', 'KANJE CHARLES TCHUNDENU J.'), false, '2ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025137', 'NGAMAKOUA NSANDAP ANGE SUNNITA', get_or_generate_vote_code('2025137', 'NGAMAKOUA NSANDAP ANGE S.'), false, '2ème année', 'Computer and Electronics Engineering', NOW()),
  
  -- CIVIL ENGINEERING L2 (3 étudiants)
  (generate_voter_id(), '2025138', 'DJEUMO RUSSEL VEDRYL', get_or_generate_vote_code('2025138', 'DJEUMO RUSSEL VEDRYL'), false, '2ème année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025139', 'INACK NKEGA ISIS DAPHNEE', get_or_generate_vote_code('2025139', 'INACK ISIS DAPHNEE'), false, '2ème année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025140', 'WOUAPIT YONKOU MANJIA PRISQUE BETHANY', get_or_generate_vote_code('2025140', 'WOUAPIT YONKOU MANJIA P.'), false, '2ème année', 'Civil Engineering', NOW()),
  
  -- PREPA L2 (6 étudiants)
  (generate_voter_id(), '2025141', 'DEFFO NGOUNOU STECY INA POTKER', get_or_generate_vote_code('2025141', 'DEFFO NGOUNOU STECY INA P.'), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025142', 'JOYCE KIMBERLEY EYIKE', get_or_generate_vote_code('2025142', 'JOYCE KIMBERLEY EYIKE'), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025143', 'KOUMTOUZOUA KANNENG RYAN HAROLD', get_or_generate_vote_code('2025143', 'KOUMTOUZOUA KANNENG RYAN H.'), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025144', 'MANDJOMBE MOUYENGA G.', get_or_generate_vote_code('2025144', 'MANDJOMBE MOUYENGA G.'), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025145', 'MANFOUO ABO GRACE DAVILLA', get_or_generate_vote_code('2025145', 'MANFOUO ABO GRACE DAVILLA'), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025146', 'INOUA RABIOU TADJIRI', get_or_generate_vote_code('2025146', 'INOUA RABIOU TADJIRI'), false, '2ème année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L2 (12 étudiants)
  (generate_voter_id(), '2025147', 'BEYHIA LEONARD-BRUCE', get_or_generate_vote_code('2025147', 'BEYHIA LEONARD-BRUCE'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025148', 'CLARKE NIYABI ANNE-MARIE', get_or_generate_vote_code('2025148', 'CLARKE NIYABI ANNE-MARIE'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025149', 'FRITZ HONORE ALLISON ELAME NGANGUE', get_or_generate_vote_code('2025149', 'FRITZ HONORE ALLISON ELAME NGANGUE'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025150', 'IGEDI AFSAT ASHAKE DIMODI', get_or_generate_vote_code('2025150', 'IGEDI AFSAT ASHAKE DIMODI'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025151', 'KIDJOCK NWALL DANIEL', get_or_generate_vote_code('2025151', 'KIDJOCK NWALL DANIEL'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025152', 'MAHAMAT SALLET KAYA', get_or_generate_vote_code('2025152', 'MAHAMAT SALLET KAYA'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025153', 'NAMBANG DARELLE', get_or_generate_vote_code('2025153', 'NAMBANG DARELLE'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025154', 'DANDJOUMA HABOUBAKAR SIDDIK', get_or_generate_vote_code('2025154', 'DANDJOUMA HABOUBAKAR SIDDIK'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025155', 'DASSI AMANDE PRINCESSE HELENA', get_or_generate_vote_code('2025155', 'DASSI AMANDE PRINCESSE HELENA'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025156', 'DJEUMEN NJOYA INGRID', get_or_generate_vote_code('2025156', 'DJEUMEN NJOYA INGRID'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025157', 'KONLACK TOUOTSAP FRED ULRICH', get_or_generate_vote_code('2025157', 'KONLACK TOUOTSAP FRED ULRICH'), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025158', 'TIAKO NGAMENI ASHLEY ANYOH', get_or_generate_vote_code('2025158', 'TIAKO NGAMENI ASHLEY ANYOH'), false, '2ème année', 'Business Management', NOW()),
  
  -- NURSING L2 (4 étudiants)
  (generate_voter_id(), '2025159', 'EWODI NGASSE MADELEINE DEO GRACE', get_or_generate_vote_code('2025159', 'EWODI NGASSE MADELEINE DEO'), false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025160', 'JAGNI JIODA GOULA CHRIST', get_or_generate_vote_code('2025160', 'JAGNI JIODA GOULA CHRIST'), false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025161', 'SIEWE DJUMENI ELDA PARKER', get_or_generate_vote_code('2025161', 'SIEWE DJUMENI ELDA PARKER'), false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025162', 'HOBLOG GENEVIEVE LESLIE', get_or_generate_vote_code('2025162', 'HOBLOG GENEVIEVE LESLIE'), false, '2ème année', 'Health Sciences', NOW()),
  
  -- PROJECT MANAGEMENT L3 AND TOP-UP (3 étudiants)
  (generate_voter_id(), '2025163', 'NATHAN KIMBALLY NGWEN', get_or_generate_vote_code('2025163', 'NATHAN KIMBALLY NGWEN'), false, '3ème année', 'Project Management', NOW()),
  (generate_voter_id(), '2025164', 'OUMAR MOHAMED', get_or_generate_vote_code('2025164', 'OUMAR MOHAMED'), false, '3ème année', 'Project Management', NOW()),
  (generate_voter_id(), '2025165', 'LUMMAH NELLY GUDMIA', get_or_generate_vote_code('2025165', 'LUMMAH NELLY GUDMIA'), false, 'Top-Up', 'Project Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L3 (11 étudiants)
  (generate_voter_id(), '2025166', 'CAMBAY YVES', get_or_generate_vote_code('2025166', 'CAMBAY YVES'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025167', 'FOTSO TEGUEO KENNY FRED', get_or_generate_vote_code('2025167', 'FOTSO TEGUEO KENNY FRED'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025168', 'KUOH BEKOMBO-KUOH YVAN', get_or_generate_vote_code('2025168', 'KUOH BEKOMBO-KUOH YVAN'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025169', 'LENGONO ELOUNDOU MARIETTE LARISSA', get_or_generate_vote_code('2025169', 'LENGONO ELOUNDOU MARIETTE L.'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025170', 'LORENZO EBOA', get_or_generate_vote_code('2025170', 'LORENZO EBOA'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025171', 'MATJABI PAULINE ROMAINE', get_or_generate_vote_code('2025171', 'MATJABI PAULINE ROMAINE'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025172', 'NDIOMO EVINI JEAN-BOSCO D.', get_or_generate_vote_code('2025172', 'NDIOMO EVINI JEAN-BOSCO D.'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025173', 'NKWESI TCHUISSEU DITRICH L.', get_or_generate_vote_code('2025173', 'NKWESI TCHUISSEU DITRICH L.'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025174', 'POUGOM TCHATCHOUA DOMINIQUE OTHNIEL', get_or_generate_vote_code('2025174', 'POUGOM TCHATCHOUA DOMINIQUE OTHNIEL'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025175', 'TONYE MANUELLA ANGE OPHELIE', get_or_generate_vote_code('2025175', 'TONYE MANUELLA ANGE OPHELIE'), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025176', 'DIPITA NSANGUE JEAN YVES ROSLIN', get_or_generate_vote_code('2025176', 'DIPITA NSANGUE JEAN YVES ROSLIN'), false, '3ème année', 'Computer Engineering', NOW()),
  (generate_voter_id(), '2025177', 'NANA DJOUNDI YVES-MARCEL', get_or_generate_vote_code('2025177', 'NANA DJOUNDI YVES-MARCEL'), false, '3ème année', 'Computer Engineering', NOW()),
  
  -- LEGAL CAREER L3 (8 étudiants)
  (generate_voter_id(), '2025178', 'HAOUA HAIFA ABDOUL AZIZ', get_or_generate_vote_code('2025178', 'HAOUA HAIFA ABDOUL AZIZ'), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025179', 'LOUANGE EMMANUELLE SANDRA', get_or_generate_vote_code('2025179', 'LOUANGE EMMANUELLE'), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025180', 'MOHAMMED SEYO', get_or_generate_vote_code('2025180', 'MOHAMMED SEYO'), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025181', 'PATIENCE ANNY MANGA', get_or_generate_vote_code('2025181', 'PATIENCE ANNY MANGA'), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025182', 'ABAH BILOA CECILE ANDREA', get_or_generate_vote_code('2025182', 'ABAH BILOA CECILE ANDREA'), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025183', 'MOUHAMED BOURHAN BOGNE', get_or_generate_vote_code('2025183', 'MOUHAMED BOURHAN BOGNE'), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025184', 'NZOUAKEU MBOUM ALEXANDRA CLEMENTINE ODETTE SUZAN', get_or_generate_vote_code('2025184', 'NZOUAKEU MBOUM ALEXANDRA CLEMENTINE ODETTE SUZAN'), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025185', 'NZOUDJA BATEKI GUY KHARIS', get_or_generate_vote_code('2025185', 'NZOUDJA BATEKI GUY KHARIS'), false, '1ère année', 'Legal Career', NOW()),
  
  -- ELECTRICAL ENGINEERING L3 (2 étudiants)
  (generate_voter_id(), '2025186', 'NOUHOU ISSOUFOU', get_or_generate_vote_code('2025186', 'NOUHOU ISSOUFOU'), false, '3ème année', 'Electrical Engineering', NOW()),
  (generate_voter_id(), '2025187', 'WAMBA LATIFA', get_or_generate_vote_code('2025187', 'WAMBA LATIFA'), false, '3ème année', 'Electrical Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L1 (9 étudiants du PDF)
  (generate_voter_id(), '2025188', 'BASSA A IROUME JOYCE DIVINE', get_or_generate_vote_code('2025188', 'BASSA A IROUME JOYCE DIVINE'), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025189', 'CHIDIEU DEMGNE OCEANE JOYCE', get_or_generate_vote_code('2025189', 'CHIDIEU DEMGNE OCEANE JOYCE'), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025190', 'ESSOME EFOUBA THOMAS MARTIAL', get_or_generate_vote_code('2025190', 'ESSOME EFOUBA THOMAS MARTIAL'), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025191', 'FOKOU SIPETKAM OCEANE', get_or_generate_vote_code('2025191', 'FOKOU SIPETKAM OCEANE'), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025192', 'MOUKOKO SUZANNE', get_or_generate_vote_code('2025192', 'MOUKOKO SUZANNE'), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025193', 'NJAMEN DJAPOM WILHEM ARYOLD', get_or_generate_vote_code('2025193', 'NJAMEN DJAPOM WILHEM ARYOLD'), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025194', 'NJOCK CESAR BRICE', get_or_generate_vote_code('2025194', 'NJOCK CESAR BRICE'), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025195', 'SIMO KAMGANG GABRIELLE NORIA', get_or_generate_vote_code('2025195', 'SIMO KAMGANG GABRIELLE NORIA'), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025196', 'VICTORINE NKOME NDJEM LAFLEURE', get_or_generate_vote_code('2025196', 'VICTORINE NKOME NDJEM L.'), false, '1ère année', 'Software Engineering', NOW()),
  
  -- MECATRONICS L1 (3 étudiants)
  (generate_voter_id(), '2025197', 'BIDJECKE TAGNE SERGE', get_or_generate_vote_code('2025197', 'BIDJECKE TAGNE SERGE'), false, '1ère année', 'Mecatronics', NOW()),
  (generate_voter_id(), '2025198', 'FEUK''SI DJOKO CHOUTCHEDJIM MC DONALD DAVID BRANDON', get_or_generate_vote_code('2025198', 'FEUK''SI DJOKO CHOUTCHEDJIM MC DONALD DAVID BRANDON'), false, '1ère année', 'Mecatronics', NOW()),
  (generate_voter_id(), '2025199', 'FOMO MEKAM STEVE ROLAND', get_or_generate_vote_code('2025199', 'FOMO MEKAM STEVE ROLAND'), false, '1ère année', 'Mecatronics', NOW()),
  
  -- PREPA L1 (13 étudiants)
  (generate_voter_id(), '2025200', 'BOUALLO ALEXANDRA KINZI', get_or_generate_vote_code('2025200', 'BOUALLO ALEXANDRA KINZI'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025201', 'DJOUMUKAM INGRID FLORE', get_or_generate_vote_code('2025201', 'DJOUMUKAM INGRID FLORE'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025202', 'ENDEME KOM ANAELLE', get_or_generate_vote_code('2025202', 'ENDEME KOM ANAELLE'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025203', 'ENDEME YANN MARK', get_or_generate_vote_code('2025203', 'ENDEME YANN MARK'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025204', 'ESSOMBE ESSOMBE MARVIN AUGUSTE MICHAUX', get_or_generate_vote_code('2025204', 'ESSOMBE ESSOMBE MARVIN AUGUSTE MICHAUX'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025205', 'ETEKI EWANE DANIELLE TAMARA', get_or_generate_vote_code('2025205', 'ETEKI EWANE DANIELLE TAMARA'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025206', 'FOTSO FOTSO ALAN FAREL', get_or_generate_vote_code('2025206', 'FOTSO FOTSO ALAN FAREL'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025207', 'KENFACK TSATCHOU VERANE', get_or_generate_vote_code('2025207', 'KENFACK TSATCHOU VERANE'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025208', 'NGA BAKARI TRESOR', get_or_generate_vote_code('2025208', 'NGA BAKARI TRESOR'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025209', 'OUAMBO MATHIEU', get_or_generate_vote_code('2025209', 'OUAMBO MATHIEU'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025210', 'TABAKOUO BRICE KABREL', get_or_generate_vote_code('2025210', 'TABAKOUO BRICE KABREL'), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025211', 'TABUE MESSA CELIA SERENA', get_or_generate_vote_code('2025211', 'TABUE MESSA CELIA SERENA'), false, '1ère année', 'Prepa', NOW()),
  
  -- PHARMACY L1 (2 étudiants)
  (generate_voter_id(), '2025212', 'TENJO MUNOH GRACE BELLE', get_or_generate_vote_code('2025212', 'TENJO MUNOH GRACE BELLE'), false, '1ère année', 'PHARMACY', NOW()),
  (generate_voter_id(), '2025213', 'YANGA NJOCK JOSE LUIGY', get_or_generate_vote_code('2025213', 'YANGA NJOCK JOSE LUIGY'), false, '1ère année', 'PHARMACY', NOW()),
  
  -- MASTER 1 KL UNIVERSITY (1 étudiant)
  (generate_voter_id(), '2025214', 'BIND MAX GIOVANNI', get_or_generate_vote_code('2025214', 'BIND MAX GIOVANNI'), false, 'Master 1', 'Master 1 KL University', NOW()),
  
  -- BACHELOR OF ENGINEERING (1 étudiant)
  (generate_voter_id(), '2025215', 'EPEE EBOULE WILLIAM FREDERICK ALAIN', get_or_generate_vote_code('2025215', 'EPEE EBOULE WILLIAM FREDERICK ALAIN'), false, 'Bachelor', 'Bachelor of Engineering', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1 (étudiant supplémentaire)
  (generate_voter_id(), '2025216', 'SIHNO HOUETO MAGLOIRE ESPOIR KEVIN', get_or_generate_vote_code('2025216', 'SIHNO HOVETO MAGLOIRE E.'), false, '1ère année', 'Computer and Electronics Engineering', NOW());

-- ============================================
-- NETTOYER LES FONCTIONS TEMPORAIRES
-- ============================================
DROP FUNCTION IF EXISTS get_or_generate_vote_code(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS generate_voter_id();

-- ============================================
-- VÉRIFICATION
-- ============================================
-- Afficher le nombre total de votants
SELECT COUNT(*) as total_voters FROM voters;

-- Afficher le nombre par filière
SELECT field, COUNT(*) as count 
FROM voters 
GROUP BY field 
ORDER BY field;

-- Afficher le nombre par année
SELECT year, COUNT(*) as count 
FROM voters 
GROUP BY year 
ORDER BY year;

-- Afficher quelques exemples pour vérification
SELECT student_id, name, year, field, vote_code 
FROM voters 
ORDER BY student_id 
LIMIT 10;


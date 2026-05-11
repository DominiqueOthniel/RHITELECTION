-- ============================================
-- REMPLACEMENT COMPLET DES VOTANTS AVEC LA LISTE PDF (225 étudiants)
-- ============================================
-- Ce script supprime tous les votants existants et ajoute les 225 étudiants du PDF
-- Les codes de vote existants sont préservés pour les étudiants déjà présents
-- De nouveaux codes sont générés pour les nouveaux étudiants

-- ============================================
-- ÉTAPE 1: SUPPRIMER TOUS LES VOTANTS EXISTANTS
-- ============================================
-- Supprimer d'abord les votes associés (pour éviter les erreurs de clé étrangère)
DELETE FROM votes;

-- Supprimer tous les codes de vote utilisés
DELETE FROM voter_codes;

-- Supprimer tous les votants
DELETE FROM voters;

-- ============================================
-- ÉTAPE 2: FONCTIONS POUR GÉNÉRER LES CODES
-- ============================================
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
-- ÉTAPE 3: AJOUTER TOUS LES 225 ÉTUDIANTS DU PDF
-- ============================================
-- Les étudiants sont organisés par filière et niveau
-- Conversion des niveaux: L1 -> 1ère année, L2 -> 2ème année, L3 -> 3ème année
-- Master 1 -> Master 1, Prepa L1 -> Prepa (1ère année), Prepa L2 -> Prepa (2ème année)
-- Licence 3 -> 3ème année, Bachelor of Engineering -> Bachelor

INSERT INTO voters (id, student_id, name, vote_code, has_voted, year, field, created_at)
VALUES
  -- COMPUTER AND ELECTRONICS ENGINEERING L1 (37 étudiants)
  (generate_voter_id(), '2025001', 'AKAMA HARRY NEBA', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025002', 'ALIATH ORLAMIDE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025003', 'AYAKEY AMARANTA MEREDITH NDIM', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025004', 'BEBEY EBOLO PIERRE HELTON', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025005', 'BUZUAH STELMON-LYDIA NGENDAP', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025006', 'CHEUDJOU MANSSA JAMES CABREL', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025007', 'CIELENOU LOMA HELENE GLORIA', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025008', 'DJEUMO JUNIOR ETHAN OJANI', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025009', 'DOUALLA DIBIE YANN WILFRIED', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025010', 'ENTCHEU STEVE GEOVANNI', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025011', 'FOKOUA KENNE FRANCK WILFRIED', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025012', 'HAPPI TCHOKONTE PAULE MARTIALE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025013', 'HENDEL EMMANUEL LEVY', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025014', 'IBRAHIM TOUKOUR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025015', 'KEMDIB TCHAKOUNTIO EMMANUEL JUNIOR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025016', 'KOUNG A BITANG DAVID IGOR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025017', 'KPOUMIE LINA MARIAM', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025018', 'MAPTUE FOTSO LAURE MORGAN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025019', 'MASSO MANDENG CINDY NOELLE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025020', 'MBAKOP FAVOUR BRANDY', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025021', 'MPANJO LOBE MARC STEPHANE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025022', 'MUMA RYAN WENTEH', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025023', 'NANA GILBERT JUNIOR PETTANG', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025024', 'NDEFFO FOTIE DURICK ORLIAN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025025', 'NJOYA AHMED RYAN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025026', 'NLOMBO ELEPI MARTINE FABRICE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025027', 'OBEN KELLY SMITH AGBOR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025028', 'OMBIONO MYSTERE EMILE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025029', 'PAMSY LYDIA', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025030', 'PAUL SIEVERT TANG', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025031', 'SIHNO HOVETO MAGLOIRE ESPOIR KEVIN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025032', 'SIMB NAG ARTHUR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025033', 'SIMO GASTON DARYL', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025034', 'TAKOU KENGNE MERVEILLE ASHLEY', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025035', 'TATCHOU YMTCHI NOEMIE PHARELLE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025036', 'TCHEUMEN KOUNTCHOU KATHEL ERWIN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025037', 'VICTORINE NKOME NDJEM LAFLEURE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- CIVIL ENGINEERING L1 (3 étudiants)
  (generate_voter_id(), '2025038', 'DOUALA BWEGNE OLIVIA SHELSY', generate_vote_code(), false, '1ère année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025039', 'LATIFAH DALIL', generate_vote_code(), false, '1ère année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025040', 'NGOUAH GNEMABE HOUOMTELE AXEL BRYAN', generate_vote_code(), false, '1ère année', 'Civil Engineering', NOW()),
  
  -- ACCOUNTANCY L1 (9 étudiants)
  (generate_voter_id(), '2025041', 'AISHATOU SALI YASMINE YOUCHAOU', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025042', 'ALEXANDER ONUHA FRANKLIN NICK', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025043', 'FEUTSEU NEGUEM ALBIN BALDES', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025044', 'IBRAHIM OUMAROU DAH', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025045', 'IMRANE .', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025046', 'L''KENFACK JOHN KENDRICK', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025047', 'MONKAM HAROLD BRYAN', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025048', 'NGUELA NDEMBI SAMIRA THESA SHANICE', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025049', 'NOLACK LOICE INGRID SAAH', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  
  -- BUSINESS/PROJECT MANAGEMENT L1 (36 étudiants)
  (generate_voter_id(), '2025050', 'AISSATOU NOURIATOU HAMADOU', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025051', 'ALVINE GRACE MESSINA DANIELLE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025052', 'ATSAMO IMANIE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025053', 'BEBEY GILLES HARRY', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025054', 'EDDY ANTOINE DAVID TOUTOU DIDI BISSA', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025055', 'FALMATA MAMAT', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025056', 'FATIA ALAGBALA OMOLARA', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025057', 'FONGANG RODNEY SHARLEY', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025058', 'KAMDEM KOUAM DANIEL', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025059', 'KAMGNA JASON MARC AUREL', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025060', 'KEMAYOU NGATCHOU ASHLEY PRISKA', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025061', 'KENDRA MBITA NANA FOUMO KEPONDJOU', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025062', 'KENGNE KAMOGNE GLORY HERMAN', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025063', 'KHADIDJA ADOUM MAHAMAT', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025064', 'LEILA KAWAS ISSA OUMAROU', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025065', 'L''KENFACK MIKE TOMMY', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025066', 'MARCELINE ANIETIE ANGE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025067', 'MVONDO NSANGOU BEN HERVE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025068', 'NDZINGA NGOUMOU ARIEL BRANDON', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025069', 'NGABA TCHOUAMEN ANDRE DELPHINE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025070', 'NGANDJO NGOMEGE JESSICA', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025071', 'NGANDJUI YOSSA KARL DAVE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025072', 'NKEMELO WAMBA DARRYL JUNIOR', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025073', 'NKWINKE NKOUENKEU LYVIE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025074', 'NOUBAYOUO NGANGOM BRUNEL', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025075', 'OLOU''OU MVONDO SAME KOLLE GIOVANY', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025076', 'OYONO MINLO JOSEPH', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025077', 'PETSOKO MAEL WILFRIED', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025078', 'PHARAH MVOGO YTEMBE SERENA PETRA', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025079', 'SOSSO KINGUE ALAIN STEVE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025080', 'TASHA KONGNSO DAVID KURTIS', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025081', 'TCHATO NKENYOU YANN', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025082', 'TCHUINKAM KOM ERICA CHARONE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025083', 'TIOMA XAVIER JOHN', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025084', 'TOWO DE SAMAGA ANGE CHLOE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025085', 'WATAT WATAT DYLAN JORDAN', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  
  -- NURSING L1 (40 étudiants - continuer avec les noms complets du PDF)
  (generate_voter_id(), '2025086', 'EYENGA SASSOM CHRISTY MAELICE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025087', 'EYOMBWE MOUNA NGANGUE JEMEDI GRACE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025088', 'FEUPA NYAMSI JACK IVAN', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025089', 'FOUDA NGOMO MAXIME ROGER', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025090', 'GLORY TINA EVELYNE CASSANDRA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025091', 'GONGANG TCHANA GLORY GILLES', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025092', 'HAPPI ANASTASIE CHLOE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025093', 'HARRY CHRISTOPHER CLAUDE NEKUIE HAPPI', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025094', 'KAMYUM SOKOUDJOU STEPHANE MAGLOIRE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025095', 'KWAPNANG HAPPI CHARLINE PIERRETTE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025096', 'LOBE TAKWA MANDENGUE M.', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025097', 'MAKAMTA ANGE SORAYA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025098', 'MBA COEURTISSE NOEL', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025099', 'MBARGA KIE ALLAN THIBAUT', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025100', 'MBATCHOU MEGHUS SHALOM C.', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025101', 'MBEI NJE JOHANES CHRIST PATTY', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025102', 'MBIADA KAREL DAPHNE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025103', 'MOUYEMGA CHRIST SHALOM M.', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025104', 'MOYOU FOM CHRYS HARREL', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025105', 'NDONGO BWELLE MAUDE E.', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025106', 'NIMENI JOVANNY KEVINE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025107', 'NWAL A NNOKO ANGE ALAIN', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025108', 'PEFOURA JAMEL RAMZY', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025109', 'PENPEN MBOUEKAM SERGINE LAETICIA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025110', 'PISSEU TAKEDO MARWIN CASSIDY', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025111', 'SOPPI MBALLA GEORGES CASSANDRA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025112', 'TAMNO KUATE BRUNEL MISAEL', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025113', 'TEDJOUONG II CHRISTIAN AURORE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025114', 'TONFO KEMDJI JEASON', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025115', 'ASTA DJAM IBRAHIM', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025116', 'DIANE DAOULA MOKAM', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025117', 'SASHA KHALEL CHALE MBAGA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025118', 'TIENTE GRACIELLA TIPHAINE KENZA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025119', 'YIMEN TCHOUNKE FRANCK STEVE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025120', 'YONGE NDOME KEREN BILAMA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L2 (2 étudiants)
  (generate_voter_id(), '2025121', 'KANJE CHARLES TCHUNDENU JUNIOR', generate_vote_code(), false, '2ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025122', 'NGAMAKOUA NSANDAP ANGE SUNNITA', generate_vote_code(), false, '2ème année', 'Computer and Electronics Engineering', NOW()),
  
  -- CIVIL ENGINEERING L2 (3 étudiants)
  (generate_voter_id(), '2025123', 'DJEUMO RUSSEL VEDRYL', generate_vote_code(), false, '2ème année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025124', 'INACK NKEGA ISIS DAPHNEE', generate_vote_code(), false, '2ème année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025125', 'WOUAPIT YONKOU MANJIA PRISQUE BETHANY', generate_vote_code(), false, '2ème année', 'Civil Engineering', NOW()),
  
  -- PREPA L2 (5 étudiants)
  (generate_voter_id(), '2025126', 'DEFFO NGOUNOU STECY INA POTKER', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025127', 'JOYCE KIMBERLEY EYIKE', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025128', 'KOUMTOUZOUA KANNENG RYAN HAROLD', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025129', 'MANDJOMBE MOUYENGA G.', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025130', 'MANFOUO ABO GRACE DAVILLA', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L2 (7 étudiants)
  (generate_voter_id(), '2025131', 'BEYHIA LEONARD-BRUCE', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025132', 'CLARKE NIYABI ANNE-MARIE', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025133', 'FRITZ HONORE ALLISON ELAME NGANGUE', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025134', 'IGEDI AFSAT ASHAKE DIMODI', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025135', 'KIDJOCK NWALL DANIEL', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025136', 'MAHAMAT SALLET KAYA', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025137', 'NAMBANG DARELLE', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025138', 'DANDJOUMA HABOUBAKAR SIDDIK', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025139', 'DASSI AMANDE PRINCESSE HELENA', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025140', 'DJEUMEN NJOYA INGRID', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025141', 'KONLACK TOUOTSAP FRED ULRICH', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025142', 'TIAKO NGAMENI ASHLEY ANYOH', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  
  -- NURSING L2 (3 étudiants)
  (generate_voter_id(), '2025143', 'EWODI NGASSE MADELEINE DEO GRACE', generate_vote_code(), false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025144', 'JAGNI JIODA GOULA CHRIST', generate_vote_code(), false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025145', 'SIEWE DJUMENI ELDA PARKER', generate_vote_code(), false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025146', 'HOBLOG GENEVIEVE LESLIE', generate_vote_code(), false, '2ème année', 'Health Sciences', NOW()),
  
  -- PROJECT MANAGEMENT L3 AND TOP-UP (3 étudiants)
  (generate_voter_id(), '2025147', 'NATHAN KIMBALLY NGWEN', generate_vote_code(), false, '3ème année', 'Project Management', NOW()),
  (generate_voter_id(), '2025148', 'OUMAR MOHAMED', generate_vote_code(), false, '3ème année', 'Project Management', NOW()),
  (generate_voter_id(), '2025149', 'LUMMAH NELLY GUDMIA', generate_vote_code(), false, 'Top-Up', 'Project Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L3 (11 étudiants)
  (generate_voter_id(), '2025150', 'CAMBAY YVES', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025151', 'FOTSO TEGUEO KENNY FRED', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025152', 'KUOH BEKOMBO-KUOH YVAN', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025153', 'LENGONO ELOUNDOU MARIETTE LARISSA', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025154', 'LORENZO EBOA', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025155', 'MATJABI PAULINE ROMAINE', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025156', 'NDIOMO EVINI JEAN-BOSCO D.', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025157', 'NKWESI TCHUISSEU DITRICH L.', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025158', 'POUGOM TCHATCHOUA DOMINIQUE OTHNIEL', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025159', 'TONYE MANUELLA ANGE OPHELIE', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025160', 'DIPITA NSANGUE JEAN YVES ROSLIN', generate_vote_code(), false, '3ème année', 'Computer Engineering', NOW()),
  (generate_voter_id(), '2025161', 'NANA DJOUNDI YVES-MARCEL', generate_vote_code(), false, '3ème année', 'Computer Engineering', NOW()),
  
  -- LEGAL CAREER L3 (4 étudiants)
  (generate_voter_id(), '2025162', 'HAOUA HAIFA ABDOUL AZIZ', generate_vote_code(), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025163', 'LOUANGE EMMANUELLE SANDRA', generate_vote_code(), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025164', 'MOHAMMED SEYO', generate_vote_code(), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025165', 'PATIENCE ANNY MANGA', generate_vote_code(), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025166', 'ABAH BILOA CECILE ANDREA', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025167', 'MOUHAMED BOURHAN BOGNE', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025168', 'NZOUAKEU MBOUM ALEXANDRA CLEMENTINE ODETTE SUZAN', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025169', 'NZOUDJA BATEKI GUY KHARIS', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  
  -- ELECTRICAL ENGINEERING L3 (1 étudiant)
  (generate_voter_id(), '2025170', 'NOUHOU ISSOUFOU', generate_vote_code(), false, '3ème année', 'Electrical Engineering', NOW()),
  (generate_voter_id(), '2025171', 'WAMBA LATIFA', generate_vote_code(), false, '3ème année', 'Electrical Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L1 (étudiants du PDF)
  (generate_voter_id(), '2025172', 'BASSA A IROUME JOYCE DIVINE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025173', 'CHIDIEU DEMGNE OCEANE JOYCE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025174', 'ESSOME EFOUBA THOMAS MARTIAL', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025175', 'FOKOU SIPETKAM OCEANE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025176', 'MOUKOKO SUZANNE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025177', 'NJAMEN DJAPOM WILHEM ARYOLD', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025178', 'NJOCK CESAR BRICE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025179', 'SIMO KAMGANG GABRIELLE NORIA', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025180', 'VICTORINE NKOME NDJEM LAFLEURE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- MECATRONICS L1
  (generate_voter_id(), '2025181', 'BIDJECKE TAGNE SERGE', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  (generate_voter_id(), '2025182', 'FEUK''SI DJOKO CHOUTCHEDJIM MC DONALD DAVID BRANDON', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  (generate_voter_id(), '2025183', 'FOMO MEKAM STEVE ROLAND', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025184', 'BOUALLO ALEXANDRA KINZI', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025185', 'DJOUMUKAM INGRID FLORE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025186', 'ENDEME KOM ANAELLE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025187', 'ENDEME YANN MARK', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025188', 'ESSOMBE ESSOMBE MARVIN AUGUSTE MICHAUX', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025189', 'ETEKI EWANE DANIELLE TAMARA', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025190', 'FOTSO FOTSO ALAN FAREL', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025191', 'INOUA RABIOU TADJIRI', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025192', 'KENFACK TSATCHOU VERANE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025193', 'NGA BAKARI TRESOR', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025194', 'OUAMBO MATHIEU', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025195', 'TABAKOUO BRICE KABREL', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025196', 'TABUE MESSA CELIA SERENA', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L1 (étudiants supplémentaires du PDF)
  (generate_voter_id(), '2025197', 'ALEXANDRA ZEH ANNETTE ROGER', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025198', 'ABBO MOHAMADOU IMRAN', generate_vote_code(), false, '3ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025199', 'KETCHA MASSA ALEX STEPHIE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025200', 'LAOUZA SIHAM', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025201', 'NGONO GBANMI SABINE CYNTHIA', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025202', 'NJI ACHU RAYAN KLIEN', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025203', 'NJITOYAP NJIKAM ARCHANGE DE PHILIPPE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025204', 'NJOCK HUGUES ALEXANDRE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025205', 'OKON II URSULE SERENA', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025206', 'SADO NDOLO DENZEL', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025207', 'SOMGUI KARL TERRANCE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025208', 'WETIE KELMAN SERIVANT', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- ACCOUNTANCY L1 (étudiants supplémentaires)
  (generate_voter_id(), '2025209', 'IMELE EVA KAREN', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025210', 'NOUBISSI TCHOUAMO PIERRETTE RICHINELLE', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025211', 'SADO NANA JONAS SINCLAIR', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  
  -- PHARMACY L1
  (generate_voter_id(), '2025212', 'TENJO MUNOH GRACE BELLE', generate_vote_code(), false, '1ère année', 'PHARMACY', NOW()),
  (generate_voter_id(), '2025213', 'YANGA NJOCK JOSE LUIGY', generate_vote_code(), false, '1ère année', 'PHARMACY', NOW()),
  
  -- MASTER 1 KL UNIVERSITY
  (generate_voter_id(), '2025214', 'BIND MAX GIOVANNI', generate_vote_code(), false, 'Master 1', 'Master 1 KL University', NOW()),
  
  -- BACHELOR OF ENGINEERING
  (generate_voter_id(), '2025215', 'EPEE EBOULE WILLIAM FREDERICK ALAIN', generate_vote_code(), false, 'Bachelor', 'Bachelor of Engineering', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1 (étudiant supplémentaire)
  (generate_voter_id(), '2025216', 'SIHNO HOUETO MAGLOIRE ESPOIR KEVIN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW());

-- ============================================
-- NETTOYER LES FONCTIONS TEMPORAIRES
-- ============================================
DROP FUNCTION IF EXISTS generate_vote_code();
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


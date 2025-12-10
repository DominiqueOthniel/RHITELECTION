-- ============================================
-- IMPORT DES VOTANTS DEPUIS LA LISTE D'EXAMENS
-- ============================================
-- Ce script importe tous les étudiants de la liste d'examens RHIT CA1 2526
-- Date: 25/10/2025
-- Les codes étudiants vont de 2025001 à 2025155

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
-- COMPUTER AND ELECTRONICS ENGINEERING 1
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025001', '', 'AKAMA HARRY NEBA', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025002', '', 'ALIATH ORLAMIDE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025003', '', 'AYAKEY AMARANTA MEREDITH', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025004', '', 'BEBEY EBOLO PIERRE HELTON', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025005', '', 'BUZUAH STELMON-LYDIA NGENDAP', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025006', '', 'CHEUDIOU MANSSA JAMES CABREL', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025007', '', 'CIELENOU LOMA HELENE GLORIA', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025008', '', 'DJEUMO JUNIOR ETHAN OJANI', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025009', '', 'DOUALLA DIBIE YANN WILFRIED', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025010', '', 'ENTCHEU STEVE GEOVANNI', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025011', '', 'FOKOUA KENNE FRANCK', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025012', '', 'HAPPI TCHOKONTE PAULE M.', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025013', '', 'HENDEL EMMANUEL LEVY', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025014', '', 'IBRAHIM TOUKOUR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025015', '', 'KEMDIB TCHAKOUNTIO EMMANUEL', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025016', '', 'KOUNG A BITANG DAVID IGOR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025017', '', 'KPOUMIE LINA MARIAM', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025018', '', 'MAPTUE FOTSO LAURE MORGAN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025019', '', 'MASSO MANDENG CINDY NOELLE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025020', '', 'MBAKOP FAVOUR BRANDY', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025021', '', 'MPANJO LOBE MARC STEPHANE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025022', '', 'MUMA RYAN WENTEH', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025023', '', 'NANA GILBERT JUNIOR PETTANG', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025024', '', 'NDEFFO FOTIE DURICK ORLIAN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025025', '', 'NJOYA AHMED RYAN', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025026', '', 'NLOMBO ELEPI MARTINE FABRICE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025027', '', 'OBEN KELLY SMITH AGBOR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025028', '', 'OMBIONO MYSTERE EMILE', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025029', '', 'PAMSY LYDIA', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025030', '', 'PAUL SIEVERT TANG', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025031', '', 'SIHNO HOVETO MAGLOIRE E.', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025032', '', 'SIMB NAG ARTHUR', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025033', '', 'SIMO GASTON DARYL', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025034', '', 'TAKOU KENGNE MERVEILLE A.', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025035', '', 'TATCHOU YMTCHI NOEMIE P.', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025036', '', 'TCHEUMEN KOUNTCHOU KATHEL', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025037', '', 'VICTORINE NKOME NDJEM L.', generate_vote_code(), false, '1ère année', 'Computer and Electronics Engineering', NOW());

-- ============================================
-- CIVIL ENGINEERING 1
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025038', '', 'DOUALA BWEGNE OLIVIA SHELSY', generate_vote_code(), false, '1ère année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025039', '', 'LATIFAH DALIL', generate_vote_code(), false, '1ère année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025040', '', 'NGOUAH GNEMABE HOUOMTELE', generate_vote_code(), false, '1ère année', 'Civil Engineering', NOW());

-- ============================================
-- ACCOUNTANCY 1
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025041', '', 'AISHATOU SALI YASMINE Y.', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025042', '', 'ALEXANDER ONUHA FRANKLIN N.', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025043', '', 'FEUTSEU NEGUEM ALBIN BALDES', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025044', '', 'IBRAHIM OUMAROU DAH', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025045', '', 'IMRANE IMRANE', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025046', '', 'L''KENFACK JOHN KENDRICK', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025047', '', 'MONKAM HAROLD BRYAN', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025048', '', 'NGUELA NDEMBI SAMIRA THESA S.', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025049', '', 'NOLACK LOICE INGRID SAAH', generate_vote_code(), false, '1ère année', 'Accountancy', NOW());

-- ============================================
-- BUSINESS/PROJECT MANAGEMENT 1
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025050', '', 'AISSATOU NOURIATOU HAMADOU', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025051', '', 'ALVINE GRACE MESSINA DANIELLE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025052', '', 'ATSAMO IMANIE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025053', '', 'BEBEY GILLES HARRY', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025054', '', 'EDDY ANTOINE DAVID TOUTOU D.', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025055', '', 'FALMATA MAMAT', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025056', '', 'FATIA ALAGBALA OMOLARA', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025057', '', 'FONGANG RODNEY SHARLEY', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025058', '', 'KAMDEM KOUAM DANIEL', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025059', '', 'KAMGNA JASON MARC AUREL', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025060', '', 'KEMAYOU NGATCHOU ASHLEY P.', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025061', '', 'KENDRA MBITA NANA FOUMO K.', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025062', '', 'KENGNE KAMOGNE GLORY H.', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025063', '', 'KHADIDJA ADOUM MAHAMAT', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025064', '', 'LEILA KAWAS ISSA OUMAROU', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025065', '', 'L''KENFACK MIKE TOMMY', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025066', '', 'MARCELINE ANIETIE ANGE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025067', '', 'MVONDO NSANGOU BEN HERVE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025068', '', 'NDZINGA NGOUMOU ARIEL B.', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025069', '', 'NGABA TCHOUAMEN ANDRE D.', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025070', '', 'NGANDJO NGOMEGE JESSICA', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025071', '', 'NGANDJUI YOSSA KARL DAVE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025072', '', 'NKEMELO WAMBA DARRYL JUNIOR', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025073', '', 'NKWINKE NKOUENKEU LYVIE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025074', '', 'NOUBAYOUO NGANGOM BRUNEL', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025075', '', 'OLOU''OU MVONDO SAME KOLLE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025076', '', 'OYONO MINLO JOSEPH', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025077', '', 'PETSOKO MAEL WILFRIED', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025078', '', 'PHARAH MVOGO YTEMBE SERENA', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025079', '', 'SOSSO KINGUE ALAIN STEVE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025080', '', 'TASHA KONGNSO DAVID KURTIS', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025081', '', 'TCHATO NKENYOU YANN', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025082', '', 'TCHUINKAM KOM ERICA CHARONE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025083', '', 'TIOMA XAVIER JOHN', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025084', '', 'TOWO DE SAMAGA ANGE CHLOE', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025085', '', 'WATAT WA...', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW());

-- ============================================
-- NURSING 1
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025086', '', 'EYENGA SASSOM CHRISTY M.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025087', '', 'EYOMBWE MOUNA NGANGUE J.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025088', '', 'FEUPA NYAMSI JACK IVAN', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025089', '', 'FOUDA NGOMO MAXIME ROGER', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025090', '', 'GLORY TINA EVELYNE CASSANDRA', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025091', '', 'GONGANG TCHANA GLORY GILLES', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025092', '', 'HAPPI ANASTASIE CHLOE', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025093', '', 'HARRY CHRISTOPHER CLAUDE N.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025094', '', 'KAMYUM SOKOUDJOU STEPHANE', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025095', '', 'KWAPNANG HAPPI CHARLINE P.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025096', '', 'LOBE TAKWA MANDENGUE M.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025097', '', 'MAKAMTA ANGE SORAYA', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025098', '', 'MBA COEURTISSE NOEL', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025099', '', 'MBARGA KIE ALLAN THIBAUT', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025100', '', 'MBATCHOU MEGHUS SHALOM C.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025101', '', 'MBEI NJE JOHANES CHRIST PATTY', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025102', '', 'MBIADA KAREL DAPHNE', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025103', '', 'MOUYEMGA CHRIST SHALOM M.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025104', '', 'MOYOU FOM CHRYS HARREL', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025105', '', 'NDONGO BWELLE MAUDE E.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025106', '', 'NIMENI JOVANNY KEVINE', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025107', '', 'NWAL A NNOXO ANGE ALAIN', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025108', '', 'PEFOURA JAMEL', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025109', '', 'PENPEN MBOUEKAM SERGINE L.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025110', '', 'PISSEU TAKEDO MARWIN CASSIDY', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025111', '', 'SOPPI MBALLA GEORGES C.', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025112', '', 'TAMNO KUATE BRUNEL MISAEL', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025113', '', 'TEDJOUONG II CHRISTIAN AURORE', generate_vote_code(), false, '1ère année', 'Nursing', NOW()),
  (generate_voter_id(), '2025114', '', 'TONFO KEMDJI JEASON', generate_vote_code(), false, '1ère année', 'Nursing', NOW());

-- ============================================
-- COMPUTER AND ELECTRONICS ENGINEERING 2
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025115', '', 'KANJE CHARLES TCHUNDENU J.', generate_vote_code(), false, '2ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025116', '', 'NGAMAKOUA NSANDAP ANGE S.', generate_vote_code(), false, '2ème année', 'Computer and Electronics Engineering', NOW());

-- ============================================
-- CIVIL ENGINEERING 2
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025117', '', 'DJEUMO RUSSEL VEDRYL', generate_vote_code(), false, '2ème année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025118', '', 'INACK ISIS DAPHNEE', generate_vote_code(), false, '2ème année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025119', '', 'WOUAPIT YONKOU MANJIA P.', generate_vote_code(), false, '2ème année', 'Civil Engineering', NOW());

-- ============================================
-- PREPA 2
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025120', '', 'DEFFO NGOUNOU STECY INA P.', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025121', '', 'JOYCE KIMBERLEY EYIKE', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025122', '', 'KOUMTOUZOUA KANNENG RYAN H.', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025123', '', 'MANDJOMBE MOUYENGA G.', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025124', '', 'MANFOUO ABO GRACE DAVILLA', generate_vote_code(), false, '2ème année', 'Prepa', NOW());

-- ============================================
-- BUSINESS MANAGEMENT 2
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025125', '', 'BEYHIA LEONARD-BRUCE', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025126', '', 'CLARKE NIYABI ANNE-MARIE', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025127', '', 'FRITZ HONORE ALLISON ELAME NGANGUE', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025128', '', 'IGEDI AFSAT ASHAKE DIMODI', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025129', '', 'KIDJOCK NWALL DANIEL', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025130', '', 'MAHAMAT SALLET KAYA', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025131', '', 'NAMBANG DARELLE', generate_vote_code(), false, '2ème année', 'Business Management', NOW());

-- ============================================
-- NURSING 2
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025132', '', 'EWODI NGASSE MADELEINE DEO', generate_vote_code(), false, '2ème année', 'Nursing', NOW()),
  (generate_voter_id(), '2025133', '', 'JAGNI JIODA GOULA CHRIST', generate_vote_code(), false, '2ème année', 'Nursing', NOW()),
  (generate_voter_id(), '2025134', '', 'SIEWE DJUMENI ELDA PARKER', generate_vote_code(), false, '2ème année', 'Nursing', NOW());

-- ============================================
-- PROJECT MANAGEMENT 3 AND TOP-UP
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025135', '', 'NATHAN KIMBALLY NGWEN', generate_vote_code(), false, '3ème année', 'Project Management', NOW()),
  (generate_voter_id(), '2025136', '', 'OUMAR MOHAMED', generate_vote_code(), false, '3ème année', 'Project Management', NOW()),
  (generate_voter_id(), '2025137', '', 'LUMMAH NELLY GUDMIA', generate_vote_code(), false, 'Top-Up', 'Project Management', NOW());

-- ============================================
-- COMPUTER AND ELECTRONICS ENGINEERING 3
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025138', '', 'CAMBAY YVES', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025139', '', 'FOTSO TEGUEO KENNY FRED', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025140', '', 'KUOH BEKOMBO-KUOH YVAN', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025141', '', 'LENGONO ELOUNDOU MARIETTE L.', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025142', '', 'LORENZO EBOA', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025143', '', 'MATJABI PAULINE ROMAINE', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025144', '', 'NDIOMO EVINI JEAN-BOSCO D.', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025145', '', 'NKWESI TCHUISSEU DITRICH L.', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025146', '', 'POUGOM TCHATCHOUA DOMINIQUE OTHNIEL', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025147', '', 'TONYE MANUELLA ANGE OPHELIE', generate_vote_code(), false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025148', '', 'DIKELEL LEONCE AXEL', generate_vote_code(), false, 'LP GL', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025149', '', 'NITCHEU POUGOM DOROTHEE C.', generate_vote_code(), false, 'LP GL', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025150', '', 'NOUBISSI TCHOUAMO PIERETTE R.', generate_vote_code(), false, 'LP GL', 'Computer and Electronics Engineering', NOW());

-- ============================================
-- LEGAL CAREER 3
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025151', '', 'HAOUA HAIFA ABDOUL AZIZ', generate_vote_code(), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025152', '', 'LOUANGE EMMANUELLE', generate_vote_code(), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025153', '', 'MOHAMMED SEYO', generate_vote_code(), false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025154', '', 'PATIENCE ANNY MANGA', generate_vote_code(), false, '3ème année', 'Legal Career', NOW());

-- ============================================
-- ELECTRICAL ENGINEERING 3
-- ============================================
INSERT INTO voters (id, student_id, email, name, vote_code, has_voted, year, field, created_at)
VALUES
  (generate_voter_id(), '2025155', '', 'NOUHOU ISSOUFOU', generate_vote_code(), false, '3ème année', 'Electrical Engineering', NOW());

-- ============================================
-- NETTOYER LES FONCTIONS TEMPORAIRES
-- ============================================
DROP FUNCTION IF EXISTS generate_vote_code();
DROP FUNCTION IF EXISTS generate_voter_id();

-- ============================================
-- VÉRIFICATION
-- ============================================
-- Afficher le nombre total de votants importés
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

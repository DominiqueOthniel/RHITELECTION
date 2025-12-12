-- ============================================
-- REMPLACEMENT COMPLET DES VOTANTS AVEC CODES DE VOTE DU CSV
-- ============================================
-- Ce script supprime tous les votants existants et ajoute les 225 étudiants du PDF
-- Les codes de vote sont extraits du fichier CSV votants_2025-12-11.csv
-- Pour les étudiants sans code dans le CSV, de nouveaux codes sont générés

-- ============================================
-- ÉTAPE 1: SUPPRIMER TOUS LES VOTANTS ET VOTES
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
-- Les codes de vote sont extraits du CSV votants_2025-12-11.csv
-- Conversion des niveaux: L1 -> 1ère année, L2 -> 2ème année, L3 -> 3ème année
-- Master 1 -> Master 1, Prepa L1 -> Prepa (1ère année), Prepa L2 -> Prepa (2ème année)
-- Licence 3 -> 3ème année, Bachelor of Engineering -> Bachelor

INSERT INTO voters (id, student_id, name, vote_code, has_voted, year, field, created_at)
VALUES
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025001', 'AKAMA HARRY NEBA', '65A7RLFB', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025002', 'ALIATH ORLAMIDE', 'NEGGD5PA', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025003', 'AYAKEY AMARANTA MEREDITH NDIM', 'URK7FFZL', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025004', 'BEBEY EBOLO PIERRE HELTON', 'QUMJ4EKW', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025005', 'BUZUAH STELMON-LYDIA NGENDAP', 'TBGA6PGK', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025006', 'CHEUDJOU MANSSA JAMES CABREL', 'DPBTL2WZ', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025007', 'CIELENOU LOMA HELENE GLORIA', 'R5FTCLDB', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025008', 'DJEUMO JUNIOR ETHAN OJANI', 'T6ZEHVXE', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025009', 'DOUALLA DIBIE YANN WILFRIED', 'TQ88YB64', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025010', 'ENTCHEU STEVE GEOVANNI', 'RVWJ8Y6R', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025011', 'FOKOUA KENNE FRANCK WILFRIED', '9M2KQ8BQ', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025012', 'HAPPI TCHOKONTE PAULE MARTIALE', 'A2B9D8SH', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025013', 'HENDEL EMMANUEL LEVY', '4CDLKU5K', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025014', 'IBRAHIM TOUKOUR', 'B7VYMW4D', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025015', 'KEMDIB TCHAKOUNTIO EMMANUEL JUNIOR', 'FBUJZ54M', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025016', 'KOUNG A BITANG DAVID IGOR', 'HQ9ZEAMJ', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025017', 'KPOUMIE LINA MARIAM', '2BP7Y9VC', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025018', 'MAPTUE FOTSO LAURE MORGAN', 'ZBWGP5E5', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025019', 'MASSO MANDENG CINDY NOELLE', 'QV86VXU4', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025020', 'MBAKOP FAVOUR BRANDY', '9H9HP67A', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025021', 'MPANJO LOBE MARC STEPHANE', 'Z3GJGM2Q', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025022', 'MUMA RYAN WENTEH', 'E8GUGSVR', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025023', 'NANA GILBERT JUNIOR PETTANG', 'LVCYXLG2', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025024', 'NDEFFO FOTIE DURICK ORLIAN', '7SW8CZ4Q', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025025', 'NJOYA AHMED RYAN', 'BZ7T4ZZF', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025026', 'NLOMBO ELEPI MARTINE FABRICE', '8ZFFGH4B', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025027', 'OBEN KELLY SMITH AGBOR', 'NZDP7SLP', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025028', 'OMBIONO MYSTERE EMILE', '3T52X6BS', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025029', 'PAMSY LYDIA', 'NHRUEYZX', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025030', 'PAUL SIEVERT TANG', 'HSNZZTWA', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025031', 'SIHNO HOVETO MAGLOIRE ESPOIR KEVIN', 'K6HT56AU', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025032', 'SIMB NAG ARTHUR', '3EZPZREL', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025033', 'SIMO GASTON DARYL', 'HLUHRTZ9', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025034', 'TAKOU KENGNE MERVEILLE ASHLEY', 'A3YTLEXQ', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025035', 'TATCHOU YMTCHI NOEMIE PHARELLE', 'X5GRZCP3', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025036', 'TCHEUMEN KOUNTCHOU KATHEL ERWIN', 'KPNMYK43', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025037', 'VICTORINE NKOME NDJEM LAFLEURE', 'R8C7VM8F', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- CIVIL ENGINEERING L1
  (generate_voter_id(), '2025038', 'DOUALA BWEGNE OLIVIA SHELSY', 'DAETYP4G', false, '1ère année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025039', 'LATIFAH DALIL', 'RRR5XNJC', false, '1ère année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025040', 'NGOUAH GNEMABE HOUOMTELE AXEL BRYAN', 'S8UYCQH4', false, '1ère année', 'Civil Engineering', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025041', 'AISHATOU SALI YASMINE YOUCHAOU', 'ZYCDUCG4', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025042', 'ALEXANDER ONUHA FRANKLIN NICK', 'JCRTRPJ8', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025043', 'FEUTSEU NEGUEM ALBIN BALDES', 'F5W7HCAW', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025044', 'IBRAHIM OUMAROU DAH', 'P4CQVBS7', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025045', 'IMRANE .', 'VDJZDT9C', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025046', 'L''KENFACK JOHN KENDRICK', 'F537L3EL', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025047', 'MONKAM HAROLD BRYAN', 'YK86Z6RV', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025048', 'NGUELA NDEMBI SAMIRA THESA SHANICE', '4KPNHXAW', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025049', 'NOLACK LOICE INGRID SAAH', 'ZPBSHP2S', false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025050', 'IMELE EVA KAREN', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025051', 'NOUBISSI TCHOUAMO PIERRETTE RICHINELLE', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  (generate_voter_id(), '2025052', 'SADO NANA JONAS SINCLAIR', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  
  -- BUSINESS/PROJECT MANAGEMENT L1
  (generate_voter_id(), '2025053', 'AISSATOU NOURIATOU HAMADOU', 'EB59F5D5', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025054', 'ALVINE GRACE MESSINA DANIELLE', 'BNUTHMTG', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025055', 'ATSAMO IMANIE', 'WUMK4DX8', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025056', 'BEBEY GILLES HARRY', 'HUK5FFXS', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025057', 'EDDY ANTOINE DAVID TOUTOU DIDI BISSA', 'GLMS7V5N', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025058', 'FALMATA MAMAT', 'AQR55ND4', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025059', 'FATIA ALAGBALA OMOLARA', 'C45A2JC9', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025060', 'FONGANG RODNEY SHARLEY', 'L5TDRRJH', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025061', 'KAMDEM KOUAM DANIEL', 'VSSRSN95', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025062', 'KAMGNA JASON MARC AUREL', 'SZEVK7ZT', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025063', 'KEMAYOU NGATCHOU ASHLEY PRISKA', 'PQDCAYMG', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025064', 'KENDRA MBITA NANA FOUMO KEPONDJOU', 'JSRU8KG6', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025065', 'KENGNE KAMOGNE GLORY HERMAN', 'Q5UGJSCR', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025066', 'KHADIDJA ADOUM MAHAMAT', 'DAN8TR7Y', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025067', 'LEILA KAWAS ISSA OUMAROU', 'JVDENNBQ', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025068', 'L''KENFACK MIKE TOMMY', 'LDT382G8', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025069', 'MARCELINE ANIETIE ANGE', 'A42B7U6S', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025070', 'MVONDO NSANGOU BEN HERVE', '79L7727F', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025071', 'NDZINGA NGOUMOU ARIEL BRANDON', 'SP3GLLUW', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025072', 'NGABA TCHOUAMEN ANDRE DELPHINE', 'YF5TJDWJ', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025073', 'NGANDJO NGOMEGE JESSICA', 'DK6YGJB5', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025074', 'NGANDJUI YOSSA KARL DAVE', '99M4LMB2', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025075', 'NKEMELO WAMBA DARRYL JUNIOR', '7LZ3YQNA', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025076', 'NKWINKE NKOUENKEU LYVIE', 'PXX4XHUK', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025077', 'NOUBAYOUO NGANGOM BRUNEL', 'UX83AU6D', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025078', 'OLOU''OU MVONDO SAME KOLLE GIOVANY', 'ZXZ96WYB', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025079', 'OYONO MINLO JOSEPH', '2TP4P4FV', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025080', 'PETSOKO MAEL WILFRIED', 'PZEVUSYF', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025081', 'PHARAH MVOGO YTEMBE SERENA PETRA', 'NJREP2R3', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025082', 'SOSSO KINGUE ALAIN STEVE', 'ADHUNFHY', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025083', 'TASHA KONGNSO DAVID KURTIS', '2LKLVEVD', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025084', 'TCHATO NKENYOU YANN', '22CSXSE5', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025085', 'TCHUINKAM KOM ERICA CHARONE', '6LEBDADE', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025086', 'TIOMA XAVIER JOHN', 'HTA546ZT', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025087', 'TOWO DE SAMAGA ANGE CHLOE', 'GFXY25ZR', false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025088', 'WATAT WATAT DYLAN JORDAN', 'NSJMLLSZ', false, '1ère année', 'Business/Project Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1 (étudiants supplémentaires du PDF)
  (generate_voter_id(), '2025089', 'ALEXANDRA ZEH ANNETTE ROGER', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025090', 'ABBO MOHAMADOU IMRAN', generate_vote_code(), false, '3ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025091', 'KETCHA MASSA ALEX STEPHIE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025092', 'LAOUZA SIHAM', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025093', 'NGONO GBANMI SABINE CYNTHIA', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025094', 'NJI ACHU RAYAN KLIEN', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025095', 'NJITOYAP NJIKAM ARCHANGE DE PHILIPPE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025096', 'NJOCK HUGUES ALEXANDRE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025097', 'OKON II URSULE SERENA', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025098', 'SADO NDOLO DENZEL', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025099', 'SOMGUI KARL TERRANCE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025100', 'WETIE KELMAN SERIVANT', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- NURSING L1 (40 étudiants du PDF)
  (generate_voter_id(), '2025101', 'EYENGA SASSOM CHRISTY MAELICE', 'WTYH23XZ', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025102', 'EYOMBWE MOUNA NGANGUE JEMEDI GRACE', 'AASR98PS', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025103', 'FEUPA NYAMSI JACK IVAN', '6P65XRU2', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025104', 'FOUDA NGOMO MAXIME ROGER', '7QL7YCPD', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025105', 'GLORY TINA EVELYNE CASSANDRA', '9TKBVR24', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025106', 'GONGANG TCHANA GLORY GILLES', 'SSYWVDTZ', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025107', 'HAPPI ANASTASIE CHLOE', 'HNFPN74G', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025108', 'HARRY CHRISTOPHER CLAUDE NEKUIE HAPPI', 'YTT56KKD', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025109', 'KAMYUM SOKOUDJOU STEPHANE MAGLOIRE', 'V3UJF2S3', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025110', 'KWAPNANG HAPPI CHARLINE PIERRETTE', 'F47BH2WC', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025111', 'LOBE TAKWA MANDENGUE M.', 'N6Y8XN2B', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025112', 'MAKAMTA ANGE SORAYA', '9FDCFW8H', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025113', 'MBA COEURTISSE NOEL', 'P4YVGAWB', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025114', 'MBARGA KIE ALLAN THIBAUT', 'KST9Q3BG', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025115', 'MBATCHOU MEGHUS SHALOM C.', 'V8SGQERZ', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025116', 'MBEI NJE JOHANES CHRIST PATTY', '4TFUHC9L', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025117', 'MBIADA KAREL DAPHNE', 'BHNA25EN', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025118', 'MOUYEMGA CHRIST SHALOM M.', 'UUK3K9BC', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025119', 'MOYOU FOM CHRYS HARREL', 'LLP89FMC', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025120', 'NDONGO BWELLE MAUDE E.', 'SJQHUGRS', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025121', 'NIMENI JOVANNY KEVINE', 'D8QJVSU9', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025122', 'NWAL A NNOKO ANGE ALAIN', 'YBRWSYP5', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025123', 'PEFOURA JAMEL RAMZY', 'LT8YDWJW', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025124', 'PENPEN MBOUEKAM SERGINE LAETICIA', 'EW5EBYSA', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025125', 'PISSEU TAKEDO MARWIN CASSIDY', '8ZA4MDET', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025126', 'SOPPI MBALLA GEORGES CASSANDRA', 'VBNSSP3Y', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025127', 'TAMNO KUATE BRUNEL MISAEL', 'MQSFG6MA', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025128', 'TEDJOUONG II CHRISTIAN AURORE', 'VRFSM22Q', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025129', 'TONFO KEMDJI JEASON', 'GR7649GD', false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025130', 'ASTA DJAM IBRAHIM', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025131', 'DIANE DAOULA MOKAM', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025132', 'SASHA KHALEL CHALE MBAGA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025133', 'TIENTE GRACIELLA TIPHAINE KENZA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025134', 'YIMEN TCHOUNKE FRANCK STEVE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  (generate_voter_id(), '2025135', 'YONGE NDOME KEREN BILAMA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L2
  (generate_voter_id(), '2025136', 'KANJE CHARLES TCHUNDENU JUNIOR', 'ZFJY8L4X', false, '2ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025137', 'NGAMAKOUA NSANDAP ANGE SUNNITA', '24CC6THK', false, '2ème année', 'Computer and Electronics Engineering', NOW()),
  
  -- CIVIL ENGINEERING L2
  (generate_voter_id(), '2025138', 'DJEUMO RUSSEL VEDRYL', 'EHBYBST7', false, '2ème année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025139', 'INACK NKEGA ISIS DAPHNEE', 'A2ZAMJ9P', false, '2ème année', 'Civil Engineering', NOW()),
  (generate_voter_id(), '2025140', 'WOUAPIT YONKOU MANJIA PRISQUE BETHANY', '3MEB8SBD', false, '2ème année', 'Civil Engineering', NOW()),
  
  -- PREPA L2
  (generate_voter_id(), '2025141', 'DEFFO NGOUNOU STECY INA POTKER', '7RL57JC4', false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025142', 'JOYCE KIMBERLEY EYIKE', '7MDFR82X', false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025143', 'KOUMTOUZOUA KANNENG RYAN HAROLD', 'VGUNBHF2', false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025144', 'MANDJOMBE MOUYENGA G.', 'LCPXS2HD', false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025145', 'MANFOUO ABO GRACE DAVILLA', '9X77FK8T', false, '2ème année', 'Prepa', NOW()),
  (generate_voter_id(), '2025146', 'INOUA RABIOU TADJIRI', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025147', 'BEYHIA LEONARD-BRUCE', 'RPT6TZGF', false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025148', 'CLARKE NIYABI ANNE-MARIE', 'E5G3TUX4', false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025149', 'FRITZ HONORE ALLISON ELAME NGANGUE', '2LUCGD9N', false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025150', 'IGEDI AFSAT ASHAKE DIMODI', '9ZRRC7XL', false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025151', 'KIDJOCK NWALL DANIEL', 'LZ4DQTJS', false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025152', 'MAHAMAT SALLET KAYA', 'AD4A3M63', false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025153', 'NAMBANG DARELLE', 'XYRY4L4M', false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025154', 'DANDJOUMA HABOUBAKAR SIDDIK', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025155', 'DASSI AMANDE PRINCESSE HELENA', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025156', 'DJEUMEN NJOYA INGRID', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025157', 'KONLACK TOUOTSAP FRED ULRICH', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  (generate_voter_id(), '2025158', 'TIAKO NGAMENI ASHLEY ANYOH', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  
  -- NURSING L2
  (generate_voter_id(), '2025159', 'EWODI NGASSE MADELEINE DEO GRACE', '57LRHJVP', false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025160', 'JAGNI JIODA GOULA CHRIST', 'DNGS8UFN', false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025161', 'SIEWE DJUMENI ELDA PARKER', 'F9LRA98V', false, '2ème année', 'NURSING', NOW()),
  (generate_voter_id(), '2025162', 'HOBLOG GENEVIEVE LESLIE', generate_vote_code(), false, '2ème année', 'Health Sciences', NOW()),
  
  -- PROJECT MANAGEMENT L3 AND TOP-UP
  (generate_voter_id(), '2025163', 'NATHAN KIMBALLY NGWEN', '7DL3JWQ9', false, '3ème année', 'Project Management', NOW()),
  (generate_voter_id(), '2025164', 'OUMAR MOHAMED', 'VXYMYB3P', false, '3ème année', 'Project Management', NOW()),
  (generate_voter_id(), '2025165', 'LUMMAH NELLY GUDMIA', 'LWB4SDGJ', false, 'Top-Up', 'Project Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L3
  (generate_voter_id(), '2025166', 'CAMBAY YVES', 'LJPGX24Q', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025167', 'FOTSO TEGUEO KENNY FRED', '2X8Z3WLN', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025168', 'KUOH BEKOMBO-KUOH YVAN', '4CQN422X', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025169', 'LENGONO ELOUNDOU MARIETTE LARISSA', '7Q475WMU', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025170', 'LORENZO EBOA', 'D524P276', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025171', 'MATJABI PAULINE ROMAINE', '4X99SEL7', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025172', 'NDIOMO EVINI JEAN-BOSCO D.', 'BA9KYRNM', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025173', 'NKWESI TCHUISSEU DITRICH L.', 'X4HL868L', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025174', 'POUGOM TCHATCHOUA DOMINIQUE OTHNIEL', 'FEFHMKB2', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025175', 'TONYE MANUELLA ANGE OPHELIE', 'CAT3NEZ9', false, '3ème année', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025176', 'DIPITA NSANGUE JEAN YVES ROSLIN', generate_vote_code(), false, '3ème année', 'Computer Engineering', NOW()),
  (generate_voter_id(), '2025177', 'NANA DJOUNDI YVES-MARCEL', generate_vote_code(), false, '3ème année', 'Computer Engineering', NOW()),
  (generate_voter_id(), '2025178', 'DIKELEL LEONCE AXEL', 'EFYL49H7', false, 'LP GL', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025179', 'NITCHEU POUGOM DOROTHEE CHLOE', '8X3HQV5G', false, 'LP GL', 'Computer and Electronics Engineering', NOW()),
  (generate_voter_id(), '2025180', 'NOUBISSI TCHOUAMO PIERETTE R.', '4WNBSQVH', false, 'LP GL', 'Computer and Electronics Engineering', NOW()),
  
  -- LEGAL CAREER L3
  (generate_voter_id(), '2025181', 'HAOUA HAIFA ABDOUL AZIZ', 'E25FK832', false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025182', 'LOUANGE EMMANUELLE SANDRA', 'TBY6GDBN', false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025183', 'MOHAMMED SEYO', 'CPBADSN9', false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025184', 'PATIENCE ANNY MANGA', 'FLX3LJAW', false, '3ème année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025185', 'ABAH BILOA CECILE ANDREA', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025186', 'MOUHAMED BOURHAN BOGNE', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025187', 'NZOUAKEU MBOUM ALEXANDRA CLEMENTINE ODETTE SUZAN', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  (generate_voter_id(), '2025188', 'NZOUDJA BATEKI GUY KHARIS', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  
  -- ELECTRICAL ENGINEERING L3
  (generate_voter_id(), '2025189', 'NOUHOU ISSOUFOU', '6FMNEZ9Y', false, '3ème année', 'Electrical Engineering', NOW()),
  (generate_voter_id(), '2025190', 'WAMBA LATIFA', generate_vote_code(), false, '3ème année', 'Electrical Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025191', 'BASSA A IROUME JOYCE DIVINE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025192', 'CHIDIEU DEMGNE OCEANE JOYCE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025193', 'ESSOME EFOUBA THOMAS MARTIAL', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025194', 'FOKOU SIPETKAM OCEANE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025195', 'MOUKOKO SUZANNE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025196', 'NJAMEN DJAPOM WILHEM ARYOLD', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025197', 'NJOCK CESAR BRICE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025198', 'SIMO KAMGANG GABRIELLE NORIA', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  (generate_voter_id(), '2025199', 'VICTORINE NKOME NDJEM LAFLEURE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- MECATRONICS L1
  (generate_voter_id(), '2025200', 'BIDJECKE TAGNE SERGE', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  (generate_voter_id(), '2025201', 'FEUK''SI DJOKO CHOUTCHEDJIM MC DONALD DAVID BRANDON', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  (generate_voter_id(), '2025202', 'FOMO MEKAM STEVE ROLAND', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025203', 'BOUALLO ALEXANDRA KINZI', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025204', 'DJOUMUKAM INGRID FLORE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025205', 'ENDEME KOM ANAELLE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025206', 'ENDEME YANN MARK', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025207', 'ESSOMBE ESSOMBE MARVIN AUGUSTE MICHAUX', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025208', 'ETEKI EWANE DANIELLE TAMARA', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025209', 'FOTSO FOTSO ALAN FAREL', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025210', 'KENFACK TSATCHOU VERANE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025211', 'NGA BAKARI TRESOR', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025212', 'OUAMBO MATHIEU', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025213', 'TABAKOUO BRICE KABREL', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025214', 'TABUE MESSA CELIA SERENA', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  (generate_voter_id(), '2025215', 'TEDJOUONG II CHRISTIAN AURORE', 'VRFSM22Q', false, '1ère année', 'Prepa', NOW()),
  
  -- PHARMACY L1
  (generate_voter_id(), '2025216', 'TENJO MUNOH GRACE BELLE', generate_vote_code(), false, '1ère année', 'PHARMACY', NOW()),
  (generate_voter_id(), '2025217', 'YANGA NJOCK JOSE LUIGY', generate_vote_code(), false, '1ère année', 'PHARMACY', NOW()),
  
  -- MASTER 1 KL UNIVERSITY
  (generate_voter_id(), '2025218', 'BIND MAX GIOVANNI', generate_vote_code(), false, 'Master 1', 'Master 1 KL University', NOW()),
  
  -- BACHELOR OF ENGINEERING
  (generate_voter_id(), '2025219', 'EPEE EBOULE WILLIAM FREDERICK ALAIN', generate_vote_code(), false, 'Bachelor', 'Bachelor of Engineering', NOW()),
  
  -- AUTRES ÉTUDIANTS DU PDF (étudiants supplémentaires identifiés)
  (generate_voter_id(), '2025220', 'ALAIN STEVE SOSSO KINGUE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  (generate_voter_id(), '2025221', 'ERTHAN-TAWAMBA MBITA NANA FOUMO KEPONDJOU', generate_vote_code(), false, '1ère année', 'Business/Project Management', NOW()),
  (generate_voter_id(), '2025222', 'KEMAJOU NGAMENI OSWALD EVAN', generate_vote_code(), false, '1ère année', 'Prepa', NOW());

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

-- Afficher quelques exemples pour vérification
SELECT student_id, name, year, field, vote_code 
FROM voters 
ORDER BY student_id 
LIMIT 10;


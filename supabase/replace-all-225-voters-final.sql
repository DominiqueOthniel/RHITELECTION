-- ============================================
-- REMPLACEMENT COMPLET DES VOTANTS - 225 ÉTUDIANTS DU PDF
-- ============================================
-- Ce script supprime tous les votants existants et ajoute les 225 étudiants du PDF
-- Les codes de vote sont extraits du fichier CSV votants_2025-12-11.csv (155 étudiants)
-- Pour les 70 étudiants sans code dans le CSV, de nouveaux codes sont générés automatiquement

-- ============================================
-- ÉTAPE 1: SUPPRIMER TOUS LES VOTANTS ET VOTES
-- ============================================
DELETE FROM votes;
DELETE FROM voter_codes;
DELETE FROM voters;

-- ============================================
-- ÉTAPE 2: FONCTIONS POUR GÉNÉRER LES CODES
-- ============================================
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
    SELECT COUNT(*) INTO exists_check FROM voters WHERE vote_code = code;
    IF exists_check = 0 THEN
      EXIT;
    END IF;
  END LOOP;
  RETURN code;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_voter_id() RETURNS VARCHAR(255) AS $$
BEGIN
  RETURN replace(uuid_generate_v4()::text, '-', '');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ÉTAPE 3: AJOUTER TOUS LES 225 ÉTUDIANTS DU PDF
-- ============================================
-- Conversion des niveaux selon le PDF:
-- L1 -> 1ère année, L2 -> 2ème année, L3 -> 3ème année
-- Master 1 KL University -> Master 1
-- Bachelor of Engineering -> Bachelor
-- LP GL -> LP GL
-- Top-Up -> Top-Up

INSERT INTO voters (id, student_id, name, vote_code, has_voted, year, field, created_at)
VALUES
  -- LEGAL CAREER L1
  (generate_voter_id(), '2025001', 'ABAH BILOA CECILE ANDREA', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  
  -- BUSINESS MANAGEMENT L3
  (generate_voter_id(), '2025002', 'ABBO MOHAMADOU IMRAN', generate_vote_code(), false, '3ème année', 'Business Management', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025003', 'AISHATOU SALI YASMINE YOUCHAOU', 'ZYCDUCG4', false, '1ère année', 'Accountancy', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025004', 'AISSATOU NOURIATOU HAMADOU', 'EB59F5D5', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025005', 'AKAMA HARRY NEBA', '65A7RLFB', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025006', 'ALAIN STEVE SOSSO KINGUE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025007', 'ALEXANDER ONUHA FRANKLIN NICK', 'JCRTRPJ8', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025008', 'ALEXANDRA ZEH ANNETTE ROGER', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025009', 'ALIATH ORLAMIDE', 'NEGGD5PA', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025010', 'ALVINE GRACE MESSINA DANIELLE', 'BNUTHMTG', false, '1ère année', 'Business Management', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025011', 'ASTA DJAM IBRAHIM', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025012', 'ATSAMO IMANIE', 'WUMK4DX8', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025013', 'AYAKEY AMARANTA MEREDITH NDIM', 'URK7FFZL', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025014', 'BASSA A IROUME JOYCE DIVINE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025015', 'BEBEY EBOLO PIERRE HELTON', 'QUMJ4EKW', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025016', 'BEBEY GILLES HARRY', 'HUK5FFXS', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025017', 'BEYHIA LEONARD-BRUCE', 'RPT6TZGF', false, '2ème année', 'Business Management', NOW()),
  
  -- MECATRONICS L1
  (generate_voter_id(), '2025018', 'BIDJECKE TAGNE SERGE', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  
  -- MASTER 1 KL UNIVERSITY
  (generate_voter_id(), '2025019', 'BIND MAX GIOVANNI', generate_vote_code(), false, 'Master 1', 'Master 1 KL University', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025020', 'BOUALLO ALEXANDRA KINZI', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025021', 'BUZUAH STELMON-LYDIA NGENDAP', 'TBGA6PGK', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025022', 'CAMBAY YVES', 'LJPGX24Q', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025023', 'CHEUDJOU MANSSA JAMES CABREL', 'DPBTL2WZ', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025024', 'CHIDIEU DEMGNE OCEANE JOYCE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025025', 'CIELENOU LOMA HELENE GLORIA', 'R5FTCLDB', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025026', 'CLARKE NIYABI ANNE-MARIE', 'E5G3TUX4', false, '2ème année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025027', 'DANDJOUMA HABOUBAKAR SIDDIK', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025028', 'DASSI AMANDE PRINCESSE HELENA', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  
  -- PREPA L2
  (generate_voter_id(), '2025029', 'DEFFO NGOUNOU STECY INA POTKER', '7RL57JC4', false, '2ème année', 'Prepa', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025030', 'DIANE DAOULA MOKAM', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025031', 'DIKELEL LEONCE AXEL', 'EFYL49H7', false, 'LP GL', 'Computer Engineering', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025032', 'DIPITA NSANGUE JEAN YVES ROSLIN', generate_vote_code(), false, '3ème année', 'Computer Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025033', 'DJEUMEN NJOYA INGRID', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025034', 'DJEUMO JUNIOR ETHAN OJANI', 'T6ZEHVXE', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUILDING CONSTRUCTION L2
  (generate_voter_id(), '2025035', 'DJEUMO RUSSEL VEDRYL', 'EHBYBST7', false, '2ème année', 'Building Construction', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025036', 'DJOUMUKAM INGRID FLORE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- BUILDING CONSTRUCTION L1
  (generate_voter_id(), '2025037', 'DOUALA BWEGNE OLIVIA SHELSY', 'DAETYP4G', false, '1ère année', 'Building Construction', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025038', 'DOUALLA DIBIE YANN WILFRIED', 'TQ88YB64', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025039', 'EDDY ANTOINE DAVID TOUTOU DIDI BISSA', 'GLMS7V5N', false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025040', 'ENDEME KOM ANAELLE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025041', 'ENDEME YANN MARK', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025042', 'ENTCHEU STEVE GEOVANNI', 'RVWJ8Y6R', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BACHELOR OF ENGINEERING
  (generate_voter_id(), '2025043', 'EPEE EBOULE WILLIAM FREDERICK ALAIN', generate_vote_code(), false, 'Bachelor', 'Bachelor of Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025044', 'ERTHAN-TAWAMBA MBITA NANA FOUMO KEPONDJOU', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025045', 'ESSOMBE ESSOMBE MARVIN AUGUSTE MICHAUX', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025046', 'ESSOME EFOUBA THOMAS MARTIAL', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025047', 'ETEKI EWANE DANIELLE TAMARA', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- NURSING L2
  (generate_voter_id(), '2025048', 'EWODI NGASSE MADELEINE DEO GRACE', '57LRHJVP', false, '2ème année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025049', 'EYENGA SASSOM CHRISTY MAELICE', 'WTYH23XZ', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025050', 'EYOMBWE MOUNA NGANGUE JEMEDI GRACE', 'AASR98PS', false, '1ère année', 'NURSING', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025051', 'FALMATA MAMAT', 'AQR55ND4', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025052', 'FATIA ALAGBALA OMOLARA', 'C45A2JC9', false, '1ère année', 'Business Management', NOW()),
  
  -- MECATRONICS L1
  (generate_voter_id(), '2025053', 'FEUK''SI DJOKO CHOUTCHEDJIM MC DONALD DAVID BRANDON', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025054', 'FEUPA NYAMSI JACK IVAN', '6P65XRU2', false, '1ère année', 'Software Engineering', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025055', 'FEUTSEU NEGUEM ALBIN BALDES', 'F5W7HCAW', false, '1ère année', 'Accountancy', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025056', 'FOKOUA KENNE FRANCK WILFRIED', '9M2KQ8BQ', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025057', 'FOKOU SIPETKAM OCEANE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- MECATRONICS L1
  (generate_voter_id(), '2025058', 'FOMO MEKAM STEVE ROLAND', generate_vote_code(), false, '1ère année', 'Mecatronics', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025059', 'FONGANG RODNEY SHARLEY', 'L5TDRRJH', false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025060', 'FOTSO FOTSO ALAN FAREL', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025061', 'FOTSO TEGUEO KENNY FRED', '2X8Z3WLN', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025062', 'FOUDA NGOMO MAXIME ROGER', '7QL7YCPD', false, '1ère année', 'NURSING', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025063', 'FRITZ HONORE ALLISON ELAME NGANGUE', '2LUCGD9N', false, '2ème année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025064', 'GLORY TINA EVELYNE CASSANDRA', '9TKBVR24', false, '1ère année', 'Prepa', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025065', 'GONGANG TCHANA GLORY GILLES', 'SSYWVDTZ', false, '1ère année', 'Prepa', NOW()),
  
  -- LEGAL CAREER L3
  (generate_voter_id(), '2025066', 'HAOUA HAIFA ABDOUL AZIZ', 'E25FK832', false, '3ème année', 'Legal Career', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025067', 'HAPPI ANASTASIE CHLOE', 'HNFPN74G', false, '1ère année', 'Prepa', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025068', 'HAPPI TCHOKONTE PAULE MARTIALE', 'A2B9D8SH', false, '1ère année', 'Software Engineering', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025069', 'HARRY CHRISTOPHER CLAUDE NEKUIE HAPPI', 'YTT56KKD', false, '1ère année', 'Prepa', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025070', 'HENDEL EMMANUEL LEVY', '4CDLKU5K', false, '1ère année', 'Software Engineering', NOW()),
  
  -- HEALTH SCIENCES L2
  (generate_voter_id(), '2025071', 'HOBLOG GENEVIEVE LESLIE', generate_vote_code(), false, '2ème année', 'Health Sciences', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025072', 'IBRAHIM OUMAROU DAH', 'P4CQVBS7', false, '1ère année', 'Accountancy', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025073', 'IBRAHIM TOUKOUR', 'B7VYMW4D', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025074', 'IGEDI AFSAT ASHAKE DIMODI', '9ZRRC7XL', false, '2ème année', 'Business Management', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025075', 'IMELE EVA KAREN', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025076', 'IMRANE .', 'VDJZDT9C', false, '1ère année', 'Accountancy', NOW()),
  
  -- BUILDING CONSTRUCTION L2
  (generate_voter_id(), '2025077', 'INACK NKEGA ISIS DAPHNEE', 'A2ZAMJ9P', false, '2ème année', 'Building Construction', NOW()),
  
  -- PREPA L2
  (generate_voter_id(), '2025078', 'INOUA RABIOU TADJIRI', generate_vote_code(), false, '2ème année', 'Prepa', NOW()),
  
  -- NURSING L2
  (generate_voter_id(), '2025079', 'JAGNI JIODA GOULA CHRIST', 'DNGS8UFN', false, '2ème année', 'NURSING', NOW()),
  
  -- PREPA L2
  (generate_voter_id(), '2025080', 'JOYCE KIMBERLEY EYIKE', '7MDFR82X', false, '2ème année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025081', 'KAMDEM KOUAM DANIEL', 'VSSRSN95', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025082', 'KAMGNA JASON MARC AUREL', 'SZEVK7ZT', false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025083', 'KAMYUM SOKOUDJOU STEPHANE MAGLOIRE', 'V3UJF2S3', false, '1ère année', 'Prepa', NOW()),
  
  -- SOFTWARE ENGINEERING L2
  (generate_voter_id(), '2025084', 'KANJE CHARLES TCHUNDENU JUNIOR', 'ZFJY8L4X', false, '2ème année', 'Software Engineering', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025085', 'KEMAJOU NGAMENI OSWALD EVAN', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025086', 'KEMAYOU NGATCHOU ASHLEY PRISKA', 'PQDCAYMG', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025087', 'KEMDIB TCHAKOUNTIO EMMANUEL JUNIOR', 'FBUJZ54M', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025088', 'KENDRA MBITA NANA FOUMO KEPONDJOU', 'JSRU8KG6', false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025089', 'KENFACK TSATCHOU VERANE', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025090', 'KENGNE KAMOGNE GLORY HERMAN', 'Q5UGJSCR', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025091', 'KETCHA MASSA ALEX STEPHIE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025092', 'KHADIDJA ADOUM MAHAMAT', 'DAN8TR7Y', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025093', 'KIDJOCK NWALL DANIEL', 'LZ4DQTJS', false, '2ème année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025094', 'KONLACK TOUOTSAP FRED ULRICH', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  
  -- PREPA L2
  (generate_voter_id(), '2025095', 'KOUMTOUZOUA KANNENG RYAN HAROLD', 'VGUNBHF2', false, '2ème année', 'Prepa', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025096', 'KOUNG A BITANG DAVID IGOR', 'HQ9ZEAMJ', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025097', 'KPOUMIE LINA MARIAM', '2BP7Y9VC', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025098', 'KUOH BEKOMBO-KUOH YVAN', '4CQN422X', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025099', 'KWAPNANG HAPPI CHARLINE PIERRETTE', 'F47BH2WC', false, '1ère année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025100', 'LAOUZA SIHAM', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- BUILDING CONSTRUCTION L1
  (generate_voter_id(), '2025101', 'LATIFAH DALIL', 'RRR5XNJC', false, '1ère année', 'Building Construction', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025102', 'LEILA KAWAS ISSA OUMAROU', 'JVDENNBQ', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025103', 'LENGONO ELOUNDOU MARIETTE LARISSA', '7Q475WMU', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025104', 'L''KENFACK JOHN KENDRICK', 'F537L3EL', false, '1ère année', 'Accountancy', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025105', 'L''KENFACK MIKE TOMMY', 'LDT382G8', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025106', 'LORENZO EBOA', 'D524P276', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- PROJECT MANAGEMENT TOP-UP
  (generate_voter_id(), '2025107', 'LUMMAH NELLY GUDMIA', 'LWB4SDGJ', false, 'Top-Up', 'Project Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025108', 'MARCELINE ANIETIE ANGE', 'A42B7U6S', false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L2
  (generate_voter_id(), '2025109', 'MANDJOMBE MOUYENGA G.', 'LCPXS2HD', false, '2ème année', 'Prepa', NOW()),
  
  -- PREPA L2
  (generate_voter_id(), '2025110', 'MANFOUO ABO GRACE DAVILLA', '9X77FK8T', false, '2ème année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025111', 'MAHAMAT SALLET KAYA', 'AD4A3M63', false, '2ème année', 'Business Management', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025112', 'MATJABI PAULINE ROMAINE', '4X99SEL7', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025113', 'MBA COEURTISSE NOEL', 'P4YVGAWB', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025114', 'MBARGA KIE ALLAN THIBAUT', 'KST9Q3BG', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025115', 'MBATCHOU MEGHUS SHALOM C.', 'V8SGQERZ', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025116', 'MBEI NJE JOHANES CHRIST PATTY', '4TFUHC9L', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025117', 'MBIADA KAREL DAPHNE', 'BHNA25EN', false, '1ère année', 'NURSING', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025118', 'NDIOMO EVINI JEAN-BOSCO D.', 'BA9KYRNM', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025119', 'MVONDO NSANGOU BEN HERVE', '79L7727F', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025120', 'NDZINGA NGOUMOU ARIEL BRANDON', 'SP3GLLUW', false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025121', 'NGA BAKARI TRESOR', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025122', 'NGABA TCHOUAMEN ANDRE DELPHINE', generate_vote_code(), false, '3ème année', 'Computer Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L2
  (generate_voter_id(), '2025123', 'NGAMAKOUA NSANDAP ANGE SUNNITA', '24CC6THK', false, '2ème année', 'Software Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025124', 'NGANDJO NGOMEGE JESSICA', 'DK6YGJB5', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L3
  (generate_voter_id(), '2025125', 'NGANDJUI YOSSA KARL DAVE', generate_vote_code(), false, '3ème année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025126', 'NGONO GBANMI SABINE CYNTHIA', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- BUILDING CONSTRUCTION L1
  (generate_voter_id(), '2025127', 'NGOUAH GNEMABE HOUOMTELE AXEL BRYAN', 'S8UYCQH4', false, '1ère année', 'Building Construction', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025128', 'NGUELA NDEMBI SAMIRA THESA SHANICE', '4KPNHXAW', false, '1ère année', 'Accountancy', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025129', 'NIMENI JOVANNY KEVINE', 'D8QJVSU9', false, '1ère année', 'NURSING', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025130', 'NITCHEU POUGOM DOROTHEE CHLOE', '8X3HQV5G', false, 'LP GL', 'Computer Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025131', 'NJAMEN DJAPOM WILHEM ARYOLD', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025132', 'NJI ACHU RAYAN KLIEN', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025133', 'NJITOYAP NJIKAM ARCHANGE DE PHILIPPE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025134', 'NJOCK CESAR BRICE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025135', 'NJOCK HUGUES ALEXANDRE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025136', 'NJOYA AHMED RYAN', 'BZ7T4ZZF', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025137', 'NKEMELO WAMBA DARRYL JUNIOR', '7LZ3YQNA', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025138', 'NKWINKE NKOUENKEU LYVIE', 'PXX4XHUK', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025139', 'NLOMBO ELEPI MARTINE FABRICE', '8ZFFGH4B', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025140', 'NOLACK LOICE INGRID SAAH', 'ZPBSHP2S', false, '1ère année', 'Accountancy', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025141', 'NOUBAYOUO NGANGOM BRUNEL', 'UX83AU6D', false, '1ère année', 'Business Management', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025142', 'NOUBISSI TCHOUAMO PIERRETTE RICHINELLE', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025143', 'NOUBISSI TCHOUAMO PIERETTE R.', '4WNBSQVH', false, 'LP GL', 'Computer Engineering', NOW()),
  
  -- ELECTRICAL ENGINEERING L3
  (generate_voter_id(), '2025144', 'NOUHOU ISSOUFOU', '6FMNEZ9Y', false, '3ème année', 'Electrical Engineering', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025145', 'NWAL A NNOKO ANGE ALAIN', 'YBRWSYP5', false, '1ère année', 'Prepa', NOW()),
  
  -- LEGAL CAREER L1
  (generate_voter_id(), '2025146', 'NZOUAKEU MBOUM ALEXANDRA CLEMENTINE ODETTE SUZAN', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  
  -- LEGAL CAREER L1
  (generate_voter_id(), '2025147', 'NZOUDJA BATEKI GUY KHARIS', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025148', 'OBEN KELLY SMITH AGBOR', 'NZDP7SLP', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025149', 'OKON II URSULE SERENA', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025150', 'OLOU''OU MVONDO SAME KOLLE GIOVANY', 'ZXZ96WYB', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025151', 'OMBIONO MYSTERE EMILE', '3T52X6BS', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025152', 'OUAMBO MATHIEU', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025153', 'OYONO MINLO JOSEPH', '2TP4P4FV', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025154', 'PAMSY LYDIA', 'NHRUEYZX', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- LEGAL CAREER L3
  (generate_voter_id(), '2025155', 'PATIENCE ANNY MANGA', 'FLX3LJAW', false, '3ème année', 'Legal Career', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025156', 'PAUL SIEVERT TANG', 'HSNZZTWA', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025157', 'PEFOURA JAMEL RAMZY', 'LT8YDWJW', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025158', 'PENPEN MBOUEKAM SERGINE LAETICIA', 'EW5EBYSA', false, '1ère année', 'NURSING', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025159', 'PETSOKO MAEL WILFRIED', 'PZEVUSYF', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025160', 'PHARAH MVOGO YTEMBE SERENA PETRA', 'NJREP2R3', false, '1ère année', 'Business Management', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025161', 'PISSEU TAKEDO MARWIN CASSIDY', '8ZA4MDET', false, '1ère année', 'NURSING', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025162', 'POUGOM TCHATCHOUA DOMINIQUE OTHNIEL', 'FEFHMKB2', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- ACCOUNTANCY L1
  (generate_voter_id(), '2025163', 'SADO NANA JONAS SINCLAIR', generate_vote_code(), false, '1ère année', 'Accountancy', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025164', 'SADO NDOLO DENZEL', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025165', 'SASHA KHALEL CHALE MBAGA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L2
  (generate_voter_id(), '2025166', 'SIEWE DJUMENI ELDA PARKER', 'F9LRA98V', false, '2ème année', 'NURSING', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025167', 'SIHNO HOUETO MAGLOIRE ESPOIR KEVIN', 'K6HT56AU', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025168', 'SIMB NAG ARTHUR', '3EZPZREL', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025169', 'SIMO GASTON DARYL', 'HLUHRTZ9', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025170', 'SIMO KAMGANG GABRIELLE NORIA', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025171', 'SOMGUI KARL TERRANCE', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025172', 'SOPPI MBALLA GEORGES CASSANDRA', 'VBNSSP3Y', false, '1ère année', 'NURSING', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025173', 'TABAKOUO BRICE KABREL', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025174', 'TABUE MESSA CELIA SERENA', generate_vote_code(), false, '1ère année', 'Prepa', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025175', 'TAKOU KENGNE MERVEILLE ASHLEY', 'A3YTLEXQ', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025176', 'TAMNO KUATE BRUNEL MISAEL', 'MQSFG6MA', false, '1ère année', 'NURSING', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025177', 'TASHA KONGNSO DAVID KURTIS', '2LKLVEVD', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025178', 'TATCHOU YMTCHI NOEMIE PHARELLE', 'X5GRZCP3', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025179', 'TCHATO NKENYOU YANN', '22CSXSE5', false, '1ère année', 'Business Management', NOW()),
  
  -- COMPUTER AND ELECTRONICS ENGINEERING L1
  (generate_voter_id(), '2025180', 'TCHEUMEN KOUNTCHOU KATHEL ERWIN', 'KPNMYK43', false, '1ère année', 'Computer and Electronics Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025181', 'TCHUINKAM KOM ERICA CHARONE', '6LEBDADE', false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025182', 'TEDJOUONG II CHRISTIAN AURORE', 'VRFSM22Q', false, '1ère année', 'Prepa', NOW()),
  
  -- PHARMACY L1
  (generate_voter_id(), '2025183', 'TENJO MUNOH GRACE BELLE', generate_vote_code(), false, '1ère année', 'PHARMACY', NOW()),
  
  -- BUSINESS MANAGEMENT L2
  (generate_voter_id(), '2025184', 'TIAKO NGAMENI ASHLEY ANYOH', generate_vote_code(), false, '2ème année', 'Business Management', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025185', 'TIENTE GRACIELLA TIPHAINE KENZA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025186', 'TIOMA XAVIER JOHN', 'HTA546ZT', false, '1ère année', 'Business Management', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025187', 'TONFO KEMDJI JEASON', 'GR7649GD', false, '1ère année', 'Prepa', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025188', 'TONYE MANUELLA ANGE OPHELIE', 'CAT3NEZ9', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- PREPA L1
  (generate_voter_id(), '2025189', 'TOWO DE SAMAGA ANGE CHLOE', 'GFXY25ZR', false, '1ère année', 'Prepa', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025190', 'VICTORINE NKOME NDJEM LAFLEURE', 'R8C7VM8F', false, '1ère année', 'Software Engineering', NOW()),
  
  -- ELECTRICAL ENGINEERING L3
  (generate_voter_id(), '2025191', 'WAMBA LATIFA', generate_vote_code(), false, '3ème année', 'Electrical Engineering', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025192', 'WATAT WATAT DYLAN JORDAN', 'NSJMLLSZ', false, '1ère année', 'Business Management', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025193', 'WETIE KELMAN SERIVANT', generate_vote_code(), false, '1ère année', 'Business Management', NOW()),
  
  -- BUILDING CONSTRUCTION L2
  (generate_voter_id(), '2025194', 'WOUAPIT YONKOU MANJIA PRISQUE BETHANY', '3MEB8SBD', false, '2ème année', 'Building Construction', NOW()),
  
  -- PHARMACY L1
  (generate_voter_id(), '2025195', 'YANGA NJOCK JOSE LUIGY', generate_vote_code(), false, '1ère année', 'PHARMACY', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025196', 'YIMEN TCHOUNKE FRANCK STEVE', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025197', 'YONGE NDOME KEREN BILAMA', generate_vote_code(), false, '1ère année', 'NURSING', NOW()),
  
  -- PROJECT MANAGEMENT L3
  (generate_voter_id(), '2025198', 'NATHAN KIMBALLY NGWEN', '7DL3JWQ9', false, '3ème année', 'Project Management', NOW()),
  
  -- PROJECT MANAGEMENT L3
  (generate_voter_id(), '2025199', 'OUMAR MOHAMED', 'VXYMYB3P', false, '3ème année', 'Project Management', NOW()),
  
  -- LEGAL CAREER L3
  (generate_voter_id(), '2025200', 'MOHAMMED SEYO', 'CPBADSN9', false, '3ème année', 'Legal Career', NOW()),
  
  -- LEGAL CAREER L3
  (generate_voter_id(), '2025201', 'LOUANGE EMMANUELLE SANDRA', 'TBY6GDBN', false, '3ème année', 'Legal Career', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025202', 'NANA DJOUNDI YVES-MARCEL', generate_vote_code(), false, '3ème année', 'Computer Engineering', NOW()),
  
  -- COMPUTER ENGINEERING L3
  (generate_voter_id(), '2025203', 'NKWESI TCHUISSEU DITRICH L.', 'X4HL868L', false, '3ème année', 'Computer Engineering', NOW()),
  
  -- LEGAL CAREER L1
  (generate_voter_id(), '2025204', 'MOUHAMED BOURHAN BOGNE', generate_vote_code(), false, '1ère année', 'Legal Career', NOW()),
  
  -- SOFTWARE ENGINEERING L1
  (generate_voter_id(), '2025205', 'MOUKOKO SUZANNE', generate_vote_code(), false, '1ère année', 'Software Engineering', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025206', 'LOBE TAKWA MANDENGUE M.', 'N6Y8XN2B', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025207', 'MAKAMTA ANGE SORAYA', '9FDCFW8H', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025208', 'MOUYEMGA CHRIST SHALOM M.', 'UUK3K9BC', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025209', 'MOYOU FOM CHRYS HARREL', 'LLP89FMC', false, '1ère année', 'NURSING', NOW()),
  
  -- NURSING L1
  (generate_voter_id(), '2025210', 'NDONGO BWELLE MAUDE E.', 'SJQHUGRS', false, '1ère année', 'NURSING', NOW()),
  
  -- BUSINESS MANAGEMENT L1
  (generate_voter_id(), '2025211', 'MONKAM HAROLD BRYAN', 'YK86Z6RV', false, '1ère année', 'Business Management', NOW());

-- ============================================
-- NETTOYER LES FONCTIONS TEMPORAIRES
-- ============================================
DROP FUNCTION IF EXISTS generate_vote_code();
DROP FUNCTION IF EXISTS generate_voter_id();

-- ============================================
-- VÉRIFICATION
-- ============================================
SELECT COUNT(*) as total_voters FROM voters;

SELECT field, COUNT(*) as count 
FROM voters 
GROUP BY field 
ORDER BY field;

SELECT year, COUNT(*) as count 
FROM voters 
GROUP BY year 
ORDER BY year;

SELECT student_id, name, year, field, vote_code 
FROM voters 
ORDER BY student_id 
LIMIT 10;


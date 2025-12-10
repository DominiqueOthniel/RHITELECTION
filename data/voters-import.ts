// Données des votants extraites du PDF "RHIT CA1 2526 EXAMINATIONS HALL.pdf"
// Date: 25/10/2025

export interface VoterImportData {
  name: string
  studentId: string // Généré automatiquement si non fourni
  year: string // Année d'études
  field: string // Filière
}

export const votersData: VoterImportData[] = [
  // COMPUTER AND ELECTRONICS ENGINEERING 1
  { name: 'AKAMA HARRY NEBA', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'ALIATH ORLAMIDE', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'AYAKEY AMARANTA MEREDITH', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'BEBEY EBOLO PIERRE HELTON', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'BUZUAH STELMON-LYDIA NGENDAP', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'CHEUDIOU MANSSA JAMES CABREL', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'CIELENOU LOMA HELENE GLORIA', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'DJEUMO JUNIOR ETHAN OJANI', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'DOUALLA DIBIE YANN WILFRIED', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'ENTCHEU STEVE GEOVANNI', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'FOKOUA KENNE FRANCK', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'HAPPI TCHOKONTE PAULE M.', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'HENDEL EMMANUEL LEVY', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'IBRAHIM TOUKOUR', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'KEMDIB TCHAKOUNTIO EMMANUEL', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'KOUNG A BITANG DAVID IGOR', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'KPOUMIE LINA MARIAM', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'MAPTUE FOTSO LAURE MORGAN', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'MASSO MANDENG CINDY NOELLE', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'MBAKOP FAVOUR BRANDY', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'MPANJO LOBE MARC STEPHANE', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'MUMA RYAN WENTEH', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'NANA GILBERT JUNIOR PETTANG', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'NDEFFO FOTIE DURICK ORLIAN', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'NJOYA AHMED RYAN', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'NLOMBO ELEPI MARTINE FABRICE', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'OBEN KELLY SMITH AGBOR', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'OMBIONO MYSTERE EMILE', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'PAMSY LYDIA', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'PAUL SIEVERT TANG', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'SIHNO HOVETO MAGLOIRE E.', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'SIMB NAG ARTHUR', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'SIMO GASTON DARYL', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'TAKOU KENGNE MERVEILLE A.', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'TATCHOU YMTCHI NOEMIE P.', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'TCHEUMEN KOUNTCHOU KATHEL', year: '1ère année', field: 'Computer and Electronics Engineering' },
  { name: 'VICTORINE NKOME NDJEM L.', year: '1ère année', field: 'Computer and Electronics Engineering' },

  // CIVIL ENGINEERING 1
  { name: 'DOUALA BWEGNE OLIVIA SHELSY', year: '1ère année', field: 'Civil Engineering' },
  { name: 'LATIFAH DALIL', year: '1ère année', field: 'Civil Engineering' },
  { name: 'NGOUAH GNEMABE HOUOMTELE', year: '1ère année', field: 'Civil Engineering' },

  // ACCOUNTANCY 1
  { name: 'AISHATOU SALI YASMINE Y.', year: '1ère année', field: 'Accountancy' },
  { name: 'ALEXANDER ONUHA FRANKLIN N.', year: '1ère année', field: 'Accountancy' },
  { name: 'FEUTSEU NEGUEM ALBIN BALDES', year: '1ère année', field: 'Accountancy' },
  { name: 'IBRAHIM OUMAROU DAH', year: '1ère année', field: 'Accountancy' },
  { name: 'IMRANE IMRANE', year: '1ère année', field: 'Accountancy' },
  { name: 'L\'KENFACK JOHN KENDRICK', year: '1ère année', field: 'Accountancy' },
  { name: 'MONKAM HAROLD BRYAN', year: '1ère année', field: 'Accountancy' },
  { name: 'NGUELA NDEMBI SAMIRA THESA S.', year: '1ère année', field: 'Accountancy' },
  { name: 'NOLACK LOICE INGRID SAAH', year: '1ère année', field: 'Accountancy' },

  // BUSINESS/PROJECT MANAGEMENT 1
  { name: 'AISSATOU NOURIATOU HAMADOU', year: '1ère année', field: 'Business/Project Management' },
  { name: 'ALVINE GRACE MESSINA DANIELLE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'ATSAMO IMANIE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'BEBEY GILLES HARRY', year: '1ère année', field: 'Business/Project Management' },
  { name: 'EDDY ANTOINE DAVID TOUTOU D.', year: '1ère année', field: 'Business/Project Management' },
  { name: 'FALMATA MAMAT', year: '1ère année', field: 'Business/Project Management' },
  { name: 'FATIA ALAGBALA OMOLARA', year: '1ère année', field: 'Business/Project Management' },
  { name: 'FONGANG RODNEY SHARLEY', year: '1ère année', field: 'Business/Project Management' },
  { name: 'KAMDEM KOUAM DANIEL', year: '1ère année', field: 'Business/Project Management' },
  { name: 'KAMGNA JASON MARC AUREL', year: '1ère année', field: 'Business/Project Management' },
  { name: 'KEMAYOU NGATCHOU ASHLEY P.', year: '1ère année', field: 'Business/Project Management' },
  { name: 'KENDRA MBITA NANA FOUMO K.', year: '1ère année', field: 'Business/Project Management' },
  { name: 'KENGNE KAMOGNE GLORY H.', year: '1ère année', field: 'Business/Project Management' },
  { name: 'KHADIDJA ADOUM MAHAMAT', year: '1ère année', field: 'Business/Project Management' },
  { name: 'LEILA KAWAS ISSA OUMAROU', year: '1ère année', field: 'Business/Project Management' },
  { name: 'L\'KENFACK MIKE TOMMY', year: '1ère année', field: 'Business/Project Management' },
  { name: 'MARCELINE ANIETIE ANGE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'MVONDO NSANGOU BEN HERVE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'NDZINGA NGOUMOU ARIEL B.', year: '1ère année', field: 'Business/Project Management' },
  { name: 'NGABA TCHOUAMEN ANDRE D.', year: '1ère année', field: 'Business/Project Management' },
  { name: 'NGANDJO NGOMEGE JESSICA', year: '1ère année', field: 'Business/Project Management' },
  { name: 'NGANDJUI YOSSA KARL DAVE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'NKEMELO WAMBA DARRYL JUNIOR', year: '1ère année', field: 'Business/Project Management' },
  { name: 'NKWINKE NKOUENKEU LYVIE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'NOUBAYOUO NGANGOM BRUNEL', year: '1ère année', field: 'Business/Project Management' },
  { name: 'OLOU\'OU MVONDO SAME KOLLE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'OYONO MINLO JOSEPH', year: '1ère année', field: 'Business/Project Management' },
  { name: 'PETSOKO MAEL WILFRIED', year: '1ère année', field: 'Business/Project Management' },
  { name: 'PHARAH MVOGO YTEMBE SERENA', year: '1ère année', field: 'Business/Project Management' },
  { name: 'SOSSO KINGUE ALAIN STEVE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'TASHA KONGNSO DAVID KURTIS', year: '1ère année', field: 'Business/Project Management' },
  { name: 'TCHATO NKENYOU YANN', year: '1ère année', field: 'Business/Project Management' },
  { name: 'TCHUINKAM KOM ERICA CHARONE', year: '1ère année', field: 'Business/Project Management' },
  { name: 'TIOMA XAVIER JOHN', year: '1ère année', field: 'Business/Project Management' },
  { name: 'TOWO DE SAMAGA ANGE CHLOE', year: '1ère année', field: 'Business/Project Management' },

  // NURSING 1
  { name: 'ABDOULAYE ABDOULAYE', year: '1ère année', field: 'Nursing' },
  { name: 'ADAMOU ABDOULAYE', year: '1ère année', field: 'Nursing' },
  { name: 'ALI MOHAMED', year: '1ère année', field: 'Nursing' },
  { name: 'BALLA MARTINE', year: '1ère année', field: 'Nursing' },
  { name: 'BOUBA ABDOULAYE', year: '1ère année', field: 'Nursing' },
  { name: 'DANIELA TCHUENDEU', year: '1ère année', field: 'Nursing' },
  { name: 'DJAMILA ABDOULAYE', year: '1ère année', field: 'Nursing' },
  { name: 'EYENGA SASSOM CHRISTY M.', year: '1ère année', field: 'Nursing' },
  { name: 'EYOMBWE MOUNA NGANGUE J.', year: '1ère année', field: 'Nursing' },
  { name: 'FEUPA NYAMSI JACK IVAN', year: '1ère année', field: 'Nursing' },
  { name: 'FOUDA NGOMO MAXIME ROGER', year: '1ère année', field: 'Nursing' },
  { name: 'GLORY TINA EVELYNE CASSANDRA', year: '1ère année', field: 'Nursing' },
  { name: 'GONGANG TCHANA GLORY GILLES', year: '1ère année', field: 'Nursing' },
  { name: 'HAPPI ANASTASIE CHLOE', year: '1ère année', field: 'Nursing' },
  { name: 'HARRY CHRISTOPHER CLAUDE N.', year: '1ère année', field: 'Nursing' },
  { name: 'KAMYUM SOKOUDJOU STEPHANE', year: '1ère année', field: 'Nursing' },
  { name: 'KWAPNANG HAPPI CHARLINE P.', year: '1ère année', field: 'Nursing' },
  { name: 'LOBE TAKWA MANDENGUE M.', year: '1ère année', field: 'Nursing' },
  { name: 'MAKAMTA ANGE SORAYA', year: '1ère année', field: 'Nursing' },
  { name: 'MBA COEURTISSE NOEL', year: '1ère année', field: 'Nursing' },
  { name: 'MBARGA KIE ALLAN THIBAUT', year: '1ère année', field: 'Nursing' },
  { name: 'MBATCHOU MEGHUS SHALOM C.', year: '1ère année', field: 'Nursing' },
  { name: 'MBEI NJE JOHANES CHRIST PATTY', year: '1ère année', field: 'Nursing' },
  { name: 'MBIADA KAREL DAPHNE', year: '1ère année', field: 'Nursing' },
  { name: 'MOUYEMGA CHRIST SHALOM M.', year: '1ère année', field: 'Nursing' },
  { name: 'MOYOU FOM CHRYS HARREL', year: '1ère année', field: 'Nursing' },
  { name: 'NDONGO BWELLE MAUDE E.', year: '1ère année', field: 'Nursing' },
  { name: 'NIMENI JOVANNY KEVINE', year: '1ère année', field: 'Nursing' },
  { name: 'NWAL A NNOXO ANGE ALAIN', year: '1ère année', field: 'Nursing' },
  { name: 'PEFOURA JAMEL', year: '1ère année', field: 'Nursing' },
  { name: 'PENPEN MBOUEKAM SERGINE L.', year: '1ère année', field: 'Nursing' },
  { name: 'PISSEU TAKEDO MARWIN CASSIDY', year: '1ère année', field: 'Nursing' },
  { name: 'SOPPI MBALLA GEORGES C.', year: '1ère année', field: 'Nursing' },
  { name: 'TAMNO KUATE BRUNEL MISAEL', year: '1ère année', field: 'Nursing' },
  { name: 'TEDJOUONG II CHRISTIAN AURORE', year: '1ère année', field: 'Nursing' },
  { name: 'TONFO KEMDJI JEASON', year: '1ère année', field: 'Nursing' },

  // COMPUTER AND ELECTRONICS ENGINEERING 2
  { name: 'KANJE CHARLES TCHUNDENU J.', year: '2ème année', field: 'Computer and Electronics Engineering' },
  { name: 'NGAMAKOUA NSANDAP ANGE S.', year: '2ème année', field: 'Computer and Electronics Engineering' },

  // CIVIL ENGINEERING 2
  { name: 'DJEUMO RUSSEL VEDRYL', year: '2ème année', field: 'Civil Engineering' },
  { name: 'INACK ISIS DAPHNEE', year: '2ème année', field: 'Civil Engineering' },
  { name: 'WOUAPIT YONKOU MANJIA P.', year: '2ème année', field: 'Civil Engineering' },

  // PREPA 2
  { name: 'DEFFO NGOUNOU STECY INA P.', year: '2ème année', field: 'Prépa' },
  { name: 'JOYCE KIMBERLEY EYIKE', year: '2ème année', field: 'Prépa' },
  { name: 'KOUMTOUZOUA KANNENG RYAN H.', year: '2ème année', field: 'Prépa' },
  { name: 'MANDJOMBE MOUYENGA G.', year: '2ème année', field: 'Prépa' },
  { name: 'MANFOUO ABO GRACE DAVILLA', year: '2ème année', field: 'Prépa' },

  // BUSINESS MANAGEMENT 2
  { name: 'BEYHIA LEONARD-BRUCE', year: '2ème année', field: 'Business Management' },
  { name: 'CLARKE NIYABI ANNE-MARIE', year: '2ème année', field: 'Business Management' },
  { name: 'FRITZ HONORE ALLISON ELAME NGANGUE', year: '2ème année', field: 'Business Management' },
  { name: 'IGEDI AFSAT ASHAKE DIMODI', year: '2ème année', field: 'Business Management' },
  { name: 'KIDJOCK NWALL DANIEL', year: '2ème année', field: 'Business Management' },
  { name: 'MAHAMAT SALLET KAYA', year: '2ème année', field: 'Business Management' },
  { name: 'NAMBANG DARELLE', year: '2ème année', field: 'Business Management' },

  // NURSING 2
  { name: 'EWODI NGASSE MADELEINE DEO', year: '2ème année', field: 'Nursing' },
  { name: 'JAGNI JIODA GOULA CHRIST', year: '2ème année', field: 'Nursing' },
  { name: 'SIEWE DJUMENI ELDA PARKER', year: '2ème année', field: 'Nursing' },

  // PROJECT MANAGEMENT 3 AND TOP-UP
  { name: 'NATHAN KIMBALLY NGWEN', year: '3ème année', field: 'Project Management' },
  { name: 'OUMAR MOHAMED', year: '3ème année', field: 'Project Management' },
  { name: 'LUMMAH NELLY GUDMIA', year: 'Top-Up', field: 'Project Management' },

  // COMPUTER AND ELECTRONICS ENGINEERING 3
  { name: 'CAMBAY YVES', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'FOTSO TEGUEO KENNY FRED', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'KUOH BEKOMBO-KUOH YVAN', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'LENGONO ELOUNDOU MARIETTE L.', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'LORENZO EBOA', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'MATJABI PAULINE ROMAINE', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'NDIOMO EVINI JEAN-BOSCO D.', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'NKWESI TCHUISSEU DITRICH L.', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'POUGOM TCHATCHOUA DOMINIQUE OTHNIEL', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'TONYE MANUELLA ANGE OPHELIE', year: '3ème année', field: 'Computer and Electronics Engineering' },
  { name: 'DIKELEL LEONCE AXEL', year: 'LP GL', field: 'Computer and Electronics Engineering' },
  { name: 'NITCHEU POUGOM DOROTHEE C.', year: 'LP GL', field: 'Computer and Electronics Engineering' },
  { name: 'NOUBISSI TCHOUAMO PIERETTE R.', year: 'LP GL', field: 'Computer and Electronics Engineering' },

  // LEGAL CAREER 3
  { name: 'HAOUA HAIFA ABDOUL AZIZ', year: '3ème année', field: 'Legal Career' },
  { name: 'LOUANGE EMMANUELLE', year: '3ème année', field: 'Legal Career' },
  { name: 'MOHAMMED SEYO', year: '3ème année', field: 'Legal Career' },
  { name: 'PATIENCE ANNY MANGA', year: '3ème année', field: 'Legal Career' },

  // ELECTRICAL ENGINEERING 3
  { name: 'NOUHOU ISSOUFOU', year: '3ème année', field: 'Electrical Engineering' },
]

// Fonction pour générer un ID étudiant unique basé sur l'index
export function generateStudentId(index: number): string {
  const year = new Date().getFullYear()
  return `${year}${String(index + 1).padStart(4, '0')}`
}


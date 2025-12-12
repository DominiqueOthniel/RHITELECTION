# ANALYSE DES ÉTUDIANTS MANQUANTS

## Situation actuelle:
- Base actuelle: 155 étudiants
- PDF: 225 étudiants  
- Manquants attendus: 70 étudiants (225 - 155 = 70)
- Ajoutés dans le script initial: 71 étudiants
- Doublons identifiés et retirés: 7 étudiants
- **Étudiants valides dans le script: 64 étudiants**
- **Il manque encore 6 étudiants** (70 - 64 = 6)

## Doublons identifiés et retirés (7):
1. ALAIN STEVE SOSSO KINGUE (2025158) - déjà "SOSSO KINGUE ALAIN STEVE"
2. ALEXANDER ONUHA FRANKLIN NICK (2025159) - déjà "ALEXANDER ONUHA FRANKLIN N."
3. EDDY ANTOINE DAVID TOUTOU DIDI BISSA (2025173) - déjà "EDDY ANTOINE DAVID TOUTOU D."
4. SIHNO HOUETO MAGLOIRE ESPOIR KEVIN (2025212) - déjà "SIHNO HOVETO MAGLOIRE E."
5. VICTORINE NKOME NDJEM LAFLEURE (2025220) - déjà "VICTORINE NKOME NDJEM L."
6. LENGONO ELOUNDOU MARIETTE LARISSA (2025193) - déjà "LENGONO ELOUNDOU MARIETTE L."
7. WATAT WATAT DYLAN JORDAN (2025222) - déjà "WATAT WA..."

## Pour trouver les 6 étudiants manquants:
Il faut comparer systématiquement chaque nom du PDF avec ceux dans import-voters-from-exam-list.sql.

Les étudiants du PDF qui pourraient être manquants (noms complets vs abrégés dans la base):
- AYAKEY AMARANTA MEREDITH NDIM (PDF) vs AYAKEY AMARANTA MEREDITH (base) - probablement le même
- FOKOUA KENNE FRANCK WILFRIED (PDF) vs FOKOUA KENNE FRANCK (base) - probablement le même
- HAPPI TCHOKONTE PAULE MARTIALE (PDF) vs HAPPI TCHOKONTE PAULE M. (base) - probablement le même
- KEMDIB TCHAKOUNTIO EMMANUEL JUNIOR (PDF) vs KEMDIB TCHAKOUNTIO EMMANUEL (base) - probablement le même
- TAKOU KENGNE MERVEILLE ASHLEY (PDF) vs TAKOU KENGNE MERVEILLE A. (base) - probablement le même
- TATCHOU YMTCHI NOEMIE PHARELLE (PDF) vs TATCHOU YMTCHI NOEMIE P. (base) - probablement le même
- TCHEUMEN KOUNTCHOU KATHEL ERWIN (PDF) vs TCHEUMEN KOUNTCHOU KATHEL (base) - probablement le même

Ces étudiants sont probablement les mêmes avec des noms complets vs abrégés.

## Étudiants vraiment différents à chercher:
Il faut chercher dans le PDF les étudiants qui ont des noms complètement différents de ceux dans la base, pas juste des variantes d'abréviation.


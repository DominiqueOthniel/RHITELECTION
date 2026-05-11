# LES 6 ÉTUDIANTS MANQUANTS À IDENTIFIER

## Situation:
- Base actuelle: 155 étudiants
- PDF: 225 étudiants
- Manquants attendus: 70 étudiants
- Ajoutés dans le script: 64 étudiants (après retrait de 7 doublons)
- **Il manque encore 6 étudiants**

## Méthode pour trouver les 6 étudiants manquants:

1. **Extraire tous les noms du PDF** "Copy of Student_Info_(3)(1).pdf"
2. **Extraire tous les noms de la base** (import-voters-from-exam-list.sql)
3. **Comparer systématiquement** chaque nom du PDF avec ceux de la base
4. **Identifier les 6 étudiants** qui sont dans le PDF mais pas dans la base

## Étudiants à vérifier (noms complets vs abrégés - probablement les mêmes):
- PEFOURA JAMEL RAMZY (PDF) vs PEFOURA JAMEL (base) - probablement le même
- INACK NKEGA ISIS DAPHNEE (PDF) vs INACK ISIS DAPHNEE (base) - probablement le même
- AYAKEY AMARANTA MEREDITH NDIM (PDF) vs AYAKEY AMARANTA MEREDITH (base) - probablement le même
- FOKOUA KENNE FRANCK WILFRIED (PDF) vs FOKOUA KENNE FRANCK (base) - probablement le même

## Pour trouver les 6 vraiment manquants:
Il faut comparer manuellement chaque ligne du PDF avec la base pour identifier les étudiants qui ont des noms complètement différents, pas juste des variantes d'abréviation.

**Recommandation:** Utiliser un script Python ou Excel pour comparer automatiquement les deux listes et identifier les différences.


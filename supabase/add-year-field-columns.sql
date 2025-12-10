-- ============================================
-- AJOUTER LES COLONNES YEAR ET FIELD À LA TABLE VOTERS
-- ============================================
-- Ce script ajoute les colonnes year (année d'études) et field (filière) à la table voters

ALTER TABLE voters 
ADD COLUMN IF NOT EXISTS year VARCHAR(255);

ALTER TABLE voters 
ADD COLUMN IF NOT EXISTS field VARCHAR(255);

-- Vérification
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'voters' 
  AND column_name IN ('year', 'field')
ORDER BY column_name;


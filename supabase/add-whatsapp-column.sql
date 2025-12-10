-- ============================================
-- AJOUTER LA COLONNE WHATSAPP À LA TABLE VOTERS
-- ============================================
-- Ce script ajoute la colonne whatsapp à la table voters existante

ALTER TABLE voters 
ADD COLUMN IF NOT EXISTS whatsapp VARCHAR(255);

-- Vérification
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'voters' AND column_name = 'whatsapp';


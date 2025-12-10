-- ============================================
-- SUPPRIMER LES COLONNES EMAIL ET WHATSAPP DE LA TABLE VOTERS
-- ============================================
-- Ce script supprime les colonnes email et whatsapp de la table voters
-- car elles ne sont plus utilisées lors de la création de votants

-- Étape 1: Rendre la colonne email nullable (si elle ne l'est pas déjà)
ALTER TABLE voters 
ALTER COLUMN email DROP NOT NULL;

-- Étape 2: Supprimer la colonne email
ALTER TABLE voters 
DROP COLUMN IF EXISTS email;

-- Étape 3: Supprimer la colonne whatsapp
ALTER TABLE voters 
DROP COLUMN IF EXISTS whatsapp;

-- Vérification: Afficher la structure de la table après modification
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'voters'
ORDER BY ordinal_position;


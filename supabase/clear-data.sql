-- ============================================
-- SCRIPT POUR SUPPRIMER TOUTES LES DONNÉES
-- ============================================
-- ATTENTION: Ce script supprime TOUTES les données des tables
-- Utilisez avec précaution !

-- Supprimer tous les votes (doit être fait en premier à cause des foreign keys)
DELETE FROM votes;

-- Supprimer tous les codes de voteurs
DELETE FROM voter_codes;

-- Supprimer tous les candidats
DELETE FROM candidates;

-- Optionnel: Réinitialiser les séquences si vous utilisez des séquences
-- (Non nécessaire avec UUID)

-- Vérification: Afficher le nombre de lignes restantes
SELECT 
  (SELECT COUNT(*) FROM candidates) as candidates_count,
  (SELECT COUNT(*) FROM voter_codes) as voter_codes_count,
  (SELECT COUNT(*) FROM votes) as votes_count;


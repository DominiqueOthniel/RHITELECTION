-- ============================================
-- AJOUT DE LA FONCTIONNALITÉ DE VOTES AUTOMATIQUES
-- ============================================

-- 1. Ajouter la colonne is_automatic à la table votes
ALTER TABLE votes 
ADD COLUMN IF NOT EXISTS is_automatic BOOLEAN DEFAULT false;

-- 2. Créer une table pour stocker la configuration des votes automatiques
CREATE TABLE IF NOT EXISTS auto_vote_config (
  id VARCHAR(255) PRIMARY KEY DEFAULT 'config-001',
  target_candidate_id VARCHAR(255) REFERENCES candidates(id) ON DELETE SET NULL,
  auto_vote_count INTEGER DEFAULT 5,
  current_auto_votes INTEGER DEFAULT 0,
  is_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Insérer une configuration par défaut (désactivée)
INSERT INTO auto_vote_config (id, is_enabled, auto_vote_count, current_auto_votes)
VALUES ('config-001', false, 5, 0)
ON CONFLICT (id) DO NOTHING;

-- 4. Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_votes_is_automatic ON votes(is_automatic);
CREATE INDEX IF NOT EXISTS idx_auto_vote_config_is_enabled ON auto_vote_config(is_enabled);

-- 5. Fonction pour réinitialiser le compteur de votes automatiques
CREATE OR REPLACE FUNCTION reset_auto_vote_counter()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE auto_vote_config
  SET current_auto_votes = 0
  WHERE id = 'config-001';
END;
$$;


-- ============================================
-- SYSTÈME D'AUTHENTIFICATION ADMIN
-- ============================================

-- Table pour les utilisateurs administrateurs
CREATE TABLE IF NOT EXISTS admin_users (
  id VARCHAR(255) PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_login TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true
);

-- Index pour la recherche par username
CREATE INDEX IF NOT EXISTS idx_admin_users_username ON admin_users(username);
CREATE INDEX IF NOT EXISTS idx_admin_users_is_active ON admin_users(is_active);

-- Activer RLS sur la table admin_users
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Politique : Seuls les admins authentifiés peuvent voir les autres admins
CREATE POLICY "Admin users are viewable by authenticated admins"
  ON admin_users FOR SELECT
  USING (true); -- À ajuster selon votre système d'authentification

-- Politique : Seuls les admins peuvent insérer de nouveaux admins
CREATE POLICY "Admin users can be inserted by admins"
  ON admin_users FOR INSERT
  WITH CHECK (true); -- À ajuster selon votre système d'authentification

-- Politique : Seuls les admins peuvent mettre à jour les admins
CREATE POLICY "Admin users can be updated by admins"
  ON admin_users FOR UPDATE
  USING (true); -- À ajuster selon votre système d'authentification

-- Fonction pour vérifier les identifiants admin
CREATE OR REPLACE FUNCTION verify_admin_credentials(
  p_username VARCHAR(255),
  p_password_hash VARCHAR(255)
)
RETURNS TABLE (
  id VARCHAR(255),
  username VARCHAR(255),
  email VARCHAR(255),
  is_active BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    au.id,
    au.username,
    au.email,
    au.is_active
  FROM admin_users au
  WHERE au.username = p_username
    AND au.password_hash = p_password_hash
    AND au.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour mettre à jour la dernière connexion
CREATE OR REPLACE FUNCTION update_admin_last_login(
  p_admin_id VARCHAR(255)
)
RETURNS VOID AS $$
BEGIN
  UPDATE admin_users
  SET last_login = NOW()
  WHERE id = p_admin_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- CRÉER UN ADMIN PAR DÉFAUT
-- ============================================
-- IMPORTANT: Changez le mot de passe après la création !
-- Le hash ci-dessous correspond à "admin123" (utilisez bcrypt ou un autre hash sécurisé)
-- Pour générer un nouveau hash, utilisez un outil en ligne ou une bibliothèque de hachage

-- Exemple d'insertion d'un admin par défaut
-- REMPLACEZ 'votre-hash-de-mot-de-passe' par un hash sécurisé de votre mot de passe
-- Vous pouvez utiliser bcrypt ou SHA-256 pour hasher votre mot de passe

-- Note: L'admin par défaut sera créé avec le script create-admin.sql
-- Exécutez ce script séparément après avoir créé la table

-- Note: Pour générer un hash de mot de passe sécurisé, vous pouvez utiliser:
-- - En ligne: https://bcrypt-generator.com/
-- - En Node.js: const bcrypt = require('bcrypt'); bcrypt.hash('votre-mot-de-passe', 10)
-- - En Python: import bcrypt; bcrypt.hashpw(b'votre-mot-de-passe', bcrypt.gensalt())


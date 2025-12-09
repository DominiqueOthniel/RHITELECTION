-- ============================================
-- CRÉER UN ADMIN PAR DÉFAUT
-- ============================================
-- Ce script crée un utilisateur admin par défaut
-- Mot de passe: RHIT2025VOTE

-- Le hash SHA-256 ci-dessous correspond à "RHIT2025VOTE"
-- Pour générer un nouveau hash, utilisez: https://emn178.github.io/online-tools/sha256.html
-- Ou en ligne de commande: echo -n "votre-mot-de-passe" | sha256sum

INSERT INTO admin_users (id, username, password_hash, email, is_active)
VALUES (
  'admin-001',
  'admin',
  'd5a681e79581137bf0e0e2021369450dea2a5de7758fd9e9361908a1850a0bfc', -- SHA-256 de "RHIT2025VOTE"
  'admin@rhit.com',
  true
)
ON CONFLICT (username) DO UPDATE
SET 
  password_hash = EXCLUDED.password_hash,
  is_active = true;

-- Vérification
SELECT 
  id,
  username,
  email,
  is_active,
  created_at
FROM admin_users
WHERE username = 'admin';



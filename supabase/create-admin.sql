-- ============================================
-- CRÉER UN ADMIN PAR DÉFAUT
-- ============================================
-- Ce script crée un utilisateur admin par défaut
-- IMPORTANT: Changez le mot de passe après la création !

-- Le hash SHA-256 ci-dessous correspond à "admin123"
-- Pour générer un nouveau hash, utilisez: https://emn178.github.io/online-tools/sha256.html
-- Ou en ligne de commande: echo -n "votre-mot-de-passe" | sha256sum

INSERT INTO admin_users (id, username, password_hash, email, is_active)
VALUES (
  'admin-001',
  'admin',
  '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- SHA-256 de "admin123"
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



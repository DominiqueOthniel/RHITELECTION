-- ============================================
-- CRÉER UN ADMIN PAR DÉFAUT
-- ============================================
-- Ce script crée un utilisateur admin par défaut
-- Mot de passe: admin246

-- Le hash SHA-256 ci-dessous correspond à "admin246"
-- Pour générer un nouveau hash, utilisez: https://emn178.github.io/online-tools/sha256.html
-- Ou en ligne de commande PowerShell: [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes('admin246'))).Replace('-', '').ToLower()

INSERT INTO admin_users (id, username, password_hash, email, is_active)
VALUES (
  'admin-001',
  'admin',
  '8b30d4c4f4dcc44187ce3b75d7f29d06dcae0499b2780041653be937c86b2654', -- SHA-256 de "admin246"
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



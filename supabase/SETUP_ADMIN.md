# Configuration du système d'authentification admin

## Instructions d'installation

### Étape 1 : Créer la table et les fonctions

1. Allez dans votre projet Supabase → **SQL Editor**
2. Copiez et exécutez **TOUT le contenu** du fichier `supabase/admin-auth.sql`
3. Vérifiez que la table `admin_users` a été créée :
   ```sql
   SELECT * FROM admin_users;
   ```

### Étape 2 : Créer un admin par défaut

1. Dans le même SQL Editor de Supabase
2. Copiez et exécutez **TOUT le contenu** du fichier `supabase/create-admin.sql`
3. Vérifiez que l'admin a été créé :
   ```sql
   SELECT username, email, is_active FROM admin_users WHERE username = 'admin';
   ```

### Étape 3 : Tester la connexion

1. Allez sur `/login` dans votre application
2. Connectez-vous avec :
   - **Username** : `admin`
   - **Password** : `admin123`

## Créer un nouvel admin

Pour créer un nouvel admin avec un mot de passe personnalisé :

1. Générez un hash SHA-256 de votre mot de passe :
   - Allez sur : https://emn178.github.io/online-tools/sha256.html
   - Entrez votre mot de passe
   - Copiez le hash généré

2. Exécutez dans Supabase SQL Editor :
```sql
INSERT INTO admin_users (id, username, password_hash, email, is_active)
VALUES (
  'admin-002',  -- Changez l'ID
  'votre-username',
  'votre-hash-sha256-ici',  -- Collez le hash généré
  'votre-email@example.com',
  true
);
```

## Changer le mot de passe d'un admin existant

1. Générez un hash SHA-256 du nouveau mot de passe
2. Exécutez :
```sql
UPDATE admin_users 
SET password_hash = 'nouveau-hash-sha256-ici'
WHERE username = 'admin';
```

## Désactiver un admin

```sql
UPDATE admin_users 
SET is_active = false
WHERE username = 'admin';
```


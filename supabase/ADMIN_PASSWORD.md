# Mot de passe administrateur

## Informations de connexion

- **URL de connexion** : `/login`
- **Nom d'utilisateur** : `admin`
- **Mot de passe** : `RHIT2025VOTE`

## Important

⚠️ **Le mot de passe est TOUJOURS requis pour accéder à la page admin.**

La page `/admin` vérifie automatiquement l'authentification :
- Au chargement de la page
- Toutes les 30 secondes
- Quand la fenêtre redevient visible

Si vous n'êtes pas authentifié, vous serez automatiquement redirigé vers la page de connexion.

## Changer le mot de passe

Pour changer le mot de passe de l'admin :

1. Générez un hash SHA-256 du nouveau mot de passe :
   - Allez sur : https://emn178.github.io/online-tools/sha256.html
   - Entrez votre nouveau mot de passe
   - Copiez le hash généré

2. Exécutez dans Supabase SQL Editor :
```sql
UPDATE admin_users 
SET password_hash = 'votre-nouveau-hash-sha256-ici'
WHERE username = 'admin';
```

## Sécurité

- Le mot de passe est stocké sous forme de hash SHA-256 dans la base de données
- L'authentification est vérifiée à chaque accès à la page admin
- La session expire quand l'onglet est fermé (sessionStorage)


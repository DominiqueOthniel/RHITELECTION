# Améliorations de Sécurité - Expiration des Codes de Vote

## Résumé des modifications

Ce document décrit les améliorations apportées pour garantir qu'un code de vote expire automatiquement après une utilisation unique.

## Modifications apportées

### 1. Validation côté serveur renforcée (`lib/supabase-helpers.ts`)

La fonction `syncVoteToSupabase()` a été améliorée pour effectuer plusieurs vérifications avant d'enregistrer un vote :

- ✅ **Vérification de l'existence du code** : Vérifie que le code existe dans la table `voters`
- ✅ **Vérification du statut de vote** : Vérifie que `has_voted` est `false`
- ✅ **Vérification des doublons** : Vérifie qu'aucun vote n'existe déjà avec ce code pour cette élection
- ✅ **Vérification du candidat** : Vérifie que le candidat existe
- ✅ **Mise à jour automatique** : Met à jour `has_voted` à `true` après un vote réussi

### 2. Gestion des erreurs améliorée (`app/vote/page.tsx`)

La fonction `handleVote()` a été améliorée pour :

- ✅ Vérifier une dernière fois que le code n'a pas déjà voté avant d'enregistrer
- ✅ Gérer les erreurs retournées par le serveur
- ✅ Afficher des messages d'erreur clairs à l'utilisateur
- ✅ Réinitialiser l'authentification en cas d'erreur

### 3. Retour de résultat (`lib/voteStore.ts`)

La fonction `addVote()` retourne maintenant le résultat de l'opération :

- ✅ Retourne `{ success: boolean, error?: any }`
- ✅ N'ajoute le vote localement que si l'opération serveur a réussi
- ✅ Permet à l'interface de gérer les erreurs appropriément

### 4. Script SQL de renforcement (`supabase/enforce-vote-code-expiration.sql`)

Un script SQL a été créé pour :

- ✅ Vérifier/ajouter la contrainte UNIQUE sur `(voter_code, election_id)`
- ✅ Créer une fonction de validation `validate_and_mark_vote_code()`
- ✅ Créer un trigger automatique pour marquer les codes comme utilisés
- ✅ Créer des index pour améliorer les performances
- ✅ Créer une vue pour visualiser les codes expirés

## Protection contre les attaques

### ✅ Protection contre les votes multiples

1. **Contrainte UNIQUE en base de données** : Empêche l'insertion de votes en double
2. **Vérification avant insertion** : Vérifie que le code n'a pas déjà voté
3. **Mise à jour atomique** : Le vote et la mise à jour de `has_voted` sont synchronisés

### ✅ Protection contre la manipulation côté client

1. **Validation serveur obligatoire** : Toutes les vérifications sont faites côté serveur
2. **Vérification du statut** : Le serveur vérifie toujours `has_voted` avant d'accepter un vote
3. **Contrainte de base de données** : Même si le code client est contourné, la base de données bloque les doublons

## Utilisation

### Pour appliquer les améliorations SQL

Exécutez le script dans l'éditeur SQL de Supabase :

```sql
-- Exécuter le contenu de supabase/enforce-vote-code-expiration.sql
```

### Comportement attendu

1. **Premier vote avec un code** : ✅ Succès, le code est marqué comme utilisé
2. **Tentative de réutilisation du code** : ❌ Erreur "Ce code a déjà été utilisé pour voter"
3. **Code invalide** : ❌ Erreur "Code de vote invalide"
4. **Candidat invalide** : ❌ Erreur "Candidat invalide"

## Tests recommandés

1. ✅ Voter avec un code valide → doit réussir
2. ✅ Réessayer de voter avec le même code → doit échouer
3. ✅ Vérifier que `has_voted` est bien mis à `true` dans la table `voters`
4. ✅ Vérifier qu'un vote existe dans la table `votes`
5. ✅ Tenter d'insérer manuellement un vote en double → doit échouer (contrainte UNIQUE)

## Notes importantes

- Les codes expirent **automatiquement** après utilisation
- Un code ne peut être utilisé qu'**une seule fois par élection**
- La validation est effectuée **côté serveur** pour garantir la sécurité
- Les erreurs sont **propagées** à l'interface utilisateur pour un feedback clair


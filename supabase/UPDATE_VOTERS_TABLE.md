# Mise à jour : Ajout de la table Voters

## Problème résolu

Les votants créés sur un appareil n'apparaissaient pas sur un autre appareil car ils n'étaient pas synchronisés avec Supabase.

## Solution

Une nouvelle table `voters` a été créée dans Supabase pour stocker les informations complètes des votants (nom, email, studentId, code de vote, etc.).

## Instructions

### 1. Exécuter le script SQL

Allez dans votre projet Supabase → **SQL Editor** et exécutez le contenu du fichier `supabase/add-voters-table.sql`.

Ce script va :
- Créer la table `voters`
- Ajouter la colonne `voter_id` à la table `voter_codes` (pour lier les codes aux votants)
- Créer les index nécessaires
- Configurer les politiques RLS (Row Level Security)

### 2. Vérification

Après avoir exécuté le script, vérifiez que la table `voters` existe :
```sql
SELECT * FROM voters LIMIT 5;
```

### 3. Synchronisation automatique

Une fois la table créée, tous les nouveaux votants seront automatiquement synchronisés avec Supabase :
- ✅ Ajout de votant → synchronisé avec Supabase
- ✅ Modification (marquer comme voté) → synchronisé avec Supabase
- ✅ Suppression → synchronisé avec Supabase
- ✅ Chargement au démarrage → récupère depuis Supabase

## Fonctionnalités

- **Synchronisation bidirectionnelle** : Les données sont synchronisées entre localStorage et Supabase
- **Chargement automatique** : Au démarrage de l'application, les votants sont chargés depuis Supabase
- **Temps réel** : Toutes les modifications sont immédiatement synchronisées




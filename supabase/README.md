# Configuration Supabase pour RHIT Elections

## Installation

1. Créez un projet sur [Supabase](https://supabase.com)

2. Copiez les variables d'environnement depuis votre dashboard Supabase :
   - `NEXT_PUBLIC_SUPABASE_URL` : URL de votre projet
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` : Clé anonyme publique
   - `SUPABASE_SERVICE_ROLE_KEY` : Clé de service (optionnel, pour les opérations admin)

3. Créez un fichier `.env.local` à la racine du projet avec :
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

## Configuration de la base de données

1. Allez dans votre projet Supabase → SQL Editor

2. Copiez et exécutez le contenu du fichier `schema.sql` dans l'éditeur SQL

3. Vérifiez que toutes les tables ont été créées :
   - `candidates`
   - `elections`
   - `voter_codes`
   - `votes`

## Structure des tables

### candidates
Stocke les informations des candidats à l'élection.

### elections
Gère les élections (dates de début/fin, statut actif).

### voter_codes
Codes uniques pour chaque votant, avec suivi d'utilisation.

### votes
Enregistre tous les votes avec référence au candidat et au code votant.

## Vues disponibles

- `vote_results` : Résultats des votes par candidat avec pourcentages
- `election_stats` : Statistiques globales de l'élection

## Fonctions utilitaires

- `is_voter_code_valid(p_code, p_election_id)` : Vérifie si un code de voteur est valide
- `get_election_results(p_election_id)` : Retourne les résultats d'une élection

## Sécurité (RLS)

Les politiques Row Level Security sont activées par défaut. Ajustez-les selon vos besoins d'authentification dans le fichier `schema.sql`.





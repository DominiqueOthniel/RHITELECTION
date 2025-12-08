# Configuration des variables d'environnement

Créez un fichier `.env.local` à la racine du projet avec les variables suivantes :

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

## Où trouver ces valeurs ?

1. Allez sur [Supabase Dashboard](https://app.supabase.com)
2. Sélectionnez votre projet
3. Allez dans **Settings** → **API**
4. Copiez :
   - **Project URL** → `NEXT_PUBLIC_SUPABASE_URL`
   - **anon public** key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - **service_role** key → `SUPABASE_SERVICE_ROLE_KEY` (gardez cette clé secrète !)

## Important

- Ne commitez **JAMAIS** le fichier `.env.local` (il est déjà dans `.gitignore`)
- La clé `service_role` ne doit être utilisée que côté serveur
- Les clés `NEXT_PUBLIC_*` seront exposées côté client




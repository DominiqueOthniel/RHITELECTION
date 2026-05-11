-- Si la page /vote affiche toujours « code invalide » alors que les lignes existent
-- dans Table Editor → voters : la cause est souvent le RLS qui bloque SELECT pour le rôle `anon`.
-- Exécutez ce script dans SQL Editor (une fois), puis testez à nouveau.

DROP POLICY IF EXISTS "Public read voters for voting page (anon)" ON public.voters;

CREATE POLICY "Public read voters for voting page (anon)"
  ON public.voters
  FOR SELECT
  TO anon, authenticated
  USING (true);

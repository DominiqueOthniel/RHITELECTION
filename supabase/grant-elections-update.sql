-- À exécuter dans Supabase → SQL Editor si la date de fin ne se sauvegarde pas depuis l'admin
-- (le PC affiche la bonne valeur mais le portable garde l'ancienne)

ALTER TABLE elections ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Elections are viewable by everyone" ON elections;
CREATE POLICY "Elections are viewable by everyone"
  ON elections FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Elections can be updated by anyone" ON elections;
CREATE POLICY "Elections can be updated by anyone"
  ON elections FOR UPDATE
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Elections can be inserted by anyone" ON elections;
CREATE POLICY "Elections can be inserted by anyone"
  ON elections FOR INSERT
  WITH CHECK (true);

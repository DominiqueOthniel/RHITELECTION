-- À exécuter une fois dans Supabase → SQL Editor
-- Corrige le bouton "Réinitialiser votes" de l'admin qui ne vide pas vraiment les stats

-- Permissions RLS manquantes (le client anon ne pouvait pas DELETE les votes)
DROP POLICY IF EXISTS "Votes can be deleted by anyone" ON votes;
CREATE POLICY "Votes can be deleted by anyone"
  ON votes FOR DELETE
  USING (true);

DROP POLICY IF EXISTS "Voter codes can be updated by anyone" ON voter_codes;
CREATE POLICY "Voter codes can be updated by anyone"
  ON voter_codes FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Reset complet en une seule opération côté serveur (contourne les blocages RLS)
CREATE OR REPLACE FUNCTION reset_voting_session()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  deleted_votes integer;
  reset_voters integer;
BEGIN
  DELETE FROM votes;
  GET DIAGNOSTICS deleted_votes = ROW_COUNT;

  UPDATE voters SET has_voted = false;
  GET DIAGNOSTICS reset_voters = ROW_COUNT;

  UPDATE voter_codes
  SET is_used = false, used_at = NULL
  WHERE is_used = true OR used_at IS NOT NULL;

  RETURN json_build_object(
    'success', true,
    'deleted_votes', deleted_votes,
    'reset_voters', reset_voters
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.reset_voting_session() TO anon, authenticated;

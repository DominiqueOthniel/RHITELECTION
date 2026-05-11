-- À exécuter une fois dans Supabase → SQL Editor si la connexion admin échoue
-- alors que le hash et la ligne admin_users sont corrects (souvent : permission RPC).

GRANT EXECUTE ON FUNCTION public.verify_admin_credentials(character varying, character varying) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.update_admin_last_login(character varying) TO anon, authenticated;

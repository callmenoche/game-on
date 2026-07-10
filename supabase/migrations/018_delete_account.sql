-- 018: RPC for authenticated users to delete their own account.
-- Cascades clean up matches, groups, etc. via FK constraints.

CREATE OR REPLACE FUNCTION delete_own_account()
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
DECLARE _uid UUID := auth.uid();
BEGIN
  IF _uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

  -- Explicit deletes for junction tables (safe even with cascades)
  DELETE FROM match_participants WHERE user_id = _uid;
  DELETE FROM group_members      WHERE user_id = _uid;

  -- Profile + auth user (profiles FK cascades from auth.users)
  DELETE FROM profiles   WHERE id = _uid;
  DELETE FROM auth.users WHERE id = _uid;
END;
$$;

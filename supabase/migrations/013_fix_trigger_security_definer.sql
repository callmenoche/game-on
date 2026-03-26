-- The on_participant_change trigger runs as the calling user (INVOKER), which
-- means non-creator participants' inserts hit the matches_update_own RLS policy
-- and silently fail to decrement players_needed.
-- Adding SECURITY DEFINER makes the function run as its creator (postgres/superuser),
-- bypassing RLS so every participant change correctly updates players_needed.

CREATE OR REPLACE FUNCTION public.on_participant_change()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_match_id uuid;
BEGIN
  v_match_id := COALESCE(NEW.match_id, OLD.match_id);
  UPDATE matches
  SET
    players_needed = GREATEST(
      total_spots - (
        SELECT COUNT(*) FROM match_participants WHERE match_id = v_match_id
      ),
      0
    ),
    status = CASE
      WHEN total_spots - (
        SELECT COUNT(*) FROM match_participants WHERE match_id = v_match_id
      ) <= 0 THEN 'full'
      ELSE 'open'
    END
  WHERE id = v_match_id AND total_spots IS NOT NULL;
  RETURN COALESCE(NEW, OLD);
END;
$$;

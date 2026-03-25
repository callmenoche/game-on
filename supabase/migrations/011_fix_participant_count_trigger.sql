-- Replace incremental trigger with a COUNT-based recalculation.
-- This makes players_needed self-healing: it always reflects the true
-- number of participants, regardless of how rows were inserted/deleted.

CREATE OR REPLACE FUNCTION public.on_participant_change()
RETURNS trigger LANGUAGE plpgsql AS $$
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

-- Replace the old INSERT-only trigger with INSERT OR DELETE
DROP TRIGGER IF EXISTS after_participant_join ON match_participants;

CREATE TRIGGER after_participant_change
  AFTER INSERT OR DELETE ON match_participants
  FOR EACH ROW EXECUTE FUNCTION public.on_participant_change();

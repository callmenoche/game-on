-- =============================================================
-- GameOn – Heal players_needed drift + preserve cancelled status
--
-- Matches that drifted before the 011/013 trigger fixes are never
-- recomputed unless a participant row changes again. Also the
-- trigger could flip a cancelled match back to open/full.
-- =============================================================

-- 1. Trigger: never touch cancelled matches' status
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
      WHEN status = 'cancelled' THEN 'cancelled'
      WHEN total_spots - (
        SELECT COUNT(*) FROM match_participants WHERE match_id = v_match_id
      ) <= 0 THEN 'full'
      ELSE 'open'
    END
  WHERE id = v_match_id AND total_spots IS NOT NULL;
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- 2. One-time recount of every limited match
UPDATE matches m
SET
  players_needed = GREATEST(
    m.total_spots - (
      SELECT COUNT(*) FROM match_participants mp WHERE mp.match_id = m.id
    ),
    0
  ),
  status = CASE
    WHEN m.status = 'cancelled' THEN 'cancelled'
    WHEN m.total_spots - (
      SELECT COUNT(*) FROM match_participants mp WHERE mp.match_id = m.id
    ) <= 0 THEN 'full'
    ELSE 'open'
  END
WHERE m.total_spots IS NOT NULL;

-- Prevent joining a match that is already full.
-- This BEFORE INSERT trigger rejects the row if the match has
-- no remaining spots, preventing race conditions where two users
-- join simultaneously when only one spot remains.

CREATE OR REPLACE FUNCTION public.guard_match_not_full()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_total     int;
  v_count     int;
BEGIN
  SELECT total_spots INTO v_total
    FROM matches WHERE id = NEW.match_id;

  -- Unlimited matches (total_spots IS NULL) always allow joining
  IF v_total IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT COUNT(*) INTO v_count
    FROM match_participants WHERE match_id = NEW.match_id;

  IF v_count >= v_total THEN
    RAISE EXCEPTION 'Match is full' USING ERRCODE = 'P0001';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER before_participant_insert
  BEFORE INSERT ON match_participants
  FOR EACH ROW EXECUTE FUNCTION public.guard_match_not_full();

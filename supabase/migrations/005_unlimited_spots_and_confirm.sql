-- =============================================================
-- GameOn – Unlimited spots & match confirmation
-- =============================================================

-- 1. Make total_spots and players_needed nullable.
--    NULL means "no cap" (unlimited participants).
ALTER TABLE matches ALTER COLUMN total_spots   DROP NOT NULL;
ALTER TABLE matches ALTER COLUMN players_needed DROP NOT NULL;

-- 2. Re-add CHECK constraints that accept NULL.
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_total_spots_check;
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_players_needed_check;

ALTER TABLE matches
  ADD CONSTRAINT matches_total_spots_check
    CHECK (total_spots IS NULL OR total_spots > 0),
  ADD CONSTRAINT matches_players_needed_check
    CHECK (players_needed IS NULL OR players_needed >= 0);

-- 3. Add confirmed_at: host stamps this when the session is confirmed.
ALTER TABLE matches ADD COLUMN confirmed_at TIMESTAMPTZ;

-- 4. Update join trigger to leave players_needed NULL for unlimited matches.
CREATE OR REPLACE FUNCTION on_participant_join()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE matches
  SET
    players_needed = CASE
      WHEN players_needed IS NULL THEN NULL          -- unlimited: no decrement
      ELSE GREATEST(players_needed - 1, 0)
    END,
    status = CASE
      WHEN players_needed IS NULL THEN status        -- unlimited stays open
      WHEN players_needed - 1 <= 0 THEN 'full'
      ELSE status
    END
  WHERE id = NEW.match_id;
  RETURN NEW;
END;
$$;

-- 5. Update leave trigger symmetrically.
CREATE OR REPLACE FUNCTION on_participant_leave()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE matches
  SET
    players_needed = CASE
      WHEN players_needed IS NULL THEN NULL          -- unlimited: no increment
      ELSE players_needed + 1
    END,
    status = CASE WHEN status = 'full' THEN 'open' ELSE status END
  WHERE id = OLD.match_id;
  RETURN OLD;
END;
$$;

-- =============================================================
-- GameOn – Gender-Restricted Matches
-- Run in: Supabase Dashboard > SQL Editor
-- =============================================================

-- 1. Column: NULL = unrestricted, e.g. '{F,X}' = women + non-binary only
ALTER TABLE matches ADD COLUMN IF NOT EXISTS allowed_genders TEXT[] DEFAULT NULL;

-- 2. Helper (same pattern as get_my_group_ids)
CREATE OR REPLACE FUNCTION get_my_gender()
RETURNS TEXT LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT gender FROM profiles WHERE id = auth.uid()
$$;

-- 3. Update RLS SELECT (replaces 008_groups version)
DROP POLICY IF EXISTS "matches_select_open" ON matches;
CREATE POLICY "matches_select_open" ON matches
  FOR SELECT USING (
    status IN ('open', 'full')
    AND (
      group_id IS NULL
      OR group_id IN (SELECT get_my_group_ids())
      OR creator_id = auth.uid()
    )
    AND (
      allowed_genders IS NULL
      OR creator_id = auth.uid()
      OR get_my_gender() = ANY(allowed_genders)
    )
  );

-- 4. Join guard trigger (belt-and-suspenders)
CREATE OR REPLACE FUNCTION check_gender_on_join()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  _allowed TEXT[];
  _creator UUID;
  _joiner_gender TEXT;
BEGIN
  -- Skip guests (no user_id)
  IF NEW.user_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT allowed_genders, creator_id
    INTO _allowed, _creator
    FROM matches WHERE id = NEW.match_id;

  -- Unrestricted or creator joining
  IF _allowed IS NULL OR NEW.user_id = _creator THEN
    RETURN NEW;
  END IF;

  SELECT gender INTO _joiner_gender FROM profiles WHERE id = NEW.user_id;

  IF _joiner_gender IS NULL OR NOT (_joiner_gender = ANY(_allowed)) THEN
    RAISE EXCEPTION 'Gender restriction: you cannot join this match';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS before_participant_join_gender_check ON match_participants;
CREATE TRIGGER before_participant_join_gender_check
  BEFORE INSERT ON match_participants
  FOR EACH ROW EXECUTE FUNCTION check_gender_on_join();

-- 5. GIN index for array queries
CREATE INDEX IF NOT EXISTS idx_matches_allowed_genders
  ON matches USING GIN (allowed_genders);

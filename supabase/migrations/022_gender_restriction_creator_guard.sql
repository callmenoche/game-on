-- =============================================================
-- GameOn – Gender restriction must include the creator
-- Run in: Supabase Dashboard > SQL Editor
--
-- A creator could previously restrict a match to genders that
-- exclude themselves (the 017 policies exempt the creator, so
-- they could even join it — confusing). Enforce at the source:
-- a restricted match requires the creator's gender to be set
-- and included in allowed_genders.
-- =============================================================

CREATE OR REPLACE FUNCTION check_gender_restriction_on_create()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  _creator_gender TEXT;
BEGIN
  IF NEW.allowed_genders IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT gender INTO _creator_gender FROM profiles WHERE id = NEW.creator_id;

  IF _creator_gender IS NULL THEN
    RAISE EXCEPTION 'Gender restriction: set your gender in your profile first';
  END IF;

  IF NOT (_creator_gender = ANY(NEW.allowed_genders)) THEN
    RAISE EXCEPTION 'Gender restriction: you cannot exclude your own gender';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS before_match_gender_restriction_check ON matches;
CREATE TRIGGER before_match_gender_restriction_check
  BEFORE INSERT OR UPDATE OF allowed_genders ON matches
  FOR EACH ROW EXECUTE FUNCTION check_gender_restriction_on_create();

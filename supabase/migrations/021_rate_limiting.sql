-- Rate limiting: prevent spam creation of matches and groups.
-- Max 10 matches per hour per user, max 5 groups per day per user.

CREATE OR REPLACE FUNCTION check_match_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    SELECT COUNT(*)
    FROM matches
    WHERE creator_id = NEW.creator_id
      AND created_at > NOW() - INTERVAL '1 hour'
  ) >= 10 THEN
    RAISE EXCEPTION 'Rate limit exceeded: max 10 matches per hour';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_match_rate_limit ON matches;
CREATE TRIGGER trg_match_rate_limit
  BEFORE INSERT ON matches
  FOR EACH ROW
  EXECUTE FUNCTION check_match_rate_limit();

CREATE OR REPLACE FUNCTION check_group_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    SELECT COUNT(*)
    FROM groups
    WHERE creator_id = NEW.creator_id
      AND created_at > NOW() - INTERVAL '1 day'
  ) >= 5 THEN
    RAISE EXCEPTION 'Rate limit exceeded: max 5 groups per day';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_group_rate_limit ON groups;
CREATE TRIGGER trg_group_rate_limit
  BEFORE INSERT ON groups
  FOR EACH ROW
  EXECUTE FUNCTION check_group_rate_limit();

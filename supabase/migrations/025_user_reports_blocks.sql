-- =============================================================
-- GameOn – User reporting & blocking (store UGC compliance)
--
-- Apple guideline 1.2 / Play UGC policy: apps with user-generated
-- content must offer a way to report content/users and block users.
-- Reports are triaged with the service-role key (like bug_reports).
-- =============================================================

-- 1. Blocks: blocker hides all content from blocked (client-side filter)
CREATE TABLE IF NOT EXISTS user_blocks (
  blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (blocker_id, blocked_id),
  CHECK (blocker_id <> blocked_id)
);

ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "blocks_own" ON user_blocks
  FOR ALL USING (auth.uid() = blocker_id)
  WITH CHECK (auth.uid() = blocker_id);

CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker ON user_blocks(blocker_id);

-- 2. Reports
CREATE TABLE IF NOT EXISTS user_reports (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  match_id         UUID REFERENCES matches(id) ON DELETE SET NULL,
  reason           TEXT NOT NULL
    CHECK (reason IN ('spam', 'harassment', 'inappropriate', 'fake', 'other')),
  details          TEXT CHECK (details IS NULL OR char_length(details) <= 1000),
  status           TEXT NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'reviewed', 'actioned', 'dismissed')),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE user_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reports_insert_own" ON user_reports
  FOR INSERT WITH CHECK (
    auth.uid() = reporter_id AND reporter_id <> reported_user_id
  );

CREATE POLICY "reports_select_own" ON user_reports
  FOR SELECT USING (auth.uid() = reporter_id);

CREATE INDEX IF NOT EXISTS idx_user_reports_status
  ON user_reports(status, created_at);

-- 3. Anti-spam (same pattern as 021/023): max 10 reports per day
CREATE OR REPLACE FUNCTION check_user_report_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    SELECT COUNT(*)
    FROM user_reports
    WHERE reporter_id = NEW.reporter_id
      AND created_at > NOW() - INTERVAL '1 day'
  ) >= 10 THEN
    RAISE EXCEPTION 'Rate limit exceeded: max 10 reports per day';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_user_report_rate_limit ON user_reports;
CREATE TRIGGER trg_user_report_rate_limit
  BEFORE INSERT ON user_reports
  FOR EACH ROW
  EXECUTE FUNCTION check_user_report_rate_limit();

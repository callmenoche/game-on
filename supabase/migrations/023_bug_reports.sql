-- =============================================================
-- GameOn – In-app bug reports
-- Run in: Supabase Dashboard > SQL Editor
--
-- Users file reports from Settings > Support. Triage/fixing is
-- done outside the app with the service-role key (bypasses RLS),
-- e.g. via the /triage-bugs Claude Code command.
-- =============================================================

CREATE TABLE IF NOT EXISTS bug_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  category TEXT NOT NULL DEFAULT 'bug'
    CHECK (category IN ('bug', 'suggestion', 'other')),
  description TEXT NOT NULL
    CHECK (char_length(description) BETWEEN 10 AND 2000),
  app_version TEXT,
  platform TEXT,
  status TEXT NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'triaged', 'in_progress', 'fixed', 'rejected')),
  resolution_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE bug_reports ENABLE ROW LEVEL SECURITY;

-- Users can file reports as themselves and read their own.
-- No UPDATE/DELETE policies: status changes go through the service role.
CREATE POLICY "bug_reports_insert_own" ON bug_reports
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "bug_reports_select_own" ON bug_reports
  FOR SELECT USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_bug_reports_status
  ON bug_reports (status, created_at);

-- Same anti-spam pattern as 021: max 5 reports per day per user.
CREATE OR REPLACE FUNCTION check_bug_report_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    SELECT COUNT(*)
    FROM bug_reports
    WHERE user_id = NEW.user_id
      AND created_at > NOW() - INTERVAL '1 day'
  ) >= 5 THEN
    RAISE EXCEPTION 'Rate limit exceeded: max 5 bug reports per day';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_bug_report_rate_limit ON bug_reports;
CREATE TRIGGER trg_bug_report_rate_limit
  BEFORE INSERT ON bug_reports
  FOR EACH ROW
  EXECUTE FUNCTION check_bug_report_rate_limit();

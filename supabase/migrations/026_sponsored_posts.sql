-- =============================================================
-- GameOn – Sponsored posts (native ads in the feed)
--
-- Managed via the Supabase dashboard / service role only: the app
-- has read access to active posts, nothing else. Targeting is
-- optional per field: NULL sport_type = all sports, NULL geo = all
-- locations, NULL ends_at = no end date.
-- =============================================================

CREATE TABLE IF NOT EXISTS sponsored_posts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL CHECK (char_length(title) <= 80),
  description TEXT CHECK (description IS NULL OR char_length(description) <= 200),
  image_url   TEXT,
  link_url    TEXT NOT NULL,
  sport_type  TEXT,             -- matches SportType.name ('padel', 'football', …)
  geo_lat     DOUBLE PRECISION,
  geo_lng     DOUBLE PRECISION,
  radius_km   REAL,
  starts_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at     TIMESTAMPTZ,
  active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE sponsored_posts ENABLE ROW LEVEL SECURITY;

-- Read-only for signed-in users, and only currently-running posts.
CREATE POLICY "sponsored_select_active" ON sponsored_posts
  FOR SELECT USING (
    auth.uid() IS NOT NULL
    AND active
    AND starts_at <= NOW()
    AND (ends_at IS NULL OR ends_at > NOW())
  );

CREATE INDEX IF NOT EXISTS idx_sponsored_active
  ON sponsored_posts(active, starts_at, ends_at);

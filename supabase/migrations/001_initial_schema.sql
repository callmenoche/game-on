-- =============================================================
-- GameOn – Initial Schema Migration
-- Run this in: Supabase Dashboard > SQL Editor
-- =============================================================

-- ─────────────────────────────────────────────
-- 1. PROFILES
--    Extends auth.users; one row per registered user.
-- ─────────────────────────────────────────────
CREATE TABLE profiles (
  id               UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username         TEXT        UNIQUE NOT NULL,
  bio              TEXT,
  favorite_sports  TEXT[]      NOT NULL DEFAULT '{}',
  availability_json JSONB      NOT NULL DEFAULT '{}',
  avatar_url       TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create a profile row when a new auth user signs up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id, username)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Keep updated_at current
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();


-- ─────────────────────────────────────────────
-- 2. MATCHES
-- ─────────────────────────────────────────────
CREATE TABLE matches (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  sport_type     TEXT        NOT NULL,           -- e.g. 'padel', 'football', 'running'
  location_name  TEXT        NOT NULL,
  geo_lat        DOUBLE PRECISION,
  geo_lng        DOUBLE PRECISION,
  date_time      TIMESTAMPTZ NOT NULL,
  total_spots    INT         NOT NULL CHECK (total_spots > 0),
  players_needed INT         NOT NULL CHECK (players_needed >= 0),
  status         TEXT        NOT NULL DEFAULT 'open'
                             CHECK (status IN ('open', 'full', 'cancelled')),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_matches_sport_type  ON matches(sport_type);
CREATE INDEX idx_matches_date_time   ON matches(date_time);
CREATE INDEX idx_matches_status      ON matches(status);
CREATE INDEX idx_matches_creator_id  ON matches(creator_id);


-- ─────────────────────────────────────────────
-- 3. MATCH PARTICIPANTS
-- ─────────────────────────────────────────────
CREATE TABLE match_participants (
  match_id   UUID        NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  user_id    UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (match_id, user_id)
);

CREATE INDEX idx_mp_user_id ON match_participants(user_id);

-- Decrement players_needed when someone joins; mark full when 0
CREATE OR REPLACE FUNCTION on_participant_join()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE matches
  SET
    players_needed = GREATEST(players_needed - 1, 0),
    status = CASE WHEN players_needed - 1 <= 0 THEN 'full' ELSE status END
  WHERE id = NEW.match_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER after_participant_join
  AFTER INSERT ON match_participants
  FOR EACH ROW EXECUTE FUNCTION on_participant_join();

-- Increment players_needed when someone leaves; reopen if was full
CREATE OR REPLACE FUNCTION on_participant_leave()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE matches
  SET
    players_needed = players_needed + 1,
    status = CASE WHEN status = 'full' THEN 'open' ELSE status END
  WHERE id = OLD.match_id;
  RETURN OLD;
END;
$$;

CREATE TRIGGER after_participant_leave
  AFTER DELETE ON match_participants
  FOR EACH ROW EXECUTE FUNCTION on_participant_leave();


-- ─────────────────────────────────────────────
-- 4. ROW LEVEL SECURITY (RLS)
-- ─────────────────────────────────────────────

ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches            ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_participants ENABLE ROW LEVEL SECURITY;

-- profiles: anyone can read; only owner can write
CREATE POLICY "profiles_select_all"   ON profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert_own"   ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own"   ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "profiles_delete_own"   ON profiles FOR DELETE USING (auth.uid() = id);

-- matches: open/full matches are public; only creator can mutate
CREATE POLICY "matches_select_open"   ON matches FOR SELECT USING (status IN ('open', 'full'));
CREATE POLICY "matches_insert_auth"   ON matches FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "matches_update_own"    ON matches FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "matches_delete_own"    ON matches FOR DELETE USING (auth.uid() = creator_id);

-- match_participants: authenticated users can join; only own rows deletable
CREATE POLICY "mp_select_all"         ON match_participants FOR SELECT USING (true);
CREATE POLICY "mp_insert_auth"        ON match_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "mp_delete_own"         ON match_participants FOR DELETE USING (auth.uid() = user_id);


-- ─────────────────────────────────────────────
-- 5. REALTIME
--    Enable Supabase Realtime on the key tables.
-- ─────────────────────────────────────────────
ALTER PUBLICATION supabase_realtime ADD TABLE matches;
ALTER PUBLICATION supabase_realtime ADD TABLE match_participants;

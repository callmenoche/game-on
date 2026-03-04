-- =============================================================
-- GameOn – Private Groups
-- Run in: Supabase Dashboard > SQL Editor
-- =============================================================

-- 1. Groups table
CREATE TABLE IF NOT EXISTS groups (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        NOT NULL,
  description TEXT,
  invite_code TEXT        UNIQUE NOT NULL DEFAULT upper(substring(replace(gen_random_uuid()::text, '-', ''), 1, 8)),
  creator_id  UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Group members
CREATE TABLE IF NOT EXISTS group_members (
  group_id  UUID        NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id   UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role      TEXT        NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (group_id, user_id)
);

-- 3. Link matches to a group (NULL = public)
ALTER TABLE matches ADD COLUMN IF NOT EXISTS group_id UUID REFERENCES groups(id) ON DELETE SET NULL;

-- 4. Indexes
CREATE INDEX IF NOT EXISTS idx_groups_creator   ON groups(creator_id);
CREATE INDEX IF NOT EXISTS idx_gm_user_id       ON group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_group_id ON matches(group_id);

-- 5. Security-definer helper to avoid RLS recursion
CREATE OR REPLACE FUNCTION get_my_group_ids()
RETURNS SETOF UUID LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT group_id FROM group_members WHERE user_id = auth.uid()
$$;

-- 6. RLS – groups
ALTER TABLE groups        ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- Groups: visible to creator + members
CREATE POLICY "groups_select" ON groups
  FOR SELECT USING (
    creator_id = auth.uid()
    OR id IN (SELECT get_my_group_ids())
  );
CREATE POLICY "groups_insert" ON groups
  FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "groups_update" ON groups
  FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "groups_delete" ON groups
  FOR DELETE USING (auth.uid() = creator_id);

-- Group members: visible to fellow members; anyone can join (insert own row)
CREATE POLICY "gm_select" ON group_members
  FOR SELECT USING (group_id IN (SELECT get_my_group_ids()));
CREATE POLICY "gm_insert" ON group_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "gm_delete" ON group_members
  FOR DELETE USING (
    auth.uid() = user_id
    OR group_id IN (
      SELECT group_id FROM group_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- 7. Extend matches SELECT policy to include private group matches
DROP POLICY IF EXISTS "matches_select_open" ON matches;
CREATE POLICY "matches_select_open" ON matches
  FOR SELECT USING (
    status IN ('open', 'full')
    AND (
      group_id IS NULL                              -- public: visible to all
      OR group_id IN (SELECT get_my_group_ids())   -- private: members only
      OR creator_id = auth.uid()                   -- creator always sees own
    )
  );

-- 8. Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE groups;
ALTER PUBLICATION supabase_realtime ADD TABLE group_members;

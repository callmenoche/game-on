-- =============================================================
-- GameOn – Group visibility + join requests
--
-- visibility:
--   'public'      → searchable, anyone joins instantly
--   'private'     → hidden, join via invite code only (default,
--                   matches previous behaviour)
--   'invite_only' → searchable, joining requires admin approval
-- =============================================================

-- 1. Columns
ALTER TABLE groups ADD COLUMN IF NOT EXISTS visibility TEXT NOT NULL DEFAULT 'private'
  CHECK (visibility IN ('public', 'private', 'invite_only'));
ALTER TABLE groups ADD COLUMN IF NOT EXISTS member_count INT NOT NULL DEFAULT 0;

-- member_count is denormalised so search results can show it without
-- exposing the group_members table to non-members (RLS keeps it members-only).
UPDATE groups g SET member_count =
  (SELECT COUNT(*) FROM group_members gm WHERE gm.group_id = g.id);

CREATE OR REPLACE FUNCTION bump_group_member_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE groups SET member_count = member_count + 1 WHERE id = NEW.group_id;
    RETURN NEW;
  END IF;
  UPDATE groups SET member_count = GREATEST(member_count - 1, 0)
    WHERE id = OLD.group_id;
  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS trg_group_member_count ON group_members;
CREATE TRIGGER trg_group_member_count
  AFTER INSERT OR DELETE ON group_members
  FOR EACH ROW EXECUTE FUNCTION bump_group_member_count();

-- 2. Admin helper (SECURITY DEFINER avoids RLS recursion)
CREATE OR REPLACE FUNCTION am_i_group_admin(gid UUID)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM group_members
    WHERE group_id = gid AND user_id = auth.uid() AND role = 'admin'
  )
$$;

-- 3. Public & invite-only groups appear in search
DROP POLICY IF EXISTS "groups_select" ON groups;
CREATE POLICY "groups_select" ON groups
  FOR SELECT USING (
    creator_id = auth.uid()
    OR id IN (SELECT get_my_group_ids())
    OR visibility IN ('public', 'invite_only')
  );

-- 4. Direct membership insert: own row, public groups only
--    (creator excepted — they add themselves to their new group).
--    Private = via join_group_by_code(); invite_only = via accepted request.
DROP POLICY IF EXISTS "gm_insert" ON group_members;
CREATE POLICY "gm_insert" ON group_members
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM groups g
      WHERE g.id = group_id
        AND (g.visibility = 'public' OR g.creator_id = auth.uid())
    )
  );

-- 5. Join by invite code. SECURITY DEFINER: also fixes the pre-existing
--    RLS gap where a non-member could not even SELECT the group row by code.
CREATE OR REPLACE FUNCTION join_group_by_code(code TEXT)
RETURNS SETOF groups LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  g groups%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  SELECT * INTO g FROM groups WHERE invite_code = upper(trim(code));
  IF NOT FOUND THEN
    RETURN;
  END IF;
  INSERT INTO group_members (group_id, user_id, role)
  VALUES (g.id, auth.uid(), 'member')
  ON CONFLICT (group_id, user_id) DO NOTHING;
  RETURN NEXT g;
END;
$$;

-- 6. Join requests (invite_only groups)
CREATE TABLE IF NOT EXISTS group_join_requests (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id   UUID        NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id    UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status     TEXT        NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (group_id, user_id)
);

ALTER TABLE group_join_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "gjr_insert_own" ON group_join_requests
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM groups g
      WHERE g.id = group_id AND g.visibility = 'invite_only'
    )
    AND NOT EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_id AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "gjr_select" ON group_join_requests
  FOR SELECT USING (auth.uid() = user_id OR am_i_group_admin(group_id));

CREATE POLICY "gjr_update_admin" ON group_join_requests
  FOR UPDATE USING (am_i_group_admin(group_id));

CREATE POLICY "gjr_delete" ON group_join_requests
  FOR DELETE USING (auth.uid() = user_id OR am_i_group_admin(group_id));

-- 7. Acceptance → membership
CREATE OR REPLACE FUNCTION handle_join_request_accepted()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'accepted' AND OLD.status = 'pending' THEN
    INSERT INTO group_members (group_id, user_id, role)
    VALUES (NEW.group_id, NEW.user_id, 'member')
    ON CONFLICT (group_id, user_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_join_request_accepted ON group_join_requests;
CREATE TRIGGER trg_join_request_accepted
  AFTER UPDATE ON group_join_requests
  FOR EACH ROW EXECUTE FUNCTION handle_join_request_accepted();

-- 8. Indexes
CREATE INDEX IF NOT EXISTS idx_gjr_group_status ON group_join_requests(group_id, status);
CREATE INDEX IF NOT EXISTS idx_groups_visibility ON groups(visibility);

-- =============================================================
-- GameOn – Expose public-group membership on profiles
--
-- The profile redesign shows "groups this person belongs to" on
-- everyone's profile. The existing gm_select policy (008) only lets
-- you read group_members rows for groups YOU are also a member of,
-- so a viewer could never see "X is in PublicGroupY" unless they'd
-- also joined it. Extend it: membership rows of PUBLIC groups are
-- readable by anyone signed in — private/invite_only membership
-- lists stay members-only (invite_only still gates the member LIST,
-- even though the group itself is searchable).
-- =============================================================

DROP POLICY IF EXISTS "gm_select" ON group_members;
CREATE POLICY "gm_select" ON group_members
  FOR SELECT USING (
    group_id IN (SELECT get_my_group_ids())
    OR EXISTS (
      SELECT 1 FROM groups g
      WHERE g.id = group_id AND g.visibility = 'public'
    )
  );

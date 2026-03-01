-- =============================================================
-- GameOn – Guest Spots Migration
-- Allows hosts to reserve spots for friends who aren't in the
-- app yet. Each guest gets a short claim token they can share.
-- =============================================================

-- 1. Drop old composite PK, promote to auto-generated UUID PK
ALTER TABLE match_participants DROP CONSTRAINT match_participants_pkey;
ALTER TABLE match_participants ADD COLUMN id UUID DEFAULT gen_random_uuid() NOT NULL;
ALTER TABLE match_participants ADD CONSTRAINT match_participants_pkey PRIMARY KEY (id);

-- 2. Allow nullable user_id (guests have no account yet)
ALTER TABLE match_participants ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE match_participants DROP CONSTRAINT match_participants_user_id_fkey;

-- 3. Restore FK only when user_id is present
ALTER TABLE match_participants
  ADD CONSTRAINT match_participants_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE
  NOT VALID;

-- 4. Keep uniqueness for real users (guests may have NULL user_id)
CREATE UNIQUE INDEX match_participants_user_unique
  ON match_participants(match_id, user_id)
  WHERE user_id IS NOT NULL;

-- 5. Guest columns
ALTER TABLE match_participants
  ADD COLUMN is_guest          BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN guest_claim_token TEXT    UNIQUE,
  ADD COLUMN guest_name        TEXT;

-- 6. RLS: allow creator to insert guest placeholders
DROP POLICY "mp_insert_auth" ON match_participants;
CREATE POLICY "mp_insert_auth_or_guest" ON match_participants
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    OR (is_guest AND auth.uid() = (
      SELECT creator_id FROM matches WHERE id = match_id
    ))
  );

-- 7. RLS: allow creator to delete unclaimed guest spots
DROP POLICY "mp_delete_own" ON match_participants;
CREATE POLICY "mp_delete_own_or_guest" ON match_participants
  FOR DELETE USING (
    auth.uid() = user_id
    OR (is_guest AND user_id IS NULL AND auth.uid() = (
      SELECT creator_id FROM matches WHERE id = match_id
    ))
  );

-- 8. RLS: allow the claiming user to UPDATE a guest row → set their user_id
CREATE POLICY "mp_claim_guest" ON match_participants
  FOR UPDATE USING (
    is_guest AND user_id IS NULL AND guest_claim_token IS NOT NULL
  )
  WITH CHECK (auth.uid() = user_id);

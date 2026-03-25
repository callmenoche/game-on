-- Track which user added each guest spot, so non-host players
-- can share claim codes for their own guests.
ALTER TABLE match_participants
  ADD COLUMN added_by_user_id uuid REFERENCES auth.users(id);

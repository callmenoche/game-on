-- Enforce unique usernames (case-insensitive).
CREATE UNIQUE INDEX IF NOT EXISTS profiles_username_unique
  ON profiles (LOWER(username))
  WHERE username IS NOT NULL AND username != '';

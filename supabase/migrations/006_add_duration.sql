-- Add duration_minutes to matches (step of 30 min, default 1h)
ALTER TABLE matches
  ADD COLUMN duration_minutes INTEGER NOT NULL DEFAULT 60
  CHECK (duration_minutes >= 30 AND duration_minutes <= 480);

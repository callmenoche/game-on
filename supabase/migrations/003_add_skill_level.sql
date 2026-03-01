-- Add skill_level column to matches
ALTER TABLE matches
  ADD COLUMN skill_level TEXT NOT NULL DEFAULT 'all_levels'
  CHECK (skill_level IN ('beginner', 'intermediate', 'expert', 'all_levels'));

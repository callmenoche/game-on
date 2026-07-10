-- 019: Track when a user accepted the Terms of Service / Privacy Policy.

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS accepted_terms_at TIMESTAMPTZ;

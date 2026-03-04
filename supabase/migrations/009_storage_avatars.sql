-- ── 009: Avatar storage bucket ───────────────────────────────────────────────
-- Creates a public bucket for user profile pictures and appropriate RLS rules.
-- Path convention: {userId}/avatar.{ext}   (e.g. abc-123/avatar.jpg)

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- ── RLS on storage.objects ────────────────────────────────────────────────────

-- Authenticated users may upload/overwrite their own avatar
CREATE POLICY "Users upload own avatar"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid()::text = split_part(name, '/', 1)
  );

-- Authenticated users may update their own avatar
CREATE POLICY "Users update own avatar"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = split_part(name, '/', 1)
  );

-- Authenticated users may delete their own avatar
CREATE POLICY "Users delete own avatar"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = split_part(name, '/', 1)
  );

-- Everyone (including anon) can read avatar objects
CREATE POLICY "Avatars are public"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'avatars');

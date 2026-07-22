-- =============================================================
-- GameOn – Group images
-- Path convention: {groupId}/image.{ext}  (mirrors 009_storage_avatars.sql)
-- =============================================================

ALTER TABLE groups ADD COLUMN IF NOT EXISTS image_url TEXT;

INSERT INTO storage.buckets (id, name, public)
VALUES ('group-images', 'group-images', true)
ON CONFLICT (id) DO NOTHING;

-- Only a group's admins may upload/change/remove its image.
-- am_i_group_admin() is the existing SECURITY DEFINER helper from 024.
CREATE POLICY "Group admins upload group image"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'group-images'
    AND am_i_group_admin((split_part(name, '/', 1))::uuid)
  );

CREATE POLICY "Group admins update group image"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'group-images'
    AND am_i_group_admin((split_part(name, '/', 1))::uuid)
  );

CREATE POLICY "Group admins delete group image"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'group-images'
    AND am_i_group_admin((split_part(name, '/', 1))::uuid)
  );

-- Everyone (including anon) can view group images.
CREATE POLICY "Group images are public"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'group-images');

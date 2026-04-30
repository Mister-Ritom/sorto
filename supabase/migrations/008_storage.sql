-- supabase/migrations/008_storage.sql

-- 1. Create Buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('proof-videos', 'proof-videos', false)
ON CONFLICT (id) DO NOTHING;

-- 2. Avatars RLS Policies

-- Allow public read access to avatars
CREATE POLICY "Avatar Public Read"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- Allow users to upload their own avatar folder
-- Path format: userId/filename
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to update their own avatar
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own avatar
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);


-- 3. Proof Videos RLS Policies

-- For proof videos, we use signed URLs for read access since it's a private bucket.
-- Users must be authenticated to upload.
CREATE POLICY "Authenticated users can upload proof videos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'proof-videos' AND 
  auth.role() = 'authenticated'
);

-- Allow users to delete their own uploads if needed
CREATE POLICY "Users can delete their own videos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'proof-videos' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- ================================================================
-- Storage: create the festival-media bucket and open policies
-- Run this in the Supabase SQL Editor
-- ================================================================

-- Create the bucket (public = downloadable without auth)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'festival-media',
  'festival-media',
  true,          -- publicly readable URLs
  52428800,      -- 50 MB per file
  ARRAY['image/jpeg','image/jpg','image/png','image/gif','image/webp','image/avif']
)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for storage.objects
-- (Supabase storage uses RLS on the storage.objects table)

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects'
    AND policyname = 'Public read festival-media'
  ) THEN
    CREATE POLICY "Public read festival-media"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'festival-media');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects'
    AND policyname = 'Anon upload festival-media'
  ) THEN
    CREATE POLICY "Anon upload festival-media"
    ON storage.objects FOR INSERT
    TO anon
    WITH CHECK (bucket_id = 'festival-media');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects'
    AND policyname = 'Anon update festival-media'
  ) THEN
    CREATE POLICY "Anon update festival-media"
    ON storage.objects FOR UPDATE
    TO anon
    USING (bucket_id = 'festival-media');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects'
    AND policyname = 'Anon delete festival-media'
  ) THEN
    CREATE POLICY "Anon delete festival-media"
    ON storage.objects FOR DELETE
    TO anon
    USING (bucket_id = 'festival-media');
  END IF;
END $$;

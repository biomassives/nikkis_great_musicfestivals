-- ================================================================
-- Add image_url to map_regions
-- Run in Supabase SQL Editor
-- ================================================================

ALTER TABLE map_regions ADD COLUMN IF NOT EXISTS image_url text;

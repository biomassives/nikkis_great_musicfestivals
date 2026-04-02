-- Add display_order column to tables that need it.
-- Safe to run multiple times (IF NOT EXISTS).

ALTER TABLE map_regions
  ADD COLUMN IF NOT EXISTS display_order INTEGER NOT NULL DEFAULT 0;

ALTER TABLE gallery_photos
  ADD COLUMN IF NOT EXISTS display_order INTEGER NOT NULL DEFAULT 0;

ALTER TABLE merch_items
  ADD COLUMN IF NOT EXISTS display_order INTEGER NOT NULL DEFAULT 0;

-- Seed initial ordering from row insertion order so existing rows aren't all 0.
UPDATE map_regions    SET display_order = sub.rn FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) - 1 AS rn FROM map_regions
) sub WHERE map_regions.id = sub.id AND map_regions.display_order = 0;

UPDATE gallery_photos SET display_order = sub.rn FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) - 1 AS rn FROM gallery_photos
) sub WHERE gallery_photos.id = sub.id AND gallery_photos.display_order = 0;

UPDATE merch_items    SET display_order = sub.rn FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) - 1 AS rn FROM merch_items
) sub WHERE merch_items.id = sub.id AND merch_items.display_order = 0;

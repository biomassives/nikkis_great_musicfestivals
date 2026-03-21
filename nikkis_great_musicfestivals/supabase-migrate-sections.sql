-- ============================================================
-- Sections + Staging migration
-- Requires: supabase-migrate-settings.sql to have been run first
-- ============================================================

-- Add published/staging column (DEFAULT true keeps all existing content visible)
ALTER TABLE gallery_photos ADD COLUMN IF NOT EXISTS published boolean NOT NULL DEFAULT true;
ALTER TABLE merch_items    ADD COLUMN IF NOT EXISTS published boolean NOT NULL DEFAULT true;

-- Seed gallery sections metadata (skips if already present)
INSERT INTO site_settings (key, value) VALUES
('gallery_sections', '[
  {"slug":"outdoor",  "label":"Outdoor Adventures","description":"Trails, peaks, and wild places",                "icon":"forest",      "color":"green-8"},
  {"slug":"concert",  "label":"Music Concerts",    "description":"Live moments from the festival field",           "icon":"music_note",  "color":"amber-8"},
  {"slug":"cuteness", "label":"Daily Cuteness",    "description":"The little things that make the road worth it", "icon":"favorite",    "color":"pink-8"}
]'),
('merch_sections', '[
  {"slug":"art",    "label":"Art We Make","description":"Original paintings, prints, and handcrafted pieces created during the tour",  "icon":"palette",       "color":"deep-purple"},
  {"slug":"photos", "label":"Photos",     "description":"Limited-edition festival prints, framed and fine art options available",       "icon":"photo_camera",  "color":"amber-8"},
  {"slug":"other",  "label":"Other Stuff","description":"Trail finds, festival collectibles, and curated goods from the road",          "icon":"star",          "color":"deep-orange"}
]')
ON CONFLICT (key) DO NOTHING;

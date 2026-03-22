-- ─────────────────────────────────────────────────────────────────────────────
-- Region hero carousel images — outdoors & music-by-campfire theme
-- Run in the Supabase SQL Editor (Dashboard → SQL Editor → New query)
--
-- Uses jsonb merge ( || ) so any existing youtube_id / archive_id fields are
-- preserved — only the 'images' array is added / replaced.
-- ─────────────────────────────────────────────────────────────────────────────

-- Mountain West (Rockies, Tetons, Glacier, Yellowstone)
INSERT INTO site_settings (key, value, updated_at)
VALUES (
  'region_hero_mountain-west',
  jsonb_build_object(
    'images', jsonb_build_array(
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1533130061792-64b345e4a833?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=1600&q=80'
    ),
    'archive_id', '',
    'archive_label', '',
    'youtube_id', '',
    'youtube_start', 0,
    'youtube_label', ''
  ),
  NOW()
)
ON CONFLICT (key) DO UPDATE SET
  value      = site_settings.value || jsonb_build_object('images', EXCLUDED.value->'images'),
  updated_at = NOW();

-- Southwest (Arizona, New Mexico, Utah red rocks, Nevada)
INSERT INTO site_settings (key, value, updated_at)
VALUES (
  'region_hero_southwest',
  jsonb_build_object(
    'images', jsonb_build_array(
      'https://images.unsplash.com/photo-1509316785289-025f5b846b35?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1474044159687-1ee9f3a51722?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1494587351196-bbf5f29cff42?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=1600&q=80'
    ),
    'archive_id', '',
    'archive_label', '',
    'youtube_id', '',
    'youtube_start', 0,
    'youtube_label', ''
  ),
  NOW()
)
ON CONFLICT (key) DO UPDATE SET
  value      = site_settings.value || jsonb_build_object('images', EXCLUDED.value->'images'),
  updated_at = NOW();

-- Pacific Northwest (Oregon, Washington forests & coast)
INSERT INTO site_settings (key, value, updated_at)
VALUES (
  'region_hero_pacific-northwest',
  jsonb_build_object(
    'images', jsonb_build_array(
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1533130061792-64b345e4a833?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=1600&q=80'
    ),
    'archive_id', '',
    'archive_label', '',
    'youtube_id', '',
    'youtube_start', 0,
    'youtube_label', ''
  ),
  NOW()
)
ON CONFLICT (key) DO UPDATE SET
  value      = site_settings.value || jsonb_build_object('images', EXCLUDED.value->'images'),
  updated_at = NOW();

-- Great Lakes (Michigan, Wisconsin, Minnesota, Ohio shores)
INSERT INTO site_settings (key, value, updated_at)
VALUES (
  'region_hero_great-lakes',
  jsonb_build_object(
    'images', jsonb_build_array(
      'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1519659528534-7fd733a832a0?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1494587351196-bbf5f29cff42?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=1600&q=80'
    ),
    'archive_id', '',
    'archive_label', '',
    'youtube_id', '',
    'youtube_start', 0,
    'youtube_label', ''
  ),
  NOW()
)
ON CONFLICT (key) DO UPDATE SET
  value      = site_settings.value || jsonb_build_object('images', EXCLUDED.value->'images'),
  updated_at = NOW();

-- Southeast (Tennessee, Appalachians, Georgia, Virginia, Kentucky)
INSERT INTO site_settings (key, value, updated_at)
VALUES (
  'region_hero_southeast',
  jsonb_build_object(
    'images', jsonb_build_array(
      'https://images.unsplash.com/photo-1504198322253-cfa87a0ff25f?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1530973428-5bf2db2e4d71?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1533130061792-64b345e4a833?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=1600&q=80'
    ),
    'archive_id', '',
    'archive_label', '',
    'youtube_id', '',
    'youtube_start', 0,
    'youtube_label', ''
  ),
  NOW()
)
ON CONFLICT (key) DO UPDATE SET
  value      = site_settings.value || jsonb_build_object('images', EXCLUDED.value->'images'),
  updated_at = NOW();

-- Northeast (Vermont, Maine, New Hampshire, New England coast)
INSERT INTO site_settings (key, value, updated_at)
VALUES (
  'region_hero_northeast',
  jsonb_build_object(
    'images', jsonb_build_array(
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1569587112025-0d460e81a126?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1494587351196-bbf5f29cff42?auto=format&fit=crop&w=1600&q=80',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=1600&q=80'
    ),
    'archive_id', '',
    'archive_label', '',
    'youtube_id', '',
    'youtube_start', 0,
    'youtube_label', ''
  ),
  NOW()
)
ON CONFLICT (key) DO UPDATE SET
  value      = site_settings.value || jsonb_build_object('images', EXCLUDED.value->'images'),
  updated_at = NOW();

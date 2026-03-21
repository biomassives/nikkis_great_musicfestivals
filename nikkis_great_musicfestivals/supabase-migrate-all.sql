-- ================================================================
-- FULL DATABASE MIGRATION — safe to run on a blank or existing DB
-- Run this file to bring everything up to date.
-- ================================================================

-- ── newsletter_subscribers ────────────────────────────────────────
create table if not exists newsletter_subscribers (
  id         uuid primary key default gen_random_uuid(),
  email      text unique not null,
  created_at timestamptz default now()
);
alter table newsletter_subscribers enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='newsletter_subscribers' and policyname='Public subscribe') then
    create policy "Public subscribe" on newsletter_subscribers for insert with check (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='newsletter_subscribers' and policyname='Auth read subscribers') then
    create policy "Auth read subscribers" on newsletter_subscribers for select using (auth.role() = 'authenticated');
  end if;
  if not exists (select 1 from pg_policies where tablename='newsletter_subscribers' and policyname='Test anon read newsletter') then
    create policy "Test anon read newsletter" on newsletter_subscribers for select to anon using (true);
  end if;
end $$;

-- ── map_regions ───────────────────────────────────────────────────
create table if not exists map_regions (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  description   text,
  center_lat    double precision not null,
  center_lng    double precision not null,
  zoom          int default 7,
  display_order int default 0
);
alter table map_regions enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='map_regions' and policyname='Public read regions') then
    create policy "Public read regions" on map_regions for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='map_regions' and policyname='Test anon write regions') then
    create policy "Test anon write regions" on map_regions for all to anon using (true) with check (true);
  end if;
end $$;

-- ── map_points ────────────────────────────────────────────────────
create table if not exists map_points (
  id          uuid primary key default gen_random_uuid(),
  region_id   uuid references map_regions(id) on delete cascade,
  category    text not null,
  name        text not null,
  lat         double precision not null,
  lng         double precision not null,
  date        text,
  description text,
  image_url   text
);
alter table map_points enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='map_points' and policyname='Public read points') then
    create policy "Public read points" on map_points for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='map_points' and policyname='Test anon write points') then
    create policy "Test anon write points" on map_points for all to anon using (true) with check (true);
  end if;
end $$;

-- ── gallery_photos ────────────────────────────────────────────────
create table if not exists gallery_photos (
  id            uuid primary key default gen_random_uuid(),
  category      text not null,
  url           text not null,
  caption       text,
  display_order int default 0,
  published     boolean not null default true,
  created_at    timestamptz default now()
);
-- Drop old hardcoded CHECK constraint on category (blocks dynamic sections)
do $$ begin
  if exists (select 1 from pg_constraint where conname = 'gallery_photos_category_check') then
    alter table gallery_photos drop constraint gallery_photos_category_check;
  end if;
end $$;
alter table gallery_photos add column if not exists published boolean not null default true;
alter table gallery_photos enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='gallery_photos' and policyname='Public read gallery') then
    create policy "Public read gallery" on gallery_photos for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='gallery_photos' and policyname='Test anon write gallery') then
    create policy "Test anon write gallery" on gallery_photos for all to anon using (true) with check (true);
  end if;
end $$;

-- ── newsletters ───────────────────────────────────────────────────
create table if not exists newsletters (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  subject    text,
  body       text,
  sent_at    timestamptz,
  created_at timestamptz default now()
);
alter table newsletters enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='newsletters' and policyname='Test anon write newsletters') then
    create policy "Test anon write newsletters" on newsletters for all to anon using (true) with check (true);
  end if;
end $$;

-- ── news_articles ─────────────────────────────────────────────────
create table if not exists news_articles (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  date       text,
  icon       text default 'star',
  color      text default 'amber',
  body       text,
  tags       text[] default '{}',
  image_url  text,
  published  boolean default true,
  created_at timestamptz default now()
);
alter table news_articles enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='news_articles' and policyname='Public read news') then
    create policy "Public read news" on news_articles for select using (published = true);
  end if;
  if not exists (select 1 from pg_policies where tablename='news_articles' and policyname='Test anon write news') then
    create policy "Test anon write news" on news_articles for all to anon using (true) with check (true);
  end if;
end $$;

-- ── merch_items ───────────────────────────────────────────────────
create table if not exists merch_items (
  id            uuid primary key default gen_random_uuid(),
  category      text not null,
  name          text not null,
  description   text,
  price         text,
  image_url     text,
  badge         text,
  sold_out      boolean default false,
  published     boolean not null default true,
  display_order int default 0,
  created_at    timestamptz default now()
);
-- Drop old hardcoded CHECK constraint on category (blocks dynamic sections)
do $$ begin
  if exists (select 1 from pg_constraint where conname = 'merch_items_category_check') then
    alter table merch_items drop constraint merch_items_category_check;
  end if;
end $$;
alter table merch_items add column if not exists published boolean not null default true;
alter table merch_items enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='merch_items' and policyname='Public read merch') then
    create policy "Public read merch" on merch_items for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='merch_items' and policyname='Test anon write merch') then
    create policy "Test anon write merch" on merch_items for all to anon using (true) with check (true);
  end if;
end $$;

-- ── site_settings ─────────────────────────────────────────────────
create table if not exists site_settings (
  key        text primary key,
  value      jsonb not null default '{}',
  updated_at timestamptz default now()
);
alter table site_settings enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='site_settings' and policyname='Public read settings') then
    create policy "Public read settings" on site_settings for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='site_settings' and policyname='Test anon write settings') then
    create policy "Test anon write settings" on site_settings for all to anon using (true) with check (true);
  end if;
end $$;

-- ── Seed site_settings ────────────────────────────────────────────
insert into site_settings (key, value) values
('homepage_content', '{
  "hero_title":        "Nikki''s Great Music Festivals",
  "mission_statement": "Helping to improve lives by improving access to great music, community, and the outdoors.",
  "cta_story_label":   "Our Full Story",
  "cta_tour_label":    "Explore the Tour",
  "artists_label":     "Artist Interviews",
  "artists_title":     "Featured Artists",
  "subscribe_title":   "Join the Newsletter Adventure",
  "subscribe_body":    "Show dates, artist interviews, trail reports, and community stories — straight to your inbox."
}'),
('homepage_appearance', '{
  "bg_image_url": null, "bg_variant": "home", "bg_opacity": 0.09, "footer_default_night": false
}'),
('homepage_seo', '{
  "site_name":        "Nikki''s Great Music Festivals",
  "og_title":         "Nikki''s Great Music Festivals — Tour Maps, Live Music & Community",
  "og_description":   "Follow the festival trail — tour maps, artist interviews, photography, and community across the US.",
  "og_image":         null,
  "og_url":           "https://nikkisgreatmusicfestivals.vercel.app",
  "meta_description": "Festival tour maps, artist interviews, trail photography and community — Nikki''s Great Music Festivals.",
  "meta_keywords":    "music festivals, bluegrass, outdoor concerts, Billy Strings, Leftover Salmon, Stringdusters",
  "twitter_card":     "summary_large_image",
  "twitter_site":     null,
  "twitter_creator":  null
}'),
('gallery_sections', '[
  {"slug":"outdoor",  "label":"Outdoor Adventures","description":"Trails, peaks, and wild places",                "icon":"forest",     "color":"green-8"},
  {"slug":"concert",  "label":"Music Concerts",    "description":"Live moments from the festival field",           "icon":"music_note", "color":"amber-8"},
  {"slug":"cuteness", "label":"Daily Cuteness",    "description":"The little things that make the road worth it", "icon":"favorite",   "color":"pink-8"}
]'),
('merch_sections', '[
  {"slug":"art",    "label":"Art We Make","description":"Original paintings, prints, and handcrafted pieces created during the tour", "icon":"palette",      "color":"deep-purple"},
  {"slug":"photos", "label":"Photos",     "description":"Limited-edition festival prints, framed and fine art options available",      "icon":"photo_camera", "color":"amber-8"},
  {"slug":"other",  "label":"Other Stuff","description":"Trail finds, festival collectibles, and curated goods from the road",         "icon":"star",         "color":"deep-orange"}
]')
on conflict (key) do nothing;

-- ── Seed sample data ──────────────────────────────────────────────
insert into gallery_photos (category, url, caption, display_order) values
  ('outdoor', 'https://picsum.photos/seed/hike1/800/600',  'Blue Ridge Parkway at dusk',        1),
  ('outdoor', 'https://picsum.photos/seed/hike2/800/600',  'Lost Gulch Overlook, Boulder CO',   2),
  ('outdoor', 'https://picsum.photos/seed/hike3/800/600',  'Columbia River Gorge waterfall',    3),
  ('concert', 'https://picsum.photos/seed/music1/800/600', 'Red Rocks — Billy Strings night 1', 1),
  ('concert', 'https://picsum.photos/seed/music2/800/600', 'Planet Bluegrass main stage',       2),
  ('cuteness','https://picsum.photos/seed/cute1/800/600',  'Festival dog approved',             1),
  ('cuteness','https://picsum.photos/seed/cute2/800/600',  'Trail buddy selfie',                2)
on conflict do nothing;

insert into news_articles (title, date, icon, color, body, tags, published) values
  ('Red Rocks — Billy Strings Night 1', 'July 12, 2026', 'star', 'amber',
   'An absolutely transcendent night at Red Rocks. Billy opened with a 25-minute "Meet Me at the Creek" that had the whole amphitheater on their feet by the second verse.',
   ARRAY['Billy Strings','Red Rocks','Mountain West'], true),
  ('Planet Bluegrass — Rocky Mtn Folks Festival', 'July 18, 2026', 'music_note', 'deep-orange',
   'Leftover Salmon headlined Saturday night on the main stage and played a nearly three-hour set.',
   ARRAY['Leftover Salmon','Planet Bluegrass','Colorado'], true),
  ('Bonnaroo — The Farm, Tennessee', 'June 14, 2026', 'festival', 'purple',
   'The Infamous Stringdusters closed out the Which Stage on Friday night.',
   ARRAY['Stringdusters','Bonnaroo','Southeast'], true)
on conflict do nothing;

insert into merch_items (category, name, description, price, image_url, badge, sold_out, display_order) values
  ('art',    'Mountain Mandala — Original',   'Ink and watercolour on 140lb cold-press. 9"×9". Signed, unframed.',    '$180', 'https://picsum.photos/seed/art1/400/400',   'Original', false, 1),
  ('art',    'Stage Glow — Print',            'Giclee print of oil pastel stage-light study. 8"×10". Archival paper.','$45',  'https://picsum.photos/seed/art2/400/400',   null,       false, 2),
  ('photos', 'Billy Strings — Stage Right',   '12"×16" fine art print, fuji crystal archive paper, ready to frame.',  '$65',  'https://picsum.photos/seed/photo1/400/400', 'Fan Fave', false, 1),
  ('photos', 'Sunrise Over the Field',        'Early morning campground mist. 11"×14" lustre print.',                 '$55',  'https://picsum.photos/seed/photo2/400/400', null,       false, 2),
  ('other',  'Enamel Festival Pin Set',       '4-pin set with frog, mandala, mountain, and music note designs.',      '$28',  'https://picsum.photos/seed/other1/400/400', 'Bestseller', false, 1),
  ('other',  'Hand-dyed Bandana',             'Tie-dye cotton bandana in festival-purple and gold.',                  '$22',  'https://picsum.photos/seed/other2/400/400', null, false, 2)
on conflict do nothing;

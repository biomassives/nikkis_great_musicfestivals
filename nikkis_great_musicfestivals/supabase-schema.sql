-- ===========================================
-- Nikki's Great Music Festivals — Supabase Schema
-- Run this in your Supabase SQL Editor
-- ===========================================

-- Map Regions (Mountain West, Southeast, etc.)
create table if not exists map_regions (
  id            text primary key,          -- e.g. "mountain-west"
  name          text not null,             -- e.g. "Mountain West"
  description   text,
  center_lat    float not null,
  center_lng    float not null,
  zoom          int default 7,
  display_order int default 0,
  created_at    timestamptz default now()
);

-- Map Points (shows, senior facilities, must-see nature)
create table if not exists map_points (
  id          uuid primary key default gen_random_uuid(),
  region_id   text references map_regions(id) on delete cascade,
  category    text check (category in ('show', 'senior', 'nature')) not null,
  name        text not null,
  lat         float not null,
  lng         float not null,
  date        text,           -- e.g. "2026-07-12"
  description text,
  image_url   text,
  created_at  timestamptz default now()
);

-- Enable public read access (no auth needed to view map data)
alter table map_regions enable row level security;
alter table map_points  enable row level security;

create policy "Public read map_regions"  on map_regions for select using (true);
create policy "Public read map_points"   on map_points  for select using (true);

-- Only authenticated users (Nikki) can write
create policy "Auth write map_regions"   on map_regions for all using (auth.role() = 'authenticated');
create policy "Auth write map_points"    on map_points  for all using (auth.role() = 'authenticated');

-- ===========================================
-- Seed: 6 Regions
-- ===========================================
insert into map_regions (id, name, description, center_lat, center_lng, zoom, display_order) values
  ('mountain-west',    'Mountain West',     'Colorado, Utah, Wyoming, Montana',           41.5, -107.0, 6, 1),
  ('southwest',        'Southwest',         'Arizona, New Mexico, Nevada, West Texas',    33.5, -111.0, 6, 2),
  ('pacific-northwest','Pacific Northwest', 'Washington, Oregon, Northern California',   46.5, -122.0, 6, 3),
  ('great-lakes',      'Great Lakes',       'Michigan, Ohio, Illinois, Wisconsin',        43.5,  -87.0, 6, 4),
  ('southeast',        'Southeast',         'Georgia, Tennessee, North Carolina, Florida',33.0,  -85.0, 6, 5),
  ('northeast',        'Northeast',         'New York, New England, Pennsylvania',        42.5,  -74.0, 6, 6)
on conflict (id) do nothing;

-- ===========================================
-- Seed: Sample Points (Mountain West)
-- ===========================================
insert into map_points (region_id, category, name, lat, lng, date, description) values
  ('mountain-west', 'show',   'Red Rocks Amphitheatre',    39.6654, -105.2057, '2026-07-12', 'Billy Strings Night 1 — iconic canyon venue'),
  ('mountain-west', 'show',   'Planet Bluegrass',          40.2241, -105.2714, '2026-07-18', 'Rocky Mountain Folks Festival — Leftover Salmon'),
  ('mountain-west', 'nature', 'Lost Gulch Overlook',       40.0025, -105.3400, null,         'Panoramic Boulder canyon photography spot'),
  ('mountain-west', 'senior', 'The Pearl at Boulder Creek',40.0150, -105.2705, null,         'Assisted living — share the music'),

  ('southeast', 'show',   'Bonnaroo Farm',               35.4882,  -86.0306, '2026-06-14', 'Great stage — multi-day camping festival'),
  ('southeast', 'show',   'Rabbit Rabbit Asheville',     35.5727,  -82.5531, '2026-06-20', 'Incredible Stringdusters hometown show'),
  ('southeast', 'nature', 'Blue Ridge Parkway Overlook', 35.7500,  -82.3000, null,         'Breathtaking mountain drive'),

  ('pacific-northwest', 'show', 'Pickathon Festival Grounds', 45.4400, -122.4200, '2026-08-01', 'Powell Butte farm — intimate stage magic'),
  ('pacific-northwest', 'nature', 'Columbia River Gorge',     45.7022, -121.5000, null,          'Waterfall highway — must photograph'),

  ('great-lakes', 'show', 'Interlochen Center for the Arts', 44.6700, -85.7800, '2026-07-25', 'Pine forest amphitheater — magical setting'),

  ('northeast', 'show', 'Catskill Crest Amphitheatre', 42.0900, -74.3000, '2026-08-10', 'Mountain top bluegrass weekend'),

  ('southwest', 'show', 'Rialto Theatre Tucson',     32.2198, -110.9693, '2026-05-10', 'Southwest leg opener — intimate show')
on conflict do nothing;

-- ===========================================
-- Newsletter Subscribers
-- ===========================================
create table if not exists newsletter_subscribers (
  email      text primary key,
  created_at timestamptz default now()
);
alter table newsletter_subscribers enable row level security;
create policy "Public insert newsletter" on newsletter_subscribers for insert with check (true);
create policy "Auth read newsletter"     on newsletter_subscribers for select using (auth.role() = 'authenticated');

-- ===========================================
-- Members (Stripe subscriptions)
-- ===========================================
create table if not exists members (
  id                     uuid primary key default gen_random_uuid(),
  email                  text,
  stripe_customer_id     text unique,
  stripe_subscription_id text unique,
  status                 text default 'active',
  created_at             timestamptz default now(),
  updated_at             timestamptz default now()
);
alter table members enable row level security;
create policy "Auth read members" on members for select using (auth.role() = 'authenticated');
create policy "Auth write members" on members for all using (auth.role() = 'authenticated');

-- ===========================================
-- Gallery Photos
-- ===========================================
create table if not exists gallery_photos (
  id            uuid primary key default gen_random_uuid(),
  category      text check (category in ('outdoor', 'concert', 'cuteness')) not null,
  url           text not null,
  caption       text,
  display_order int default 0,
  created_at    timestamptz default now()
);
alter table gallery_photos enable row level security;
create policy "Public read gallery"  on gallery_photos for select using (true);
create policy "Auth write gallery"   on gallery_photos for all   using (auth.role() = 'authenticated');

-- ===========================================
-- Newsletters
-- ===========================================
create table if not exists newsletters (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  subject    text,
  body       text,
  sent_at    timestamptz,
  created_at timestamptz default now()
);
alter table newsletters enable row level security;
create policy "Auth access newsletters" on newsletters for all using (auth.role() = 'authenticated');

-- Seed a few sample gallery photos (picsum placeholders)
insert into gallery_photos (category, url, caption, display_order) values
  ('outdoor', 'https://picsum.photos/seed/hike1/800/600',  'Blue Ridge Parkway at dusk',        1),
  ('outdoor', 'https://picsum.photos/seed/hike2/800/600',  'Lost Gulch Overlook, Boulder CO',   2),
  ('outdoor', 'https://picsum.photos/seed/hike3/800/600',  'Columbia River Gorge waterfall',    3),
  ('outdoor', 'https://picsum.photos/seed/hike4/800/600',  'Rocky Mountain fog morning',        4),
  ('concert', 'https://picsum.photos/seed/music1/800/600', 'Red Rocks — Billy Strings night 1', 1),
  ('concert', 'https://picsum.photos/seed/music2/800/600', 'Planet Bluegrass main stage',       2),
  ('concert', 'https://picsum.photos/seed/music3/800/600', 'Bonnaroo crowd energy',             3),
  ('concert', 'https://picsum.photos/seed/music4/800/600', 'Pickathon forest stage',            4),
  ('cuteness','https://picsum.photos/seed/cute1/800/600',  'Festival dog approved',             1),
  ('cuteness','https://picsum.photos/seed/cute2/800/600',  'Trail buddy selfie',                2),
  ('cuteness','https://picsum.photos/seed/cute3/800/600',  'Camp morning vibes',                3),
  ('cuteness','https://picsum.photos/seed/cute4/800/600',  'Sunset hammock crew',               4)
on conflict do nothing;

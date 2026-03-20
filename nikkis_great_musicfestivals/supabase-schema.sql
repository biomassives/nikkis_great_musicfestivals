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

-- ===========================================
-- News Articles
-- ===========================================
create table if not exists news_articles (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  date        text,                    -- display string e.g. "July 12, 2026"
  icon        text default 'star',     -- material icon name
  color       text default 'amber',    -- quasar color
  body        text,
  tags        text[] default '{}',
  image_url   text,
  published   boolean default true,
  created_at  timestamptz default now()
);
alter table news_articles enable row level security;
create policy "Public read news"  on news_articles for select using (published = true);
create policy "Auth write news"   on news_articles for all   using (auth.role() = 'authenticated');

-- Seed sample news articles
insert into news_articles (title, date, icon, color, body, tags, published) values
  ('Red Rocks — Billy Strings Night 1', 'July 12, 2026', 'star', 'amber',
   'An absolutely transcendent night at Red Rocks. Billy opened with a 25-minute "Meet Me at the Creek" that had the whole amphitheater on their feet by the second verse. The canyon walls bounced the sound into something otherworldly.',
   ARRAY['Billy Strings','Red Rocks','Mountain West'], true),
  ('Planet Bluegrass — Rocky Mtn Folks Festival', 'July 18, 2026', 'music_note', 'deep-orange',
   'Leftover Salmon headlined the Saturday night on the main stage and played a nearly three-hour set. Vince Herman told stories between every song. The kind of show you tell your grandkids about.',
   ARRAY['Leftover Salmon','Planet Bluegrass','Colorado'], true),
  ('Bonnaroo — The Farm, Tennessee', 'June 14, 2026', 'festival', 'purple',
   'The Infamous Stringdusters closed out the Which Stage on Friday night. Silver Sky into Fork in the Road — the field went absolutely still, then erupted. Festival season officially opened.',
   ARRAY['Stringdusters','Bonnaroo','Southeast'], true)
on conflict do nothing;

-- ===========================================
-- Merch Items
-- ===========================================
create table if not exists merch_items (
  id            uuid primary key default gen_random_uuid(),
  category      text check (category in ('art','photos','other')) not null,
  name          text not null,
  description   text,
  price         text,             -- display string e.g. "$45"
  image_url     text,
  badge         text,             -- "New", "Limited", "Fan Fave", etc.
  sold_out      boolean default false,
  display_order int default 0,
  created_at    timestamptz default now()
);
alter table merch_items enable row level security;
create policy "Public read merch" on merch_items for select using (true);
create policy "Auth write merch"  on merch_items for all   using (auth.role() = 'authenticated');

-- Seed sample merch items
insert into merch_items (category, name, description, price, image_url, badge, sold_out, display_order) values
  ('art',    'Mountain Mandala — Original',  'Ink and watercolour on 140lb cold-press. 9"×9". Signed, unframed.',              '$180', 'https://picsum.photos/seed/art1/400/400',   'Original', false, 1),
  ('art',    'Stage Glow — Print',           'Giclee print of oil pastel stage-light study. 8"×10". Archival paper.',           '$45',  'https://picsum.photos/seed/art2/400/400',   null,       false, 2),
  ('art',    'Desert Road Triptych',         'Set of three 5"×7" prints. Signed edition of 50.',                               '$75',  'https://picsum.photos/seed/art3/400/400',   'Limited',  false, 3),
  ('art',    'Festival Camp — Acrylic',      'Small acrylic on wood panel. 6"×6". One of a kind.',                             '$120', 'https://picsum.photos/seed/art4/400/400',   null,       true,  4),
  ('photos', 'Billy Strings — Stage Right',  '12"×16" fine art print, fuji crystal archive paper, ready to frame.',            '$65',  'https://picsum.photos/seed/photo1/400/400', 'Fan Fave', false, 1),
  ('photos', 'Sunrise Over the Field',       'Early morning campground mist. 11"×14" lustre print.',                           '$55',  'https://picsum.photos/seed/photo2/400/400', null,       false, 2),
  ('photos', 'Crowd Hands — Panoramic',      'Wide-angle crowd shot during a full-field singalong. 20"×8".',                   '$80',  'https://picsum.photos/seed/photo3/400/400', 'Limited',  false, 3),
  ('other',  'Enamel Festival Pin Set',      '4-pin set with frog, mandala, mountain, and music note designs.',                '$28',  'https://picsum.photos/seed/other1/400/400', 'Bestseller',false,1),
  ('other',  'Hand-dyed Bandana',            'Tie-dye cotton bandana in festival-purple and gold. One per dye.',               '$22',  'https://picsum.photos/seed/other2/400/400', null,       false, 2),
  ('other',  'Nikki''s Great Festivals Tote','Heavy cotton tote with screen-printed frog logo. 15"×17". Natural.',             '$30',  'https://picsum.photos/seed/other4/400/400', 'New',      false, 3)
on conflict do nothing;

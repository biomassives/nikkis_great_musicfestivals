-- ===========================================
-- Migration: add gallery, newsletters, news,
-- and merch tables (safe to run if they exist)
-- ===========================================

-- Gallery Photos
create table if not exists gallery_photos (
  id            uuid primary key default gen_random_uuid(),
  category      text check (category in ('outdoor', 'concert', 'cuteness')) not null,
  url           text not null,
  caption       text,
  display_order int default 0,
  created_at    timestamptz default now()
);
alter table gallery_photos enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='gallery_photos' and policyname='Public read gallery') then
    create policy "Public read gallery" on gallery_photos for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='gallery_photos' and policyname='Auth write gallery') then
    create policy "Auth write gallery" on gallery_photos for all using (auth.role() = 'authenticated');
  end if;
  if not exists (select 1 from pg_policies where tablename='gallery_photos' and policyname='Test anon write gallery') then
    create policy "Test anon write gallery" on gallery_photos for all to anon using (true) with check (true);
  end if;
end $$;

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

-- Newsletters
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
  if not exists (select 1 from pg_policies where tablename='newsletters' and policyname='Auth access newsletters') then
    create policy "Auth access newsletters" on newsletters for all using (auth.role() = 'authenticated');
  end if;
  if not exists (select 1 from pg_policies where tablename='newsletters' and policyname='Test anon write newsletters') then
    create policy "Test anon write newsletters" on newsletters for all to anon using (true) with check (true);
  end if;
end $$;

-- News Articles
create table if not exists news_articles (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  date        text,
  icon        text default 'star',
  color       text default 'amber',
  body        text,
  tags        text[] default '{}',
  image_url   text,
  published   boolean default true,
  created_at  timestamptz default now()
);
alter table news_articles enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='news_articles' and policyname='Public read news') then
    create policy "Public read news" on news_articles for select using (published = true);
  end if;
  if not exists (select 1 from pg_policies where tablename='news_articles' and policyname='Auth write news') then
    create policy "Auth write news" on news_articles for all using (auth.role() = 'authenticated');
  end if;
  if not exists (select 1 from pg_policies where tablename='news_articles' and policyname='Test anon write news') then
    create policy "Test anon write news" on news_articles for all to anon using (true) with check (true);
  end if;
end $$;

insert into news_articles (title, date, icon, color, body, tags, published) values
  ('Red Rocks — Billy Strings Night 1', 'July 12, 2026', 'star', 'amber',
   'An absolutely transcendent night at Red Rocks. Billy opened with a 25-minute "Meet Me at the Creek" that had the whole amphitheater on their feet by the second verse.',
   ARRAY['Billy Strings','Red Rocks','Mountain West'], true),
  ('Planet Bluegrass — Rocky Mtn Folks Festival', 'July 18, 2026', 'music_note', 'deep-orange',
   'Leftover Salmon headlined the Saturday night on the main stage and played a nearly three-hour set.',
   ARRAY['Leftover Salmon','Planet Bluegrass','Colorado'], true),
  ('Bonnaroo — The Farm, Tennessee', 'June 14, 2026', 'festival', 'purple',
   'The Infamous Stringdusters closed out the Which Stage on Friday night.',
   ARRAY['Stringdusters','Bonnaroo','Southeast'], true)
on conflict do nothing;

-- Merch Items
create table if not exists merch_items (
  id            uuid primary key default gen_random_uuid(),
  category      text check (category in ('art','photos','other')) not null,
  name          text not null,
  description   text,
  price         text,
  image_url     text,
  badge         text,
  sold_out      boolean default false,
  display_order int default 0,
  created_at    timestamptz default now()
);
alter table merch_items enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='merch_items' and policyname='Public read merch') then
    create policy "Public read merch" on merch_items for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='merch_items' and policyname='Auth write merch') then
    create policy "Auth write merch" on merch_items for all using (auth.role() = 'authenticated');
  end if;
  if not exists (select 1 from pg_policies where tablename='merch_items' and policyname='Test anon write merch') then
    create policy "Test anon write merch" on merch_items for all to anon using (true) with check (true);
  end if;
end $$;

insert into merch_items (category, name, description, price, image_url, badge, sold_out, display_order) values
  ('art',    'Mountain Mandala — Original',   'Ink and watercolour on 140lb cold-press. 9"×9". Signed, unframed.',    '$180', 'https://picsum.photos/seed/art1/400/400',   'Original',   false, 1),
  ('art',    'Stage Glow — Print',            'Giclee print of oil pastel stage-light study. 8"×10". Archival paper.','$45',  'https://picsum.photos/seed/art2/400/400',   null,         false, 2),
  ('art',    'Desert Road Triptych',          'Set of three 5"×7" prints. Signed edition of 50.',                     '$75',  'https://picsum.photos/seed/art3/400/400',   'Limited',    false, 3),
  ('art',    'Festival Camp — Acrylic',       'Small acrylic on wood panel. 6"×6". One of a kind.',                   '$120', 'https://picsum.photos/seed/art4/400/400',   null,         true,  4),
  ('photos', 'Billy Strings — Stage Right',   '12"×16" fine art print, fuji crystal archive paper, ready to frame.',  '$65',  'https://picsum.photos/seed/photo1/400/400', 'Fan Fave',   false, 1),
  ('photos', 'Sunrise Over the Field',        'Early morning campground mist. 11"×14" lustre print.',                 '$55',  'https://picsum.photos/seed/photo2/400/400', null,         false, 2),
  ('photos', 'Crowd Hands — Panoramic',       'Wide-angle crowd shot during a full-field singalong. 20"×8".',         '$80',  'https://picsum.photos/seed/photo3/400/400', 'Limited',    false, 3),
  ('other',  'Enamel Festival Pin Set',       '4-pin set with frog, mandala, mountain, and music note designs.',      '$28',  'https://picsum.photos/seed/other1/400/400', 'Bestseller', false, 1),
  ('other',  'Hand-dyed Bandana',             'Tie-dye cotton bandana in festival-purple and gold.',                  '$22',  'https://picsum.photos/seed/other2/400/400', null,         false, 2),
  ('other',  'Nikki''s Great Festivals Tote', 'Heavy cotton tote with screen-printed frog logo. 15"×17". Natural.',  '$30',  'https://picsum.photos/seed/other4/400/400', 'New',        false, 3)
on conflict do nothing;

-- Also open up newsletter_subscribers for anon read (admin list view)
do $$ begin
  if not exists (select 1 from pg_policies where tablename='newsletter_subscribers' and policyname='Test anon read newsletter') then
    create policy "Test anon read newsletter" on newsletter_subscribers for select to anon using (true);
  end if;
end $$;

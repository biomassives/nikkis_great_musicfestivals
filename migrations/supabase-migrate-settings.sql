-- ===========================================
-- site_settings table — homepage content, appearance, SEO
-- ===========================================
create table if not exists site_settings (
  key        text primary key,
  value      jsonb not null default '{}',
  updated_at timestamptz default now()
);
alter table site_settings enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where tablename='site_settings' and policyname='Public read settings') then
    create policy "Public read settings"     on site_settings for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='site_settings' and policyname='Auth write settings') then
    create policy "Auth write settings"      on site_settings for all    using (auth.role() = 'authenticated');
  end if;
  if not exists (select 1 from pg_policies where tablename='site_settings' and policyname='Test anon write settings') then
    create policy "Test anon write settings" on site_settings for all to anon using (true) with check (true);
  end if;
end $$;

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
  "bg_image_url":          null,
  "bg_variant":            "home",
  "bg_opacity":            0.09,
  "footer_default_night":  false
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
}')
on conflict (key) do nothing;

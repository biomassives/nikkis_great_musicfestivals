-- ===========================================
-- Restore production RLS — run after testing
-- Drops the temporary open-access policies
-- ===========================================

drop policy if exists "Test anon write map_regions"     on map_regions;
drop policy if exists "Test anon write map_points"      on map_points;
drop policy if exists "Test anon write gallery"         on gallery_photos;
drop policy if exists "Test anon read newsletter"       on newsletter_subscribers;
drop policy if exists "Test anon write newsletter_subs" on newsletter_subscribers;
drop policy if exists "Test anon write newsletters"     on newsletters;
drop policy if exists "Test anon write news"            on news_articles;
drop policy if exists "Test anon write merch"           on merch_items;

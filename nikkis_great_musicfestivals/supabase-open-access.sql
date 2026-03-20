-- ===========================================
-- TEMPORARY: Open anon access for local testing
-- Run this in Supabase SQL Editor to allow all
-- admin operations without logging in.
--
-- REVERT with supabase-restore-rls.sql before
-- going to production.
-- ===========================================

-- Map regions + points
create policy "Test anon write map_regions"
  on map_regions for all to anon using (true) with check (true);

create policy "Test anon write map_points"
  on map_points for all to anon using (true) with check (true);

-- Gallery
create policy "Test anon write gallery"
  on gallery_photos for all to anon using (true) with check (true);

-- Newsletter subscribers (add anon read too so admin list works)
create policy "Test anon read newsletter"
  on newsletter_subscribers for select to anon using (true);

create policy "Test anon write newsletter_subs"
  on newsletter_subscribers for all to anon using (true) with check (true);

-- Newsletters (compose / send)
create policy "Test anon write newsletters"
  on newsletters for all to anon using (true) with check (true);

-- News articles (including unpublished)
create policy "Test anon write news"
  on news_articles for all to anon using (true) with check (true);

-- Merch items
create policy "Test anon write merch"
  on merch_items for all to anon using (true) with check (true);

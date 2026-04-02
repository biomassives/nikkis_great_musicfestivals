-- ─────────────────────────────────────────────────────────────────────────────
--  site_changelog — curated log of DB changes, code deploys, and content edits
-- ─────────────────────────────────────────────────────────────────────────────

create table if not exists site_changelog (
  id          uuid        default gen_random_uuid() primary key,
  created_at  timestamptz default now(),
  category    text        not null default 'other',
  -- Suggested categories: code | design | content | data | db | media | fix | other
  summary     text        not null,
  description text,
  author      text,
  tags        text[]      default '{}'
);

-- RLS: anyone can read; only authenticated users can write
alter table site_changelog enable row level security;

create policy "changelog_public_read"   on site_changelog for select using (true);
create policy "changelog_admin_insert"  on site_changelog for insert  to authenticated with check (true);
create policy "changelog_admin_update"  on site_changelog for update  to authenticated using (true);
create policy "changelog_admin_delete"  on site_changelog for delete  to authenticated using (true);

-- ─────────────────────────────────────────────────────────────────────────────
--  Seed — history from git log + recent session changes
-- ─────────────────────────────────────────────────────────────────────────────

insert into site_changelog (created_at, category, summary, description, author, tags) values

-- ── Today (2026-03-24) — this session ────────────────────────────────────────
('2026-03-24 21:00:00+00', 'code',   'Archive.org live artist search in Header Design admin',
  'Added q-select with @filter to the region Header Design modal. Searches archive.org advancedsearch.php (free, no API key). Type an artist name, pick from dropdown — fills archive_id + archive_label automatically. 380ms debounce.',
  'claude', '{admin,audio,archive.org}'),

('2026-03-24 21:00:00+00', 'code',   'YouTube search helper in Header Design admin',
  'Added YouTube search UX to the Header Design modal. If VITE_YOUTUBE_API_KEY is set: live inline search dropdown via YouTube Data API v3. If not set (current): type artist name + click Open button to search YouTube in a new tab, then paste the URL back.',
  'claude', '{admin,audio,youtube}'),

('2026-03-24 20:45:00+00', 'code',   'Shared archive shows library (src/lib/archiveShows.ts)',
  'Extracted ARCHIVE_SHOWS from MapDetailPage.vue into a shared src/lib/archiveShows.ts. Added 3 new entries: Louis Armstrong · St. James Infirmary (1928), Benny Goodman · Sing Sing Sing (1937), Billie Holiday · Strange Fruit (1939). Both the admin and front-end player now import from the same source.',
  'claude', '{audio,archive.org,refactor}'),

('2026-03-24 20:30:00+00', 'design', 'Sun icon redesign — 32 tapered rays for richer starburst',
  'Replaced SpirographLogo sun from 8+8 pill-rects (16 rays) to 16 tapered triangle primaries + 16 tapered triangle secondaries (32 rays total). Primaries every 22.5° reaching r=19.5; secondaries offset 11.25° reaching r=15.5. Also expanded corona circle to r=20.',
  'claude', '{homepage,spirograph,svg}'),

('2026-03-24 20:30:00+00', 'design', 'Light theme hero title: warm orange-amber (#ff9800)',
  'Added body.body--light override so .hero-title uses color: #ff9800 (orange-amber) instead of inheriting Quasar''s dark text color. Also fixed .hero-mission in light mode from near-black rgba(26,10,46,0.82) to white rgba(255,255,255,0.85) — both were invisible on the dark hero background.',
  'claude', '{homepage,light-theme,design}'),

-- ── 2026-03-24 early morning ─────────────────────────────────────────────────
('2026-03-24 08:35:00+00', 'design', 'Dark homepage: star field, dog flip/woof, artist card contrast',
  'Added animated star-field to homepage background. Added flip + woof animation to dog element. Fixed artist card text contrast in dark mode.',
  'nikki', '{homepage,dark-mode,animation}'),

('2026-03-24 06:01:00+00', 'fix',    'Root package.json — API dependencies for Vercel functions',
  'Added root-level package.json listing the dependencies needed by the /api serverless functions (mailgun-js, stripe, @supabase/supabase-js). Vercel was failing to install them because it only looked at the root.',
  'nikki', '{vercel,api,fix}'),

-- ── 2026-03-23 ───────────────────────────────────────────────────────────────
('2026-03-23 23:51:00+00', 'fix',    'Force-redeploy to pick up updated Vercel env vars',
  'No code change — redeploy triggered after adding missing env vars in Vercel dashboard.',
  'nikki', '{vercel,deploy}'),

('2026-03-23 23:28:00+00', 'fix',    'Newsletter send-test: wrap all errors, improve auth fallback, add missing RLS policy',
  'send-test API endpoint now catches and surfaces all error types. Auth fallback uses Supabase anon key when JWT is absent. Added missing RLS policy that was causing 403s on the newsletter_subscribers table for the service role.',
  'nikki', '{newsletter,api,fix,rls}'),

('2026-03-23 21:05:00+00', 'code',   'Add Reply-To support to all outgoing emails',
  'MAILGUN_REPLY_TO env var now added to every email sent via Mailgun (newsletters, test sends, cuteness emails). Replies from recipients go to the configured address rather than bouncing.',
  'nikki', '{newsletter,email,mailgun}'),

('2026-03-23 20:29:00+00', 'fix',    'Fix test-to-self newsletter send: unblock button, error logging',
  'Admin newsletter panel "Send to Self" button was staying disabled after a failed send. Added proper error notifications and reset logic. Added server-side error logging to help diagnose Mailgun failures.',
  'nikki', '{newsletter,admin,fix}'),

('2026-03-23 20:16:00+00', 'content','Rename News → Blog across all UI labels and routes',
  'Updated nav labels, page titles, admin sidebar, and routes from "News" to "Blog & Updates" to better reflect the content type.',
  'nikki', '{nav,blog,rename}'),

('2026-03-23 19:42:00+00', 'fix',    'Harden admin auth: replace static secret with Supabase JWT',
  'All admin API endpoints now verify the Supabase JWT from the Authorization header instead of checking a static ADMIN_SECRET. Fixes a security gap and aligns with the rest of the auth model.',
  'nikki', '{auth,security,api}'),

-- ── 2026-03-23 afternoon ──────────────────────────────────────────────────────
('2026-03-23 22:33:00+00', 'fix',    'Move api/ directory to repo root for Vercel auto-detection',
  'Vercel only auto-detects /api functions at the repository root. Moved api/ from the subdirectory to the root so serverless functions are picked up automatically without extra vercel.json rewrites.',
  'nikki', '{vercel,api,deploy}'),

('2026-03-23 16:08:00+00', 'fix',    'vercel.json: remove invalid rootDirectory key',
  'rootDirectory must be set in the Vercel dashboard, not in vercel.json. Removing it from the file fixed a deployment config error.',
  'nikki', '{vercel,config,fix}'),

('2026-03-23 15:40:00+00', 'fix',    'Fix Vercel GitHub deployment — root-level vercel.json',
  'Added root-level vercel.json with outputDirectory pointing to the subdirectory build output so Vercel GitHub integration could find the built assets.',
  'nikki', '{vercel,deploy,fix}'),

-- ── 2026-03-22 ───────────────────────────────────────────────────────────────
('2026-03-22 12:21:00+00', 'code',   'General site work — layout and content updates',
  null, 'nikki', '{}'),

-- ── 2026-03-21 ───────────────────────────────────────────────────────────────
('2026-03-21 15:58:00+00', 'design', 'Map detail page UI updates',
  'Improvements to map region hero layout, player strip, and region card styling.',
  'nikki', '{maps,design}'),

('2026-03-21 11:04:00+00', 'fix',    'Admin page fixes — forms and save logic',
  null, 'nikki', '{admin}'),

-- ── 2026-03-20 ───────────────────────────────────────────────────────────────
('2026-03-20 18:11:00+00', 'fix',    'Fix admin routing: remove stale routes.js shadowing routes.ts',
  'A leftover routes.js was being loaded before routes.ts, masking all admin-side route definitions. Deleting routes.js restored correct routing.',
  'nikki', '{admin,router,fix}'),

('2026-03-20 18:11:00+00', 'code',   'Nominatim place-search autocomplete in map point editor',
  'Added live geocoding autocomplete to the lat/lng fields in the admin map point editor. Uses OpenStreetMap Nominatim API (free). Type a place name to search and click to fill coordinates.',
  'nikki', '{maps,admin,geocoding}');

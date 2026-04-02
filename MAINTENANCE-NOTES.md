# Maintenance Notes — Nikki's Great Music Festivals
*Last updated: 2026-03-31. Written for future-me and any collaborators.*

---

## What This Repo Is

A single-repo Vercel deployment combining:
- **Serverless API** (`/api/` at repo root) — TypeScript Vercel functions
- **SPA frontend** (`/nikkis_great_musicfestivals/` subfolder) — Vue 3 + Quasar 2
- **Backend** — Supabase (Postgres + Auth + Storage + RLS)
- **Payments** — Stripe (checkout sessions + webhooks)
- **Email** — Mailgun (newsletter broadcast + welcome emails)

Live domain: `https://lovelight.cc` · GitHub: `git@github.com:biomassives/nikkis_great_musicfestivals.git`

---

## Repo Layout

```
nikkis_great_musicfestivals/        ← GIT ROOT (also Vercel project root)
│
├── .git/                           ← git repo lives HERE, not in subfolder
├── vercel.json                     ← AUTHORITATIVE deployment config (Vercel reads this)
├── package.json                    ← dependencies for /api/ functions only
│
├── api/                            ← Vercel serverless functions (auto-discovered)
│   ├── _auth.ts                    ← shared JWT verification helper
│   ├── stripe-checkout.ts          ← creates Stripe checkout sessions
│   ├── stripe-webhook.ts           ← handles Stripe webhook events → updates members table
│   └── newsletter/
│       ├── subscribe.ts            ← public signup form handler
│       ├── unsubscribe.ts          ← token-based unsubscribe (returns HTML page)
│       ├── send.ts                 ← admin broadcast (requires JWT)
│       ├── send-test.ts            ← sends rendered preview to admin email
│       └── send-cuteness.ts        ← alternate send variant
│
├── nikkis_great_musicfestivals/    ← Quasar SPA (nested subfolder)
│   ├── vercel.json                 ← ⚠️ NOT USED in production — see warning below
│   ├── package.json                ← frontend dependencies (Vue, Quasar, Leaflet, etc.)
│   ├── quasar.config.ts
│   ├── .env                        ← committed env (public VITE_ vars only — safe)
│   ├── .env.local                  ← ⚠️ gitignored — secrets for local dev
│   └── src/
│       ├── pages/                  ← routed components
│       ├── components/             ← shared UI
│       ├── layouts/                ← MainLayout.vue, AdminLayout.vue
│       ├── router/                 ← routes.ts
│       ├── lib/                    ← supabase.ts, mondrian.ts, archiveShows.ts
│       └── stores/                 ← Pinia
│
└── *.sql                           ← migration files (see note on SQL file organisation)
```

---

## ⚠️ Known Gotchas

### 1. Two `vercel.json` files — one is dead

| File | Status | Purpose |
|------|--------|---------|
| `/vercel.json` (root) | **Active** | What Vercel actually reads. Runs install, build, sets output dir, SPA fallback. |
| `/nikkis_great_musicfestivals/vercel.json` (subfolder) | **Dead in production** | Was the original config before the API was lifted to root. Has API route mappings that are never executed in prod. |

**Action needed:** Either delete the subfolder `vercel.json` or replace it with a comment-only marker file so future-you doesn't get confused. Vercel auto-discovers all `/api/*.ts` files — no explicit route entries are needed for them.

### 2. Git root vs working directory confusion

The `.git` folder is at the **repo root** (`/nikkis_great_musicfestivals/`), but development sessions often start from inside the subfolder (`/nikkis_great_musicfestivals/nikkis_great_musicfestivals/`).

Running `git` from the subfolder **works** (git walks up to find `.git`) but shows confusing `../` prefixes in status output:

```
M ../api/newsletter/send.ts     ← this is /api/newsletter/send.ts
M .env                          ← this is /nikkis_great_musicfestivals/.env
?? ../supabase-migrate-foo.sql  ← this is at repo root
```

**Best practice:** always `cd` to the repo root before git operations. Set a shell alias or use an IDE that respects the git root.

### 3. SQL migration files are scattered

New migration files keep appearing at the repo root. They should live in a dedicated folder:

```
/migrations/
  YYYY-MM-DD-description.sql
```

Current stragglers at root level (as of 2026-03-31):
- `supabase-migrate-display-order.sql`
- `supabase-migrate-newsletter-rls.sql`
- `supabase-migrate-newsletter-schema.sql`
- `supabase-migrate-show-social.sql`
- (several more in the subfolder)

**Action needed:** Create `/migrations/` at repo root, move all `.sql` files there, update any tooling that references them.

### 4. API environment variables — local dev vs production

| Variable | Where set | Notes |
|----------|-----------|-------|
| `VITE_SUPABASE_URL` | `.env` (committed) | Safe — public URL |
| `VITE_SUPABASE_KEY` | `.env` (committed) | Safe — anon/publishable key only |
| `SUPABASE_SERVICE_ROLE_KEY` | Vercel dashboard + `.env.local` | NEVER commit — full DB access |
| `STRIPE_SECRET_KEY` | Vercel dashboard + `.env.local` | NEVER commit |
| `STRIPE_WEBHOOK_SECRET` | Vercel dashboard + `.env.local` | NEVER commit |
| `MAILGUN_API_KEY` | Vercel dashboard + `.env.local` | NEVER commit |
| `MAILGUN_DOMAIN` | Vercel dashboard + `.env.local` | e.g. `mg.lovelight.cc` |
| `MAILGUN_FROM` | Vercel dashboard + `.env.local` | sender address |

The `/api/_auth.ts` helper tries multiple key names in fallback order:
`SUPABASE_SERVICE_ROLE_KEY` → `VITE_SUPABASE_KEY` → `VITE_SUPABASE_ANON_KEY`

If the service role key is missing from Vercel env, admin API endpoints silently fall back to the anon key (insufficient permissions). **Always verify `SUPABASE_SERVICE_ROLE_KEY` is set in Vercel dashboard.**

---

## Local Development Workflow

### Frontend only (no API needed)
```bash
cd nikkis_great_musicfestivals/nikkis_great_musicfestivals
quasar dev            # http://localhost:9000
```

This is fine for all UI work. Supabase calls go directly to the cloud project. API functions (`/api/*`) return 404 in this mode — that only matters if testing newsletter send or Stripe flows.

### Full-stack (frontend + API functions)
```bash
# From REPO ROOT:
npm install               # install /api dependencies
vercel dev                # starts Vercel dev server

# In a second terminal:
cd nikkis_great_musicfestivals
quasar dev --port 9000    # starts Quasar dev server
```

Then configure the Quasar dev proxy to forward `/api/*` to the Vercel dev port (usually 3000). In `quasar.config.ts`:

```ts
devServer: {
  proxy: {
    '/api': 'http://localhost:3000'
  }
}
```

*(This proxy config may not be set yet — check `quasar.config.ts` before assuming it works.)*

### Production deploy
Push to `main` on GitHub. Vercel auto-deploys via the GitHub integration. Build takes ~90 seconds.

```bash
# From repo root (not subfolder):
git add -A
git commit -m "your message"
git push origin main
```

---

## Supabase Database Tables

| Table | Purpose |
|-------|---------|
| `site_settings` | Key/value jsonb store — all admin-managed content lives here |
| `map_regions` | Tour regions (name, lat/lng, zoom, description, image_url) |
| `map_points` | Show/venue/nature pins per region (category: show/senior/nature) |
| `show_stars` | Fan star counts per show (social feature) |
| `show_boosts` | Fan boost/cheer counts per show |
| `show_comments` | Fan board comments per show |
| `custom_pages` | Admin-created rich-text pages (slug, nav_parent, blocks) |
| `newsletter_subscribers` | Email list with status and unsubscribe tokens |
| `newsletters` | Draft and sent newsletter records |
| `news_articles` | Blog/news posts |
| `gallery_items` | Photo gallery |
| `merch_items` | Shop products |
| `support_tiers` | Membership tier definitions |
| `members` | Stripe customer + subscription status |
| `homepage_artists` | Featured artists for homepage carousel |
| `arc_collections` | Archive.org curated collections |

All tables use Supabase Row Level Security. Public reads are allowed on most tables; writes go through either RLS policies or the service role key in API functions.

---

## Relationship to Other Projects

Three independent projects share the same `/home/solstice/Desktop/art/` directory and the same author (`biomassives` GitHub org). They do **not** share code, npm packages, or Supabase instances.

| Project | Repo | Stack | Hosting | Status |
|---------|------|-------|---------|--------|
| Nikki's Great Music Festivals | `biomassives/nikkis_great_musicfestivals` | Vue 3 + Quasar + Supabase + Vercel | Vercel | Active |
| FoodBank | `biomassives/foodbank` | Vue 3 + Quasar + Supabase | Netlify/Vercel | Separate |
| BioMassives Signal Station | *(no remote)* | Vue 3 + Quasar + Three.js | Unknown | Unknown |

**Why not a shared library?** Tempting but inadvisable until both projects are stable. Shared code creates shared blast radius — a breaking change in a "common" module would require coordinated deploys. The `site_settings` jsonb pattern is already the generalization mechanism: each project gets its own Supabase instance, its own Vercel deployment, its own secrets. Copy-paste shared patterns as needed, then diverge freely.

The `README-GENERALIZED.md` at repo root documents the architectural pattern for reuse as a template/scaffold, which is the right level of sharing.

---

## What Nikki (the client) Can Manage Herself

All of the following require zero developer involvement:
- Page content (rich text, images, embeds) — via `/admin/pages`
- Navigation links — via `/admin/nav`
- Homepage hero, mission text, featured artists — via `/admin/home`
- News/blog posts — via `/admin/blog`
- Gallery photos — via `/admin/gallery`
- Merch items — via `/admin/merch`
- Map region descriptions, archive.org show assignments, hero images — via `/admin/maps`
- Show venue pins on maps — via `/admin/maps/:regionId`
- Newsletter compose + broadcast + subscriber list — via `/admin/newsletter`
- Support tier descriptions — via `/admin/support`

Developer involvement is still needed for:
- Schema migrations (new Supabase tables)
- New page types or UI layouts
- Stripe product/price configuration
- DNS and Vercel project settings
- New API endpoints

---

## Quick Reference: Important Files

| File | What it does |
|------|-------------|
| `/vercel.json` | Deployment config — don't edit without testing |
| `/package.json` | API-layer deps (Stripe, Supabase, @vercel/node) |
| `/api/_auth.ts` | JWT verification shared by all admin API routes |
| `/nikkis_great_musicfestivals/.env` | Public env vars (committed, safe) |
| `/nikkis_great_musicfestivals/src/lib/supabase.ts` | Supabase client + all TypeScript interfaces |
| `/nikkis_great_musicfestivals/src/lib/mondrian.ts` | SVG collage generator (6 layouts) |
| `/nikkis_great_musicfestivals/src/lib/archiveShows.ts` | Curated archive.org recording list |
| `/nikkis_great_musicfestivals/src/router/routes.ts` | All public and admin routes |
| `README-GENERALIZED.md` | Platform reuse documentation |

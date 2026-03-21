# Generalized Platform Roadmap

*How the tooling built for Nikki's Great Music Festivals becomes a reusable foundation for community publishing, data-driven web experiences, and cultural organization sites.*

---

## The Core Thesis

This project is, underneath its festival branding, a **community content platform** with:

- A no-migration CMS backed by a single key/value settings table
- A role-based admin panel that non-developers can operate
- An interactive multi-layer map system for any kind of geographic data
- A media integration layer (archive.org, Supabase Storage, Unsplash, Stripe)
- A component library of animated SVG visual elements
- Full dark/light theming built into the design system

None of those things are specific to music festivals. Strip the color palette and swap the copy, and this is infrastructure for a regional hiking collective, a rural arts organization, a neighborhood history archive, a touring theater company, or a municipal parks department.

---

## What Generalizes Immediately (No Rework)

### 1. The `site_settings` CMS Pattern

Every piece of admin-editable content is stored as `jsonb` in a single Supabase table:

```
site_settings
  key   TEXT PRIMARY KEY
  value JSONB
```

The admin writes structured fields through a Quasar form; the frontend reads with safe fallbacks. Adding a new configurable piece of content requires:
- A new key string
- A `reactive()` object in the admin page
- An `upsert` call on save
- A `select().eq('key', ...)` on load in the public page

**No schema migrations. No new tables. No API routes.**

This pattern ports to any organization that needs editorial control without a developer in the loop.

---

### 2. The Admin Panel Architecture

The accordion-based `AdminHomePage.vue` pattern — per-section save state, independent `flash()` confirmations, "Save All" batch — is a reusable admin shell. Current sections:

- Page content (hero, CTAs, headings, body text)
- Welcome overlay (full-screen onboarding splash)
- Artist / featured person profiles
- Background & theme (image, SVG pattern, footer behavior)
- Footer sky text (animated orb writer)
- SEO & social meta (og:title, og:image, twitter card)

To adapt for another organization, rename "Artist Profiles" to "Staff Bios", "Featured Projects", "Partner Organizations", or whatever that site needs. The CRUD pattern (list → add dialog → edit dialog → reorder → delete confirm) is already built and consistent.

---

### 3. The Multi-Layer Interactive Map

`MapDetailPage.vue` + `AdminMapEditorPage.vue` implement:

- Leaflet map with CartoDB Voyager tiles (clean, no API key required)
- Multiple named regions (e.g., tour regions, districts, neighborhoods, chapters)
- Per-region point layers with three category types and distinct icons
- Dashed polyline tour-leg connections between ordered points
- Scrollable side panel with venue/location cards
- Sticky topbar with filter pills
- Chronological timeline visualization at the bottom
- Photo panel for region imagery

**Reuse scenarios:**

| Organization | Regions | Point categories |
|---|---|---|
| Regional hiking club | Trail systems | Trailhead, shelter, viewpoint |
| Arts council | County districts | Gallery, studio, public mural |
| Community health org | Service areas | Clinic, pharmacy, food pantry |
| Historical society | Eras or neighborhoods | Landmark, archive, oral history site |
| Farmer's market network | City zones | Market, farm, pickup point |
| Municipal parks dept | Park zones | Facility, trail, accessible feature |

The map admin (`AdminMapEditorPage.vue`) lets a non-technical user click a map to drop a pin, fill in a name/description/date/image, and save. No GIS knowledge required.

---

### 4. The Custom Pages System

`CustomPage.vue` + `AdminPagesPage.vue` provide a full CMS for arbitrary rich-text pages:

- Quill WYSIWYG editor with heading, bold, italic, link, list, blockquote, image insert
- Image dialog with upload-to-Supabase-Storage or URL paste, caption, and link-wrapping
- Legacy block renderer supports heading, text, image, video (YouTube/Vimeo/archive.org), iframe embed, media link card, divider
- Slug-based routing: `/p/about-us`, `/p/volunteer`, `/p/sponsors`

Any organization can use this to publish articles, policy pages, event recaps, or "about" content without touching code.

---

### 5. The Archive.org / Open Media Integration

The audio player strip (in `MapDetailPage.vue`) embeds any archive.org recording via:

```
https://archive.org/embed/{identifier}
```

Archive.org hosts millions of freely streamable items: live concert recordings, oral histories, old-time radio, government hearings, educational lectures, field recordings. For a historical society, that's primary source audio. For a folk music org, it's the whole canon. The player strip (pulsing live dot, title, pop-out link) is generic enough to carry anything.

The same pattern works for:
- Internet Archive video embeds
- Wikimedia Commons media
- Any freely embeddable public domain source

---

### 6. The Animated SVG Footer

`FooterScene.vue` is a self-contained visual system: two SVG variants (day/night), a landscape with parallax depth, animated campfire, hammock sway, stream shimmer, smoke wisps, and the crop-circle orb sky writer.

The sky writer uses only SVG SMIL — no JavaScript, no external dependencies. It works in:
- Static HTML exports
- Email clients that support SVG (limited but growing)
- PDF renderers
- Embedded widgets

**Generalization path:** The landscape elements (mountains, campfire, trees, stream) can be swapped for any context — urban skyline, desert mesa, coastal bluff, winter pines. The SMIL animation rig stays the same. The orb writer works for any short message.

---

## Roadmap: Making It a Reusable Template

### Phase 1 — Decouple branding from structure

- [ ] Extract all color tokens into a `theme.scss` config file (currently hardcoded as `#7c4dff`, `#ffd700`, `#0d0028`, etc.)
- [ ] Move site name, logo, and mission from hardcoded strings to `site_settings` keys loaded at app init
- [ ] Make the SVG landscape theme-selectable from the admin (landscape style, color palette, sky/ground color)
- [ ] Replace all hardcoded Quasar color references (`text-teal-3`, `color="purple-5"`) with CSS custom properties driven by the theme config

### Phase 2 — Generalize the map point schema

Currently, map points have three hardcoded category types: `show`, `senior`, `nature`. Generalize to:

```sql
ALTER TABLE map_points ADD COLUMN category_label TEXT;
ALTER TABLE map_points ADD COLUMN category_icon  TEXT;
ALTER TABLE map_points ADD COLUMN category_color TEXT;
```

Admin defines the categories per-region. The map renders them dynamically. This unlocks any domain.

### Phase 3 — Pluggable content sections

The homepage currently has: hero → featured artists → newsletter. Make each section optional and reorderable from the admin:

```json
{
  "sections": [
    { "type": "hero",       "enabled": true },
    { "type": "profiles",   "enabled": true,  "label": "Our Team" },
    { "type": "gallery",    "enabled": false },
    { "type": "newsletter", "enabled": true }
  ]
}
```

The `IndexPage.vue` renders sections in order based on this config. A rural arts org enables gallery; a community health org disables it and adds a resources section.

### Phase 4 — Multi-tenant support

The current architecture is single-tenant (one Supabase project, one app). To serve multiple organizations:

- Add an `organization_id` foreign key to every table
- Use Supabase Row Level Security policies to isolate data per org
- Add an org-switcher or subdomain routing layer
- Each org gets its own admin credentials, settings, and content

This turns the platform into a hosted service: one codebase, many organizations.

### Phase 5 — Data publishing and open data UI

The `site_settings` + `map_points` pattern can be extended to publish structured data openly:

- **Export endpoints:** Supabase's auto-generated REST API already exposes tables. Add a `/data` public route in the app that renders a clean data browser (filterable table, downloadable CSV/JSON).
- **Embeddable widgets:** The map, timeline, and photo panel can be iframed into third-party sites. A small `embed.js` script lets partner organizations drop in a filtered map view.
- **Feed publishing:** The news table already has the structure for RSS. Add a Vercel Edge Function that returns `application/rss+xml`.
- **Open data landing page:** A `/data` page listing available datasets (tour stops, senior facilities, gallery, etc.) with download buttons — useful for journalists, researchers, community planners.

### Phase 6 — Offline / low-bandwidth support

Many of the communities this serves — rural Tennessee, small mountain towns — have unreliable internet. Roadmap:

- [ ] Quasar's PWA mode: add a service worker that caches the app shell and last-loaded map data
- [ ] Supabase's `realtime` is not needed for this use case; switch to aggressive `stale-while-revalidate` caching
- [ ] Provide a static export of the current tour data as downloadable PDF (generated from the map page using `window.print()` CSS or a Vercel function)
- [ ] Compress all images at upload time (Supabase Storage image transformations)

---

## Potential Deployment Templates

| Template name | Domain | Key adaptations |
|---|---|---|
| **Tour & Road** | Traveling musicians, theater companies, sports teams | Keep maps + archive player, swap artist profiles |
| **Regional Heritage** | Historical societies, oral history projects | Swap archive pool for oral histories, map points = landmarks, gallery = photo archive |
| **Community Health** | Rural clinics, food pantries, community health orgs | Map layers = services/facilities, no merch, support page = donations |
| **Outdoor Collective** | Hiking clubs, paddling clubs, trail orgs | Map layers = trails/trailheads/campsites, gallery = trip photos, news = trip reports |
| **Arts Council** | Municipal or regional arts organizations | Gallery = exhibitions, map = venues/murals, custom pages = grant info/calls for artists |
| **Farmers Market / Food Network** | Regional food systems | Map = markets/farms/pickups, merch = CSA/box ordering, news = seasonal availability |
| **Municipal Parks** | City or county parks department | Map = parks/facilities/trails, accessibility layer, support = volunteer sign-up |

---

## What's Already Production-Ready

The following subsystems require no further generalization work — they are already domain-agnostic:

- ✅ Admin authentication (Supabase Auth, password reset flow)
- ✅ File upload to Supabase Storage with public URL generation
- ✅ Rich text page editor (Quill, image insert, block renderer)
- ✅ Newsletter subscriber capture and management
- ✅ Custom page routing (`/p/:slug`)
- ✅ SEO meta tag management (og, twitter card, canonical)
- ✅ Dark/light theme toggle with body background matching
- ✅ Responsive layout (mobile-first, Quasar breakpoints)
- ✅ Animated SVG footer with configurable sky message
- ✅ Admin dashboard with table-count stats
- ✅ Per-section independent save state in admin
- ✅ Image upload with preview in all admin forms
- ✅ Stripe integration scaffolding

---

## Stack Summary for New Deployments

```
npm install
cp .env.example .env       # fill in Supabase URL + anon key
quasar dev                 # local dev
quasar build               # production build → dist/spa/
vercel deploy              # or any static host
```

Supabase project setup:
1. Create project at supabase.com
2. Run the SQL schema (see `/supabase/schema.sql` — to be extracted)
3. Enable Email auth
4. Create `festival-media` storage bucket (public read)
5. Paste URL and anon key into `.env`

No server. No Docker. No DevOps. Total cold-start to running site: under an hour.

---

*Built with care for communities that deserve beautiful, functional tools regardless of budget.*

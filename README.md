# Nikki's Great Music Festivals

A community-focused web platform for documenting, sharing, and growing access to live music, outdoor adventure, and community connection across the United States.

Built with **Vue 3 + Quasar + Supabase**, deployed on Vercel.

---

## What It Does

The site follows a traveling music festival circuit — documenting tour stops, supporting senior communities along the way, connecting people with outdoor must-sees, and publishing the story as it happens. Essentially a good music blog interactive map community building experiment, and merch shop, all in one.

---

## Tech Stack

| Layer | Tool |
|---|---|
| Frontend framework | Vue 3 (Composition API, `<script setup lang="ts">`) |
| UI component library | Quasar 2 (dark/light theme, layout, dialogs, forms) |
| Build tool | Vite via `@quasar/app-vite` |
| Backend / database | Supabase (PostgreSQL + Row Level Security) |
| File storage | Supabase Storage (`festival-media` bucket) |
| Maps | Leaflet.js with CartoDB Voyager tiles |
| Rich text editing | `@vueup/vue-quill` (Quill editor) |
| Payments | Stripe |
| Hosting | Vercel |

---

## Pages

### Public

| Route | Page | Description |
|---|---|---|
| `/` | IndexPage | Home — hero carousel, mission, featured artists accordion, newsletter signup |
| `/maps` | MapsPage | Region overview — cards linking to each tour region |
| `/maps/:regionId` | MapDetailPage | Per-region detail — hero carousel, archive.org audio player, Leaflet map with shows/senior/nature layers, timeline, photo panel |
| `/photography` | PhotographyPage | Photo gallery — outdoor adventures, concerts, community |
| `/support` | SupportPage | Support tiers, one-time and recurring memberships |
| `/merch` | MerchPage | Merch shop — art, photos, and other items |
| `/news` | NewsPage | News feed — recent events and upcoming tour stops |
| `/p/:customSlug` | CustomPage | Admin-created custom pages (rich Quill content + legacy block renderer) |

### Admin (behind Supabase Auth)

| Route | Admin Page | Manages |
|---|---|---|
| `/admin` | Dashboard | Site-wide stats, quick nav |
| `/admin/home` | Homepage Manager | Hero, welcome splash, artist profiles, background/theme, footer sky text, SEO/social meta |
| `/admin/story` | Story Overlay Editor | Full-screen "Our Full Story" overlay content |
| `/admin/maps` | Map Regions | Region cards, display order, preview images, hero carousel images, archive.org player per region |
| `/admin/maps/:regionId` | Map Point Editor | Add/edit/delete show, senior facility, and nature points on the Leaflet map |
| `/admin/news` | News Manager | Publish news posts |
| `/admin/gallery` | Gallery Manager | Upload and curate photography |
| `/admin/merch` | Merch Manager | Products, categories, pricing |
| `/admin/newsletter` | Newsletter | Subscriber list and broadcast |
| `/admin/pages` | Custom Pages | Create/edit rich-text pages with Quill editor |
| `/admin/nav` | Navigation | Edit site navigation links |
| `/admin/support` | Support Tiers | Edit membership/support options |

---

## Key Components

| Component | What it does |
|---|---|
| `FooterScene.vue` | Animated SVG landscape footer — day and night variants, campfire, hammock, stream, smoke wisps. Includes a **crop-circle orb sky writer**: a glowing Saturn-ring spacecraft that slowly traverses the sky, revealing admin-configured text in dashed monospace behind it via SVG `clipPath` animation |
| `WelcomeOverlay.vue` | Full-screen welcome splash shown once per session — admin-configurable image, title, tagline, button |
| `StoryOverlay.vue` | Full-screen "Our Full Story" reader — split image/text layout, scrollable, keyboard-dismissable |
| `PhotoSlideshow.vue` | Autoplay image carousel used in the hero and region detail pages |
| `PageBackground.vue` | Per-page SVG pattern backgrounds (Mardi-Gras spiral, soundwave rings, topographic contours, etc.) |
| `SpirographLogo.vue` | Animated SVG spirograph mark |

---

## Database (Supabase Tables)

| Table | Purpose |
|---|---|
| `site_settings` | Key/value store for all admin-configurable content (homepage, SEO, appearance, story overlay, footer sky text, per-region hero config) |
| `map_regions` | Tour regions (name, description, center lat/lng, zoom, image) |
| `map_points` | Individual map pins — shows, senior facilities, nature points — linked to a region |
| `news_posts` | News articles |
| `gallery_items` | Photography gallery entries |
| `merch_items` | Merch products |
| `newsletter_subscribers` | Email list |
| `custom_pages` | Admin-created rich-text pages |
| `nav_items` | Navigation link configuration |
| `support_tiers` | Membership and support options |

---

## Architecture Notes

**Content management pattern:** Nearly all editorial content is stored as `jsonb` in `site_settings` rows, keyed by a logical name (e.g. `homepage_content`, `region_hero_NNN`, `footer_sky_text`). The admin writes structured JSON; the frontend reads it with safe fallbacks. This means no schema migration is needed to add new configurable fields.

**Per-region hero config:** Each map region can have a custom image carousel (up to 5 Unsplash or uploaded URLs) and a custom archive.org show. If none is set, a deterministic hash of the region name selects from the default pool — so it always looks intentional.

**Archive.org integration:** Freely streamable live recordings from archive.org are embedded via `https://archive.org/embed/{identifier}` in an iframe player strip. The pool includes Duke Ellington (1941 78rpm), multiple Grateful Dead soundboards, and Billy Strings (Athens, GA 2026).

**Footer SVG:** ViewBox `0 0 1440 390`. 120px of sky sits above the landscape group `<g transform="translate(0,120)">`. The orb sky writer uses SMIL `<animate>` and `<animateTransform>` — no JavaScript, no CSS animation dependencies — so it runs even in restricted rendering environments.

**Dark / light mode:** Quasar's `useQuasar().dark.isActive` drives conditional CSS classes throughout. Body background is matched to page colors in `app.scss` to eliminate white bleed at the footer seam.

---

## Getting Started

```bash
# Install dependencies
npm install

# Start dev server
quasar dev

# Build for production
quasar build
```

### Environment variables (`.env`)

```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

---

## Project by

Greg Willson — [greg@ecocity.com](mailto:greg@ecocity.com)
Built for Nikki and everyone who believes great music and the outdoors belong to everyone.

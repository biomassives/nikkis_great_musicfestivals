<template>
  <q-page class="home-page">
    <PageBackground :variant="bgVariant" :opacity="bgOpacity" :imageUrl="bgImageUrl"
      :spiroColors="bgSpiroColors" :skyTint="bgSkyTint" :cloudsOpacity="bgCloudsOpacity" />
    <WelcomeOverlay @dismissed="onWelcomeDismissed" />
    <StoryOverlay v-model="showStory" />

    <!-- ═══════════════════════════════════════════════════════════
         HERO  —  full-viewport entrance
    ═══════════════════════════════════════════════════════════ -->
    <section class="hero-section">
      <div class="hero-inner q-pa-lg">

        <div class="hero-logo-wrap hero-entrance-logo">
          <SpirographLogo :size="220" :spin="true" class="hero-logo" />
        </div>

        <div class="hero-text hero-entrance-text">
          <div class="hero-eyebrow">Festival Tour · Summer 2026</div>
          <h1 class="hero-title">{{ content.hero_title }}</h1>
          <div class="hero-mission">
            <span class="hero-mission-mark">"</span>{{ content.mission_statement }}<span class="hero-mission-mark">"</span>
          </div>
          <div class="hero-ctas row q-gutter-sm q-mt-lg">
            <q-btn
              :label="content.cta_story_label"
              color="secondary" outline size="lg"
              @click="showStory = true"
            />
            <q-btn
              :label="content.cta_tour_label"
              color="primary" unelevated size="lg"
              :to="'/maps'"
            />
          </div>
        </div>

      </div>

      <!-- scroll indicator -->
      <div class="scroll-cue" aria-hidden="true">
        <span class="scroll-cue-label">Scroll</span>
        <div class="scroll-cue-chevrons">
          <div class="scroll-chevron sc1" />
          <div class="scroll-chevron sc2" />
          <div class="scroll-chevron sc3" />
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════════
         STATS STRIP
    ═══════════════════════════════════════════════════════════ -->
    <section class="stats-section">
      <div class="stats-inner">
        <div v-for="(s, i) in STATS" :key="s.label"
             class="stat-item reveal" :class="`stagger-${i + 1}`">
          <div class="stat-icon"><q-icon :name="s.icon" size="28px" /></div>
          <div class="stat-num">{{ s.num }}</div>
          <div class="stat-label">{{ s.label }}</div>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════════
         MONDRIAN REGION MOSAIC  —  our own design feature
    ═══════════════════════════════════════════════════════════ -->
    <section class="regions-section q-pa-lg">
      <div class="section-header text-center q-mb-xl">
        <div class="section-eyebrow reveal">Tour Regions</div>
        <h2 class="section-title reveal stagger-1">Where We're Playing</h2>
        <div class="section-rule reveal stagger-2" />
        <p class="section-sub reveal stagger-3">
          Six distinct American regions — each with its own outdoor character, senior-friendly stops, and natural wonders.
        </p>
      </div>

      <div v-if="mapRegions.length" class="mondrian-mosaic reveal stagger-1">
        <router-link
          v-for="(region, i) in mapRegions"
          :key="region.id"
          :to="`/maps/${region.id}`"
          class="mosaic-tile"
          :class="mosaicTileClass(i)"
        >
          <div class="mosaic-mondrian" v-html="regionMondrian(region.id)" />
          <div class="mosaic-overlay">
            <div class="mosaic-name">{{ region.name }}</div>
            <div class="mosaic-hint">
              <q-icon name="explore" size="14px" />
              Explore
            </div>
          </div>
        </router-link>
      </div>

      <div class="text-center q-mt-xl reveal stagger-2">
        <q-btn
          to="/maps"
          label="Open the Tour Map"
          color="primary" outline size="md"
          icon-right="arrow_forward"
        />
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════════
         ARTISTS  —  card grid
    ═══════════════════════════════════════════════════════════ -->
    <section class="artists-section q-pa-lg">
      <canvas ref="artistSpiroCanvas" class="artist-spiro-bg" aria-hidden="true" />
      <div class="section-header text-center q-mb-xl">
        <div class="section-eyebrow reveal">{{ content.artists_label }}</div>
        <h2 class="section-title reveal stagger-1">{{ content.artists_title }}</h2>
        <div class="section-rule reveal stagger-2" />
      </div>

      <div class="artist-grid">
        <router-link
          v-for="(artist, i) in artists" :key="artist.id"
          :to="`/artists/${artist.id}`"
          class="artist-card reveal"
          :class="`stagger-${(i % 3) + 1}`"
          :style="`--ac: ${artistColor(artist.icon_color)}`"
        >
          <div class="artist-card-accent" />
          <div class="artist-card-body">
            <div class="artist-card-top">
              <div class="artist-icon-circle" :style="`background: ${artistColor(artist.icon_color)}22`">
                <q-icon :name="artist.icon || 'music_note'" size="32px"
                  :style="`color: ${artistColor(artist.icon_color)}`" />
              </div>
              <q-badge :color="artist.badge_color" :label="artist.badge_text" class="artist-badge" />
            </div>
            <div class="artist-name">{{ artist.name }}</div>
            <div class="artist-subtitle">{{ artist.subtitle }}</div>
            <p class="artist-bio">{{ artist.bio_main.slice(0, 160) }}…</p>
            <div class="artist-songs row q-gutter-xs q-mt-md">
              <q-chip
                v-for="song in artist.songs" :key="song"
                dense icon="music_note"
                :style="`background: ${artistColor(artist.icon_color)}18; color: ${artistColor(artist.icon_color)}`"
              >{{ song }}</q-chip>
            </div>
          </div>
        </router-link>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════════
         LISTENING ROOM
    ═══════════════════════════════════════════════════════════ -->
    <ArchivePlayerSection />

    <!-- ═══════════════════════════════════════════════════════════
         SUBSCRIBE
    ═══════════════════════════════════════════════════════════ -->
    <section class="subscribe-section q-pa-lg" id="subscribe-bottom">
      <div class="subscribe-inner reveal">
        <div class="subscribe-deco" aria-hidden="true">
          <div class="sub-deco-ring ring-1" />
          <div class="sub-deco-ring ring-2" />
          <div class="sub-deco-ring ring-3" />
        </div>
        <div class="subscribe-content">
          <div class="section-eyebrow">Stay Connected</div>
          <h2 class="section-title q-mb-sm">{{ content.subscribe_title }}</h2>
          <p class="subscribe-body">{{ content.subscribe_body }}</p>
          <NewsletterSignup class="q-mt-lg" />
        </div>
      </div>
    </section>

    <!-- fade the page floor down into the footer -->
    <div class="page-fade-runway" aria-hidden="true" />

  </q-page>

  <!-- Home gate (blocks until welcome overlay dismissed) -->
  <Teleport to="body">
    <Transition name="home-gate">
      <div v-if="!welcomed" class="home-gate" />
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useMeta } from 'quasar'
import { supabase } from 'src/lib/supabase'
import { sessionKey } from 'src/lib/instance'
import type { MapRegion } from 'src/lib/supabase'
import { mondrianSvg } from 'src/lib/mondrian'
import type { MondrianOpts } from 'src/lib/mondrian'
import { ARTISTS } from 'src/lib/artists'
import type { Artist } from 'src/lib/artists'
import PageBackground from 'src/components/PageBackground.vue'
import SpirographLogo from 'src/components/SpirographLogo.vue'
import WelcomeOverlay from 'src/components/WelcomeOverlay.vue'
import StoryOverlay      from 'src/components/StoryOverlay.vue'
import NewsletterSignup  from 'src/components/NewsletterSignup.vue'
import ArchivePlayerSection from 'src/components/ArchivePlayerSection.vue'

const showStory = ref(false)
const SESSION_KEY = sessionKey('welcomed_v1')
const welcomed = ref<boolean>(!!sessionStorage.getItem(SESSION_KEY))
function onWelcomeDismissed() { welcomed.value = true }

// ── Static stats ────────────────────────────────────────────────────────────
const STATS = [
  { icon: 'explore',      num: '6',    label: 'Tour Regions'     },
  { icon: 'event',        num: '30+',  label: 'Shows Planned'    },
  { icon: 'elderly',      num: '50+',  label: 'Senior Stops'     },
  { icon: 'park',         num: '40+',  label: 'Nature Must-Sees' },
]

// ── Color map for artists ────────────────────────────────────────────────────
const COLOR_MAP: Record<string, string> = {
  amber: '#ffc107', 'deep-orange': '#ff6d00', purple: '#9c27b0',
  teal: '#009688', indigo: '#3f51b5', green: '#4caf50',
  pink: '#e91e63', blue: '#2196f3', red: '#f44336',
}
function artistColor(c: string): string { return COLOR_MAP[c] ?? '#7c4dff' }

// ── Homepage content ─────────────────────────────────────────────────────────
const content = reactive({
  hero_title:        "Nikki's Great Music Festivals",
  mission_statement: 'Helping to improve lives by improving access to great music, community, and the outdoors.',
  cta_story_label:   'Our Full Story',
  cta_tour_label:    'Explore the Tour',
  artists_label:     'Artist Interviews',
  artists_title:     'Featured Artists',
  subscribe_title:   'Join the Newsletter Adventure',
  subscribe_body:    'Show dates, artist interviews, trail reports, and community stories — straight to your inbox.',
})

const artists = ref<Artist[]>([])

// ── Background / SEO ─────────────────────────────────────────────────────────
const bgImageUrl     = ref<string | null>(null)
const bgVariant      = ref<'home'|'support'|'blog'|'photography'|'maps'|'merch'>('home')
const bgOpacity      = ref(0.09)
const bgSpiroColors  = ref<string[]>(['#f5a623', '#b39ddb', '#5ba3c9', '#e8956c'])
const bgSkyTint      = ref('#04001a')
const bgCloudsOpacity = ref(0.92)

const seo = reactive({
  og_title: "Nikki's Great Music Festivals — Tour Maps, Live Music & Community",
  og_description: 'Follow the festival trail — tour maps, artist interviews, photography, and community across the US.',
  og_image: '',
  meta_description: "Festival tour maps, artist interviews, trail photography and community — Nikki's Great Music Festivals.",
  meta_keywords: 'music festivals, bluegrass, outdoor concerts, Billy Strings, Leftover Salmon',
  twitter_card: 'summary_large_image',
})

useMeta(() => ({
  title: seo.og_title,
  meta: {
    description:   { name: 'description',     content: seo.meta_description },
    keywords:      { name: 'keywords',         content: seo.meta_keywords },
    ogTitle:       { property: 'og:title',     content: seo.og_title },
    ogDescription: { property: 'og:description', content: seo.og_description },
    ogImage:       { property: 'og:image',     content: seo.og_image },
    twitterCard:   { name: 'twitter:card',     content: seo.twitter_card },
  },
}))

// ── Map regions + Mondrian ───────────────────────────────────────────────────
const mapRegions   = ref<MapRegion[]>([])
const regionHeroData = ref<Record<string, { images: string[]; opts: MondrianOpts }>>({})

function regionMondrian(regionId: string): string {
  const d = regionHeroData.value[regionId]
  return mondrianSvg(regionId, d?.images ?? [], d?.opts)
}

// Alternate big/small tile for visual mosaic rhythm
function mosaicTileClass(i: number): string {
  // Pattern: positions 0 and 4 are "wide" tiles; rest are normal
  if (i === 0 || i === 4) return 'mosaic-tile--wide'
  return ''
}

// ── Scroll reveal ─────────────────────────────────────────────────────────────
let revealObserver: IntersectionObserver | null = null

function initReveal() {
  revealObserver?.disconnect()
  revealObserver = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible')
        revealObserver?.unobserve(entry.target)
      }
    }
  }, { threshold: 0.08, rootMargin: '0px 0px -32px 0px' })
  document.querySelectorAll('.reveal').forEach(el => revealObserver!.observe(el))
}

// ── Load settings ────────────────────────────────────────────────────────────
async function loadSettings() {
  const [settingsRes, regionsRes, heroRes] = await Promise.all([
    supabase.from('site_settings').select('key, value')
      .in('key', ['homepage_content', 'homepage_seo', 'homepage_appearance', 'homepage_artists']),
    supabase.from('map_regions').select('*').order('display_order'),
    supabase.from('site_settings').select('key, value').like('key', 'region_hero_%'),
  ])

  // Homepage settings
  for (const row of (settingsRes.data ?? []) as { key: string; value: unknown }[]) {
    if (row.key === 'homepage_content')    Object.assign(content, row.value as object)
    if (row.key === 'homepage_seo')        Object.assign(seo, row.value as object)
    if (row.key === 'homepage_appearance') {
      const v = row.value as Record<string, unknown>
      if (v['bg_image_url']     != null) bgImageUrl.value      = v['bg_image_url'] as string
      if (v['bg_variant']       != null) bgVariant.value       = v['bg_variant'] as typeof bgVariant.value
      if (v['bg_opacity']       != null) bgOpacity.value       = v['bg_opacity'] as number
      if (v['spiro_colors']     != null) bgSpiroColors.value   = v['spiro_colors'] as string[]
      if (v['sky_tint']         != null) bgSkyTint.value       = v['sky_tint'] as string
      if (v['clouds_opacity']   != null) bgCloudsOpacity.value = v['clouds_opacity'] as number
    }
    if (row.key === 'homepage_artists' && Array.isArray(row.value) && (row.value as unknown[]).length) {
      const dbList = row.value as Artist[]
      const dbIds  = new Set(dbList.map(a => a.id))
      // DB order first, then append any static featured artists not yet included
      artists.value = [
        ...dbList,
        ...ARTISTS.filter(a => a.featured && !dbIds.has(a.id)),
      ]
    }
  }

  // Nothing in DB at all — use the full static featured roster
  if (artists.value.length === 0) {
    artists.value = ARTISTS.filter(a => a.featured)
  }

  // Regions
  mapRegions.value = (regionsRes.data as MapRegion[]) ?? []

  // Region hero / mondrian data
  type HeroRow = { key: string; value: Record<string, unknown> }
  for (const row of (heroRes.data as HeroRow[]) ?? []) {
    const regionId = row.key.replace('region_hero_', '')
    const images   = Array.isArray(row.value.images)
      ? (row.value.images as string[]).filter(Boolean)
      : []
    const opts: MondrianOpts = {}
    if (typeof row.value.mondrian_layout === 'number') opts.layout   = row.value.mondrian_layout
    if (typeof row.value.mondrian_stroke  === 'number') opts.stroke   = row.value.mondrian_stroke
    if (Array.isArray(row.value.mondrian_featured) && (row.value.mondrian_featured as unknown[]).length)
      opts.featured = row.value.mondrian_featured as number[]
    regionHeroData.value[regionId] = { images, opts }
  }

  // Kick off scroll-reveal after DOM updates
  await nextTick()
  initReveal()
}

// ── Artist spirograph canvas ──────────────────────────────────────────────────
const artistSpiroCanvas = ref<HTMLCanvasElement | null>(null)

function startArtistSpiro() {
  const canvas = artistSpiroCanvas.value
  if (!canvas) return
  const ctx = canvas.getContext('2d')
  if (!ctx) return

  const dpr = window.devicePixelRatio || 1

  const resize = () => {
    const r = (canvas.parentElement ?? canvas).getBoundingClientRect()
    canvas.width  = r.width  * dpr
    canvas.height = r.height * dpr
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
  }
  resize()
  window.addEventListener('resize', resize)

  const w = () => canvas.width  / dpr
  const h = () => canvas.height / dpr

  const NEON = ['#ff6b9d', '#c849ff', '#00e5ff', '#ffe033', '#00ff9f', '#ff9944', '#7b2fff']
  function gcd2(a: number, b: number): number { return b === 0 ? a : gcd2(b, a % b) }

  const CONFIGS = [
    { R: 80, r:  8, d: 68, speed: 0.016 },
    { R: 65, r: 14, d: 52, speed: 0.021 },
    { R: 90, r:  5, d: 78, speed: 0.013 },
    { R: 72, r:  9, d: 60, speed: 0.018 },
    { R: 58, r: 11, d: 46, speed: 0.024 },
  ]

  type Painter = typeof CONFIGS[0] & { t: number; cx: number; cy: number; color: string; alpha: number }
  const painters: Painter[] = CONFIGS.map((c, i) => ({
    ...c, t: 0, cx: 0, cy: 0,
    color: NEON[i % NEON.length]!,
    alpha: 0.5,
  }))

  const reposition = (p: Painter, i: number) => {
    p.cx    = (w() * (i + 0.5)) / painters.length + (Math.random() - 0.5) * w() * 0.25
    p.cy    = h() / 2 + (Math.random() - 0.5) * h() * 0.45
    p.color = NEON[Math.floor(Math.random() * NEON.length)]!
    p.t     = 0
    p.alpha = 0.38 + Math.random() * 0.32
  }
  painters.forEach(reposition)

  const tick = () => {
    // Self-terminate when canvas leaves the DOM (component unmounted)
    if (!canvas.isConnected) return

    // Soft fade trail — clears slowly so curves leave a glowing wake
    ctx.globalCompositeOperation = 'source-over'
    ctx.fillStyle = 'rgba(7, 0, 20, 0.018)'
    ctx.fillRect(0, 0, w(), h())

    ctx.globalCompositeOperation = 'lighter'  // additive light: overlaps glow white

    for (let i = 0; i < painters.length; i++) {
      const p = painters[i]!
      const { R, r, d, speed } = p
      const ratio = (R - r) / r
      const seg = 8

      for (let s = 0; s < seg; s++) {
        const t1 = p.t + s * speed
        const t2 = p.t + (s + 1) * speed
        const x1 = p.cx + (R - r) * Math.cos(t1) + d * Math.cos(ratio * t1)
        const y1 = p.cy + (R - r) * Math.sin(t1) - d * Math.sin(ratio * t1)
        const x2 = p.cx + (R - r) * Math.cos(t2) + d * Math.cos(ratio * t2)
        const y2 = p.cy + (R - r) * Math.sin(t2) - d * Math.sin(ratio * t2)
        ctx.beginPath()
        ctx.moveTo(x1, y1)
        ctx.lineTo(x2, y2)
        ctx.strokeStyle = p.color
        ctx.lineWidth   = 1.5
        ctx.globalAlpha = p.alpha
        ctx.stroke()
      }

      p.t += speed * seg
      const loops = R / gcd2(R, r)
      if (p.t > loops * 2 * Math.PI * 2.5) reposition(p, i)
    }

    ctx.globalAlpha = 1
    ctx.globalCompositeOperation = 'source-over'
    requestAnimationFrame(tick)
  }

  tick()
}

onMounted(() => {
  void loadSettings()
  void nextTick(() => startArtistSpiro())
})
</script>

<style lang="scss" scoped>
// ── Page shell ───────────────────────────────────────────────────────────────
.home-page { min-height: 100vh; }

// ── Scroll reveal base ───────────────────────────────────────────────────────
.reveal {
  opacity: 0;
  transform: translateY(36px);
  transition: opacity 0.65s ease, transform 0.65s ease;
  &.is-visible { opacity: 1; transform: none; }
}
// Stagger delays
@for $i from 1 through 6 {
  .stagger-#{$i} { transition-delay: #{$i * 0.1}s; }
}

// ── HERO ─────────────────────────────────────────────────────────────────────
.hero-section {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
}
.hero-inner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 48px;
  flex-wrap: wrap;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  padding-top: 80px; // clear the header
}

// Entrance animations (fire on load, not scroll)
@keyframes heroLogoIn {
  from { opacity: 0; transform: scale(0.78) rotate(-12deg); }
  to   { opacity: 1; transform: scale(1) rotate(0deg); }
}
@keyframes heroTextIn {
  from { opacity: 0; transform: translateY(48px); }
  to   { opacity: 1; transform: translateY(0); }
}
.hero-entrance-logo { animation: heroLogoIn 1s cubic-bezier(0.22, 1, 0.36, 1) both; }
.hero-entrance-text { animation: heroTextIn 0.9s cubic-bezier(0.22, 1, 0.36, 1) 0.2s both; }

.hero-logo {
  filter: drop-shadow(0 0 22px rgba(124,77,255,0.45));
  transition: filter 0.4s;
  &:hover { filter: drop-shadow(0 0 36px rgba(124,77,255,0.75)); }
}
.hero-text { max-width: 560px; }

.hero-eyebrow {
  font-size: 10px; font-weight: 900; letter-spacing: 4px;
  text-transform: uppercase; color: #ffd700;
  margin-bottom: 12px;
}
.hero-title {
  font-size: clamp(2rem, 5vw, 3.4rem);
  font-weight: 900; line-height: 1.1;
  margin: 0 0 20px; color: inherit;
  letter-spacing: -0.5px;
}
.hero-mission {
  font-size: clamp(1rem, 2vw, 1.25rem);
  font-weight: 300; line-height: 1.55;
  border-left: 4px solid #ffd700;
  padding-left: 18px;
  opacity: 0.85;
}
.hero-mission-mark { color: #ffd700; font-size: 1.4em; line-height: 0; vertical-align: -4px; }

// Scroll cue
.scroll-cue {
  position: absolute; bottom: 32px; left: 50%; transform: translateX(-50%);
  display: flex; flex-direction: column; align-items: center; gap: 6px;
  animation: fadeIn 1s 1.6s both;
}
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.scroll-cue-label {
  font-size: 9px; font-weight: 700; letter-spacing: 3px;
  text-transform: uppercase; color: rgba(255,255,255,0.3);
}
.scroll-cue-chevrons { display: flex; flex-direction: column; align-items: center; gap: 2px; }
.scroll-chevron {
  width: 12px; height: 12px;
  border-right: 2px solid rgba(255,215,0,0.6);
  border-bottom: 2px solid rgba(255,215,0,0.6);
  transform: rotate(45deg);
  animation: chevronBounce 1.6s ease-in-out infinite;
}
.sc1 { animation-delay: 0s; }
.sc2 { animation-delay: 0.15s; }
.sc3 { animation-delay: 0.3s; }
@keyframes chevronBounce {
  0%, 100% { opacity: 0.2; transform: rotate(45deg) translateY(0); }
  50%       { opacity: 1;   transform: rotate(45deg) translateY(3px); }
}

// ── STATS STRIP ──────────────────────────────────────────────────────────────
.stats-section {
  background: linear-gradient(105deg, #0d0024 0%, #1a0042 55%, #0d1a3a 100%);
  border-top: 1px solid rgba(124,77,255,0.3);
  border-bottom: 1px solid rgba(124,77,255,0.3);
  padding: 40px 24px;
}
.stats-inner {
  max-width: 900px; margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  @media (max-width: 600px) { grid-template-columns: repeat(2, 1fr); }
}
.stat-item {
  text-align: center; padding: 16px 8px;
  border: 1px solid rgba(124,77,255,0.2); border-radius: 12px;
  background: rgba(124,77,255,0.06);
  transition: border-color 0.25s, background 0.25s;
  &:hover { border-color: #7c4dff; background: rgba(124,77,255,0.12); }
}
.stat-icon { color: #ffd700; margin-bottom: 6px; }
.stat-num {
  font-size: 2.2rem; font-weight: 900; color: #fff !important;
  letter-spacing: -1px; line-height: 1;
}
.stat-label {
  font-size: 10px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; color: rgba(255,255,255,0.65) !important; margin-top: 6px;
}
.stat-icon { color: #ffd700 !important; }

// ── SECTION HEADER SHARED ────────────────────────────────────────────────────
.section-eyebrow {
  font-size: 10px; font-weight: 900; letter-spacing: 4px;
  text-transform: uppercase; color: #ab47bc; margin-bottom: 10px;
}
.section-title {
  font-size: clamp(1.6rem, 4vw, 2.4rem);
  font-weight: 900; margin: 0 0 16px; color: inherit;
}
.section-rule {
  width: 60px; height: 4px; border-radius: 2px;
  background: linear-gradient(90deg, #7c4dff, #ffd700);
  margin: 0 auto 20px;
}
.section-sub {
  max-width: 540px; margin: 0 auto;
  opacity: 0.7; font-size: 1rem; line-height: 1.6;
}

// ── MONDRIAN REGION MOSAIC ───────────────────────────────────────────────────
.regions-section {
  max-width: 1100px; margin: 0 auto; padding-top: 80px; padding-bottom: 80px;
  // Force readable text — section sits on the dark page bg in both themes
  .section-eyebrow { color: rgba(255,255,255,0.9) !important; }
  .section-sub      { color: rgba(255,255,255,0.72) !important; }
  // "Where We're Playing" — neon celebration gradient
  .section-title {
    background: linear-gradient(120deg, #ff6b9d 0%, #ffd700 48%, #00e5ff 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    // paint-order trick so outline still works if added later
    display: inline-block;
  }
}

.mondrian-mosaic {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-template-rows: 200px 200px;
  gap: 4px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0,0,0,0.3);
  // Wide tiles span 2 columns
  .mosaic-tile--wide { grid-column: span 2; }
  @media (max-width: 700px) {
    grid-template-columns: repeat(2, 1fr);
    grid-template-rows: repeat(3, 160px);
    .mosaic-tile--wide { grid-column: span 1; }
  }
  @media (max-width: 480px) {
    grid-template-columns: 1fr;
    grid-template-rows: repeat(6, 140px);
    .mosaic-tile--wide { grid-column: span 1; }
  }
}

.mosaic-tile {
  position: relative; overflow: hidden;
  cursor: pointer; text-decoration: none;
  display: block;
}
.mosaic-mondrian {
  width: 100%; height: 100%; display: block;
  transition: transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
  .mosaic-tile:hover & { transform: scale(1.06); }
}
.mosaic-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.72) 0%, transparent 60%);
  display: flex; flex-direction: column;
  justify-content: flex-end; align-items: flex-start;
  padding: 14px 16px;
  opacity: 0; transition: opacity 0.3s;
  .mosaic-tile:hover & { opacity: 1; }
}
.mosaic-name {
  font-size: 14px; font-weight: 900; color: #fff;
  letter-spacing: 1.5px; text-transform: uppercase;
}
.mosaic-hint {
  font-size: 10px; color: rgba(255,215,0,0.9);
  font-weight: 700; letter-spacing: 2px; margin-top: 3px;
  display: flex; align-items: center; gap: 4px;
}

// ── ARTISTS ──────────────────────────────────────────────────────────────────
.artists-section {
  padding-top: 80px; padding-bottom: 80px;
  background: linear-gradient(180deg, transparent, rgba(124,77,255,0.04), transparent);
  position: relative;   // contain the canvas
  overflow: hidden;
}

// Spirograph canvas — drawn behind the cards
.artist-spiro-bg {
  position: absolute; inset: 0;
  width: 100%; height: 100%;
  pointer-events: none;
  opacity: 0.42;
  z-index: 0;
}

// Cards sit above the canvas
.section-header, .artist-grid { position: relative; z-index: 1; }
.artist-grid {
  max-width: 1100px; margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  @media (max-width: 860px) { grid-template-columns: repeat(2, 1fr); }
  @media (max-width: 560px) { grid-template-columns: 1fr; }
}
.artist-card {
  border-radius: 16px; overflow: hidden;
  background: rgba(7, 0, 20, 0.72);
  border: 1px solid rgba(124,77,255,0.28);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  position: relative;
  transition: transform 0.3s cubic-bezier(0.22, 1, 0.36, 1), box-shadow 0.3s, border-color 0.3s;
  // Artist-colour wash fades in on hover via a z-index-0 pseudo layer
  &::before {
    content: '';
    position: absolute; inset: 0;
    background: var(--ac, #7c4dff);
    opacity: 0;
    transition: opacity 0.35s ease;
    pointer-events: none;
    z-index: 0;
  }
  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 24px 48px rgba(0,0,0,0.4), 0 0 28px rgba(124,77,255,0.22);
    border-color: var(--ac, rgba(124,77,255,0.6));
    &::before { opacity: 0.13; }
  }
}
.artist-card-accent {
  height: 4px;
  background: var(--ac, #7c4dff);
  position: relative; z-index: 1;
}
.artist-card-body { padding: 20px; position: relative; z-index: 1; }
.artist-card-top {
  display: flex; justify-content: space-between; align-items: flex-start;
  margin-bottom: 14px;
}
.artist-icon-circle {
  width: 52px; height: 52px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  border: 1.5px solid var(--ac, #7c4dff);
}
.artist-badge { align-self: flex-start; }
.artist-name {
  font-size: 1.2rem; font-weight: 900; letter-spacing: -0.2px;
  margin-bottom: 4px; color: #fff;
}
.artist-subtitle {
  font-size: 11px; font-weight: 600; letter-spacing: 1px;
  text-transform: uppercase; color: rgba(255,255,255,0.5); margin-bottom: 12px;
}
.artist-bio {
  font-size: 0.88rem; line-height: 1.65; color: rgba(255,255,255,0.78); margin: 0;
}
.artist-songs { flex-wrap: wrap; }

// ── SUBSCRIBE ────────────────────────────────────────────────────────────────
.subscribe-section {
  padding-top: 80px; padding-bottom: 80px;
}
.subscribe-inner {
  max-width: 680px; margin: 0 auto;
  position: relative; text-align: center;
  padding: 60px 40px;
  border-radius: 24px;
  background: linear-gradient(135deg, rgba(75,0,130,0.08), rgba(255,215,0,0.06), rgba(0,143,57,0.07));
  border: 1px solid rgba(171,71,188,0.22);
  overflow: hidden;
  @media (max-width: 560px) { padding: 40px 20px; }
}
// Decorative rings
.subscribe-deco { position: absolute; inset: 0; pointer-events: none; overflow: hidden; }
.sub-deco-ring {
  position: absolute; border-radius: 50%;
  border: 1px solid rgba(255,215,0,0.12);
  top: 50%; left: 50%; transform: translate(-50%, -50%);
}
.ring-1 { width: 300px; height: 300px; }
.ring-2 { width: 500px; height: 500px; border-color: rgba(124,77,255,0.08); }
.ring-3 { width: 700px; height: 700px; border-color: rgba(0,188,212,0.06); }

.subscribe-content { position: relative; z-index: 1; }
.subscribe-body {
  max-width: 420px; margin: 0 auto;
  opacity: 0.7; line-height: 1.65;
}

// ── PAGE FADE RUNWAY ─────────────────────────────────────────────────────────
// 400px bridge that melts the page floor into the footer colour.
// Night footer SVG top = #070014, day footer SVG top = #f5f0ff (see FooterScene.vue).
// Use rgba() from the same base so there's no colour-band mid-gradient.
.page-fade-runway {
  height: 400px;
  background: linear-gradient(to bottom,
    rgba(7, 0, 20, 0)    0%,
    rgba(7, 0, 20, 0.6) 50%,
    #070014             100%
  );
  pointer-events: none;
}
</style>

<style lang="scss">
/* ── Light/dark overrides (unscoped) ─────────────────────────────────────── */
.home-gate {
  position: fixed; inset: 0; z-index: 8500;
  background: linear-gradient(135deg, #07001a 0%, #1a0042 45%, #0a1230 100%);
  pointer-events: none;
}
.home-gate-leave-active { transition: opacity 0.6s ease 0.35s; }
.home-gate-leave-to     { opacity: 0; }

body.body--dark {
  /* Artist song chips: brighten the inline color in dark mode */
  .artist-songs .q-chip {
    filter: brightness(1.7) saturate(1.2);
  }
}

body.body--light {
  .stats-section {
    background: linear-gradient(105deg, #1a0042 0%, #2d006e 55%, #0d1a3a 100%);
  }
  .artist-card {
    background: rgba(255,255,255,0.80) !important;
    border-color: rgba(124,77,255,0.18) !important;
    backdrop-filter: blur(10px) !important;
    -webkit-backdrop-filter: blur(10px) !important;
    &:hover { border-color: var(--ac, rgba(124,77,255,0.55)) !important; }
  }
  .artist-bio      { color: rgba(26,10,46,0.75) !important; }
  .artist-subtitle { color: rgba(26,10,46,0.6)  !important; }
  .artist-name     { color: #1a0a2e !important; }
  .artist-songs .q-chip { filter: none !important; }
  .subscribe-inner {
    background: linear-gradient(135deg, rgba(75,0,130,0.07), rgba(255,215,0,0.09), rgba(0,143,57,0.06)) !important;
  }
  // Tour Regions section — light page background, use dark readable text
  .regions-section {
    .section-eyebrow { color: #ab47bc !important; }
    .section-sub     { color: rgba(26,10,46,0.65) !important; }
    // Keep the neon gradient on the title — it reads fine on light too
  }
  // Page fade runway — dissolve into the light footer SVG top colour (#f5f0ff)
  .page-fade-runway {
    background: linear-gradient(to bottom,
      rgba(245, 240, 255, 0)    0%,
      rgba(245, 240, 255, 0.6) 50%,
      #f5f0ff                  100%
    ) !important;
  }
  // Hero sits on a dark star-field background regardless of theme —
  // keep all hero text light/warm so it reads on the dark canvas.
  .hero-title   { color: #ff9800 !important; }
  .hero-mission { color: rgba(255,255,255,0.85) !important; }
}
</style>

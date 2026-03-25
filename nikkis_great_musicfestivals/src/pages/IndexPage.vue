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
          <div class="subscribe-form row items-start q-gutter-sm justify-center q-mt-lg">
            <q-input
              v-model="email"
              type="email"
              placeholder="your@email.com"
              outlined dense
              class="subscribe-input"
              :error="!!emailError"
              :error-message="emailError"
              hide-bottom-space
            />
            <q-btn
              label="Subscribe"
              color="secondary" unelevated
              :loading="subscribing"
              :disable="subscribed"
              @click="subscribe"
              icon-right="send"
            />
          </div>
          <div v-if="subscribed" class="text-positive q-mt-md">
            <q-icon name="check_circle" size="16px" class="q-mr-xs" />
            You're in! We'll be in touch soon.
          </div>
          <div class="subscribe-fine q-mt-md">No spam. Unsubscribe anytime.</div>
        </div>
      </div>
    </section>

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
import type { MapRegion } from 'src/lib/supabase'
import { mondrianSvg } from 'src/lib/mondrian'
import type { MondrianOpts } from 'src/lib/mondrian'
import { ARTISTS } from 'src/lib/artists'
import type { Artist } from 'src/lib/artists'
import PageBackground from 'src/components/PageBackground.vue'
import SpirographLogo from 'src/components/SpirographLogo.vue'
import WelcomeOverlay from 'src/components/WelcomeOverlay.vue'
import StoryOverlay   from 'src/components/StoryOverlay.vue'

const showStory = ref(false)
const SESSION_KEY = 'ngmf_welcomed_v1'
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

const artists = ref<Artist[]>(ARTISTS.filter(a => a.featured))

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
      artists.value = row.value as Artist[]
    }
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

// ── Newsletter ────────────────────────────────────────────────────────────────
const email       = ref('')
const subscribing = ref(false)
const subscribed  = ref(false)
const emailError  = ref('')

async function subscribe() {
  emailError.value = ''
  if (!email.value || !/\S+@\S+\.\S+/.test(email.value)) {
    emailError.value = 'Please enter a valid email'
    return
  }
  subscribing.value = true
  await supabase.from('newsletter_subscribers').upsert({ email: email.value })
  subscribing.value = false
  subscribed.value = true
}

onMounted(() => { void loadSettings() })
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
  font-size: 2.2rem; font-weight: 900; color: #fff;
  letter-spacing: -1px; line-height: 1;
}
.stat-label {
  font-size: 10px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; color: rgba(255,255,255,0.45); margin-top: 6px;
}

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
.regions-section { max-width: 1100px; margin: 0 auto; padding-top: 80px; padding-bottom: 80px; }

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
}
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
  background: rgba(124,77,255,0.10);
  border: 1px solid rgba(124,77,255,0.22);
  transition: transform 0.3s cubic-bezier(0.22, 1, 0.36, 1), box-shadow 0.3s, border-color 0.3s;
  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 24px 48px rgba(0,0,0,0.4), 0 0 20px rgba(124,77,255,0.15);
    border-color: var(--ac, rgba(124,77,255,0.6));
  }
}
.artist-card-accent {
  height: 4px;
  background: var(--ac, #7c4dff);
}
.artist-card-body { padding: 20px; }
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
.subscribe-input { min-width: 260px; }
.subscribe-fine  { font-size: 11px; opacity: 0.35; letter-spacing: 0.5px; }
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
    background: rgba(255,255,255,0.82) !important;
    border-color: rgba(0,0,0,0.08) !important;
    &:hover { border-color: var(--ac, rgba(124,77,255,0.6)) !important; }
  }
  .artist-bio   { color: rgba(26,10,46,0.75) !important; }
  .artist-subtitle { color: rgba(26,10,46,0.6) !important; }
  .artist-name  { color: #1a0a2e !important; }
  .artist-songs .q-chip { filter: none !important; }
  .subscribe-inner {
    background: linear-gradient(135deg, rgba(75,0,130,0.07), rgba(255,215,0,0.09), rgba(0,143,57,0.06)) !important;
  }
  // Hero sits on a dark star-field background regardless of theme —
  // keep all hero text light/warm so it reads on the dark canvas.
  .hero-title   { color: #ff9800 !important; }
  .hero-mission { color: rgba(255,255,255,0.85) !important; }
}
</style>

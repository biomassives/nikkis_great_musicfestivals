<template>
  <q-page class="mf-page" :class="$q.dark.isActive ? 'mf--dark' : 'mf--light'">

    <!-- ══ HEADER ════════════════════════════════════════════════════ -->
    <div class="mf-header">
      <div class="mf-header-strip">
        <div class="mhs-blk" style="background:#cc1010;flex:3" />
        <div class="mhs-sep" />
        <div class="mhs-blk" style="background:#111;flex:1" />
        <div class="mhs-sep" />
        <div class="mhs-blk" style="background:#ffd600;flex:4" />
        <div class="mhs-sep" />
        <div class="mhs-blk" style="background:#1040a8;flex:2" />
        <div class="mhs-sep" />
        <div class="mhs-blk" style="background:#f5f0e8;flex:6" />
        <div class="mhs-sep" />
        <div class="mhs-blk" style="background:#cc1010;flex:1" />
      </div>
      <div class="mf-header-body">
        <div class="mf-header-left-bar" />
        <div class="mf-header-text">
          <div class="mf-title">Festival Tour Map</div>
          <div class="mf-subtitle">Six regions · Summer 2026 · Select a region to explore</div>
        </div>
        <div class="mf-header-controls">
          <router-link to="/artists" class="mf-hctl-btn">
            <q-icon name="queue_music" size="13px" /> Artists &amp; Songs
          </router-link>
          <router-link to="/blog" class="mf-hctl-btn">
            <q-icon name="article" size="13px" /> Tour News
          </router-link>
        </div>
      </div>
    </div>

    <!-- ══ LOADING ═══════════════════════════════════════════════════ -->
    <div v-if="loading" class="mf-loading flex flex-center">
      <q-spinner-orbit color="primary" size="52px" />
    </div>

    <!-- ══ REGION ROWS ════════════════════════════════════════════════ -->
    <div v-else class="mf-body">

      <template v-for="(region, idx) in regions" :key="region.id">

        <!-- ─ Region row ─────────────────────────────────────────── -->
        <div class="mf-region" :style="cssVars(region.id)">

          <!-- Top bar: name + stats -->
          <div class="mfr-topbar">
            <div class="mfr-topbar-accent" />
            <div class="mfr-name">{{ region.name }}</div>
            <div class="mfr-stats">
              <span v-if="counts(region.id).show"
                    class="mfr-stat mfr-stat--show">
                <q-icon name="music_note" size="11px" />
                {{ counts(region.id).show }} Shows
              </span>
              <span v-if="counts(region.id).senior"
                    class="mfr-stat mfr-stat--senior">
                <q-icon name="favorite" size="11px" />
                {{ counts(region.id).senior }} Senior
              </span>
              <span v-if="counts(region.id).nature"
                    class="mfr-stat mfr-stat--nature">
                <q-icon name="park" size="11px" />
                {{ counts(region.id).nature }} Nature
              </span>
            </div>
          </div>

          <!-- Body: map + panel -->
          <div class="mfr-body">

            <!-- Mini Leaflet map -->
            <div class="mfr-map-wrap">
              <div :id="`rmap-${region.id}`" class="mfr-map" />
              <div class="mfr-map-overlay" />
            </div>

            <!-- Info panel -->
            <div class="mfr-panel">

              <!-- Tabs -->
              <div class="mfr-tabs" role="tablist">
                <button
                  v-for="tab in TABS"
                  :key="tab.key"
                  role="tab"
                  :aria-selected="activeTab[region.id] === tab.key"
                  :class="['mfr-tab', { 'mfr-tab--active': activeTab[region.id] === tab.key }]"
                  @click="activeTab[region.id] = tab.key"
                >
                  <q-icon :name="tab.icon" size="13px" />
                  {{ tab.label }}
                </button>
              </div>

              <!-- Tab: Overview ───────────────────────────── -->
              <div
                v-if="activeTab[region.id] === 'overview'"
                class="mfr-content mfr-content--overview"
                role="tabpanel"
              >
                <!-- Left: description + small Mondrian strip -->
                <div class="mfro-left">
                  <p class="mfr-desc">{{ region.description || 'Explore upcoming festival shows, senior-friendly venues, and outdoor highlights across this region.' }}</p>
                  <div class="mfro-hint">
                    <q-icon name="music_note" size="12px" />
                    <span>{{ counts(region.id).show }} shows · {{ counts(region.id).nature }} outdoor · {{ counts(region.id).senior }} senior</span>
                  </div>
                  <!-- Small Mondrian accent — fewer images, flat blocks visible -->
                  <div
                    class="mfro-small"
                    v-html="mondrianSvg(region.id, regionImages[region.id] ?? [], { ...mondrianOpts[region.id], stroke: 5, featured: [2, 3] })"
                  />
                </div>
                <!-- Right: large Mondrian filling full panel height -->
                <div class="mfro-right">
                  <div
                    class="mfro-large"
                    v-html="mondrianSvg(region.id, regionImages[region.id] ?? [], { ...mondrianOpts[region.id], stroke: 9 })"
                  />
                </div>
              </div>

              <!-- Tab: Shows ──────────────────────────────── -->
              <div
                v-else-if="activeTab[region.id] === 'shows'"
                class="mfr-content mfr-content--timeline"
                role="tabpanel"
              >
                <template v-if="showsByRegion[region.id]?.length">

                  <!-- Month tick ruler -->
                  <div class="tl-ruler">
                    <div v-for="m in TIMELINE_MONTHS" :key="m.label"
                      class="tl-month"
                      :style="{ left: m.pct + '%' }">
                      {{ m.label }}
                    </div>
                  </div>

                  <!-- SVG track + show nodes -->
                  <div class="tl-track">
                    <svg class="tl-svg" width="100%" height="32" preserveAspectRatio="none">
                      <line x1="3%" y1="50%" x2="96%" y2="50%" stroke="#ccc" stroke-width="1.5" />
                      <template v-for="leg in showLegs(region.id)" :key="leg.key">
                        <line
                          :x1="`${leg.x1}%`" y1="50%" :x2="`${leg.x2}%`" y2="50%"
                          :stroke="`var(--rc, #888)`" stroke-width="2" stroke-dasharray="5 5" opacity="0.55"
                        />
                        <foreignObject :x="`${leg.mid - 4}%`" y="2" width="8%" height="28">
                          <div xmlns="http://www.w3.org/1999/xhtml" class="tl-leg-pill">{{ leg.days }}d</div>
                        </foreignObject>
                      </template>
                    </svg>

                    <button
                      v-for="(show, i) in showsByRegion[region.id]"
                      :key="show.id"
                      class="tl-node"
                      :style="{ left: showPct(show) + '%' }"
                      @click="goToShow(region.id, show.id)"
                      :title="show.name"
                    >
                      <div class="tl-dot">{{ i + 1 }}</div>
                      <div class="tl-label">{{ formatDate(show.date) }}</div>
                    </button>
                  </div>

                  <!-- Name chips linking to detail page -->
                  <div class="tl-names">
                    <button
                      v-for="(show, i) in showsByRegion[region.id]"
                      :key="show.id"
                      class="tl-name-chip"
                      @click="goToShow(region.id, show.id)"
                    >
                      <span class="tl-name-seq">{{ i + 1 }}</span>
                      <span class="tl-name-text">{{ show.name }}</span>
                      <span v-if="show.date" class="tl-name-date">{{ formatDate(show.date) }}</span>
                      <q-icon name="arrow_forward" size="10px" />
                    </button>
                  </div>

                </template>
                <div v-else class="mfr-empty">
                  <q-icon name="calendar_month" size="32px" class="q-mb-sm" />
                  <div>No shows scheduled yet</div>
                  <div class="mfr-empty-sub">Add shows via the admin panel</div>
                </div>
              </div>

              <!-- Tab: Listen ─────────────────────────────── -->
              <div
                v-else-if="activeTab[region.id] === 'player'"
                class="mfr-content mfr-content--player"
                role="tabpanel"
              >
                <!-- Track selector (only shown when multiple recordings) -->
                <div v-if="archiveShowList(region.id).length > 1" class="mfr-track-picker">
                  <button
                    v-for="(s, i) in archiveShowList(region.id)"
                    :key="s.id"
                    :class="['mfr-track-btn', { 'is-active': (activePlayerIdx[region.id] ?? 0) === i }]"
                    @click="activePlayerIdx[region.id] = i"
                  >
                    <q-icon name="music_note" size="10px" />
                    {{ s.label.split('·').slice(0, 2).join('·') }}
                  </button>
                </div>

                <div class="mfr-player-head">
                  <span class="live-pulse" />
                  <div class="mfr-player-info">
                    <div class="mfr-player-title">{{ archiveShow(region.id).label }}</div>
                    <div class="mfr-player-sub">archive.org · Live Recording</div>
                  </div>
                  <a
                    :href="`https://archive.org/details/${archiveShow(region.id).id}`"
                    target="_blank" rel="noopener noreferrer"
                    class="mfr-popout-link"
                  >
                    <q-icon name="open_in_new" size="12px" />
                    Pop out
                  </a>
                </div>
                <iframe
                  :key="archiveShow(region.id).id"
                  :src="`https://archive.org/embed/${archiveShow(region.id).id}`"
                  class="mfr-player-frame"
                  frameborder="0"
                  allow="autoplay"
                  loading="lazy"
                />
              </div>

              <!-- Actions ─────────────────────────────────── -->
              <div class="mfr-actions">
                <button class="mfra-btn mfra-btn--primary" @click="goToRegion(region.id)">
                  <q-icon name="explore" size="14px" />
                  <span>Explore Full Map</span>
                </button>
                <router-link to="/artists" class="mfra-btn">
                  <q-icon name="queue_music" size="14px" />
                  <span>Artists &amp; Songs</span>
                </router-link>
              </div>

            </div>
          </div>
        </div>

        <!-- ─ Flowing connector between rows ──────────────────────── -->
        <div v-if="idx < regions.length - 1" class="mf-flow">
          <svg
            viewBox="0 0 1200 36"
            preserveAspectRatio="none"
            class="mf-flow-svg"
          >
            <path
              :d="flowPath(idx)"
              fill="none"
              stroke-width="2"
              :stroke="flowColors[idx % flowColors.length]"
              opacity="0.35"
            />
          </svg>
        </div>

      </template>
    </div>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'
import { mondrianSvg } from 'src/lib/mondrian'
import type { MondrianOpts } from 'src/lib/mondrian'

const router  = useRouter()
const $q      = useQuasar()
const loading = ref(true)

const regions      = ref<MapRegion[]>([])
const allPoints    = ref<MapPoint[]>([])
const regionImages = ref<Record<string, string[]>>({})
const mondrianOpts = ref<Record<string, MondrianOpts>>({})
const activeTab       = reactive<Record<string, string>>({})
const activePlayerIdx = reactive<Record<string, number>>({})
const mapInstances    = new Map<string, L.Map>()

// ── Tabs definition ───────────────────────────────────────────────────────────
const TABS = [
  { key: 'overview', label: 'Overview', icon: 'landscape'     },
  { key: 'shows',    label: 'Shows',    icon: 'music_note'    },
  { key: 'player',   label: 'Listen',   icon: 'headphones'    },
]

// ── Region color + tile-filter system ────────────────────────────────────────
interface RegionMeta {
  color: string        // primary accent hex
  tileFilter: string   // CSS filter for the Leaflet tile pane
  bgLight: string
  bgDark:  string
}

const REGION_META: Record<string, RegionMeta> = {
  'northeast':           { color: '#b87010', tileFilter: 'hue-rotate(22deg) saturate(1.5) brightness(1.04)',  bgLight: '#fdf8ef', bgDark: '#17100a' },
  'southeast':           { color: '#2a7d34', tileFilter: 'hue-rotate(105deg) saturate(1.55) brightness(0.98)', bgLight: '#f1f8f2', bgDark: '#0b160d' },
  'southwest':           { color: '#c04018', tileFilter: 'hue-rotate(8deg) saturate(1.7) brightness(1.04)',   bgLight: '#fdf3ee', bgDark: '#180d08' },
  'mountain-west':       { color: '#1558b8', tileFilter: 'hue-rotate(198deg) saturate(1.45) brightness(1.04)', bgLight: '#eef4fd', bgDark: '#090f1a' },
  'pacific-northwest':   { color: '#00705e', tileFilter: 'hue-rotate(152deg) saturate(1.65) brightness(0.96)', bgLight: '#edf8f4', bgDark: '#081510' },
  'great-lakes':         { color: '#0270b8', tileFilter: 'hue-rotate(183deg) saturate(1.5) brightness(1.03)',  bgLight: '#edf4fd', bgDark: '#090e1a' },
}
const DEFAULT_META: RegionMeta = {
  color: '#7c4dff', tileFilter: 'saturate(1.2)', bgLight: '#f5f0ff', bgDark: '#0d0028',
}

function getMeta(id: string): RegionMeta { return REGION_META[id] ?? DEFAULT_META }

function cssVars(id: string) {
  const m = getMeta(id)
  return { '--rc': m.color, '--rc-bg': $q.dark.isActive ? m.bgDark : m.bgLight }
}

// ── Archive shows per region ──────────────────────────────────────────────────
const REGION_SHOWS: Record<string, Array<{ id: string; label: string }>> = {
  'northeast':         [
    { id: 'gd1977-05-08.aud.moore.berger.28354.flac16',
      label: 'Grateful Dead · Cornell University — May 8, 1977' },
  ],
  'southeast':         [
    { id: 'wsp2013-11-09.ak40.flac24',
      label: 'Widespread Panic · Asheville Civic Center — Nov 9, 2013' },
  ],
  'southwest':         [
    { id: 'billystrings2019-04-13.litz.schoepsMK41v.flac16',
      label: 'Billy Strings · Bender Jamboree, Las Vegas — Apr 13, 2019' },
  ],
  'mountain-west':     [
    { id: 'gsbg2021-09-19.akg61.stearns.flac16',
      label: 'Greensky Bluegrass · Red Rocks Amphitheatre — Sep 19, 2021' },
  ],
  'pacific-northwest': [
    { id: 'gd1985-07-04.sbd.seamons.9517.sbeok.shnf',
      label: 'Grateful Dead · Autzen Stadium, Eugene OR — Jul 4, 1985' },
    { id: 'ig1993-08-21alt2.lifeblood.net',
      label: 'Indigo Girls · Aug 21, 1993' },
    { id: 'littlefeat1990-06-24.sennheiserMD421.flac1648',
      label: 'Little Feat · Jun 24, 1990' },
  ],
  'great-lakes':       [
    { id: 'um2004-07-03.flac',
      label: "Umphrey's McGee · Summerfest, Milwaukee WI — Jul 3, 2004" },
  ],
}

const FALLBACK_SHOW = { id: '78_9958-Take-the-A-train', label: 'Duke Ellington · Take the A Train' }

function archiveShowList(id: string): Array<{ id: string; label: string }> {
  return REGION_SHOWS[id]?.length ? REGION_SHOWS[id] ?? [FALLBACK_SHOW] : [FALLBACK_SHOW]
}

function archiveShow(id: string) {
  const list = archiveShowList(id)
  return list[activePlayerIdx[id] ?? 0] ?? list[0] ?? FALLBACK_SHOW
}

// ── Show points grouped by region ────────────────────────────────────────────
const showsByRegion = computed<Record<string, MapPoint[]>>(() => {
  const out: Record<string, MapPoint[]> = {}
  allPoints.value
    .filter(p => p.category === 'show')
    .sort((a, b) => (a.date ?? '').localeCompare(b.date ?? ''))
    .forEach(p => {
      ;(out[p.region_id] ??= []).push(p)
    })
  return out
})

function counts(id: string) {
  const pts = allPoints.value.filter(p => p.region_id === id)
  return {
    show:   pts.filter(p => p.category === 'show').length,
    senior: pts.filter(p => p.category === 'senior').length,
    nature: pts.filter(p => p.category === 'nature').length,
  }
}

// ── Date formatting ───────────────────────────────────────────────────────────
function formatDate(d: string | null): string {
  if (!d) return ''
  const [, m, day] = d.split('-')
  const names = ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  return `${names[parseInt(m ?? '0')] ?? ''} ${parseInt(day ?? '0')}`
}

// ── Tour timeline season maths ────────────────────────────────────────────────
const SEASON_START_MS = new Date('2026-06-01').getTime()
const SEASON_END_MS   = new Date('2026-09-15').getTime()
const SEASON_RANGE_MS = SEASON_END_MS - SEASON_START_MS

const TIMELINE_MONTHS = [
  { label: 'JUN', pct:  0 },
  { label: 'JUL', pct: (30 / 106) * 100 },
  { label: 'AUG', pct: (61 / 106) * 100 },
  { label: 'SEP', pct: (92 / 106) * 100 },
]

function showPct(show: MapPoint): number {
  if (!show.date) return 50
  const t = new Date(show.date).getTime()
  return Math.max(3, Math.min(96, ((t - SEASON_START_MS) / SEASON_RANGE_MS) * 100))
}

function daysBetween(a: string | null, b: string | null): number {
  if (!a || !b) return 0
  return Math.round((new Date(b).getTime() - new Date(a).getTime()) / 86_400_000)
}

// Show-to-show leg segments for the SVG connectors
function showLegs(regionId: string) {
  const shows = showsByRegion.value[regionId] ?? []
  return shows.slice(1).map((s, i) => ({
    key:  `${i}`,
    x1:   showPct(shows[i]!),
    x2:   showPct(s),
    mid:  (showPct(shows[i]!) + showPct(s)) / 2,
    days: daysBetween(shows[i]!.date, s.date),
  }))
}

// Navigate to detail page with a specific show pre-selected
function goToShow(regionId: string, showId: string) {
  void router.push(`/maps/${regionId}?show=${showId}`)
}

// ── Flowing connectors ────────────────────────────────────────────────────────
const flowColors = ['#b87010','#2a7d34','#c04018','#1558b8','#00705e']

function flowPath(idx: number): string {
  const dir = idx % 2 === 0
  return dir
    ? 'M 0,8 C 200,0 400,34 600,18 C 800,4 1000,30 1200,14'
    : 'M 0,22 C 200,36 400,4 600,18 C 800,32 1000,6 1200,20'
}

// ── Navigation ────────────────────────────────────────────────────────────────
function goToRegion(id: string) { void router.push(`/maps/${id}`) }

// ── Dark-mode map tile filter ─────────────────────────────────────────────────
// Invert + hue-rotate turns the light Voyager tiles into a convincing dark map.
const DARK_TILE_FILTER = 'invert(1) hue-rotate(180deg) brightness(0.68) saturate(0.80)'

function buildTileFilter(id: string): string {
  return $q.dark.isActive ? DARK_TILE_FILTER : getMeta(id).tileFilter
}

function applyAllMapFilters() {
  for (const [id, map] of mapInstances) {
    const pane = map.getPane('tilePane')
    if (pane) pane.style.filter = buildTileFilter(id)
  }
}

watch(() => $q.dark.isActive, applyAllMapFilters)

// ── Mini Leaflet map initialization ──────────────────────────────────────────
function makeMarkerHtml(n: number, color: string): string {
  return `<div style="
    width:22px;height:22px;border-radius:50%;
    background:${color};border:2.5px solid #fff;
    display:flex;align-items:center;justify-content:center;
    font-size:10px;font-weight:800;color:#fff;
    box-shadow:0 2px 8px rgba(0,0,0,0.45);
    cursor:pointer;
  ">${n}</div>`
}

async function initMaps() {
  await nextTick()
  for (const region of regions.value) {
    const el = document.getElementById(`rmap-${region.id}`)
    if (!el || mapInstances.has(region.id)) continue

    const meta = getMeta(region.id)

    const map = L.map(el, {
      zoomControl:       false,
      dragging:          false,
      scrollWheelZoom:   false,
      doubleClickZoom:   false,
      touchZoom:         false,
      keyboard:          false,
      attributionControl: false,
      boxZoom:           false,
    }).setView([region.center_lat, region.center_lng], Math.max(3, (region.zoom ?? 6) - 1))

    L.tileLayer(
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
      { subdomains: 'abcd', maxZoom: 18 },
    ).addTo(map)

    // Color tint via CSS filter on tile pane (respects current dark mode)
    const tilePane = map.getPane('tilePane')
    if (tilePane) tilePane.style.filter = buildTileFilter(region.id)

    // Numbered show markers — clickable, link to show detail page
    const shows = showsByRegion.value[region.id] ?? []
    shows.forEach((p, i) => {
      L.marker([p.lat, p.lng], {
        icon: L.divIcon({
          className: '',
          html: makeMarkerHtml(i + 1, meta.color),
          iconSize: [22, 22], iconAnchor: [11, 11],
        }),
        title: p.name,
      }).addTo(map).on('click', () => {
        void router.push(`/maps/${region.id}/shows/${p.id}`)
      })
    })

    mapInstances.set(region.id, map)
  }
}

// ── Data loading ──────────────────────────────────────────────────────────────
async function loadData() {
  const [{ data: rgns }, { data: pts }, { data: hero }] = await Promise.all([
    supabase.from('map_regions').select('*').order('display_order'),
    supabase.from('map_points').select('*'),
    supabase.from('site_settings').select('key, value').like('key', 'region_hero_%'),
  ])

  regions.value   = (rgns as MapRegion[]) ?? []
  allPoints.value = (pts as MapPoint[]) ?? []

  if (hero) {
    type Row = { key: string; value: { images?: string[]; mondrian_layout?: number | null; mondrian_stroke?: number; mondrian_featured?: number[] } }
    for (const row of hero as Row[]) {
      const id   = row.key.replace('region_hero_', '')
      const imgs = (row.value?.images ?? []).filter(Boolean)
      if (imgs.length) regionImages.value[id] = imgs
      const opts: MondrianOpts = {}
      if (row.value.mondrian_layout !== undefined) opts.layout = row.value.mondrian_layout
      if (row.value.mondrian_stroke  !== undefined) opts.stroke = row.value.mondrian_stroke
      if (row.value.mondrian_featured?.length)      opts.featured = row.value.mondrian_featured
      if (Object.keys(opts).length) mondrianOpts.value[id] = opts
    }
  }

  regions.value.forEach(r => {
    activeTab[r.id]       ??= 'overview'
    activePlayerIdx[r.id] ??= 0
  })
  loading.value = false
  await initMaps()
}

onMounted(()    => { void loadData() })
onUnmounted(()  => { mapInstances.forEach(m => m.remove()); mapInstances.clear() })
</script>

<style lang="scss" scoped>
// ── Page ───────────────────────────────────────────────────────────────────────
.mf-page    { min-height: 100vh; }
.mf-loading { padding: 80px 0; }

// ── Header ─────────────────────────────────────────────────────────────────────
.mf-header {
  border-bottom: 5px solid #111;
  background: #fff;
  position: sticky;
  top: 58px;     // main app bar height
  z-index: 50;
}

.mf-header-strip {
  display: flex;
  height: 16px;
  border-bottom: 4px solid #111;
  overflow: hidden;
}

.mhs-blk { flex-shrink: 0; height: 100%; }
.mhs-sep { width: 4px; flex-shrink: 0; background: #111; }

.mf-header-body {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 10px 20px;
  flex-wrap: wrap;
}

.mf-header-left-bar {
  width: 8px; height: 32px;
  background: #cc1010;
  border-radius: 2px;
  border: 2px solid #111;
  flex-shrink: 0;
}

.mf-header-text { flex: 1; min-width: 180px; }

.mf-title    { font-size: clamp(16px, 2.4vw, 22px); font-weight: 900; color: #0a0018; letter-spacing: 0.3px; line-height: 1.1; }
.mf-subtitle { font-size: 11px; color: rgba(0,0,0,0.4); letter-spacing: 0.8px; margin-top: 2px; }

.mf-header-controls { display: flex; gap: 8px; flex-wrap: wrap; }

.mf-hctl-btn {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 5px 12px; border-radius: 20px;
  border: 1.5px solid rgba(0,0,0,0.18);
  font-size: 11px; font-weight: 700; letter-spacing: 0.5px;
  text-decoration: none; color: rgba(0,0,0,0.55);
  transition: all 0.15s;
  &:hover { border-color: #111; color: #0a0018; background: rgba(0,0,0,0.04); }
}

// ── Body ───────────────────────────────────────────────────────────────────────
.mf-body { display: flex; flex-direction: column; }

// ── Region row ─────────────────────────────────────────────────────────────────
.mf-region {
  background: var(--rc-bg, #fafaf6);
  border-bottom: 5px solid #111;
}

// Top bar
.mfr-topbar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 18px;
  border-bottom: 4px solid #111;
  flex-wrap: wrap;
  row-gap: 6px;
}

.mfr-topbar-accent {
  width: 5px; height: 28px;
  border-radius: 2px;
  background: var(--rc, #888);
  border: 2px solid #111;
  flex-shrink: 0;
}

.mfr-name {
  font-size: 15px; font-weight: 900; letter-spacing: 0.5px;
  color: #0a0018; flex: 1; min-width: 120px;
}

.mfr-stats { display: flex; gap: 6px; flex-wrap: wrap; }

.mfr-stat {
  display: inline-flex; align-items: center; gap: 4px;
  padding: 3px 9px; border-radius: 12px; border: 1.5px solid transparent;
  font-size: 10px; font-weight: 700;
  &--show   { background: rgba(124,77,255,0.08); border-color: #7c4dff; color: #5c35b0; }
  &--senior { background: rgba(46,125,50,0.08);  border-color: #388e3c; color: #2e7d32; }
  &--nature { background: rgba(230,81,0,0.08);   border-color: #e65100; color: #bf360c; }
}

// Body: map + panel
.mfr-body {
  display: flex;
  min-height: 380px;
  @media (max-width: 680px) { flex-direction: column; }
}

// Mini map
.mfr-map-wrap {
  flex: 0 0 42%;
  position: relative;
  border-right: 5px solid #111;
  overflow: hidden;
  min-height: 320px;
  @media (max-width: 680px) { flex: 0 0 240px; border-right: none; border-bottom: 5px solid #111; }
}

.mfr-map { width: 100%; height: 100%; min-height: 320px; }

// Subtle vignette overlay on map edges
.mfr-map-overlay {
  position: absolute; inset: 0; pointer-events: none;
  background: radial-gradient(ellipse at center, transparent 55%, rgba(0,0,0,0.12) 100%);
}

// Panel
.mfr-panel { flex: 1; display: flex; flex-direction: column; min-width: 0; }

// Tabs
.mfr-tabs {
  display: flex;
  border-bottom: 4px solid #111;
  background: rgba(255,255,255,0.6);
  overflow-x: auto;
  &::-webkit-scrollbar { height: 0; }
}

.mfr-tab {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 10px 16px;
  font-size: 10px; font-weight: 800; letter-spacing: 1.5px; text-transform: uppercase;
  color: rgba(0,0,0,0.4);
  border: none; border-right: 4px solid #111;
  background: transparent; cursor: pointer;
  white-space: nowrap;
  transition: background 0.15s, color 0.15s;

  &:hover { color: rgba(0,0,0,0.7); background: rgba(0,0,0,0.04); }

  &--active {
    color: var(--rc, #7c4dff);
    background: rgba(255,255,255,0.9);
    box-shadow: inset 0 -3px 0 var(--rc, #7c4dff);
  }
}

// Tab content — default (shows + player tabs)
.mfr-content {
  flex: 1; padding: 16px 20px; overflow-y: auto;
  &::-webkit-scrollbar { width: 3px; }
  &::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.2); border-radius: 2px; }
}

// ── Overview tab: split layout ──────────────────────────────────────────────
.mfr-content--overview {
  padding: 0;
  overflow: visible;
  display: flex;
  // fill the full panel height — no max-height constraint
  flex: 1;
}

.mfro-left {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 16px 16px 12px;
  border-right: 4px solid #111;
  min-width: 0;
  overflow: hidden;
}

.mfr-desc {
  font-size: 13px; line-height: 1.7; color: rgba(0,0,0,0.6);
  margin: 0; flex-shrink: 0;
}

.mfro-hint {
  display: flex; align-items: center; gap: 5px;
  font-size: 11px; color: rgba(0,0,0,0.38); letter-spacing: 0.3px;
  flex-shrink: 0;
}

// Small Mondrian — uses fewer image slots so colour blocks show through
.mfro-small {
  flex: 1; min-height: 80px; max-height: 120px;
  overflow: hidden;
  border: 4px solid #111;
}

// Right column: large Mondrian filling full panel height
.mfro-right {
  flex: 0 0 46%;
  overflow: hidden;
  display: flex;
}

.mfro-large {
  width: 100%;
  // stretch SVG to full height via flex
  flex: 1;
  overflow: hidden;
  // The SVG has preserveAspectRatio="xMidYMid slice" so it tiles nicely
  :deep(svg) { width: 100%; height: 100%; display: block; }
}

// Show list
.mfr-show-row {
  display: flex; align-items: center; gap: 10px;
  padding: 9px 10px; border-radius: 6px;
  border-left: 3px solid var(--rc, #888);
  background: rgba(0,0,0,0.025);
  margin-bottom: 6px; cursor: pointer;
  transition: background 0.14s;
  &:hover { background: rgba(0,0,0,0.05); }
  &:last-child { margin-bottom: 0; }
}

.mfrs-seq {
  width: 22px; height: 22px; border-radius: 50%;
  background: var(--rc, #888); color: #fff;
  font-size: 10px; font-weight: 800;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.mfrs-info { flex: 1; min-width: 0; }
.mfrs-name { font-size: 13px; font-weight: 700; color: #0a0018; }
.mfrs-date { font-size: 11px; color: var(--rc, #888); margin-top: 2px; }
.mfrs-desc { font-size: 11px; color: rgba(0,0,0,0.4); margin-top: 2px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.mfrs-arrow { color: rgba(0,0,0,0.25); flex-shrink: 0; }

.mfr-empty {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  height: 100%; min-height: 180px;
  color: rgba(0,0,0,0.3); font-size: 13px; font-weight: 600;
  .mfr-empty-sub { font-size: 11px; font-weight: 400; margin-top: 4px; }
}

// ── Shows visual timeline ───────────────────────────────────────────────────
.mfr-content--timeline {
  padding: 12px 18px 10px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.tl-ruler {
  position: relative;
  height: 18px;
  flex-shrink: 0;
}

.tl-month {
  position: absolute;
  transform: translateX(-50%);
  font-size: 9px; font-weight: 800; letter-spacing: 1.5px;
  color: rgba(0,0,0,0.32);
  top: 0;
  &::after {
    content: '';
    position: absolute;
    left: 50%; top: 100%;
    width: 1px; height: 5px;
    background: rgba(0,0,0,0.18);
    transform: translateX(-50%);
  }
}

.tl-track {
  position: relative;
  height: 58px;
  flex-shrink: 0;
}

.tl-svg {
  position: absolute;
  top: 10px; left: 0;
  width: 100%; height: 32px;
  pointer-events: none;
}

.tl-leg-pill {
  font-size: 8px; font-weight: 800;
  color: var(--rc, #888);
  background: #fff;
  border: 1.5px solid var(--rc, #888);
  border-radius: 4px;
  padding: 0 3px;
  text-align: center;
  line-height: 15px; height: 15px;
  white-space: nowrap; overflow: hidden;
}

.tl-node {
  position: absolute;
  top: 2px;
  transform: translateX(-50%);
  display: flex; flex-direction: column; align-items: center; gap: 2px;
  cursor: pointer; border: none; background: none; padding: 0;

  .tl-dot {
    width: 22px; height: 22px; border-radius: 50%;
    background: var(--rc, #888); color: #fff;
    font-size: 9px; font-weight: 800;
    display: flex; align-items: center; justify-content: center;
    border: 2px solid #111;
    transition: transform 0.15s;
    flex-shrink: 0;
  }

  .tl-label {
    font-size: 8px; font-weight: 700;
    color: rgba(0,0,0,0.4);
    white-space: nowrap;
  }

  &:hover .tl-dot { transform: scale(1.25); }
}

.tl-names {
  display: flex; flex-wrap: wrap; gap: 5px;
  overflow-y: auto; max-height: 96px;
  &::-webkit-scrollbar { width: 2px; }
  &::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.15); }
}

.tl-name-chip {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 3px 9px 3px 4px;
  border-radius: 20px;
  border: 1.5px solid var(--rc, #888);
  background: none; cursor: pointer;
  font-size: 10px; font-weight: 700;
  color: rgba(0,0,0,0.55);
  transition: all 0.14s;

  .tl-name-seq {
    width: 16px; height: 16px; border-radius: 50%;
    background: var(--rc, #888); color: #fff;
    font-size: 8px; font-weight: 800;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
  }

  .tl-name-text {
    max-width: 110px; overflow: hidden;
    text-overflow: ellipsis; white-space: nowrap;
    color: rgba(0,0,0,0.65);
  }

  .tl-name-date {
    color: var(--rc, #888); opacity: 0.7; white-space: nowrap;
  }

  &:hover {
    background: var(--rc, #888); color: #fff;
    .tl-name-text, .tl-name-date { color: #fff; opacity: 1; }
  }
}

// ── Track picker (multi-show selector) ─────────────────────────────────────
.mfr-track-picker {
  display: flex; flex-direction: column; gap: 2px;
  padding: 8px 12px; border-bottom: 3px solid #111;
  background: rgba(0,0,0,0.03);
}

.mfr-track-btn {
  display: flex; align-items: center; gap: 6px;
  padding: 5px 10px;
  border: 1.5px solid rgba(0,0,0,0.15);
  background: #fff; cursor: pointer;
  font-size: 10px; font-weight: 700; letter-spacing: 0.3px;
  color: rgba(0,0,0,0.55); text-align: left;
  transition: all 0.14s;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
  &:hover { border-color: var(--rc, #888); color: var(--rc, #888); background: rgba(0,0,0,0.03); }
  &.is-active { background: var(--rc, #888); color: #fff; border-color: var(--rc, #888); }
}

// Player tab
.mfr-content--player { padding: 12px 16px; }

.mfr-player-head {
  display: flex; align-items: center; gap: 10px; margin-bottom: 10px;
}

.live-pulse {
  width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0;
  background: #f44; box-shadow: 0 0 6px rgba(255,60,60,0.7);
  animation: livePulse 1.8s ease-in-out infinite;
}
@keyframes livePulse {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0.2; }
}

.mfr-player-info  { flex: 1; min-width: 0; }
.mfr-player-title { font-size: 12px; font-weight: 700; color: #0a0018; line-height: 1.3; }
.mfr-player-sub   { font-size: 10px; color: rgba(0,0,0,0.4); margin-top: 2px; }

.mfr-popout-link {
  flex-shrink: 0; display: inline-flex; align-items: center; gap: 3px;
  font-size: 10px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase;
  text-decoration: none; color: var(--rc, #888);
  padding: 4px 10px; border: 1.5px solid var(--rc, #888); border-radius: 20px;
  transition: all 0.15s;
  &:hover { background: var(--rc, #888); color: #fff; }
}

.mfr-player-frame {
  width: 100%; height: 120px; display: block;
  border: 3px solid #111; border-radius: 1px;
}

// Actions row
.mfr-actions {
  display: flex; border-top: 4px solid #111; flex-shrink: 0;
  flex-wrap: wrap;
}

.mfra-btn {
  flex: 1; min-width: 70px;
  display: flex; align-items: center; justify-content: center; gap: 5px;
  padding: 10px 8px;
  font-size: 10px; font-weight: 800; letter-spacing: 1.2px; text-transform: uppercase;
  text-decoration: none; color: rgba(0,0,0,0.45);
  border: none; border-right: 4px solid #111;
  background: transparent; cursor: pointer;
  transition: background 0.15s, color 0.15s;
  &:last-child { border-right: none; }
  &:hover { background: rgba(0,0,0,0.04); color: rgba(0,0,0,0.75); }
  &--primary {
    color: var(--rc, #7c4dff);
    &:hover { background: var(--rc, #7c4dff); color: #fff; }
  }
}

// ── Flowing SVG connector between regions ──────────────────────────────────────
.mf-flow { height: 36px; overflow: hidden; pointer-events: none; }
.mf-flow-svg { width: 100%; height: 36px; display: block; }

// ── Dark mode ─────────────────────────────────────────────────────────────────
.mf--dark {
  // Page + header
  background: #0a0a10;
  .mf-header      { background: #0d0014; }
  .mf-title       { color: #eeeaff; }
  .mf-subtitle    { color: rgba(255,255,255,0.36); }
  .mf-header-left-bar { background: #cc1010; }
  .mf-hctl-btn    {
    border-color: rgba(255,255,255,0.16); color: rgba(255,255,255,0.48);
    &:hover { border-color: rgba(255,255,255,0.45); color: #fff; background: rgba(255,255,255,0.07); }
  }

  // Region row
  .mfr-topbar { background: rgba(0,0,0,0.35); }
  .mfr-name   { color: #eeeaff; }
  .mfr-stat {
    &--show   { background: rgba(124,77,255,0.2); border-color: rgba(124,77,255,0.6); color: #c5b8ff; }
    &--senior { background: rgba(46,125,50,0.2);  border-color: rgba(56,142,60,0.6);  color: #a5d6a7; }
    &--nature { background: rgba(230,81,0,0.2);   border-color: rgba(230,81,0,0.6);   color: #ffcc80; }
  }

  // Map vignette — darker in dark mode
  .mfr-map-overlay {
    background: radial-gradient(ellipse at center, transparent 40%, rgba(0,0,0,0.35) 100%);
  }

  // Tabs
  .mfr-tabs { background: rgba(255,255,255,0.05); border-bottom-color: #222; }
  .mfr-tab  {
    color: rgba(255,255,255,0.35); border-right-color: #222;
    &:hover   { color: rgba(255,255,255,0.65); background: rgba(255,255,255,0.05); }
    &--active { color: var(--rc); background: rgba(255,255,255,0.09); box-shadow: inset 0 -3px 0 var(--rc); }
  }

  // Overview tab
  .mfro-left  { border-right-color: #222; }
  .mfr-desc   { color: rgba(255,255,255,0.52); }
  .mfro-hint  { color: rgba(255,255,255,0.28); }
  .mfro-small { border-color: #222; }

  // Shows timeline tab
  .tl-month     { color: rgba(255,255,255,0.28); }
  .tl-month::after { background: rgba(255,255,255,0.15); }
  .tl-label     { color: rgba(255,255,255,0.35); }
  .tl-leg-pill  { background: #0d0014; }
  .tl-node .tl-dot { border-color: rgba(255,255,255,0.3); }
  .tl-name-chip {
    color: rgba(255,255,255,0.45);
    .tl-name-text { color: rgba(255,255,255,0.65); }
    &:hover { color: #fff; .tl-name-text, .tl-name-date { color: #fff; } }
  }
  .mfr-empty  { color: rgba(255,255,255,0.26); }

  // Track picker
  .mfr-track-picker { background: rgba(255,255,255,0.04); border-bottom-color: #222; }
  .mfr-track-btn {
    background: #1a1a2e; border-color: #333; color: rgba(255,255,255,0.45);
    &:hover   { border-color: var(--rc); color: var(--rc); background: rgba(255,255,255,0.05); }
    &.is-active { background: var(--rc); color: #fff; border-color: var(--rc); }
  }

  // Player tab
  .mfr-player-title { color: rgba(255,255,255,0.85); }
  .mfr-player-sub   { color: rgba(255,255,255,0.36); }
  .mfr-player-frame { border-color: #222; }
  .mfr-popout-link  {
    border-color: var(--rc);
    &:hover { background: var(--rc); color: #fff; }
  }

  // Actions
  .mfr-actions { border-top-color: #222; }
  .mfra-btn {
    color: rgba(255,255,255,0.38); border-right-color: #222;
    &:hover   { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.8); }
    &--primary { color: var(--rc);
      &:hover  { background: var(--rc); color: #fff; } }
  }

  // Flow connectors — slightly more visible on dark bg
  .mf-flow-svg path { opacity: 0.5; }
}
</style>

<style>
/* Un-scoped: keep Leaflet attribution readable */
.mfr-map .leaflet-control-attribution { display: none; }
</style>

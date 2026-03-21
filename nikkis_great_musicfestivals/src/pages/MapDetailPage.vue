<template>
  <q-page :class="['map-detail-page', $q.dark.isActive ? 'mdp--dark' : 'mdp--light']">

    <!-- ══ TOP BAR ══════════════════════════════════════════════════ -->
    <div class="map-topbar">
      <q-btn flat dense icon="arrow_back" :to="'/maps'"
             class="topbar-back" color="white" size="sm" label="Regions" />

      <div class="topbar-region">
        <div class="topbar-region-name">{{ region?.name ?? '…' }}</div>
        <div class="topbar-region-desc">{{ region?.description ?? '' }}</div>
      </div>

      <div class="topbar-filters">
        <button
          v-for="f in filterDefs" :key="f.key"
          :class="['filter-pill', `filter-pill--${f.key}`, { active: filters[f.key] }]"
          @click="filters[f.key] = !filters[f.key]"
        >
          <q-icon :name="f.icon" size="14px" />
          <span>{{ f.label }}</span>
          <span class="filter-pill-count">{{ counts[f.key] }}</span>
        </button>
      </div>

      <div class="topbar-actions">
        <button
          v-if="region?.image_url"
          :class="['topbar-btn', { active: photoOpen }]"
          @click="photoOpen = !photoOpen"
          title="Region photo"
        >
          <q-icon name="image" size="16px" />
        </button>
        <button
          :class="['topbar-btn', { active: sideOpen }]"
          @click="sideOpen = !sideOpen"
          title="Venue list"
        >
          <q-icon name="list" size="16px" />
        </button>
        <button
          :class="['topbar-btn', { active: timelineOpen }]"
          @click="timelineOpen = !timelineOpen"
          title="Tour timeline"
        >
          <q-icon name="timeline" size="16px" />
        </button>
      </div>
    </div>

    <!-- ══ REGION HERO ════════════════════════════════════════════════ -->
    <div v-if="region" class="region-hero">

      <!-- Image carousel -->
      <q-carousel
        v-model="currentSlide"
        animated
        infinite
        :autoplay="6500"
        arrows
        navigation
        transition-prev="slide-right"
        transition-next="slide-left"
        class="hero-carousel"
        height="228px"
      >
        <q-carousel-slide
          v-for="(img, idx) in heroImages"
          :key="idx"
          :name="idx"
        >
          <div class="hero-slide-bg" :style="{ backgroundImage: `url(${img})` }" />
          <div class="hero-slide-gradient" />
        </q-carousel-slide>

        <template #control>
          <q-carousel-control position="top-left" :offset="[18, 18]">
            <div class="hero-region-info">
              <div class="hero-eyebrow">Tour Region</div>
              <div class="hero-rname">{{ region.name }}</div>
              <div v-if="region.description" class="hero-rdesc">{{ region.description }}</div>
            </div>
          </q-carousel-control>
        </template>
      </q-carousel>

      <!-- Archive.org show player -->
      <div class="hero-player">
        <div class="player-meta">
          <span class="player-live" />
          <div class="player-info">
            <div class="player-title">{{ currentArchiveShow.label }}</div>
            <div class="player-sub">archive.org · Live Recording</div>
          </div>
          <a
            :href="`https://archive.org/details/${currentArchiveShow.id}`"
            target="_blank" rel="noopener noreferrer"
            class="player-popout"
          >
            <q-icon name="open_in_new" size="13px" />
            Pop out
          </a>
        </div>
        <iframe
          :src="`https://archive.org/embed/${currentArchiveShow.id}`"
          class="player-frame"
          frameborder="0"
          allow="autoplay"
          loading="lazy"
        />
      </div>

    </div>

    <!-- ══ MAP + SIDE PANEL ROW ══════════════════════════════════════ -->
    <div class="map-body">

      <!-- Leaflet map -->
      <div id="detail-map" class="map-canvas" />

      <!-- Collapsible side panel -->
      <transition name="side-panel">
        <div v-if="sideOpen" class="side-panel">
          <div class="side-scroll">

            <!-- SHOWS -->
            <div v-if="filters.show && sortedShows.length" class="side-section">
              <div class="side-section-head">
                <q-icon name="event" size="14px" class="q-mr-xs" />
                Shows · {{ sortedShows.length }}
              </div>
              <div
                v-for="(show, i) in sortedShows"
                :key="show.id"
                :class="['venue-card', { 'venue-card--active': activeShowId === show.id }]"
                @click="panToShow(show)"
              >
                <div class="venue-seq">{{ i + 1 }}</div>
                <div class="venue-info">
                  <div class="venue-name">{{ show.name }}</div>
                  <div class="venue-date">{{ formatDate(show.date) }}</div>
                  <div v-if="show.description" class="venue-desc">{{ show.description }}</div>
                </div>
              </div>
            </div>

            <!-- SENIOR FACILITIES -->
            <div v-if="filters.senior && seniorPoints.length" class="side-section">
              <div class="side-section-head side-section-head--senior">
                <q-icon name="elderly" size="14px" class="q-mr-xs" />
                Senior Facilities · {{ seniorPoints.length }}
              </div>
              <div
                v-for="pt in seniorPoints"
                :key="pt.id"
                class="venue-card venue-card--senior"
                @click="panToPoint(pt)"
              >
                <div class="venue-info">
                  <div class="venue-name">{{ pt.name }}</div>
                  <div v-if="pt.description" class="venue-desc">{{ pt.description }}</div>
                </div>
              </div>
            </div>

            <!-- OUTDOOR MUST-SEES -->
            <div v-if="filters.nature && naturePoints.length" class="side-section">
              <div class="side-section-head side-section-head--nature">
                <q-icon name="park" size="14px" class="q-mr-xs" />
                Outdoor Must-sees · {{ naturePoints.length }}
              </div>
              <div
                v-for="pt in naturePoints"
                :key="pt.id"
                class="venue-card venue-card--nature"
                @click="panToPoint(pt)"
              >
                <div class="venue-info">
                  <div class="venue-name">{{ pt.name }}</div>
                  <div v-if="pt.description" class="venue-desc">{{ pt.description }}</div>
                </div>
              </div>
            </div>

            <div v-if="!sortedShows.length && !seniorPoints.length && !naturePoints.length"
                 class="side-empty">
              No points loaded yet — add them via the Admin panel.
            </div>

          </div>
        </div>
      </transition>
    </div>

    <!-- ══ REGION PHOTO PANEL ════════════════════════════════════════ -->
    <transition name="photo">
      <div v-if="photoOpen && region?.image_url" class="photo-panel">
        <img :src="region.image_url" class="photo-panel-img" :alt="region.name" />
        <div class="photo-panel-overlay">
          <span class="photo-panel-name">{{ region.name }}</span>
          <button class="photo-close-btn" @click="photoOpen = false">
            <q-icon name="close" size="16px" />
          </button>
        </div>
      </div>
    </transition>

    <!-- ══ TOUR TIMELINE ═════════════════════════════════════════════ -->
    <transition name="tl">
      <div v-if="timelineOpen" class="timeline-panel">

        <div class="tl-header">
          <span class="tl-title">Summer 2026 Tour</span>
          <span class="tl-subtitle">{{ sortedShows.length }} show{{ sortedShows.length !== 1 ? 's' : '' }}</span>
        </div>

        <div class="tl-track-wrap q-px-md q-pb-md" ref="trackRef">

          <!-- Month ticks -->
          <div v-for="m in months" :key="m.label" class="tl-month" :style="`left:${m.pct}%`">{{ m.label }}</div>
          <div v-for="m in months" :key="`t-${m.label}`" class="tl-tick" :style="`left:${m.pct}%`" />

          <div class="tl-base" />

          <!-- Leg SVG -->
          <svg class="tl-legs-svg" height="44" preserveAspectRatio="none">
            <line
              v-for="(leg, i) in showLegs" :key="i"
              :x1="`${leg.x1}%`" y1="22" :x2="`${leg.x2}%`" y2="22"
              stroke="#7c4dff" stroke-width="2" stroke-dasharray="5 5" opacity="0.8"
            />
            <g v-for="(leg, i) in showLegs" :key="`l-${i}`">
              <rect :x="`calc(${(leg.x1+leg.x2)/2}% - 18px)`" y="9"
                    width="36" height="14" rx="7" fill="rgba(124,77,255,0.8)" />
              <text :x="`${(leg.x1+leg.x2)/2}%`" y="20"
                    text-anchor="middle" font-size="9" font-weight="700" fill="white">
                {{ leg.days }}d
              </text>
            </g>
          </svg>

          <!-- Show dots -->
          <div
            v-for="(show, i) in sortedShows" :key="show.id"
            :class="['tl-show', { 'tl-show--active': activeShowId === show.id }]"
            :style="`left:${showPct(show)}%`"
            @click="panToShow(show)"
            :title="show.name"
          >
            <div class="tl-seq">{{ i + 1 }}</div>
            <div class="tl-dot" />
            <div class="tl-show-name">{{ show.name }}</div>
            <div class="tl-show-date">{{ formatDate(show.date) }}</div>
          </div>

        </div>
      </div>
    </transition>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useQuasar } from 'quasar'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'

const route        = useRoute()
const $q           = useQuasar()
const region       = ref<MapRegion | null>(null)
const filters      = reactive({ show: true, senior: true, nature: true })
const timelineOpen = ref(true)
const sideOpen     = ref(false)
const photoOpen    = ref(false)
const sortedShows  = ref<MapPoint[]>([])
const seniorPoints = ref<MapPoint[]>([])
const naturePoints = ref<MapPoint[]>([])
const activeShowId = ref<string | null>(null)

let mapInstance: L.Map | null = null
const showMarkerRefs  = new Map<string, L.Marker>()
const pointMarkerRefs = new Map<string, L.Marker>()

/* ── Hero carousel + archive player ─────────────────────────────── */
const HERO_IMAGES = [
  'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=1600&q=80',
  'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=1600&q=80',
  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=1600&q=80',
  'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?auto=format&fit=crop&w=1600&q=80',
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1600&q=80',
  'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1600&q=80',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1600&q=80',
  'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1600&q=80',
]

// Curated archive.org recordings — freely streamable
const ARCHIVE_SHOWS = [
  { id: '78_9958-Take-the-A-train',                                           label: 'Duke Ellington · Take the A Train (1941 78rpm)' },
  { id: 'gd1977-05-08.shure57.stevenson-ladner-beaumont.29662.sbefp.flac16', label: 'Grateful Dead · Cornell, May 8 1977' },
  { id: 'gd1972-08-27.sbd.hollister.174.sbeok.shnf',                         label: 'Grateful Dead · Veneta, Aug 27 1972' },
  { id: 'gd1991-09-10.sbd.miller.87991.sbeok.shnf',                          label: 'Grateful Dead · Madison Square Garden, Sep 1991' },
  { id: 'gd1985-07-04.sbd.seamons.9517.sbeok.shnf',                          label: 'Grateful Dead · Autzen Stadium, Jul 4 1985' },
  { id: 'gd1973-11-11.sbd.unknown.14042.sbeok.shnf',                         label: 'Grateful Dead · Winterland, Nov 11 1973' },
  { id: 'billystrings2026-02-06',                                              label: 'Billy Strings · Athens, GA — Feb 6 2026' },
]

const currentSlide      = ref(0)
const customHeroImages  = ref<string[]>([])
const customArchiveShow = ref<{ id: string; label: string } | null>(null)

const heroImages = computed(() => {
  if (customHeroImages.value.length >= 2) return customHeroImages.value
  const hash = (region.value?.name ?? '').split('').reduce((a, c) => a + c.charCodeAt(0), 0)
  const start = hash % HERO_IMAGES.length
  return Array.from({ length: 5 }, (_, i) => HERO_IMAGES[(start + i) % HERO_IMAGES.length]!)
})

const currentArchiveShow = computed(() => {
  if (customArchiveShow.value) return customArchiveShow.value
  const hash = (region.value?.name ?? '').split('').reduce((a, c) => a + c.charCodeAt(0), 0)
  return ARCHIVE_SHOWS[hash % ARCHIVE_SHOWS.length]!
})

/* ── Filter definitions ─────────────────────────────────────────── */
const filterDefs = [
  { key: 'show'   as const, label: 'Shows',              icon: 'event',   },
  { key: 'senior' as const, label: 'Senior Facilities',  icon: 'elderly', },
  { key: 'nature' as const, label: 'Outdoor Must-sees',  icon: 'park',    },
]

const counts = computed(() => ({
  show:   sortedShows.value.length,
  senior: seniorPoints.value.length,
  nature: naturePoints.value.length,
}))

/* ── Season maths ────────────────────────────────────────────────── */
const SEASON_START = new Date('2026-06-01').getTime()
const SEASON_END   = new Date('2026-09-15').getTime()
const SEASON_MS    = SEASON_END - SEASON_START

const months = [
  { label: 'JUN', pct: 0 },
  { label: 'JUL', pct: (30 / 106) * 100 },
  { label: 'AUG', pct: (61 / 106) * 100 },
  { label: 'SEP', pct: (92 / 106) * 100 },
]

function showPct(p: MapPoint): number {
  if (!p.date) return 50
  return Math.max(2, Math.min(97, ((new Date(p.date).getTime() - SEASON_START) / SEASON_MS) * 100))
}

function daysBetween(a: string | null, b: string | null): number {
  if (!a || !b) return 0
  return Math.round((new Date(b).getTime() - new Date(a).getTime()) / 86_400_000)
}

function formatDate(d: string | null): string {
  if (!d) return ''
  const [, m, day] = d.split('-')
  const names = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  return `${names[parseInt(m ?? '0')] ?? ''} ${parseInt(day ?? '0')}`
}

const showLegs = computed(() =>
  sortedShows.value.slice(1).map((show, i) => ({
    x1:   showPct(sortedShows.value[i]!),
    x2:   showPct(show),
    days: daysBetween(sortedShows.value[i]!.date, show.date),
  }))
)

/* ── Marker helpers ──────────────────────────────────────────────── */
function makeShowIcon(index: number) {
  return L.divIcon({
    className: '',
    html: `<div style="
      width:26px;height:26px;border-radius:50%;
      background:linear-gradient(135deg,#7c4dff,#5c35b0);
      border:2.5px solid white;
      display:flex;align-items:center;justify-content:center;
      font-size:11px;font-weight:800;color:white;
      box-shadow:0 2px 10px rgba(124,77,255,0.6);
      cursor:pointer;
    ">${index + 1}</div>`,
    iconSize: [26, 26], iconAnchor: [13, 13],
  })
}

function makeActiveShowIcon(index: number) {
  return L.divIcon({
    className: '',
    html: `<div style="
      width:32px;height:32px;border-radius:50%;
      background:linear-gradient(135deg,#ffd600,#ff8f00);
      border:3px solid white;
      display:flex;align-items:center;justify-content:center;
      font-size:13px;font-weight:800;color:#1a0a2e;
      box-shadow:0 3px 14px rgba(255,214,0,0.7);
      cursor:pointer;
    ">${index + 1}</div>`,
    iconSize: [32, 32], iconAnchor: [16, 16],
  })
}

function makePinIcon(color: string, glow: string) {
  return L.divIcon({
    className: '',
    html: `<div style="
      width:14px;height:14px;border-radius:50%;
      background:${color};border:2px solid white;
      box-shadow:0 1px 6px ${glow};
    "></div>`,
    iconSize: [14, 14], iconAnchor: [7, 7],
  })
}

function popupHtml(p: MapPoint, index?: number) {
  const badge = index !== undefined
    ? `<span style="background:linear-gradient(135deg,#7c4dff,#5c35b0);color:#fff;border-radius:50%;width:22px;height:22px;display:inline-flex;align-items:center;justify-content:center;font-weight:800;font-size:11px;margin-right:8px;flex-shrink:0;">${index + 1}</span>`
    : ''
  const catColors: Record<string, string> = { show: '#7c4dff', senior: '#43a047', nature: '#ff8f00' }
  const border = catColors[p.category] ?? '#888'
  return `
    <div style="min-width:220px;max-width:280px;font-family:inherit;border-top:3px solid ${border};padding-top:8px;">
      ${p.image_url ? `<img src="${p.image_url}" style="width:100%;height:130px;object-fit:cover;border-radius:6px;margin-bottom:10px;">` : ''}
      <div style="display:flex;align-items:center;margin-bottom:4px;">
        ${badge}
        <strong style="font-size:14px;color:#1a0a2e;">${p.name}</strong>
      </div>
      ${p.date ? `<div style="color:#7c4dff;font-size:12px;font-weight:600;margin-bottom:6px;">📅 ${formatDate(p.date)}</div>` : ''}
      ${p.description ? `<div style="font-size:12px;color:#444;line-height:1.5;">${p.description}</div>` : ''}
    </div>
  `
}

/* ── Pan helpers ─────────────────────────────────────────────────── */
function panToShow(show: MapPoint) {
  activeShowId.value = show.id
  if (!mapInstance) return
  mapInstance.setView([show.lat, show.lng], Math.max(mapInstance.getZoom(), 10), { animate: true })
  const marker = showMarkerRefs.get(show.id)
  if (marker) setTimeout(() => marker.openPopup(), 350)
  // update icon to active/inactive
  showMarkerRefs.forEach((m, id) => {
    const idx = sortedShows.value.findIndex(s => s.id === id)
    m.setIcon(id === show.id ? makeActiveShowIcon(idx) : makeShowIcon(idx))
  })
}

function panToPoint(pt: MapPoint) {
  if (!mapInstance) return
  mapInstance.setView([pt.lat, pt.lng], Math.max(mapInstance.getZoom(), 12), { animate: true })
  const marker = pointMarkerRefs.get(pt.id)
  if (marker) setTimeout(() => marker.openPopup(), 350)
}

/* ── Load ────────────────────────────────────────────────────────── */
onMounted(async () => {
  const regionId = route.params.regionId as string

  const [{ data: rgn }, { data: pts }, { data: heroData }] = await Promise.all([
    supabase.from('map_regions').select('*').eq('id', regionId).single(),
    supabase.from('map_points').select('*').eq('region_id', regionId),
    supabase.from('site_settings').select('value').eq('key', `region_hero_${regionId}`).limit(1),
  ])

  region.value = rgn as MapRegion

  // Apply custom hero config if present
  const heroVal = (heroData as { value: unknown }[] | null)?.[0]?.value as Record<string, unknown> | undefined
  if (heroVal) {
    if (Array.isArray(heroVal.images) && (heroVal.images as unknown[]).length >= 2)
      customHeroImages.value = heroVal.images as string[]
    if (typeof heroVal.archive_id === 'string' && heroVal.archive_id) {
      customArchiveShow.value = {
        id:    heroVal.archive_id,
        label: typeof heroVal.archive_label === 'string' ? heroVal.archive_label : heroVal.archive_id,
      }
    }
  }
  const points: MapPoint[] = (pts as MapPoint[]) ?? []

  sortedShows.value  = points
    .filter(p => p.category === 'show' && p.date)
    .sort((a, b) => (a.date ?? '').localeCompare(b.date ?? ''))
  seniorPoints.value = points.filter(p => p.category === 'senior')
  naturePoints.value = points.filter(p => p.category === 'nature')

  /* ── Leaflet init ── */
  const map = L.map('detail-map', { zoomControl: false }).setView(
    [region.value.center_lat, region.value.center_lng],
    region.value.zoom
  )
  mapInstance = map

  // Zoom control — bottom right
  L.control.zoom({ position: 'bottomright' }).addTo(map)

  // CartoDB Voyager tiles — clean, detailed, no fuss
  L.tileLayer(
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>',
      subdomains: 'abcd',
      maxZoom: 19,
    }
  ).addTo(map)

  /* ── Layer groups ── */
  const layers: Record<string, L.LayerGroup> = {
    show:   L.layerGroup().addTo(map),
    senior: L.layerGroup().addTo(map),
    nature: L.layerGroup().addTo(map),
  }

  /* ── Non-show markers ── */
  seniorPoints.value.forEach(p => {
    const marker = L.marker([p.lat, p.lng], {
      icon: makePinIcon('#43a047', 'rgba(67,160,71,0.5)'),
    }).bindPopup(popupHtml(p), { maxWidth: 300 })
      .addTo(layers.senior!)
    pointMarkerRefs.set(p.id, marker)
  })

  naturePoints.value.forEach(p => {
    const marker = L.marker([p.lat, p.lng], {
      icon: makePinIcon('#ff8f00', 'rgba(255,143,0,0.5)'),
    }).bindPopup(popupHtml(p), { maxWidth: 300 })
      .addTo(layers.nature!)
    pointMarkerRefs.set(p.id, marker)
  })

  /* ── Numbered show markers ── */
  sortedShows.value.forEach((show, i) => {
    const marker = L.marker([show.lat, show.lng], { icon: makeShowIcon(i) })
      .bindPopup(popupHtml(show, i), { maxWidth: 300 })
      .addTo(layers.show!)
    showMarkerRefs.set(show.id, marker)
  })

  /* ── Dashed tour-leg polylines ── */
  const legLayer = L.layerGroup().addTo(map)

  sortedShows.value.forEach((show, i) => {
    if (i === 0) return
    const prev = sortedShows.value[i - 1]!

    L.polyline([[prev.lat, prev.lng], [show.lat, show.lng]], {
      color: '#7c4dff', weight: 2, dashArray: '8 10', opacity: 0.7, interactive: false,
    }).addTo(legLayer)

    const midLat = (prev.lat + show.lat) / 2
    const midLng = (prev.lng + show.lng) / 2
    const days   = daysBetween(prev.date, show.date)

    if (days > 0) {
      L.marker([midLat, midLng], {
        icon: L.divIcon({
          className: '',
          html: `<div style="background:rgba(124,77,255,0.85);color:#fff;
            font-size:10px;font-weight:700;padding:2px 7px;border-radius:10px;
            white-space:nowrap;border:1px solid rgba(255,255,255,0.3);
            backdrop-filter:blur(4px);line-height:1.5;">${days}d</div>`,
          iconAnchor: [20, 10],
        }),
        interactive: false,
      } as L.MarkerOptions).addTo(legLayer)
    }
  })

  /* ── Filter watcher ── */
  watch(filters, val => {
    (['show', 'senior', 'nature'] as const).forEach(cat => {
      if (val[cat]) layers[cat]!.addTo(map)
      else          layers[cat]!.remove()
    })
    if (val.show) legLayer.addTo(map)
    else          legLayer.remove()
  }, { deep: true })
})
</script>

<style lang="scss" scoped>
/* ══ Page shell ══════════════════════════════════════════════════ */
.map-detail-page {
  display: flex;
  flex-direction: column;
  background: #0d0028;
  /* scrollable — hero → full-viewport map → timeline → footer */
}

/* ══ Top bar ═════════════════════════════════════════════════════ */
.map-topbar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 12px;
  min-height: 52px;
  flex-shrink: 0;
  background: linear-gradient(105deg, #0d0024 0%, #1a0042 100%);
  border-bottom: 1px solid rgba(124,77,255,0.35);
  flex-wrap: wrap;
  /* sticky so it stays visible while scrolling past the hero, sits flush below main header */
  position: sticky;
  top: 58px;
  z-index: 100;
}

.topbar-back { color: rgba(255,255,255,0.6) !important; }

.topbar-region {
  line-height: 1.2;
  margin-right: 8px;
}
.topbar-region-name {
  font-size: 14px; font-weight: 700; color: #fff; letter-spacing: 0.5px;
}
.topbar-region-desc {
  font-size: 10px; color: rgba(255,255,255,0.45); letter-spacing: 0.5px;
}

/* Filter pills */
.topbar-filters {
  display: flex; gap: 6px; flex-wrap: wrap; flex: 1;
}
.filter-pill {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 4px 10px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.18);
  background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.55);
  font-size: 11px; font-weight: 600; cursor: pointer;
  transition: all 0.18s;
  .filter-pill-count {
    background: rgba(255,255,255,0.1); border-radius: 8px;
    padding: 0 5px; font-size: 10px;
  }
  &.active, &:hover {
    color: #fff; border-color: rgba(255,255,255,0.4);
    background: rgba(255,255,255,0.12);
  }
  &--show.active   { border-color: #7c4dff; background: rgba(124,77,255,0.2); color: #d0b4ff; }
  &--senior.active { border-color: #43a047; background: rgba(67,160,71,0.2);  color: #a5d6a7; }
  &--nature.active { border-color: #ff8f00; background: rgba(255,143,0,0.2);  color: #ffcc80; }
}

.topbar-actions {
  display: flex; gap: 4px; margin-left: auto;
}
.topbar-btn {
  width: 32px; height: 32px; border-radius: 6px;
  border: 1px solid rgba(255,255,255,0.15);
  background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.5);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer; transition: all 0.18s;
  &:hover, &.active {
    background: rgba(124,77,255,0.3); border-color: #7c4dff; color: #fff;
  }
}

/* ══ Map + side row ══════════════════════════════════════════════ */
.map-body {
  display: flex;
  /* Map fills the full viewport below both headers: main (58px) + map topbar (52px) */
  height: calc(100vh - 110px);
  flex-shrink: 0;
  overflow: hidden;
}

.map-canvas { flex: 1; min-height: 0; }

/* ══ Side panel ══════════════════════════════════════════════════ */
.side-panel {
  width: 290px;
  flex-shrink: 0;
  background: #0d0028;
  border-left: 1px solid rgba(124,77,255,0.3);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
.side-scroll {
  overflow-y: auto;
  flex: 1;
  padding: 8px 0 16px;
  &::-webkit-scrollbar { width: 4px; }
  &::-webkit-scrollbar-track { background: transparent; }
  &::-webkit-scrollbar-thumb { background: rgba(124,77,255,0.4); border-radius: 2px; }
}
.side-panel-enter-active, .side-panel-leave-active { transition: width 0.25s ease; }
.side-panel-enter-from, .side-panel-leave-to { width: 0 !important; }

.side-section { margin-bottom: 8px; }

.side-section-head {
  padding: 8px 14px 6px;
  font-size: 10px; font-weight: 800; letter-spacing: 2px;
  text-transform: uppercase; color: #9c7aff;
  display: flex; align-items: center;
  border-bottom: 1px solid rgba(124,77,255,0.2);
  &--senior { color: #81c784; border-color: rgba(67,160,71,0.2); }
  &--nature  { color: #ffb74d; border-color: rgba(255,143,0,0.2); }
}

.venue-card {
  display: flex; gap: 10px; align-items: flex-start;
  padding: 10px 14px; cursor: pointer;
  border-left: 3px solid transparent;
  transition: background 0.15s, border-color 0.15s;
  &:hover { background: rgba(255,255,255,0.05); border-left-color: #7c4dff; }
  &--active { background: rgba(124,77,255,0.12); border-left-color: #ffd600; }
  &--senior:hover { border-left-color: #43a047; }
  &--nature:hover { border-left-color: #ff8f00; }
}
.venue-seq {
  width: 20px; height: 20px; border-radius: 50%;
  background: rgba(124,77,255,0.4); color: #d0b4ff;
  font-size: 10px; font-weight: 800;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0; margin-top: 1px;
}
.venue-info { flex: 1; min-width: 0; }
.venue-name { font-size: 12px; font-weight: 700; color: #e8e0ff; margin-bottom: 2px; }
.venue-date { font-size: 11px; color: #9c7aff; }
.venue-desc { font-size: 11px; color: rgba(255,255,255,0.4); margin-top: 2px;
              overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.side-empty { padding: 24px 16px; font-size: 12px; color: rgba(255,255,255,0.3); text-align: center; }

/* ══ Timeline ════════════════════════════════════════════════════ */
.timeline-panel {
  background: #06001a;
  border-top: 1px solid rgba(124,77,255,0.25);
  height: 160px; overflow: hidden;
}
.tl-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 6px 16px;
}
.tl-title   { font-size: 10px; font-weight: 800; letter-spacing: 3px; color: #7c4dff; text-transform: uppercase; }
.tl-subtitle { font-size: 10px; color: rgba(255,255,255,0.3); }

.tl-track-wrap { position: relative; height: 112px; }
.tl-base { position: absolute; top: 22px; left: 0; right: 0; height: 2px; background: rgba(124,77,255,0.2); }
.tl-legs-svg { position: absolute; top: 0; left: 0; width: 100%; pointer-events: none; }

.tl-month {
  position: absolute; top: 0; transform: translateX(-50%);
  font-size: 9px; font-weight: 700; letter-spacing: 1.5px; color: #4a2b8c;
}
.tl-tick {
  position: absolute; top: 18px; transform: translateX(-50%);
  width: 1px; height: 8px; background: rgba(124,77,255,0.3);
}
.tl-show {
  position: absolute; top: 0; transform: translateX(-50%);
  display: flex; flex-direction: column; align-items: center;
  cursor: pointer; transition: filter 0.15s;
  &:hover, &--active { filter: drop-shadow(0 0 6px rgba(255,214,0,0.8));
    .tl-dot { background: #ffd600; transform: scale(1.35); } }
}
.tl-seq  { font-size: 9px; font-weight: 800; color: #9c7aff; line-height: 1; margin-bottom: 2px; }
.tl-dot  { width: 12px; height: 12px; border-radius: 50%;
           background: #7c4dff; border: 2px solid rgba(255,255,255,0.45);
           transition: transform 0.15s, background 0.15s; flex-shrink: 0; }
.tl-show-name { margin-top: 4px; font-size: 9px; font-weight: 700; color: #c5b8ff;
                white-space: nowrap; max-width: 80px; overflow: hidden; text-overflow: ellipsis; }
.tl-show-date { font-size: 8px; color: #4a3870; white-space: nowrap; }

.tl-enter-active, .tl-leave-active { transition: height 0.28s ease, opacity 0.28s ease; }
.tl-enter-from, .tl-leave-to       { height: 0 !important; opacity: 0; }

/* ══ Photo panel ═════════════════════════════════════════════════ */
.photo-panel {
  position: relative;
  height: 220px;
  overflow: hidden;
  border-top: 1px solid rgba(124,77,255,0.2);
}
.photo-panel-img {
  width: 100%; height: 100%; object-fit: cover; display: block;
}
.photo-panel-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to right, rgba(0,0,0,0.55) 0%, transparent 50%);
  display: flex; align-items: flex-end; justify-content: space-between;
  padding: 10px 14px;
}
.photo-panel-name {
  font-size: 13px; font-weight: 700; color: #fff;
  letter-spacing: 0.5px; text-shadow: 0 1px 6px rgba(0,0,0,0.7);
}
.photo-close-btn {
  background: rgba(0,0,0,0.4); border: 1px solid rgba(255,255,255,0.2);
  border-radius: 50%; width: 24px; height: 24px;
  display: flex; align-items: center; justify-content: center;
  color: rgba(255,255,255,0.7); cursor: pointer;
  &:hover { background: rgba(0,0,0,0.7); color: #fff; }
}
.photo-enter-active, .photo-leave-active { transition: height 0.25s ease, opacity 0.25s ease; }
.photo-enter-from, .photo-leave-to       { height: 0 !important; opacity: 0; }

/* ══ Region hero ═════════════════════════════════════════════════ */
.region-hero { flex-shrink: 0; }

.hero-carousel {
  :deep(.q-carousel__slide)  { padding: 0; }
  :deep(.q-carousel__arrow) {
    background: rgba(0,0,0,0.38);
    backdrop-filter: blur(4px);
    border: 1px solid rgba(255,255,255,0.2);
    border-radius: 50%;
    &:hover { background: rgba(0,0,0,0.62); }
    .q-icon { color: #fff !important; }
  }
  :deep(.q-carousel__navigation-icon)         { color: rgba(255,255,255,0.45) !important; }
  :deep(.q-carousel__navigation-icon--active) { color: #fff !important; }
}

.hero-slide-bg {
  position: absolute; inset: 0;
  background-size: cover; background-position: center;
}
.hero-slide-gradient {
  position: absolute; inset: 0;
  background: linear-gradient(to bottom,
    rgba(5,0,20,0.22) 0%, transparent 38%, rgba(5,0,20,0.72) 100%);
}

.hero-region-info { text-shadow: 0 1px 8px rgba(0,0,0,0.9); }
.hero-eyebrow {
  font-size: 9px; font-weight: 800; letter-spacing: 3px;
  text-transform: uppercase; color: rgba(255,214,0,0.88); margin-bottom: 4px;
}
.hero-rname {
  font-size: clamp(15px, 2vw, 24px); font-weight: 900;
  color: #fff; line-height: 1.1;
}
.hero-rdesc {
  font-size: 11px; color: rgba(255,255,255,0.65); margin-top: 3px; max-width: 260px;
}

/* ── Archive player strip ─────────────────────────────────────── */
.hero-player {
  background: #06001a;
  border-top: 1px solid rgba(124,77,255,0.3);
  padding: 10px 16px 0;
}
.player-meta {
  display: flex; align-items: center; gap: 10px; margin-bottom: 8px;
}
.player-live {
  width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0;
  background: #ff3333; box-shadow: 0 0 7px rgba(255,50,50,0.75);
  animation: livePulse 1.8s ease-in-out infinite;
}
@keyframes livePulse {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0.2; }
}
.player-info { flex: 1; min-width: 0; }
.player-title {
  font-size: 11px; font-weight: 700; color: rgba(255,255,255,0.85);
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.player-sub {
  font-size: 9px; color: rgba(255,255,255,0.35); margin-top: 1px; letter-spacing: 0.5px;
}
.player-popout {
  flex-shrink: 0; display: flex; align-items: center; gap: 4px;
  font-size: 10px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase;
  text-decoration: none; color: rgba(179,157,219,0.75);
  padding: 4px 10px; border: 1px solid rgba(124,77,255,0.28); border-radius: 20px;
  transition: color 0.18s, border-color 0.18s;
  &:hover { color: #d0b4ff; border-color: rgba(124,77,255,0.7); }
}
.player-frame { width: 100%; height: 110px; display: block; border: none; }

/* ══ Light-mode overrides ════════════════════════════════════════ */
.mdp--light {
  background: #f5f0ff;

  .map-topbar {
    background: linear-gradient(105deg, #ede8ff 0%, #ddd0ff 100%);
    border-bottom-color: rgba(124,77,255,0.2);
  }
  .topbar-region-name { color: #1a0a2e; }
  .topbar-region-desc { color: rgba(26,10,46,0.5); }
  .topbar-back        { color: rgba(26,10,46,0.55) !important; }

  .filter-pill {
    border-color: rgba(26,10,46,0.15);
    background: rgba(26,10,46,0.04);
    color: rgba(26,10,46,0.6);
    .filter-pill-count { background: rgba(26,10,46,0.08); }
    &.active, &:hover { color: #1a0a2e; border-color: rgba(26,10,46,0.3); background: rgba(26,10,46,0.08); }
    &--show.active    { border-color: #7c4dff; background: rgba(124,77,255,0.1);  color: #5c35b0; }
    &--senior.active  { border-color: #43a047; background: rgba(67,160,71,0.1);   color: #2e7d32; }
    &--nature.active  { border-color: #e65100; background: rgba(230,81,0,0.1);    color: #bf360c; }
  }

  .topbar-btn {
    border-color: rgba(26,10,46,0.15); background: rgba(26,10,46,0.05); color: rgba(26,10,46,0.5);
    &:hover, &.active { background: rgba(124,77,255,0.12); border-color: #7c4dff; color: #5c35b0; }
  }

  .side-panel  { background: #fff; border-left-color: rgba(124,77,255,0.15); }
  .side-section-head { color: #7c4dff; border-bottom-color: rgba(124,77,255,0.12); }
  .venue-name  { color: #1a0a2e; }
  .venue-date  { color: #7c4dff; }
  .venue-desc  { color: rgba(26,10,46,0.4); }
  .venue-seq   { background: rgba(124,77,255,0.15); color: #5c35b0; }
  .venue-card:hover { background: rgba(124,77,255,0.05); }
  .side-empty  { color: rgba(26,10,46,0.3); }

  .hero-player { background: #ede8ff; border-top-color: rgba(124,77,255,0.18); }
  .player-title { color: rgba(26,10,46,0.85); }
  .player-sub   { color: rgba(26,10,46,0.4); }
  .player-popout {
    color: rgba(90,40,180,0.7); border-color: rgba(124,77,255,0.25);
    &:hover { color: #5c35b0; border-color: rgba(124,77,255,0.6); }
  }

  .timeline-panel { background: #ede8ff; border-top-color: rgba(124,77,255,0.15); }
  .tl-title    { color: #6030c0; }
  .tl-subtitle { color: rgba(26,10,46,0.4); }
  .tl-month    { color: #9c80cc; }
  .tl-base     { background: rgba(124,77,255,0.18); }
  .tl-show-name { color: #3d2080; }
  .tl-show-date { color: rgba(26,10,46,0.35); }
  .tl-dot       { background: #7c4dff; }
}
</style>

<style>
/* ── Leaflet popup overrides ──────────────────────────────────── */
.leaflet-popup-content-wrapper {
  border-radius: 10px !important;
  box-shadow: 0 8px 32px rgba(0,0,0,0.25) !important;
  padding: 0 !important;
}
.leaflet-popup-content {
  margin: 12px !important;
}
.leaflet-popup-tip-container { margin-top: -1px; }
</style>

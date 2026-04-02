<template>
  <q-page :class="['mdp-v3', $q.dark.isActive ? 'mdp--dark' : 'mdp--light']">
    
    <header class="m-grid-header">
      <div class="m-block bg-black text-white nav-back clickable" @click="$router.push('/maps')">
        <q-icon name="west" size="sm" />
        <span class="text-overline q-ml-sm">REGIONS</span>
      </div>
      
      <div class="m-block title-area">
        <div class="text-h6 text-weight-black line-height-1">{{ region?.name ?? '...' }}</div>
        <div class="text-caption text-uppercase text-grey-7">{{ region?.description }}</div>
      </div>

      <div class="m-block filter-area row no-wrap">
        <button v-for="f in filterDefs" :key="f.key"
          :class="['m-pill', `m-pill--${f.key}`, { 'is-active': filters[f.key] }]"
          @click="filters[f.key] = !filters[f.key]">
          <q-icon :name="f.icon" size="16px" />
          <span class="m-count">{{ counts[f.key] }}</span>
        </button>
      </div>

      <div class="m-block actions-area bg-red row no-wrap">
        <div class="m-btn border-left" @click="photoOpen = !photoOpen" :class="{ 'is-active': photoOpen }">
          <q-icon name="image" />
        </div>
        <div class="m-btn border-left" @click="sideOpen = !sideOpen" :class="{ 'is-active': sideOpen }">
          <q-icon name="list" />
        </div>
        <div class="m-btn border-left" @click="timelineOpen = !timelineOpen" :class="{ 'is-active': timelineOpen }">
          <q-icon name="timeline" />
        </div>
      </div>
    </header>

    <section class="m-hero row no-wrap">
      <div class="col-auto m-stripe bg-yellow" />
      
      <div class="col q-pa-lg narrative-box bg-grey-2">
        <div class="text-red text-weight-bolder text-overline">2026 SUMMER TOUR // REGION PROFILE</div>
        <h1 class="text-h3 text-weight-black q-mt-xs q-mb-md">{{ region?.name }}</h1>
        <p class="text-body1 text-grey-9 leading-relaxed max-width-600">
          {{ regionSegment }}
        </p>
      </div>

      <div class="col-5 media-box bg-black relative-position">
        <iframe 
          :src="customYoutubeId ? `https://www.youtube.com/embed/${customYoutubeId}` : `https://archive.org/embed/${currentArchiveShow?.id ?? ''}`"
          class="m-iframe"
          frameborder="0"
          allow="autoplay; fullscreen"
        />
        <div class="m-label bg-yellow text-black text-caption text-weight-bold">
          NOW STREAMING: {{ customYoutubeId ? customYoutubeLabel : (currentArchiveShow?.label ?? 'No Audio Available') }}
        </div>
      </div>
    </section>

    <section class="m-main-content relative-position">
      <div id="detail-map" class="full-height" />

      <transition name="m-pop">
        <div v-if="photoOpen && region?.image_url" class="m-photo-overlay border-all">
           <img :src="region.image_url" class="fit object-cover" />
           <div class="absolute-bottom bg-black text-white q-pa-xs q-px-sm">
             <div class="text-caption text-center">{{ region.name }}</div>
             <PhotoAttribution
               :author="region.attribution_author ?? null"
               :source-url="region.attribution_source_url ?? null"
               :license="region.attribution_license ?? null"
               :license-url="region.attribution_license_url ?? null"
               :changes="region.attribution_changes ?? null"
               class="q-mt-xs"
             />
           </div>
        </div>
      </transition>

      <transition name="m-slide">
        <div v-if="sideOpen" class="m-sidebar border-left bg-white shadow-24">
          <div class="q-pa-md scroll full-height">
            <div v-if="filters.show" class="q-mb-lg">
              <div class="m-section-head bg-blue text-white">TOUR DATES</div>
              <q-list>
                <q-item v-for="(show, i) in sortedShows" :key="show.id"
                  clickable class="m-list-item" :class="{ 'is-active': activeShowId === show.id }"
                  @click="panToShow(show)">
                  <q-item-section avatar>
                    <div class="m-num-box">{{ i + 1 }}</div>
                  </q-item-section>
                  <q-item-section>
                    <q-item-label class="text-weight-bold">{{ show.name }}</q-item-label>
                    <q-item-label caption>{{ formatDate(show.date) }}</q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <router-link
                      :to="`/maps/${route.params.regionId}/shows/${show.id}`"
                      class="m-detail-link"
                      @click.stop
                    >
                      <q-icon name="open_in_new" size="13px" />
                    </router-link>
                  </q-item-section>
                </q-item>
              </q-list>
            </div>
          </div>
        </div>
      </transition>
    </section>

    <footer v-if="timelineOpen" class="m-footer border-top row no-wrap bg-white">
      <div class="m-footer-label bg-black text-white q-px-md flex flex-center text-overline">LOGISTICS</div>
      
      <div class="col relative-position q-px-xl timeline-track">
        <svg class="absolute-full" width="100%" height="100%" preserveAspectRatio="none">
          <line v-for="(leg, i) in showLegs" :key="i"
            :x1="`${leg.x1}%`" y1="50%" :x2="`${leg.x2}%`" y2="50%"
            stroke="#1040a8" stroke-width="2" stroke-dasharray="4 6" opacity="0.4" />
        </svg>

        <div v-for="show in sortedShows" :key="show.id"
          class="tl-node clickable"
          :style="{ left: showPct(show) + '%' }"
          :class="{ 'is-active': activeShowId === show.id }"
          @click="panToShow(show)"
          @dblclick="$router.push(`/maps/${route.params.regionId}/shows/${show.id}`)">
          <div class="tl-dot" />
          <div class="tl-label">{{ formatDate(show.date) }}</div>
          <div v-if="activeShowId === show.id" class="tl-detail-link"
               @click.stop="$router.push(`/maps/${route.params.regionId}/shows/${show.id}`)">
            Detail →
          </div>
        </div>
      </div>
    </footer>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { useQuasar } from 'quasar'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'
import { ARCHIVE_SHOWS } from 'src/lib/archiveShows'
import PhotoAttribution from 'src/components/PhotoAttribution.vue'

const route = useRoute()
const $q = useQuasar()

// --- State ---
const region = ref<MapRegion | null>(null)
const filters = reactive({ show: true, senior: true, nature: true })
const timelineOpen = ref(true)
const sideOpen = ref(false)
const photoOpen = ref(false)
const sortedShows = ref<MapPoint[]>([])
const seniorPoints = ref<MapPoint[]>([])
const naturePoints = ref<MapPoint[]>([])
const activeShowId = ref<string | null>(null)
const regionSegment = ref('')

// --- Map Instances ---
let mapInstance: L.Map | null = null
const markers = new Map<string, L.Marker>()

// --- Computed ---
const counts = computed(() => ({
  show: sortedShows.value.length,
  senior: seniorPoints.value.length,
  nature: naturePoints.value.length
}))

const filterDefs = [
  { key: 'show', label: 'Shows', icon: 'event' },
  { key: 'nature', label: 'Nature', icon: 'park' },
  { key: 'senior', label: 'Facilities', icon: 'elderly' }
] as const

// --- Lifecycle ---
onMounted(async () => {
  const regionId = route.params.regionId as string

  // Parallel fetch for speed
  const [{ data: rgn }, { data: pts }, { data: seg }] = await Promise.all([
    supabase.from('map_regions').select('*').eq('id', regionId).single(),
    supabase.from('map_points').select('*').eq('region_id', regionId),
    supabase.from('site_settings').select('value').eq('key', `region_segment_${regionId}`).maybeSingle(),
  ])

  region.value = rgn
  const points = (pts as MapPoint[]) || []

  sortedShows.value = points.filter(p => p.category === 'show').sort((a,b) => (a.date||'').localeCompare(b.date||''))
  naturePoints.value = points.filter(p => p.category === 'nature')
  seniorPoints.value = points.filter(p => p.category === 'senior')

  if (seg?.value) {
    regionSegment.value = typeof seg.value === 'string' ? seg.value : (seg.value as { text?: string }).text ?? ''
  }

  initMap()

  // Handle ?show= query param: pan to that show once map is ready
  const showId = route.query.show as string | undefined
  if (showId) {
    await nextTick()
    const target = sortedShows.value.find(s => s.id === showId)
    if (target) {
      activeShowId.value = showId
      sideOpen.value = true
      // Give Leaflet a moment to fully initialize before flying
      setTimeout(() => panToShow(target), 350)
    }
  }
})

function initMap() {
  if (!region.value) return
  mapInstance = L.map('detail-map', { zoomControl: false }).setView([region.value.center_lat, region.value.center_lng], region.value.zoom)
  
  L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png').addTo(mapInstance)
  
  // Simple Vanilla Marker Generator
  sortedShows.value.forEach((s, i) => {
    const marker = L.marker([s.lat, s.lng], {
      icon: L.divIcon({
        className: 'm-map-marker',
        html: `<div>${i+1}</div>`
      })
    }).addTo(mapInstance!).on('click', () => { activeShowId.value = s.id })
    markers.set(s.id, marker)
  })
}

// --- Helpers ---
function showPct(p: MapPoint) {
  const start = new Date('2026-06-01').getTime()
  const end = new Date('2026-09-15').getTime()
  const current = new Date(p.date || '').getTime()
  return Math.max(5, Math.min(95, ((current - start) / (end - start)) * 100))
}

function panToShow(show: MapPoint) {
  activeShowId.value = show.id
  mapInstance?.flyTo([show.lat, show.lng], 12)
  markers.get(show.id)?.openPopup()
}

function formatDate(d: string | null) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

// Per-region curated show for the hero player
const REGION_SHOWS: Record<string, { id: string; label: string }> = {
  'northeast':         { id: 'gd1977-05-08.aud.moore.berger.28354.flac16',
                         label: 'Grateful Dead · Cornell University — May 8, 1977'                },
  'southeast':         { id: 'wsp2013-11-09.ak40.flac24',
                         label: 'Widespread Panic · Asheville Civic Center — Nov 9, 2013'        },
  'southwest':         { id: 'billystrings2019-04-13.litz.schoepsMK41v.flac16',
                         label: 'Billy Strings · Bender Jamboree, Las Vegas — Apr 13, 2019'      },
  'mountain-west':     { id: 'gsbg2021-09-19.akg61.stearns.flac16',
                         label: 'Greensky Bluegrass · Red Rocks Amphitheatre — Sep 19, 2021'     },
  'pacific-northwest': { id: 'gd1985-07-04.sbd.seamons.9517.sbeok.shnf',
                         label: 'Grateful Dead · Autzen Stadium, Eugene OR — Jul 4, 1985'        },
  'great-lakes':       { id: 'um2004-07-03.flac',
                         label: "Umphrey's McGee · Summerfest, Milwaukee WI — Jul 3, 2004"       },
}

const currentArchiveShow = computed(() => {
  const regionId = route.params.regionId as string
  return REGION_SHOWS[regionId] ?? ARCHIVE_SHOWS[0] ?? { id: '', label: 'No Show Selected' }
})

const customYoutubeId = ref(null)
const customYoutubeLabel = ref('Live Video')

const showLegs = computed(() => {
  return sortedShows.value.slice(1).map((s, i) => {
    const previousShow = sortedShows.value[i]

    return {
      x1: showPct(previousShow as MapPoint),
      x2: showPct(s)
    }
  })
})

</script>

<style lang="scss" scoped>
// --- Mondrian Design Variables ---
$border: 3px solid #000;
$red: #cc1010;
$blue: #1040a8;
$yellow: #ffd600;

.mdp-v3 {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
  font-family: 'Space Mono', monospace; // Matches your "retro-digital" preference
}

.m-grid-header {
  display: grid;
  grid-template-columns: 140px 1fr auto auto;
  border-bottom: $border;
  height: 70px;

  .m-block {
    border-right: $border;
    display: flex;
    align-items: center;
    padding: 0 1rem;
  }
}

.m-hero {
  height: 250px;
  border-bottom: $border;

  .m-stripe { width: 40px; border-right: $border; }
  
  .narrative-box {
    border-right: $border;
    overflow-y: auto;
  }
  
  .media-box {
    .m-iframe { width: 100%; height: 100%; border: none; }
    .m-label {
      position: absolute;
      top: 0; left: 0;
      padding: 4px 12px;
      z-index: 10;
    }
  }
}

.m-main-content {
  flex: 1;
  .map-canvas-full { width: 100%; height: 100%; }
}

.m-sidebar {
  position: absolute;
  top: 0; right: 0;
  width: 350px;
  height: 100%;
  z-index: 1000;
  border-left: $border;
}

.m-footer {
  height: 80px;
  .m-footer-label { border-right: $border; width: 140px; }
  .timeline-track {
    display: flex;
    align-items: center;
    .tl-node {
      position: absolute;
      transform: translateX(-50%);
      .tl-dot {
        width: 12px; height: 12px;
        background: #000;
        border-radius: 0; // Square dots for Mondrian
        transition: transform 0.2s;
      }
      &.is-active .tl-dot { background: $red; transform: scale(1.5); }
      .tl-label { font-size: 10px; margin-top: 4px; }
    }
  }
}

// --- Utils ---
.m-pill {
  border: 2px solid black;
  background: white;
  margin: 0 4px;
  padding: 4px 12px;
  font-weight: bold;
  cursor: pointer;
  &.is-active {
    &.m-pill--show { background: $blue; color: white; }
    &.m-pill--nature { background: $yellow; color: black; }
  }
}

.m-btn {
  width: 60px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  color: white;
  &.is-active { background: white; color: $red; }
}

.border-left { border-left: $border; }
.border-top { border-top: $border; }

// Sidebar: detail link icon
.m-detail-link {
  color: rgba(0,0,0,0.3); display: flex; align-items: center;
  text-decoration: none;
  &:hover { color: $blue; }
}

// Footer timeline: "Detail →" popup on active node
.tl-detail-link {
  position: absolute;
  top: 100%; left: 50%; transform: translateX(-50%);
  margin-top: 2px;
  font-size: 8px; font-weight: 800; letter-spacing: 0.5px;
  background: $red; color: #fff;
  padding: 1px 6px; white-space: nowrap;
  cursor: pointer;
  &:hover { background: #a50d0d; }
}

// --- Animations ---
.m-slide-enter-active, .m-slide-leave-active { transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1); }
.m-slide-enter-from, .m-slide-leave-to { transform: translateX(100%); }
</style>

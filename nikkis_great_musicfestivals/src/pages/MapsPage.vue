<template>
  <q-page class="maps-overview q-pa-lg">
    <div class="text-h4 text-bold q-mb-xs text-center">Festival Tour Map</div>
    <div class="text-body2 text-grey-6 text-center q-mb-xl">
      Select a region to explore shows, nearby senior facilities, and outdoor must-sees
    </div>

    <div v-if="loading" class="flex flex-center q-py-xl">
      <q-spinner-orbit color="primary" size="48px" />
    </div>

    <div v-else class="row q-col-gutter-lg justify-center">
      <div
        v-for="region in regions"
        :key="region.id"
        class="col-12 col-sm-6 col-md-4"
      >
        <q-card
          class="region-card cursor-pointer"
          @click="goToRegion(region.id)"
        >
          <!-- Use uploaded image if available, otherwise render mini Leaflet map -->
          <div v-if="region.image_url" class="region-map-preview region-photo">
            <img :src="region.image_url" class="region-photo-img" :alt="region.name" />
          </div>
          <div v-else class="region-map-preview" :id="`map-preview-${region.id}`"></div>

          <q-card-section>
            <div class="text-h6 text-bold">{{ region.name }}</div>
            <div class="text-caption text-grey-6">{{ region.description }}</div>
          </q-card-section>

          <q-card-section class="q-pt-none row q-gutter-xs">
            <q-badge
              v-for="cat in pointCounts[region.id]"
              :key="cat.label"
              :color="cat.color"
              :label="cat.label"
            />
          </q-card-section>

          <q-card-actions>
            <q-space />
            <q-btn flat color="primary" label="Explore Region" icon-right="arrow_forward" />
          </q-card-actions>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'

const router = useRouter()
const loading = ref(true)
const regions = ref<MapRegion[]>([])
const pointCounts = ref<Record<string, { label: string; color: string }[]>>({})

const pinColors: Record<string, string> = {
  senior: '#43a047',
  nature: '#ff8f00',
}

function makeShowIcon(i: number) {
  return L.divIcon({
    className: '',
    html: `<div style="width:18px;height:18px;border-radius:50%;background:linear-gradient(135deg,#7c4dff,#5c35b0);border:2px solid white;display:flex;align-items:center;justify-content:center;font-size:9px;font-weight:800;color:white;box-shadow:0 1px 6px rgba(124,77,255,0.6);">${i + 1}</div>`,
    iconSize: [18, 18], iconAnchor: [9, 9],
  })
}

function makePinIcon(color: string) {
  return L.divIcon({
    className: '',
    html: `<div style="width:10px;height:10px;border-radius:50%;background:${color};border:2px solid white;box-shadow:0 1px 4px rgba(0,0,0,0.4)"></div>`,
    iconSize: [10, 10], iconAnchor: [5, 5],
  })
}

async function loadData() {
  const [{ data: rgns }, { data: pts }] = await Promise.all([
    supabase.from('map_regions').select('*').order('display_order'),
    supabase.from('map_points').select('*'),
  ])

  regions.value = (rgns as MapRegion[]) ?? []
  const allPoints: MapPoint[] = (pts as MapPoint[]) ?? []

  // build point counts per region
  regions.value.forEach(r => {
    const rPts = allPoints.filter(p => p.region_id === r.id)
    const counts: Record<string, number> = { show: 0, senior: 0, nature: 0 }
    rPts.forEach(p => { counts[p.category] = (counts[p.category] ?? 0) + 1 })
    pointCounts.value[r.id] = [
      { label: `${counts.show} Shows`,    color: 'indigo-8' },
      { label: `${counts.senior} Senior`, color: 'green-8' },
      { label: `${counts.nature} Nature`, color: 'orange-8' },
    ].filter(b => parseInt(b.label) > 0)

    // init preview map after DOM (skip if a region photo is set — the image replaces it)
    if (r.image_url) return
    void nextTick(() => {
      const el = document.getElementById(`map-preview-${r.id}`)
      if (!el || (el as HTMLElement & { _leaflet_id?: number })._leaflet_id) return

      const m = L.map(el, {
        zoomControl: false, dragging: false, scrollWheelZoom: false,
        doubleClickZoom: false, touchZoom: false, keyboard: false,
        attributionControl: false,
      })

      // CartoDB Voyager — clean, same as detail page
      L.tileLayer(
        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
        { subdomains: 'abcd', maxZoom: 19 }
      ).addTo(m)

      // Separate + sort shows
      const shows = rPts
        .filter(p => p.category === 'show' && p.date)
        .sort((a, b) => (a.date ?? '').localeCompare(b.date ?? ''))
      const others = rPts.filter(p => p.category !== 'show')

      // Dashed tour route polyline
      if (shows.length >= 2) {
        L.polyline(
          shows.map(s => [s.lat, s.lng] as L.LatLngTuple),
          { color: '#7c4dff', weight: 2, dashArray: '6 8', opacity: 0.85, interactive: false }
        ).addTo(m)
      }

      // Numbered show markers
      shows.forEach((show, i) => {
        L.marker([show.lat, show.lng], { icon: makeShowIcon(i) }).addTo(m)
      })

      // Senior / nature pin markers
      others.forEach(p => {
        L.marker([p.lat, p.lng], { icon: makePinIcon(pinColors[p.category] ?? '#888') }).addTo(m)
      })

      // Fit view to the actual points; fall back to region center if empty
      if (rPts.length > 0) {
        m.fitBounds(
          L.latLngBounds(rPts.map(p => [p.lat, p.lng] as L.LatLngTuple)),
          { padding: [22, 22], maxZoom: 10 }
        )
      } else {
        m.setView([r.center_lat, r.center_lng], r.zoom ?? 7)
      }
    })
  })

  loading.value = false
}

function goToRegion(id: string) {
  void router.push(`/maps/${id}`)
}

onMounted(() => { void loadData() })
</script>

<style lang="scss" scoped>
.maps-overview { min-height: 100vh; }

.region-card {
  border-radius: 12px;
  overflow: hidden;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 32px rgba(0,0,0,0.15);
  }
}

.region-map-preview {
  height: 200px;
  width: 100%;
  background: #d4d8e8;
  pointer-events: none;
  overflow: hidden;
  position: relative;
  /* Subtle vignette so the card edge blends in */
  &::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(to bottom, transparent 60%, rgba(0,0,0,0.08) 100%);
    pointer-events: none;
    z-index: 1;
  }
}
.region-photo-img {
  width: 100%; height: 100%; object-fit: cover; display: block;
  transition: transform 0.35s ease;
  .region-card:hover & { transform: scale(1.04); }
}
</style>

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
          <div class="region-map-preview" :id="`map-preview-${region.id}`"></div>

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

const markerColors: Record<string, string> = {
  show:   '#5c6bc0',
  senior: '#66bb6a',
  nature: '#ffa726',
}

function makeIcon(color: string) {
  return L.divIcon({
    className: '',
    html: `<div style="width:10px;height:10px;border-radius:50%;background:${color};border:2px solid white;box-shadow:0 0 4px rgba(0,0,0,0.4)"></div>`,
    iconSize: [10, 10],
    iconAnchor: [5, 5],
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

    // init preview map after DOM
    void nextTick(() => {
      const el = document.getElementById(`map-preview-${r.id}`)
      if (!el || (el as HTMLElement & { _leaflet_id?: number })._leaflet_id) return
      const m = L.map(el, {
        zoomControl: false,
        dragging: false,
        scrollWheelZoom: false,
        doubleClickZoom: false,
        touchZoom: false,
        keyboard: false,
        attributionControl: false,
      }).setView([r.center_lat, r.center_lng], 5)

      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(m)

      rPts.forEach(p => {
        L.marker([p.lat, p.lng], { icon: makeIcon(markerColors[p.category] ?? '#888') })
          .bindTooltip(p.name)
          .addTo(m)
      })
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
  height: 180px;
  width: 100%;
  background: #e8e8e8;
  pointer-events: none;
}
</style>

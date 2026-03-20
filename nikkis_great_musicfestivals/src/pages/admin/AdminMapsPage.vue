<template>
  <q-page class="q-pa-lg">
    <div class="text-h5 text-teal-3 q-mb-xs">Map Regions</div>
    <div class="text-caption text-grey-5 q-mb-xl">Click a region to add or edit map points</div>

    <div v-if="loading" class="flex flex-center q-py-xl">
      <q-spinner-orbit color="teal" size="48px" />
    </div>

    <div v-else class="row q-col-gutter-md">
      <div v-for="region in regions" :key="region.id" class="col-12 col-sm-6 col-md-4">
        <q-card class="admin-region-card cursor-pointer" @click="editRegion(region.id)">
          <q-card-section>
            <div class="text-h6 text-teal-2">{{ region.name }}</div>
            <div class="text-caption text-grey-5">{{ region.description }}</div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-caption text-grey-6">
              Center: {{ region.center_lat.toFixed(2) }}, {{ region.center_lng.toFixed(2) }}
              — Zoom {{ region.zoom }}
            </div>
            <div class="row q-gutter-xs q-mt-sm">
              <q-badge v-for="c in counts[region.id]" :key="c.label" :color="c.color" :label="c.label" />
            </div>
          </q-card-section>
          <q-card-actions align="right">
            <q-btn flat color="teal-3" label="Edit Points" icon="edit_location" />
          </q-card-actions>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'

const router  = useRouter()
const loading = ref(true)
const regions = ref<MapRegion[]>([])
const counts  = ref<Record<string, { label: string; color: string }[]>>({})

async function loadData() {
  const [{ data: rgns }, { data: pts }] = await Promise.all([
    supabase.from('map_regions').select('*').order('display_order'),
    supabase.from('map_points').select('*'),
  ])
  regions.value = (rgns as MapRegion[]) ?? []
  const allPoints: MapPoint[] = (pts as MapPoint[]) ?? []

  regions.value.forEach(r => {
    const rPts = allPoints.filter(p => p.region_id === r.id)
    const c: Record<string, number> = { show: 0, senior: 0, nature: 0 }
    rPts.forEach(p => { c[p.category] = (c[p.category] ?? 0) + 1 })
    counts.value[r.id] = [
      { label: `${c.show} Shows`,    color: 'indigo-7' },
      { label: `${c.senior} Senior`, color: 'green-7' },
      { label: `${c.nature} Nature`, color: 'orange-7' },
    ]
  })
  loading.value = false
}

onMounted(() => { void loadData() })

function editRegion(id: string) {
  void router.push(`/admin/maps/${id}`)
}
</script>

<style lang="scss" scoped>
.admin-region-card {
  background: #1a1a2e;
  border: 1px solid rgba(77, 182, 172, 0.2);
  border-radius: 12px;
  transition: border-color 0.2s;
  &:hover { border-color: #4db6ac; }
}
</style>

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
          <div class="region-map-preview">
            <div
              class="mondrian-wrap"
              v-html="mondrianSvg(region.id, regionImages[region.id] ?? [], mondrianOpts[region.id])"
            />
          </div>

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
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'
import { mondrianSvg } from 'src/lib/mondrian'
import type { MondrianOpts } from 'src/lib/mondrian'

const router = useRouter()
const loading = ref(true)
const regions = ref<MapRegion[]>([])
const pointCounts = ref<Record<string, { label: string; color: string }[]>>({})
const regionImages = ref<Record<string, string[]>>({})
const mondrianOpts = ref<Record<string, MondrianOpts>>({})

// ─── Data loading ──────────────────────────────────────────────────────────

async function loadData() {
  const [{ data: rgns }, { data: pts }, { data: heroSettings }] = await Promise.all([
    supabase.from('map_regions').select('*').order('display_order'),
    supabase.from('map_points').select('*'),
    supabase.from('site_settings').select('key, value').like('key', 'region_hero_%'),
  ])

  regions.value = (rgns as MapRegion[]) ?? []
  const allPoints: MapPoint[] = (pts as MapPoint[]) ?? []

  // Build regionImages + mondrianOpts from site_settings hero configs
  if (heroSettings) {
    type HeroRow = {
      key: string
      value: {
        images?: string[]
        mondrian_layout?: number | null
        mondrian_stroke?: number
        mondrian_featured?: number[]
      }
    }
    for (const row of heroSettings as HeroRow[]) {
      const regionId = row.key.replace('region_hero_', '')
      const imgs = (row.value?.images ?? []).filter(Boolean)
      if (imgs.length) regionImages.value[regionId] = imgs

      const opts: MondrianOpts = {}
      if (row.value.mondrian_layout !== undefined) opts.layout = row.value.mondrian_layout
      if (row.value.mondrian_stroke !== undefined)  opts.stroke = row.value.mondrian_stroke
      if (row.value.mondrian_featured?.length)       opts.featured = row.value.mondrian_featured
      if (Object.keys(opts).length) mondrianOpts.value[regionId] = opts
    }
  }

  regions.value.forEach(r => {
    const rPts = allPoints.filter(p => p.region_id === r.id)
    const counts: Record<string, number> = { show: 0, senior: 0, nature: 0 }
    rPts.forEach(p => { counts[p.category] = (counts[p.category] ?? 0) + 1 })
    pointCounts.value[r.id] = [
      { label: `${counts.show} Shows`,    color: 'indigo-8' },
      { label: `${counts.senior} Senior`, color: 'green-8' },
      { label: `${counts.nature} Nature`, color: 'orange-8' },
    ].filter(b => parseInt(b.label) > 0)
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
    box-shadow: 0 12px 32px rgba(0,0,0,0.22);
  }
}

.region-map-preview {
  height: 200px;
  width: 100%;
  overflow: hidden;
  position: relative;
  background: #0d0028;
  &::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(to bottom, transparent 55%, rgba(0,0,0,0.12) 100%);
    pointer-events: none;
    z-index: 1;
  }
}

.mondrian-wrap {
  width: 100%;
  height: 100%;
  display: block;
  transition: transform 0.4s ease;
  .region-card:hover & { transform: scale(1.025); }
}
</style>

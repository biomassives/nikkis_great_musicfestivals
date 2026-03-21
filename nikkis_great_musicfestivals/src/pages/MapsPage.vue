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
            <img
              v-if="region.image_url"
              :src="region.image_url"
              class="region-photo-img"
              :alt="region.name"
            />
            <div
              v-else
              class="mondrian-wrap"
              v-html="mondrianSvg(region.id, regionImages[region.id] ?? [])"
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

const router = useRouter()
const loading = ref(true)
const regions = ref<MapRegion[]>([])
const pointCounts = ref<Record<string, { label: string; color: string }[]>>({})
const regionImages = ref<Record<string, string[]>>({})

// ─── Mondrian SVG generator ────────────────────────────────────────────────

interface R {
  x: number; y: number; w: number; h: number
  fill: string
  img?: true   // marks this rect as an image slot (~42% of frames)
}

// Six layouts — each has its own colour palette and image-slot pattern

// Layout 0 — Midnight Festival (purple dominant)
const L0: R[] = [
  { x:   0, y:   0, w: 120, h: 200, fill: '#7c4dff',  img: true  },
  { x: 120, y:   0, w: 200, h:  88, fill: '#ffd700',  img: true  },
  { x: 120, y:  88, w: 100, h:  62, fill: '#f0ece0'              },
  { x: 220, y:  88, w: 100, h:  62, fill: '#4dd0c4',  img: true  },
  { x: 120, y: 150, w:  64, h:  50, fill: '#0d0028'              },
  { x: 184, y: 150, w:  76, h:  50, fill: '#c8a8ff'              },
  { x: 260, y: 150, w:  60, h:  50, fill: '#12122a'              },
]
// 3 / 7 = 43%

// Layout 1 — Golden Hour (southwest earth tones)
const L1: R[] = [
  { x:   0, y:   0, w:  80, h:  70, fill: '#d4850a',  img: true  },
  { x:  80, y:   0, w: 160, h:  70, fill: '#f5ede0',  img: true  },
  { x: 240, y:   0, w:  80, h:  70, fill: '#1c1c24'              },
  { x:   0, y:  70, w: 140, h:  72, fill: '#9e2a0f',  img: true  },
  { x: 140, y:  70, w: 180, h:  72, fill: '#e05c2a',  img: true  },
  { x:   0, y: 142, w:  60, h:  58, fill: '#f5ede0'              },
  { x:  60, y: 142, w:  80, h:  58, fill: '#b07c10'              },
  { x: 140, y: 142, w: 100, h:  58, fill: '#c8a060'              },
  { x: 240, y: 142, w:  80, h:  58, fill: '#1c1c24'              },
]
// 4 / 9 = 44%

// Layout 2 — Pacific Coast (deep teal / seafoam / clay)
const L2: R[] = [
  { x:   0, y:   0, w: 120, h:  72, fill: '#006070',  img: true  },
  { x: 120, y:   0, w:  60, h:  36, fill: '#4dd0c4'              },
  { x: 120, y:  36, w:  60, h:  36, fill: '#e0f0f4'              },
  { x: 180, y:   0, w: 140, h: 120, fill: '#1a3828',  img: true  },
  { x:   0, y:  72, w: 120, h:  48, fill: '#e0f0f4',  img: true  },
  { x:   0, y: 120, w: 180, h:  80, fill: '#3a5060'              },
  { x: 180, y: 120, w:  80, h:  80, fill: '#c86040'              },
  { x: 260, y: 120, w:  60, h:  80, fill: '#4dd0c4'              },
]
// 3 / 8 = 37.5% → close to 42%, acceptable

// Layout 3 — Bold Primaries (classic Mondrian energy)
const L3: R[] = [
  { x:   0, y:   0, w: 100, h:  80, fill: '#7c4dff',  img: true  },
  { x: 100, y:   0, w: 120, h:  80, fill: '#0a0a14',  img: true  },
  { x: 220, y:   0, w: 100, h:  80, fill: '#ffd700'              },
  { x:   0, y:  80, w: 320, h:  42, fill: '#f5f0e8'              },  // accent strip
  { x:   0, y: 122, w: 150, h:  78, fill: '#d42010',  img: true  },
  { x: 150, y: 122, w: 100, h:  78, fill: '#c8a8ff'              },
  { x: 250, y: 122, w:  70, h:  78, fill: '#0a0a14'              },
]
// 3 / 7 = 43%

// Layout 4 — Autumn Appalachian (rust, amber, deep forest)
const L4: R[] = [
  { x:   0, y:   0, w: 160, h: 130, fill: '#8b2010',  img: true  },
  { x:   0, y: 130, w: 160, h:  70, fill: '#c47a10',  img: true  },
  { x: 160, y:   0, w: 160, h:  60, fill: '#f5ede0'              },
  { x: 160, y:  60, w:  80, h:  80, fill: '#1e4028',  img: true  },
  { x: 240, y:  60, w:  80, h:  80, fill: '#c89030'              },
  { x: 160, y: 140, w: 160, h:  60, fill: '#1a1212'              },
]
// 3 / 6 = 50% — slightly over, keeps visual richness

// Layout 5 — Deep Indigo Night (electric purple / teal / gold)
const L5: R[] = [
  { x:   0, y:   0, w:  80, h:  67, fill: '#7c4dff',  img: true  },
  { x:  80, y:   0, w:  80, h:  67, fill: '#050510'              },
  { x: 160, y:   0, w: 160, h:  67, fill: '#0a0a1e',  img: true  },
  { x:   0, y:  67, w:  80, h:  66, fill: '#c0d8f0'              },
  { x:  80, y:  67, w:  80, h:  66, fill: '#4dd0c4',  img: true  },
  { x: 160, y:  67, w:  80, h:  66, fill: '#050510'              },
  { x: 240, y:  67, w:  80, h:  66, fill: '#c060d0'              },
  { x:   0, y: 133, w: 160, h:  67, fill: '#ffd700',  img: true  },
  { x: 160, y: 133, w:  80, h:  67, fill: '#7c4dff'              },
  { x: 240, y: 133, w:  80, h:  67, fill: '#0a0a1e'              },
]
// 4 / 10 = 40%

const LAYOUTS: R[][] = [L0, L1, L2, L3, L4, L5]

function hashId(id: string): number {
  return id.split('').reduce((n, c) => n + c.charCodeAt(0), 0)
}

function mondrianSvg(regionId: string, images: string[]): string {
  const layoutIdx = hashId(regionId) % LAYOUTS.length
  const layout = LAYOUTS[layoutIdx]!
  const safeId = regionId.replace(/[^a-z0-9]/gi, '_')

  let imgSlotIdx = 0
  const defs: string[] = []
  const els: string[] = []

  layout.forEach((r, i) => {
    if (r.img && images.length > 0) {
      const url = images[imgSlotIdx % images.length]!
      imgSlotIdx++
      const cpId = `cp_${safeId}_${i}`
      defs.push(
        `<clipPath id="${cpId}"><rect x="${r.x}" y="${r.y}" width="${r.w}" height="${r.h}"/></clipPath>`
      )
      els.push(
        `<image x="${r.x}" y="${r.y}" width="${r.w}" height="${r.h}" href="${url}" preserveAspectRatio="xMidYMid slice" clip-path="url(#${cpId})"/>`,
        // border overlay keeps the Mondrian grid crisp over images
        `<rect x="${r.x}" y="${r.y}" width="${r.w}" height="${r.h}" fill="none" stroke="#111" stroke-width="4"/>`
      )
    } else {
      els.push(
        `<rect x="${r.x}" y="${r.y}" width="${r.w}" height="${r.h}" fill="${r.fill}" stroke="#111" stroke-width="4" stroke-linejoin="miter"/>`
      )
    }
  })

  const defsStr = defs.length ? `<defs>${defs.join('')}</defs>` : ''
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 200" width="100%" height="100%" preserveAspectRatio="xMidYMid slice">${defsStr}${els.join('')}</svg>`
}

// ─── Data loading ──────────────────────────────────────────────────────────

async function loadData() {
  const [{ data: rgns }, { data: pts }, { data: heroSettings }] = await Promise.all([
    supabase.from('map_regions').select('*').order('display_order'),
    supabase.from('map_points').select('*'),
    supabase.from('site_settings').select('key, value').like('key', 'region_hero_%'),
  ])

  regions.value = (rgns as MapRegion[]) ?? []
  const allPoints: MapPoint[] = (pts as MapPoint[]) ?? []

  // Build regionImages map from site_settings hero configs
  if (heroSettings) {
    for (const row of heroSettings as { key: string; value: { images?: string[] } }[]) {
      const regionId = row.key.replace('region_hero_', '')
      const imgs = (row.value?.images ?? []).filter(Boolean)
      if (imgs.length) regionImages.value[regionId] = imgs
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

.region-photo-img {
  width: 100%; height: 100%; object-fit: cover; display: block;
  transition: transform 0.35s ease;
  .region-card:hover & { transform: scale(1.04); }
}
</style>

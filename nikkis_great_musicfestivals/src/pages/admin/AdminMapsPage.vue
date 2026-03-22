<template>
  <q-page class="q-pa-lg">
    <div class="row items-center q-mb-xl">
      <div>
        <div class="text-h5 text-teal-3 q-mb-xs">Map Regions</div>
        <div class="text-caption text-grey-5">Add, rename, reorder regions — click a card to edit its map points</div>
      </div>
      <q-space />
      <q-btn color="teal" icon="add" label="Add Region" unelevated @click="openAdd" />
    </div>

    <div v-if="loading" class="flex flex-center q-py-xl">
      <q-spinner-orbit color="teal" size="48px" />
    </div>

    <div v-else class="row q-col-gutter-md">
      <div v-for="(region, i) in regions" :key="region.id" class="col-12 col-sm-6 col-md-4">
        <q-card class="admin-region-card">

          <!-- Mondrian preview — click to open style modal -->
          <div class="region-mondrian-wrap" @click.stop="openMondrianDialog(region)">
            <div class="region-mondrian" v-html="cardMondrianSvg(region.id)" />
            <div class="region-mondrian-overlay">
              <q-icon name="palette" size="22px" color="white" />
              <div class="text-caption text-white q-mt-xs" style="font-weight:700;letter-spacing:.5px">Header Design</div>
            </div>
            <div class="region-mondrian-name">{{ region.name }}</div>
          </div>

          <!-- Reorder arrows -->
          <div class="reorder-row row justify-end q-pt-xs q-pr-xs">
            <q-btn flat dense round icon="arrow_back" color="grey-6" size="xs"
              :disable="i === 0" @click.stop="moveRegion(i, -1)" title="Move left" />
            <q-btn flat dense round icon="arrow_forward" color="grey-6" size="xs"
              :disable="i === regions.length - 1" @click.stop="moveRegion(i, 1)" title="Move right" />
          </div>

          <q-card-section class="cursor-pointer" @click="editPoints(region.id)">
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
            <q-btn flat color="grey-5"   icon="delete"        size="sm" @click.stop="deleteRegion(region)" />
            <q-btn flat color="teal-5"   icon="palette"       size="sm" label="Style"       @click.stop="openMondrianDialog(region)" />
            <q-btn flat color="teal-4"   icon="edit"          size="sm" label="Edit"        @click.stop="openEdit(region)" />
            <q-btn flat color="teal-3"   icon="edit_location" size="sm" label="Points"      @click.stop="editPoints(region.id)" />
          </q-card-actions>
        </q-card>
      </div>

      <div v-if="regions.length === 0" class="col-12 text-grey-6 text-center q-py-xl">
        No regions yet — add one to get started.
      </div>
    </div>

    <!-- ── Geo Edit Dialog (name / description / lat-lng / zoom) ─────────── -->
    <q-dialog v-model="dialog.open" persistent>
      <q-card style="min-width:380px; max-width:460px; background:#1a1a2e; border:1px solid rgba(77,182,172,0.3)">
        <q-card-section>
          <div class="text-h6 text-teal-3">{{ dialog.isNew ? 'Add Region' : 'Edit Region' }}</div>
          <div class="text-caption text-grey-5">Map position &amp; labels — use the Header Design button to customise the section header</div>
        </q-card-section>
        <q-card-section class="q-gutter-md">

          <q-input v-model="form.name" label="Region name *"
            dark outlined dense label-color="teal-3" color="teal-3" />
          <q-input v-model="form.description" label="Description (shown on map page)"
            dark outlined dense label-color="teal-3" color="teal-3" />

          <div class="row q-col-gutter-sm">
            <div class="col-6">
              <q-input v-model.number="form.center_lat" label="Center latitude *" type="number" step="0.0001"
                dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
            <div class="col-6">
              <q-input v-model.number="form.center_lng" label="Center longitude *" type="number" step="0.0001"
                dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
          </div>

          <q-input v-model.number="form.zoom" label="Default zoom (1–18)" type="number" min="1" max="18"
            dark outlined dense label-color="teal-3" color="teal-3" />

        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Save" color="teal" :loading="saving"
            :disable="!form.name"
            @click="saveRegion" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- ── Mondrian / Collage Style Modal ────────────────────────────────── -->
    <q-dialog v-model="mondrianDialog.open" persistent>
      <q-card style="min-width:460px; max-width:560px; background:#1a1a2e; border:1px solid rgba(77,182,172,0.3)">
        <q-card-section class="row items-center">
          <div>
            <div class="text-h6 text-teal-3">Map section header design</div>
            <div class="text-caption text-grey-5">{{ mondrianDialog.regionName }}</div>
          </div>
          <q-space />
          <q-btn flat round dense icon="close" color="grey-5" v-close-popup />
        </q-card-section>

        <q-card-section class="q-gutter-md" style="max-height:78vh; overflow-y:auto">

          <!-- Live Mondrian preview -->
          <div class="mondrian-admin-preview" v-html="mondrianPreview" />

          <!-- ── Palette ──────────────────────────────────────── -->
          <div>
            <div class="text-caption text-teal-5 text-uppercase q-mb-xs" style="letter-spacing:1.5px">Colour Palette</div>
            <div class="text-caption text-grey-6 q-mb-sm">
              Active: <span class="text-teal-4">{{ MONDRIAN_NAMES[activeLayout] }}</span>
              <span v-if="heroForm.mondrian_layout === null" class="text-grey-6"> (auto from region ID)</span>
            </div>
            <div class="row q-gutter-sm q-mb-xs">
              <div
                v-for="(name, i) in MONDRIAN_NAMES"
                :key="i"
                class="layout-swatch"
                :class="{ 'layout-swatch--active': activeLayout === i }"
                :title="name"
                @click="heroForm.mondrian_layout = (heroForm.mondrian_layout === i) ? null : i"
              >
                <div class="swatch-a" :style="{ background: MONDRIAN_SWATCHES[i]![0] }" />
                <div class="swatch-b" :style="{ background: MONDRIAN_SWATCHES[i]![1] }" />
                <div class="swatch-num">{{ i }}</div>
              </div>
            </div>
            <q-btn flat size="xs" color="grey-6" label="Reset to auto" icon="refresh"
              @click="heroForm.mondrian_layout = null" />
          </div>

          <!-- ── Grid line thickness ────────────────────────── -->
          <div>
            <div class="text-caption text-teal-5 text-uppercase q-mb-xs" style="letter-spacing:1.5px">
              Grid Line Thickness · {{ heroForm.mondrian_stroke }}px
            </div>
            <q-slider v-model="heroForm.mondrian_stroke" :min="1" :max="10" :step="1" color="teal-5" dark />
          </div>

          <!-- ── Carousel images ────────────────────────────── -->
          <div>
            <div class="text-caption text-teal-5 text-uppercase q-mb-xs" style="letter-spacing:1.5px">Hero Carousel Images</div>
            <div class="text-caption text-grey-6 q-mb-sm">
              Up to 5 images — shown in the slideshow above the region map and used in the collage slots.
            </div>
            <div v-for="(_, idx) in heroForm.images" :key="idx">
              <q-input
                v-model="heroForm.images[idx]"
                :label="`Image ${idx + 1} URL`"
                dark outlined dense label-color="teal-3" color="teal-3" clearable
                class="q-mb-xs"
              />
            </div>
          </div>

          <!-- ── Photos in Collage ───────────────────────── -->
          <div v-if="heroForm.images.some(Boolean)">
            <div class="text-caption text-teal-5 text-uppercase q-mb-xs" style="letter-spacing:1.5px">Photos in Collage</div>
            <div class="text-caption text-grey-6 q-mb-sm">
              <span class="text-teal-4">{{ featuredLabel }}</span> featured ·
              click to include/exclude · <q-icon name="drag_indicator" size="12px" /> drag to reorder
            </div>
            <div class="row q-gutter-xs">
              <template v-for="(img, idx) in heroForm.images" :key="idx">
                <div
                  v-if="img"
                  class="featured-slot"
                  :class="{
                    'featured-slot--off':        !isFeatured(idx),
                    'featured-slot--dragging':   photoDragSrc === idx,
                    'featured-slot--drag-over':  photoDragOver === idx,
                  }"
                  draggable="true"
                  @click="toggleFeatured(idx)"
                  @dragstart="onPhotoDragStart(idx)"
                  @dragover.prevent="onPhotoDragOver(idx)"
                  @dragleave="onPhotoDragLeave"
                  @drop.prevent="onPhotoDrop(idx)"
                  :title="isFeatured(idx) ? 'In collage — click to exclude' : 'Excluded — click to include'"
                >
                  <img :src="img" class="featured-thumb" />
                  <div class="featured-badge">
                    <q-icon
                      :name="isFeatured(idx) ? 'check_circle' : 'cancel'"
                      :color="isFeatured(idx) ? 'teal-4' : 'grey-5'"
                      size="14px"
                    />
                  </div>
                  <div class="featured-drag-handle">
                    <q-icon name="drag_indicator" size="14px" color="white" />
                  </div>
                </div>
              </template>
            </div>
          </div>

          <!-- ── Archive.org player ─────────────────────────── -->
          <div>
            <div class="text-caption text-teal-5 text-uppercase q-mb-xs" style="letter-spacing:1.5px">Archive.org Show Player</div>
            <div class="text-caption text-grey-6 q-mb-sm">Audio player strip beneath the hero carousel. Leave blank for auto-default.</div>
            <q-input v-model="heroForm.archive_id" label="archive.org identifier (e.g. billystrings2026-02-06)"
              dark outlined dense label-color="teal-3" color="teal-3" clearable class="q-mb-xs" />
            <q-input v-model="heroForm.archive_label" label="Display label (e.g. Billy Strings · Athens, GA)"
              dark outlined dense label-color="teal-3" color="teal-3" />
            <div v-if="heroForm.archive_id" class="text-caption text-teal-6 q-mt-xs">
              <q-icon name="open_in_new" size="12px" />
              <a :href="`https://archive.org/details/${heroForm.archive_id}`"
                 target="_blank" rel="noopener noreferrer" class="text-teal-4 q-ml-xs">
                Preview on archive.org
              </a>
            </div>
          </div>

          <!-- ── YouTube video ──────────────────────────────── -->
          <div>
            <div class="text-caption text-teal-5 text-uppercase q-mb-xs" style="letter-spacing:1.5px">YouTube Show Video</div>
            <div class="text-caption text-grey-6 q-mb-sm">
              Embeds a video in the region header. Supports <code style="color:#4dd0c4">?t=</code> timestamps. Overrides Archive.org player.
            </div>
            <q-input v-model="heroForm.youtube_url" label="YouTube URL (e.g. youtube.com/watch?v=…)"
              dark outlined dense label-color="teal-3" color="teal-3" clearable class="q-mb-xs" />
            <q-input v-model="heroForm.youtube_label" label="Display label (e.g. Billy Strings · Portland, OR)"
              dark outlined dense label-color="teal-3" color="teal-3" />
            <div v-if="heroForm.youtube_url" class="text-caption text-teal-6 q-mt-xs">
              <q-icon name="smart_display" size="12px" />
              <a :href="heroForm.youtube_url" target="_blank" rel="noopener noreferrer" class="text-teal-4 q-ml-xs">
                Preview on YouTube
              </a>
            </div>
          </div>

        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Save Design" color="teal" icon="save"
            :loading="savingHero" @click="saveMondrianSettings" />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'
import { mondrianSvg, MONDRIAN_NAMES, MONDRIAN_SWATCHES, resolveLayout } from 'src/lib/mondrian'
import type { MondrianOpts } from 'src/lib/mondrian'

const router  = useRouter()
const $q      = useQuasar()
const loading = ref(true)
const saving  = ref(false)
const savingHero = ref(false)
const regions = ref<MapRegion[]>([])
const counts  = ref<Record<string, { label: string; color: string }[]>>({})

// Per-card Mondrian preview data (images + opts loaded from site_settings)
const regionHeroData = ref<Record<string, { images: string[]; opts: MondrianOpts }>>({})

function cardMondrianSvg(regionId: string): string {
  const d = regionHeroData.value[regionId]
  return mondrianSvg(regionId, d?.images ?? [], d?.opts)
}

// ── Geo edit dialog ──────────────────────────────────────────────────────────
const dialog = ref({ open: false, isNew: true, editId: '' })
const form   = reactive({
  name: '', description: '',
  center_lat: 37.5, center_lng: -98.0, zoom: 6,
})

function openAdd() {
  dialog.value = { open: true, isNew: true, editId: '' }
  Object.assign(form, { name: '', description: '', center_lat: 37.5, center_lng: -98.0, zoom: 6 })
}

function openEdit(region: MapRegion) {
  dialog.value = { open: true, isNew: false, editId: region.id }
  Object.assign(form, {
    name:        region.name,
    description: region.description ?? '',
    center_lat:  region.center_lat,
    center_lng:  region.center_lng,
    zoom:        region.zoom,
  })
}

async function saveRegion() {
  saving.value = true
  const payload = {
    name:        form.name,
    description: form.description || null,
    center_lat:  form.center_lat,
    center_lng:  form.center_lng,
    zoom:        form.zoom,
  }
  if (dialog.value.isNew) {
    const { data, error } = await supabase.from('map_regions')
      .insert({ ...payload, display_order: regions.value.length })
      .select().single()
    if (error) {
      $q.notify({ message: `Error: ${error.message}`, color: 'negative', position: 'top' })
    } else if (data) {
      regions.value.push(data as MapRegion)
      counts.value[(data as MapRegion).id] = defaultCount()
    }
  } else {
    const { error } = await supabase.from('map_regions').update(payload).eq('id', dialog.value.editId)
    if (error) {
      $q.notify({ message: `Error: ${error.message}`, color: 'negative', position: 'top' })
    } else {
      const idx = regions.value.findIndex(r => r.id === dialog.value.editId)
      if (idx !== -1) Object.assign(regions.value[idx]!, payload)
    }
  }
  saving.value = false
  dialog.value.open = false
}

// ── Mondrian / header design modal ───────────────────────────────────────────
const mondrianDialog = ref({ open: false, regionId: '', regionName: '' })

const heroForm = reactive({
  images:            ['', '', '', '', ''] as string[],
  archive_id:        '',
  archive_label:     '',
  youtube_url:       '',
  youtube_label:     '',
  mondrian_layout:   null as number | null,
  mondrian_stroke:   4,
  mondrian_featured: [] as number[],
})

const hashLayout   = computed(() => resolveLayout(mondrianDialog.value.regionId || 'new_region'))
const activeLayout = computed(() => heroForm.mondrian_layout ?? hashLayout.value)

const mondrianPreview = computed(() => {
  const images = heroForm.images.filter(Boolean)
  const opts: MondrianOpts = { stroke: heroForm.mondrian_stroke }
  if (heroForm.mondrian_layout !== null) opts.layout = heroForm.mondrian_layout
  if (heroForm.mondrian_featured.length)  opts.featured = heroForm.mondrian_featured
  return mondrianSvg(mondrianDialog.value.regionId || 'new_region', images, opts)
})

const featuredLabel = computed(() => {
  const total = heroForm.images.filter(Boolean).length
  if (!total) return 'no images yet'
  if (!heroForm.mondrian_featured.length || heroForm.mondrian_featured.length === total) return 'all images'
  return `${heroForm.mondrian_featured.length} of ${total}`
})

function isFeatured(i: number): boolean {
  return !heroForm.mondrian_featured.length || heroForm.mondrian_featured.includes(i)
}

function toggleFeatured(i: number) {
  if (!heroForm.mondrian_featured.length) {
    heroForm.mondrian_featured = heroForm.images.map((u, idx) => (u ? idx : -1)).filter(idx => idx !== -1)
  }
  const pos = heroForm.mondrian_featured.indexOf(i)
  if (pos === -1) heroForm.mondrian_featured.push(i)
  else heroForm.mondrian_featured.splice(pos, 1)
  const filled = heroForm.images.filter(Boolean).length
  if (heroForm.mondrian_featured.length === filled) heroForm.mondrian_featured = []
}

// ── Photo drag-to-reorder ─────────────────────────────────────────────────────
const photoDragSrc  = ref(-1)
const photoDragOver = ref(-1)

function onPhotoDragStart(idx: number) {
  photoDragSrc.value = idx
}
function onPhotoDragOver(idx: number) {
  if (photoDragSrc.value !== -1 && photoDragSrc.value !== idx) photoDragOver.value = idx
}
function onPhotoDragLeave() {
  photoDragOver.value = -1
}
function onPhotoDrop(idx: number) {
  const from = photoDragSrc.value
  photoDragSrc.value  = -1
  photoDragOver.value = -1
  if (from === -1 || from === idx) return
  reorderImages(from, idx)
}

function reorderImages(from: number, to: number) {
  // Splice a copy, write back element-by-element to preserve Vue reactivity
  const imgs = [...heroForm.images]
  const [moved] = imgs.splice(from, 1)
  imgs.splice(to, 0, moved!)
  while (imgs.length < 5) imgs.push('')
  for (let i = 0; i < 5; i++) heroForm.images[i] = imgs[i] ?? ''

  // Remap mondrian_featured indices to follow their images
  if (heroForm.mondrian_featured.length) {
    heroForm.mondrian_featured = heroForm.mondrian_featured.map(fi => {
      if (fi === from)                                  return to
      if (from < to && fi > from && fi <= to) return fi - 1
      if (from > to && fi >= to  && fi <  from) return fi + 1
      return fi
    })
  }
}

async function openMondrianDialog(region: MapRegion) {
  mondrianDialog.value = { open: true, regionId: region.id, regionName: region.name }
  Object.assign(heroForm, {
    images: ['', '', '', '', ''], archive_id: '', archive_label: '',
    youtube_url: '', youtube_label: '', mondrian_layout: null, mondrian_stroke: 4, mondrian_featured: [],
  })
  const { data: heroData } = await supabase
    .from('site_settings').select('value')
    .eq('key', `region_hero_${region.id}`).limit(1)
  const heroVal = (heroData as { value: unknown }[] | null)?.[0]?.value as Record<string, unknown> | undefined
  if (heroVal) {
    if (Array.isArray(heroVal.images)) {
      const imgs = heroVal.images as string[]
      for (let i = 0; i < 5; i++) heroForm.images[i] = imgs[i] ?? ''
    }
    if (typeof heroVal.archive_id    === 'string') heroForm.archive_id    = heroVal.archive_id
    if (typeof heroVal.archive_label === 'string') heroForm.archive_label = heroVal.archive_label
    if (typeof heroVal.youtube_id    === 'string' && heroVal.youtube_id) {
      const start = typeof heroVal.youtube_start === 'number' ? heroVal.youtube_start : 0
      heroForm.youtube_url = start > 0
        ? `https://www.youtube.com/watch?v=${heroVal.youtube_id}&t=${start}s`
        : `https://www.youtube.com/watch?v=${heroVal.youtube_id}`
    }
    if (typeof heroVal.youtube_label === 'string') heroForm.youtube_label = heroVal.youtube_label
    heroForm.mondrian_layout   = typeof heroVal.mondrian_layout === 'number' ? heroVal.mondrian_layout : null
    heroForm.mondrian_stroke   = typeof heroVal.mondrian_stroke === 'number' ? heroVal.mondrian_stroke : 4
    heroForm.mondrian_featured = Array.isArray(heroVal.mondrian_featured) ? heroVal.mondrian_featured as number[] : []
  }
}

async function saveMondrianSettings() {
  savingHero.value = true
  const regionId    = mondrianDialog.value.regionId
  const cleanImages = heroForm.images.map(u => u.trim()).filter(Boolean)

  // Parse YouTube URL → id + start time
  let youtubeId = '', youtubeStart = 0
  const ytRaw = heroForm.youtube_url.trim()
  if (ytRaw) {
    const startMatch = ytRaw.match(/[?&]t=(\d+)/)
    youtubeStart = startMatch ? parseInt(startMatch[1]!) : 0
    const watchMatch = ytRaw.match(/[?&]v=([A-Za-z0-9_-]{11})/)
    if (watchMatch) youtubeId = watchMatch[1]!
    else {
      const shortMatch = ytRaw.match(/youtu\.be\/([A-Za-z0-9_-]{11})/)
      if (shortMatch) youtubeId = shortMatch[1]!
      else if (/^[A-Za-z0-9_-]{11}$/.test(ytRaw)) youtubeId = ytRaw
    }
  }

  await supabase.from('site_settings').upsert({
    key:   `region_hero_${regionId}`,
    value: {
      images:            cleanImages,
      archive_id:        heroForm.archive_id.trim(),
      archive_label:     heroForm.archive_label.trim(),
      youtube_id:        youtubeId,
      youtube_start:     youtubeStart,
      youtube_label:     heroForm.youtube_label.trim(),
      mondrian_layout:   heroForm.mondrian_layout,
      mondrian_stroke:   heroForm.mondrian_stroke,
      mondrian_featured: heroForm.mondrian_featured,
    },
    updated_at: new Date().toISOString(),
  })

  // Refresh card preview immediately
  const opts: MondrianOpts = { stroke: heroForm.mondrian_stroke }
  if (heroForm.mondrian_layout !== null) opts.layout = heroForm.mondrian_layout
  if (heroForm.mondrian_featured.length)  opts.featured = heroForm.mondrian_featured
  regionHeroData.value[regionId] = { images: cleanImages, opts }

  savingHero.value = false
  mondrianDialog.value.open = false
  $q.notify({ message: 'Header design saved', color: 'teal', icon: 'check', position: 'top' })
}

// ── Shared helpers ───────────────────────────────────────────────────────────
function deleteRegion(region: MapRegion) {
  $q.dialog({
    title: 'Delete region?',
    message: `"${region.name}" and ALL its map points will be permanently deleted.`,
    cancel: true, persistent: true, color: 'negative', dark: true,
  }).onOk(() => {
    void supabase.from('map_regions').delete().eq('id', region.id).then(() => {
      regions.value = regions.value.filter(r => r.id !== region.id)
    })
  })
}

async function moveRegion(i: number, dir: -1 | 1) {
  const arr = [...regions.value]
  const a = arr[i]!
  const b = arr[i + dir]!
  a.display_order = i
  b.display_order = i + dir
  arr[i] = b
  arr[i + dir] = a
  regions.value = arr
  await Promise.all([
    supabase.from('map_regions').update({ display_order: i       }).eq('id', a.id),
    supabase.from('map_regions').update({ display_order: i + dir }).eq('id', b.id),
  ])
}

function editPoints(id: string) {
  void router.push(`/admin/maps/${id}`)
}

function defaultCount() {
  return [
    { label: '0 Shows',  color: 'indigo-7' },
    { label: '0 Senior', color: 'green-7'  },
    { label: '0 Nature', color: 'orange-7' },
  ]
}

async function loadData() {
  const [{ data: rgns }, { data: pts }, { data: heroRows }] = await Promise.all([
    supabase.from('map_regions').select('*').order('display_order'),
    supabase.from('map_points').select('*'),
    supabase.from('site_settings').select('key, value').like('key', 'region_hero_%'),
  ])

  regions.value = (rgns as MapRegion[]) ?? []
  const allPoints: MapPoint[] = (pts as MapPoint[]) ?? []

  regions.value.forEach(r => {
    const rPts = allPoints.filter(p => p.region_id === r.id)
    const c: Record<string, number> = { show: 0, senior: 0, nature: 0 }
    rPts.forEach(p => { c[p.category] = (c[p.category] ?? 0) + 1 })
    counts.value[r.id] = [
      { label: `${c.show} Shows`,    color: 'indigo-7' },
      { label: `${c.senior} Senior`, color: 'green-7'  },
      { label: `${c.nature} Nature`, color: 'orange-7' },
    ]
  })

  // Populate per-card Mondrian previews
  type HeroRow = { key: string; value: Record<string, unknown> }
  for (const row of (heroRows as HeroRow[]) ?? []) {
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

  loading.value = false
}

onMounted(() => { void loadData() })
</script>

<style lang="scss" scoped>
.admin-region-card {
  background: #1a1a2e;
  border: 1px solid rgba(77, 182, 172, 0.2);
  border-radius: 12px;
  overflow: hidden;
  transition: border-color 0.2s;
  &:hover { border-color: #4db6ac; }
}
.reorder-row { min-height: 28px; }

/* ── Mondrian card preview ───────────────────────────────────────── */
.region-mondrian-wrap {
  position: relative;
  height: 150px;
  overflow: hidden;
  cursor: pointer;
  background: #0d0028;
}
.region-mondrian {
  width: 100%; height: 100%; display: block;
  transition: transform 0.35s ease;
  .region-mondrian-wrap:hover & { transform: scale(1.03); }
}
.region-mondrian-overlay {
  position: absolute; inset: 0;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  background: rgba(0, 0, 0, 0.48);
  backdrop-filter: blur(2px);
  opacity: 0; transition: opacity 0.2s;
  .region-mondrian-wrap:hover & { opacity: 1; }
}
.region-mondrian-name {
  position: absolute; bottom: 0; left: 0; right: 0;
  padding: 6px 10px;
  background: linear-gradient(transparent, rgba(0,0,0,0.68));
  color: white; font-size: 12px; font-weight: 600;
  pointer-events: none;
}

/* ── Mondrian modal editor ───────────────────────────────────────── */
.mondrian-admin-preview {
  width: 100%;
  height: 170px;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid rgba(77,182,172,0.28);
  background: #0d0028;
}

.layout-swatch {
  width: 46px; height: 46px;
  border-radius: 6px; overflow: hidden;
  cursor: pointer; flex-shrink: 0;
  border: 2px solid transparent;
  position: relative; display: flex; flex-direction: column;
  transition: border-color 0.15s, transform 0.15s;
  &:hover { transform: scale(1.1); border-color: rgba(77,182,172,0.55); }
  &--active { border-color: #4dd0c4 !important; box-shadow: 0 0 8px rgba(77,208,196,0.45); }
  .swatch-a { flex: 2; }
  .swatch-b { flex: 1; }
  .swatch-num {
    position: absolute; bottom: 2px; right: 4px;
    font-size: 9px; font-weight: 700; color: rgba(255,255,255,0.75);
    text-shadow: 0 1px 2px rgba(0,0,0,0.8);
  }
}

.featured-slot {
  position: relative; width: 54px; height: 54px;
  border-radius: 6px; overflow: hidden; cursor: grab;
  border: 2px solid rgba(77,182,172,0.45);
  transition: opacity 0.2s, border-color 0.2s, transform 0.15s, box-shadow 0.15s;
  &:hover { border-color: #4dd0c4; transform: scale(1.06); }
  &:active { cursor: grabbing; }
  &--off { opacity: 0.3; border-color: rgba(255,255,255,0.1); }
  &--dragging { opacity: 0.35; transform: scale(0.95); }
  &--drag-over {
    border-color: #ffd700 !important;
    box-shadow: 0 0 10px rgba(255,215,0,0.45);
    transform: scale(1.12) !important;
  }
}
.featured-thumb { width: 100%; height: 100%; object-fit: cover; display: block; }
.featured-badge {
  position: absolute; bottom: 2px; right: 2px;
  background: rgba(0,0,0,0.55); border-radius: 50%; line-height: 1;
}
.featured-drag-handle {
  position: absolute; top: 2px; left: 2px;
  background: rgba(0,0,0,0.45); border-radius: 3px;
  line-height: 1; padding: 1px;
  opacity: 0; transition: opacity 0.15s;
  .featured-slot:hover & { opacity: 1; }
}

.hidden { display: none; }
</style>

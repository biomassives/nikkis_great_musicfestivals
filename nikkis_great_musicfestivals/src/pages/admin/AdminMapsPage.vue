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

          <!-- Region image thumbnail / placeholder -->
          <div v-if="region.image_url" class="region-thumb-wrap">
            <img :src="region.image_url" class="region-thumb" />
            <div class="region-thumb-label">{{ region.name }}</div>
            <div class="region-thumb-actions">
              <q-btn round dense size="xs" color="grey-9" icon="photo_camera"
                :loading="uploadingQuickImg && quickImgRegionId === region.id"
                @click.stop="triggerQuickImg(region.id)" title="Change preview image" />
              <q-btn round dense size="xs" color="grey-9" icon="close"
                @click.stop="clearRegionImage(region)" title="Remove preview image" class="q-ml-xs" />
            </div>
          </div>
          <div v-else class="region-img-placeholder" @click.stop="triggerQuickImg(region.id)">
            <q-icon name="add_photo_alternate" size="28px" color="teal-8" />
            <div class="text-caption text-teal-8 q-mt-xs">Set preview image</div>
            <q-inner-loading :showing="uploadingQuickImg && quickImgRegionId === region.id">
              <q-spinner-orbit color="teal" size="24px" />
            </q-inner-loading>
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
            <q-btn flat color="grey-5"  icon="delete"        size="sm" @click.stop="deleteRegion(region)" />
            <q-btn flat color="teal-4"  icon="edit"          size="sm" label="Edit"        @click.stop="openEdit(region)" />
            <q-btn flat color="teal-3"  icon="edit_location" size="sm" label="Edit Points" @click.stop="editPoints(region.id)" />
          </q-card-actions>
        </q-card>
      </div>

      <div v-if="regions.length === 0" class="col-12 text-grey-6 text-center q-py-xl">
        No regions yet — add one to get started.
      </div>
    </div>

    <!-- Hidden input for quick card image upload -->
    <input ref="quickImgFileInput" type="file" accept="image/*" class="hidden" @change="handleQuickImgUpload" />

    <!-- Add / Edit Region Dialog -->
    <q-dialog v-model="dialog.open" persistent>
      <q-card style="min-width:420px; max-width:520px; background:#1a1a2e; border:1px solid rgba(77,182,172,0.3)">
        <q-card-section>
          <div class="text-h6 text-teal-3">{{ dialog.isNew ? 'Add Region' : 'Edit Region' }}</div>
        </q-card-section>
        <q-card-section class="q-gutter-md" style="max-height:76vh; overflow-y:auto">

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

          <q-separator dark class="q-my-xs" />
          <div class="text-caption text-teal-5 text-uppercase" style="letter-spacing:1.5px">Region Image (optional)</div>
          <div class="text-caption text-grey-6">
            Shown as card cover on the overview page and in a photo panel on the detail map
          </div>
          <div class="row q-col-gutter-sm items-start">
            <div class="col">
              <q-input v-model="form.image_url" label="Image URL"
                dark outlined dense label-color="teal-3" color="teal-3" clearable />
            </div>
            <div class="col-auto">
              <q-btn color="teal-8" icon="upload" label="Upload" unelevated size="sm"
                :loading="uploadingImg" @click="triggerImgUpload" />
              <input ref="imgFileInput" type="file" accept="image/*" class="hidden" @change="handleImgUpload" />
            </div>
          </div>
          <div v-if="form.image_url" class="q-mt-xs">
            <img :src="form.image_url" class="img-preview" />
            <div class="text-caption text-grey-5 q-mt-xs">Preview</div>
          </div>

        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Save" color="teal" :loading="saving"
            :disable="!form.name"
            @click="saveRegion" />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'

const router  = useRouter()
const $q      = useQuasar()
const loading = ref(true)
const saving  = ref(false)
const uploadingImg      = ref(false)
const uploadingQuickImg = ref(false)
const quickImgRegionId  = ref('')
const regions = ref<MapRegion[]>([])
const counts  = ref<Record<string, { label: string; color: string }[]>>({})
const imgFileInput      = ref<HTMLInputElement | null>(null)
const quickImgFileInput = ref<HTMLInputElement | null>(null)

const dialog = ref({ open: false, isNew: true, editId: '' })
const form   = reactive({
  name: '', description: '',
  center_lat: 37.5, center_lng: -98.0, zoom: 6,
  image_url: null as string | null,
})

function openAdd() {
  dialog.value = { open: true, isNew: true, editId: '' }
  Object.assign(form, { name: '', description: '', center_lat: 37.5, center_lng: -98.0, zoom: 6, image_url: null })
}

function openEdit(region: MapRegion) {
  dialog.value = { open: true, isNew: false, editId: region.id }
  Object.assign(form, {
    name:        region.name,
    description: region.description ?? '',
    center_lat:  region.center_lat,
    center_lng:  region.center_lng,
    zoom:        region.zoom,
    image_url:   region.image_url ?? null,
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
    image_url:   form.image_url || null,
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

function triggerImgUpload() { imgFileInput.value?.click() }

function triggerQuickImg(regionId: string) {
  quickImgRegionId.value = regionId
  quickImgFileInput.value?.click()
}

async function handleQuickImgUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file || !quickImgRegionId.value) return
  uploadingQuickImg.value = true
  const path = `map-regions/${Date.now()}.${file.name.split('.').pop() ?? 'jpg'}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    const imageUrl = data.publicUrl
    const { error: dbErr } = await supabase.from('map_regions')
      .update({ image_url: imageUrl })
      .eq('id', quickImgRegionId.value)
    if (!dbErr) {
      const idx = regions.value.findIndex(r => r.id === quickImgRegionId.value)
      if (idx !== -1) regions.value[idx]!.image_url = imageUrl
      $q.notify({ message: 'Preview image updated', color: 'teal', position: 'top', icon: 'check' })
    } else {
      $q.notify({ message: `DB error: ${dbErr.message}`, color: 'negative', position: 'top' })
    }
  } else {
    $q.notify({ message: `Upload error: ${error.message}`, color: 'negative', position: 'top' })
  }
  uploadingQuickImg.value = false
  quickImgRegionId.value  = ''
  if (quickImgFileInput.value) quickImgFileInput.value.value = ''
}

async function clearRegionImage(region: MapRegion) {
  const { error } = await supabase.from('map_regions').update({ image_url: null }).eq('id', region.id)
  if (!error) {
    const idx = regions.value.findIndex(r => r.id === region.id)
    if (idx !== -1) regions.value[idx]!.image_url = null
  }
}

async function handleImgUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingImg.value = true
  const path = `map-regions/${Date.now()}.${file.name.split('.').pop() ?? 'jpg'}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    form.image_url = data.publicUrl
  }
  uploadingImg.value = false
  // reset file input so same file can be re-selected
  if (imgFileInput.value) imgFileInput.value.value = ''
}

function defaultCount() {
  return [
    { label: '0 Shows',  color: 'indigo-7' },
    { label: '0 Senior', color: 'green-7'  },
    { label: '0 Nature', color: 'orange-7' },
  ]
}

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
      { label: `${c.senior} Senior`, color: 'green-7'  },
      { label: `${c.nature} Nature`, color: 'orange-7' },
    ]
  })
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

.region-thumb-wrap {
  position: relative;
  height: 140px;
  overflow: hidden;
}
.region-thumb {
  width: 100%; height: 100%; object-fit: cover; display: block;
  transition: transform 0.3s ease;
  .admin-region-card:hover & { transform: scale(1.03); }
}
.region-thumb-label {
  position: absolute; bottom: 0; left: 0; right: 0;
  padding: 6px 10px;
  background: linear-gradient(transparent, rgba(0,0,0,0.65));
  color: white; font-size: 12px; font-weight: 600;
}
.region-thumb-actions {
  position: absolute; top: 6px; right: 6px;
  opacity: 0; transition: opacity 0.2s;
  .region-thumb-wrap:hover & { opacity: 1; }
}

.region-img-placeholder {
  height: 90px;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  border-bottom: 1px dashed rgba(77,182,172,0.2);
  cursor: pointer; position: relative;
  transition: background 0.2s;
  &:hover { background: rgba(77,182,172,0.06); }
}

.img-preview {
  max-height: 140px; max-width: 100%;
  border-radius: 8px; object-fit: cover; display: block;
}
.hidden { display: none; }
</style>

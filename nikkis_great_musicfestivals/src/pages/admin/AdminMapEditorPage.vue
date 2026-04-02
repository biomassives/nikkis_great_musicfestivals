<template>
  <q-page class="q-pa-lg">
    <div class="row items-center q-mb-xl">
      <q-btn flat icon="arrow_back" :to="'/admin/maps'" class="q-mr-md" />
      <div>
        <div class="text-h5 text-teal-3">{{ region?.name ?? 'Loading...' }}</div>
        <div class="text-caption text-grey-5">Map point editor</div>
      </div>
    </div>

    <div class="row q-col-gutter-xl">
      <!-- Point list -->
      <div class="col-12 col-md-5">
        <div class="row items-center q-mb-md">
          <div class="text-subtitle1 text-teal-2 col">Points ({{ points.length }})</div>
          <q-btn color="teal" icon="add" label="Add Point" unelevated @click="openAddDialog" />
        </div>

        <q-list separator dark class="rounded-borders" style="background:#1a1a2e; border:1px solid rgba(77,182,172,0.2)">
          <q-item
            v-for="pt in points"
            :key="pt.id"
            class="q-py-md"
          >
            <q-item-section avatar>
              <q-icon :name="catIcon(pt.category)" :color="catColor(pt.category)" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-white">{{ pt.name }}</q-item-label>
              <q-item-label caption class="text-grey-5">
                {{ pt.date ?? 'No date' }} · {{ pt.lat.toFixed(4) }}, {{ pt.lng.toFixed(4) }}
              </q-item-label>
              <q-item-label v-if="pt.description" caption class="text-grey-6 ellipsis">{{ pt.description }}</q-item-label>
            </q-item-section>
            <q-item-section side>
              <div class="row q-gutter-xs">
                <q-btn flat round dense icon="edit" color="teal-3" @click="openEditDialog(pt)" />
                <q-btn flat round dense icon="delete" color="red-4" @click="deletePoint(pt.id)" />
              </div>
            </q-item-section>
          </q-item>
          <q-item v-if="points.length === 0">
            <q-item-section class="text-grey-6 text-center q-py-lg">No points yet — add one!</q-item-section>
          </q-item>
        </q-list>
      </div>

      <!-- Add/Edit form -->
      <div class="col-12 col-md-7">
        <div class="editor-panel q-pa-lg rounded-borders">
          <div class="text-subtitle1 text-teal-2 q-mb-md">{{ editingId ? 'Edit Point' : 'Add New Point' }}</div>

          <q-form @submit="savePoint" class="q-gutter-md">
            <q-select
              v-model="form.category"
              :options="categoryOptions"
              emit-value map-options
              label="Category"
              dark outlined
              label-color="teal-3" color="teal-3"
              :rules="[v => !!v || 'Required']"
            />
            <q-input v-model="form.name" label="Name" dark outlined label-color="teal-3" color="teal-3" :rules="[v => !!v || 'Required']" />

            <!-- Place search → auto-fills lat/lng -->
            <q-select
              v-model="selectedPlace"
              :options="placeOptions"
              use-input
              input-debounce="500"
              label="Search place to fill lat/lng"
              hint="Type a venue, city, or address"
              dark outlined
              label-color="teal-3" color="teal-3"
              :loading="searchingPlace"
              clearable
              @filter="filterPlaces"
              @update:model-value="onPlaceSelect"
            >
              <template #no-option>
                <q-item>
                  <q-item-section class="text-grey-5">
                    {{ searchingPlace ? 'Searching…' : 'No results' }}
                  </q-item-section>
                </q-item>
              </template>
              <template #prepend><q-icon name="search" color="teal-5" /></template>
            </q-select>

            <div class="row q-col-gutter-md">
              <div class="col-6">
                <q-input v-model.number="form.lat" type="number" step="0.0001" label="Latitude"  dark outlined label-color="teal-3" color="teal-3" :rules="[v => !!v || 'Required']" />
              </div>
              <div class="col-6">
                <q-input v-model.number="form.lng" type="number" step="0.0001" label="Longitude" dark outlined label-color="teal-3" color="teal-3" :rules="[v => !!v || 'Required']" />
              </div>
            </div>
            <q-input v-model="form.date"        label="Date (YYYY-MM-DD)"     dark outlined label-color="teal-3" color="teal-3" />
            <q-input v-model="form.description" label="Description"  type="textarea" autogrow dark outlined label-color="teal-3" color="teal-3" />

            <!-- Image: upload or URL -->
            <div class="text-caption text-grey-5 q-mb-xs">Image (upload to Supabase Storage or paste a URL)</div>
            <div class="row q-col-gutter-md items-center">
              <div class="col">
                <q-input v-model="form.image_url" label="Image URL" dark outlined label-color="teal-3" color="teal-3" />
              </div>
              <div class="col-auto">
                <q-btn color="teal-8" icon="upload" label="Upload" unelevated @click="triggerUpload" :loading="uploading" />
                <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="handleUpload" />
              </div>
            </div>
            <div v-if="form.image_url" class="q-mt-xs">
              <img :src="form.image_url" style="max-height:120px; border-radius:8px; max-width:100%;" />
            </div>

            <div class="row q-gutter-sm q-mt-md">
              <q-btn type="submit" :label="editingId ? 'Update Point' : 'Add Point'" color="teal" unelevated :loading="saving" />
              <q-btn v-if="editingId" flat label="Cancel" @click="resetForm" />
            </div>
          </q-form>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'
import { storageBucket } from 'src/lib/instance'

const route    = useRoute()
const regionId = route.params.regionId as string

const region   = ref<MapRegion | null>(null)
const points   = ref<MapPoint[]>([])
const saving   = ref(false)
const uploading= ref(false)
const editingId     = ref<string | null>(null)
const fileInput     = ref<HTMLInputElement | null>(null)
const searchingPlace= ref(false)
const selectedPlace = ref<{ label: string; lat: number; lng: number } | null>(null)
const placeOptions  = ref<{ label: string; lat: number; lng: number }[]>([])

const categoryOptions = [
  { label: 'Show / Festival',      value: 'show' },
  { label: 'Senior Facility',      value: 'senior' },
  { label: 'Nature Must-See',      value: 'nature' },
]

const emptyForm = () => ({
  category: 'show' as 'show' | 'senior' | 'nature',
  name: '', lat: 0, lng: 0, date: '', description: '', image_url: '',
})
const form = reactive(emptyForm())

async function filterPlaces(inputVal: string, doneFn: (cb: () => void) => void) {
  if (!inputVal || inputVal.length < 3) {
    doneFn(() => { placeOptions.value = [] })
    return
  }
  searchingPlace.value = true
  try {
    const resp = await fetch(
      `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(inputVal)}&format=json&limit=6&addressdetails=0`,
      { headers: { 'User-Agent': "Nikki's Great Music Festivals admin" } }
    )
    const data = await resp.json() as { display_name: string; lat: string; lon: string }[]
    doneFn(() => {
      placeOptions.value = data.map(r => ({
        label: r.display_name,
        lat:   parseFloat(r.lat),
        lng:   parseFloat(r.lon),
      }))
    })
  } catch {
    doneFn(() => { placeOptions.value = [] })
  } finally {
    searchingPlace.value = false
  }
}

function onPlaceSelect(place: { label: string; lat: number; lng: number } | null) {
  if (!place) return
  form.lat = place.lat
  form.lng = place.lng
  if (!form.name) {
    // Use the first part of the display name (before the first comma) as a name hint
    form.name = place.label.split(',')[0]?.trim() ?? ''
  }
}

function catIcon(cat: string) {
  return cat === 'show' ? 'event' : cat === 'senior' ? 'elderly' : 'landscape'
}
function catColor(cat: string) {
  return cat === 'show' ? 'indigo-4' : cat === 'senior' ? 'green-4' : 'orange-4'
}

async function loadData() {
  const [{ data: rgn }, { data: pts }] = await Promise.all([
    supabase.from('map_regions').select('*').eq('id', regionId).single(),
    supabase.from('map_points').select('*').eq('region_id', regionId).order('created_at'),
  ])
  region.value = rgn as MapRegion
  points.value = (pts as MapPoint[]) ?? []
}

function openAddDialog() {
  resetForm()
}

function openEditDialog(pt: MapPoint) {
  editingId.value = pt.id
  Object.assign(form, {
    category: pt.category, name: pt.name,
    lat: pt.lat, lng: pt.lng, date: pt.date ?? '',
    description: pt.description ?? '', image_url: pt.image_url ?? '',
  })
}

function resetForm() {
  editingId.value = null
  selectedPlace.value = null
  Object.assign(form, emptyForm())
}

async function savePoint() {
  saving.value = true
  const payload = {
    region_id:   regionId,
    category:    form.category,
    name:        form.name,
    lat:         form.lat,
    lng:         form.lng,
    date:        form.date || null,
    description: form.description || null,
    image_url:   form.image_url || null,
  }

  if (editingId.value) {
    await supabase.from('map_points').update(payload).eq('id', editingId.value)
  } else {
    await supabase.from('map_points').insert(payload)
  }

  await loadData()
  resetForm()
  saving.value = false
}

async function deletePoint(id: string) {
  await supabase.from('map_points').delete().eq('id', id)
  points.value = points.value.filter(p => p.id !== id)
}

function triggerUpload() {
  fileInput.value?.click()
}

async function handleUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploading.value = true
  const ext  = file.name.split('.').pop()
  const path = `map-points/${regionId}/${Date.now()}.${ext}`
  const { error } = await supabase.storage.from(storageBucket()).upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from(storageBucket()).getPublicUrl(path)
    form.image_url = data.publicUrl
  }
  uploading.value = false
}

onMounted(loadData)
</script>

<style lang="scss" scoped>
.editor-panel {
  background: #1a1a2e;
  border: 1px solid rgba(77, 182, 172, 0.2);
}
.hidden { display: none; }
</style>

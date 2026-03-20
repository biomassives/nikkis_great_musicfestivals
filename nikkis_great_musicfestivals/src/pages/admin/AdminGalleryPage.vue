<template>
  <q-page class="q-pa-lg">
    <div class="text-h5 text-teal-3 q-mb-xs">Gallery Manager</div>
    <div class="text-caption text-grey-5 q-mb-lg">Upload images or add URLs · organise by category</div>

    <!-- Category tabs -->
    <q-tabs v-model="tab" dense align="left" active-color="teal-3" indicator-color="teal-3" class="q-mb-lg">
      <q-tab name="outdoor"  icon="forest"            label="Outdoor Adventures" />
      <q-tab name="concert"  icon="music_note"         label="Music Concerts"    />
      <q-tab name="cuteness" icon="sentiment_very_satisfied" label="Daily Cuteness" />
    </q-tabs>

    <div class="row q-col-gutter-xl">

      <!-- Photo grid -->
      <div class="col-12 col-md-7">
        <div class="row items-center q-mb-md">
          <div class="text-subtitle2 text-teal-2 col">
            {{ tabLabel }} ({{ byCategory(tab).length }})
          </div>
        </div>

        <div v-if="loading" class="flex flex-center q-py-xl">
          <q-spinner-orbit color="teal" size="40px" />
        </div>
        <div v-else class="admin-photo-grid">
          <div
            v-for="photo in byCategory(tab)"
            :key="photo.id"
            class="admin-thumb"
          >
            <img :src="photo.url" class="admin-thumb-img" :alt="photo.caption ?? ''" />
            <div class="admin-thumb-overlay">
              <div class="text-caption text-white ellipsis q-px-xs" style="max-width:140px">
                {{ photo.caption ?? '—' }}
              </div>
              <q-btn flat round dense icon="delete" color="red-3" size="sm" @click="deletePhoto(photo.id)" />
            </div>
          </div>
          <div v-if="byCategory(tab).length === 0" class="text-grey-6 text-center q-py-xl col-span-full">
            No photos yet in this category
          </div>
        </div>
      </div>

      <!-- Add panel -->
      <div class="col-12 col-md-5">
        <div class="admin-add-panel q-pa-lg rounded-borders">
          <div class="text-subtitle2 text-teal-2 q-mb-md">Add Photos</div>

          <!-- URL input -->
          <div class="text-caption text-grey-5 q-mb-xs">Single URL</div>
          <div class="row q-gutter-sm items-start q-mb-md">
            <q-input
              v-model="urlInput"
              placeholder="https://..."
              dark outlined dense
              label-color="teal-3" color="teal-3"
              class="col"
            />
            <q-btn icon="add" color="teal" unelevated dense @click="addByUrl" :disable="!urlInput" />
          </div>

          <!-- Batch URL textarea -->
          <div class="text-caption text-grey-5 q-mb-xs">Batch URLs (one per line)</div>
          <q-input
            v-model="batchUrls"
            type="textarea"
            :rows="5"
            placeholder="https://example.com/photo1.jpg&#10;https://example.com/photo2.jpg"
            dark outlined
            label-color="teal-3" color="teal-3"
            class="q-mb-sm"
          />
          <q-btn
            label="Add All URLs"
            color="teal-8"
            outline
            class="full-width q-mb-lg"
            :loading="addingBatch"
            :disable="!batchUrls.trim()"
            @click="addBatch"
          />

          <!-- File upload -->
          <div class="text-caption text-grey-5 q-mb-xs">Upload Files (to Supabase Storage)</div>
          <q-btn
            label="Choose Images"
            icon="upload"
            color="teal"
            unelevated
            class="full-width q-mb-xs"
            :loading="uploading"
            @click="triggerUpload"
          />
          <input ref="fileInput" type="file" multiple accept="image/*" class="hidden" @change="handleUpload" />
          <div v-if="uploadProgress.length" class="q-mt-sm">
            <div v-for="p in uploadProgress" :key="p.name" class="row items-center q-gutter-xs q-mb-xs">
              <q-linear-progress :value="p.pct / 100" color="teal" class="col" style="height:4px" rounded />
              <div class="text-caption text-grey-5" style="width:80px;overflow:hidden;text-overflow:ellipsis;">{{ p.name }}</div>
            </div>
          </div>

          <!-- Caption for new items -->
          <div class="text-caption text-grey-5 q-mt-md q-mb-xs">Caption (applied to next item added)</div>
          <q-input
            v-model="captionInput"
            placeholder="Optional caption..."
            dark outlined dense
            label-color="teal-3" color="teal-3"
          />
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { GalleryPhoto } from 'src/lib/supabase'

type Category = GalleryPhoto['category']

const tab      = ref<Category>('outdoor')
const photos   = ref<GalleryPhoto[]>([])
const loading  = ref(true)
const urlInput     = ref('')
const batchUrls    = ref('')
const captionInput = ref('')
const addingBatch  = ref(false)
const uploading    = ref(false)
const fileInput    = ref<HTMLInputElement | null>(null)
const uploadProgress = ref<{ name: string; pct: number }[]>([])

const tabLabel = computed(() => {
  return { outdoor: 'Outdoor Adventures', concert: 'Music Concerts', cuteness: 'Daily Cuteness' }[tab.value] ?? ''
})

function byCategory(cat: Category) {
  return photos.value.filter(p => p.category === cat)
}

async function loadPhotos() {
  const { data } = await supabase.from('gallery_photos').select('*').order('display_order')
  photos.value = (data as GalleryPhoto[]) ?? []
  loading.value = false
}

async function addByUrl() {
  if (!urlInput.value) return
  const { data } = await supabase.from('gallery_photos').insert({
    category: tab.value,
    url: urlInput.value,
    caption: captionInput.value || null,
    display_order: byCategory(tab.value).length + 1,
  }).select().single()
  if (data) photos.value.push(data as GalleryPhoto)
  urlInput.value = ''
  captionInput.value = ''
}

async function addBatch() {
  const urls = batchUrls.value.split('\n').map(u => u.trim()).filter(Boolean)
  if (!urls.length) return
  addingBatch.value = true
  const rows = urls.map((url, i) => ({
    category: tab.value,
    url,
    caption: null,
    display_order: byCategory(tab.value).length + i + 1,
  }))
  const { data } = await supabase.from('gallery_photos').insert(rows).select()
  if (data) photos.value.push(...(data as GalleryPhoto[]))
  batchUrls.value = ''
  addingBatch.value = false
}

async function deletePhoto(id: string) {
  await supabase.from('gallery_photos').delete().eq('id', id)
  photos.value = photos.value.filter(p => p.id !== id)
}

function triggerUpload() { fileInput.value?.click() }

async function handleUpload(e: Event) {
  const files = Array.from((e.target as HTMLInputElement).files ?? [])
  if (!files.length) return
  uploading.value = true
  uploadProgress.value = files.map(f => ({ name: f.name, pct: 0 }))

  for (let i = 0; i < files.length; i++) {
    const file = files[i]!
    const ext  = file.name.split('.').pop()
    const path = `gallery/${tab.value}/${Date.now()}-${i}.${ext}`

    const { error } = await supabase.storage.from('festival-media').upload(path, file)
    uploadProgress.value[i]!.pct = 50

    if (!error) {
      const { data: urlData } = supabase.storage.from('festival-media').getPublicUrl(path)
      const { data: row } = await supabase.from('gallery_photos').insert({
        category: tab.value,
        url: urlData.publicUrl,
        caption: captionInput.value || null,
        display_order: byCategory(tab.value).length + i + 1,
      }).select().single()
      if (row) photos.value.push(row as GalleryPhoto)
    }
    uploadProgress.value[i]!.pct = 100
  }

  uploading.value = false
  uploadProgress.value = []
  captionInput.value = ''
}

onMounted(() => { void loadPhotos() })
</script>

<style lang="scss" scoped>
.admin-add-panel {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.2);
}
.admin-photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
  gap: 8px;
}
.admin-thumb {
  position: relative; border-radius: 6px; overflow: hidden;
  aspect-ratio: 1;
  &:hover .admin-thumb-overlay { opacity: 1; }
}
.admin-thumb-img { width: 100%; height: 100%; object-fit: cover; display: block; }
.admin-thumb-overlay {
  position: absolute; inset: 0;
  background: rgba(0,0,0,0.55);
  display: flex; flex-direction: column;
  justify-content: space-between; align-items: flex-start;
  padding: 6px; opacity: 0; transition: opacity 0.2s;
}
.hidden { display: none; }
</style>

<template>
  <q-page class="q-pa-lg">
    <div class="text-h5 text-teal-3 q-mb-xs">Gallery Manager</div>
    <div class="text-caption text-grey-5 q-mb-lg">Upload images · organise by section · stage drafts before publishing</div>

    <!-- Sections Manager -->
    <q-expansion-item
      icon="tune"
      label="Manage Sections"
      class="section-mgr q-mb-md rounded-borders"
      header-class="section-mgr-header"
    >
      <q-card class="section-mgr-card">
        <q-card-section>
          <div class="row items-center q-mb-sm">
            <div class="text-caption text-grey-5 col">Sections appear as tabs on the public gallery page</div>
            <q-btn icon="add" label="Add Section" color="teal-7" outline size="sm" @click="openAddSection" />
          </div>
          <q-list separator dark style="background:transparent">
            <q-item v-for="(sec, i) in sections" :key="sec.slug" dense class="q-py-sm">
              <q-item-section avatar>
                <q-icon :name="sec.icon" :color="sec.color" size="20px" />
              </q-item-section>
              <q-item-section>
                <q-item-label class="text-grey-2 text-weight-medium">{{ sec.label }}</q-item-label>
                <q-item-label caption class="text-grey-6">{{ sec.description }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <div class="row q-gutter-xs">
                  <q-btn flat dense round icon="arrow_upward"   color="grey-5" size="sm" :disable="i === 0"                    @click="moveSection(i, -1)" />
                  <q-btn flat dense round icon="arrow_downward" color="grey-5" size="sm" :disable="i === sections.length - 1"  @click="moveSection(i,  1)" />
                  <q-btn flat dense round icon="edit"   color="teal-4" size="sm" @click="openEditSection(i)" />
                  <q-btn flat dense round icon="delete" color="red-4"  size="sm" @click="removeSection(i)" :disable="sections.length <= 1" />
                </div>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>
      </q-card>
    </q-expansion-item>

    <!-- Attribution Review Queue -->
    <q-expansion-item
      icon="policy"
      label="Attribution Review"
      :caption="reviewPending.length ? `${reviewPending.length} pending approval` : 'All attributions approved'"
      class="attr-review q-mb-md rounded-borders"
      header-class="attr-review-header"
    >
      <q-card class="attr-review-card">
        <q-card-section v-if="reviewPending.length === 0" class="text-grey-5 text-center q-py-lg text-caption">
          Nothing pending — all credited photos have been reviewed.
        </q-card-section>
        <q-list v-else separator dark style="background:transparent">
          <q-item v-for="photo in reviewPending" :key="photo.id" class="q-py-sm">
            <q-item-section avatar>
              <img :src="photo.url" class="attr-review-thumb" :alt="photo.caption ?? ''" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-grey-2 text-weight-medium">{{ photo.attribution_author }}</q-item-label>
              <q-item-label caption class="text-grey-6">
                {{ photo.attribution_license }}
                <span v-if="!photo.attribution_source_url" class="text-amber-6"> · source URL missing</span>
              </q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-btn flat dense label="Edit & Approve" color="teal-3" icon="fact_check" size="sm"
                @click="openAttrReview(photo)" />
            </q-item-section>
          </q-item>
        </q-list>
      </q-card>
    </q-expansion-item>

    <!-- Attribution Edit & Approve Dialog -->
    <q-dialog v-model="attrReview.open" persistent>
      <q-card style="min-width:440px;background:#1a1a2e;border:1px solid rgba(77,182,172,0.3)">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6 text-teal-3">Review Attribution</div>
          <q-space />
          <q-btn icon="close" flat round dense color="grey-5" v-close-popup />
        </q-card-section>

        <q-card-section v-if="attrReview.photo" class="q-gutter-sm">
          <div class="row items-center q-gutter-md q-mb-sm">
            <img :src="attrReview.photo.url" class="attr-dialog-thumb" />
            <div class="text-caption text-grey-5">
              {{ attrReview.photo.caption ?? attrReview.photo.category }}
            </div>
          </div>
          <q-input v-model="attrReview.form.author"
            label="Author / photographer" dark outlined dense label-color="teal-3" color="teal-3" />
          <q-input v-model="attrReview.form.source_url"
            label="Source URL" hint="Wikimedia page, Flickr, etc."
            dark outlined dense label-color="teal-3" color="teal-3" />
          <q-input v-model="attrReview.form.license"
            label="License" dark outlined dense label-color="teal-3" color="teal-3" />
          <q-input v-model="attrReview.form.license_url"
            label="License deed URL" dark outlined dense label-color="teal-3" color="teal-3" />
          <q-input v-model="attrReview.form.changes"
            label="Modifications (if any)" dark outlined dense label-color="teal-3" color="teal-3" />
        </q-card-section>

        <q-card-actions align="right" class="q-px-md q-pb-md">
          <q-btn flat label="Save draft" color="grey-5"
            :loading="attrReview.saving" @click="saveAttrReview(false)" />
          <q-btn unelevated label="Approve" icon="check" color="teal"
            :loading="attrReview.saving" @click="saveAttrReview(true)" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Section tabs -->
    <q-tabs v-model="tab" dense align="left" active-color="teal-3" indicator-color="teal-3" class="q-mb-lg">
      <q-tab v-for="sec in sections" :key="sec.slug" :name="sec.slug" :icon="sec.icon" :label="sec.label" />
    </q-tabs>

    <div class="row q-col-gutter-xl">

      <!-- Photo grid -->
      <div class="col-12 col-md-7">
        <div class="row items-center q-mb-md">
          <div class="text-subtitle2 text-teal-2 col">
            {{ currentSection?.label }} ({{ byCategory(tab).length }})
          </div>
          <div class="text-caption text-grey-6">
            {{ publishedInTab }} published · {{ draftInTab }} staged
          </div>
        </div>

        <div v-if="loading" class="flex flex-center q-py-xl">
          <q-spinner-orbit color="teal" size="40px" />
        </div>
        <div v-else class="admin-photo-grid">
          <div
            v-for="photo in byCategory(tab)"
            :key="photo.id"
            :class="['admin-thumb', { 'admin-thumb--draft': !photo.published }]"
          >
            <img :src="photo.url" class="admin-thumb-img" :alt="photo.caption ?? ''" />
            <div class="admin-thumb-overlay">
              <div class="text-caption text-white ellipsis q-px-xs" style="max-width:120px">
                {{ photo.caption ?? '—' }}
              </div>
              <div class="row q-gutter-xs q-mt-xs">
                <q-btn
                  flat round dense size="sm"
                  :icon="photo.published ? 'visibility' : 'visibility_off'"
                  :color="photo.published ? 'teal-3' : 'amber-5'"
                  :title="photo.published ? 'Published — click to stage' : 'Staged — click to publish'"
                  @click="togglePublished(photo)"
                />
                <q-btn flat round dense icon="delete" color="red-3" size="sm" @click="deletePhoto(photo.id)" />
              </div>
            </div>
            <q-badge v-if="!photo.published" class="draft-badge" color="amber-8" text-color="black" label="DRAFT" />
            <q-icon v-if="photo.attribution_author && !photo.attribution_approved"
              name="policy" color="amber-6" size="14px" class="attr-pending-badge"
              title="Attribution pending review" />
          </div>
          <div v-if="byCategory(tab).length === 0" class="text-grey-6 text-center q-py-xl col-span-full">
            No photos yet in this section
          </div>
        </div>
      </div>

      <!-- Add panel -->
      <div class="col-12 col-md-5">
        <div class="admin-add-panel q-pa-lg rounded-borders">
          <div class="text-subtitle2 text-teal-2 q-mb-md">Add Photos</div>

          <div class="text-caption text-grey-5 q-mb-xs">Single URL</div>
          <div class="row q-gutter-sm items-start q-mb-md">
            <q-input v-model="urlInput" placeholder="https://..." dark outlined dense
              label-color="teal-3" color="teal-3" class="col" />
            <q-btn icon="add" color="teal" unelevated dense @click="addByUrl" :disable="!urlInput" />
          </div>

          <div class="text-caption text-grey-5 q-mb-xs">Batch URLs (one per line)</div>
          <q-input
            v-model="batchUrls" type="textarea" :rows="4"
            placeholder="https://example.com/photo1.jpg&#10;https://example.com/photo2.jpg"
            dark outlined label-color="teal-3" color="teal-3" class="q-mb-sm"
          />
          <q-btn label="Add All URLs" color="teal-8" outline class="full-width q-mb-lg"
            :loading="addingBatch" :disable="!batchUrls.trim()" @click="addBatch" />

          <div class="text-caption text-grey-5 q-mb-xs">Upload Files (to Supabase Storage)</div>
          <q-btn label="Choose Images" icon="upload" color="teal" unelevated class="full-width q-mb-xs"
            :loading="uploading" @click="triggerUpload" />
          <input ref="fileInput" type="file" multiple accept="image/*" class="hidden" @change="handleUpload" />
          <div v-if="uploadProgress.length" class="q-mt-sm">
            <div v-for="p in uploadProgress" :key="p.name" class="row items-center q-gutter-xs q-mb-xs">
              <q-linear-progress :value="p.pct / 100" color="teal" class="col" style="height:4px" rounded />
              <div class="text-caption text-grey-5" style="width:80px;overflow:hidden;text-overflow:ellipsis;">{{ p.name }}</div>
            </div>
          </div>

          <div class="text-caption text-grey-5 q-mt-md q-mb-xs">Caption (applied to next item added)</div>
          <q-input v-model="captionInput" placeholder="Optional caption..." dark outlined dense
            label-color="teal-3" color="teal-3" class="q-mb-md" />

          <q-expansion-item dense icon="policy" label="Attribution (CC / third-party photos)"
            header-class="text-teal-4" class="q-mb-md attr-expand">
            <div class="q-pt-sm q-gutter-sm">
              <q-input v-model="attrInput.author" label="Creator / photographer" dark outlined dense
                label-color="teal-3" color="teal-3" placeholder="e.g. Ser Amantio di Nicolao" />
              <q-input v-model="attrInput.source_url" label="Source URL (Wikimedia page, Flickr, etc.)" dark outlined dense
                label-color="teal-3" color="teal-3" placeholder="https://commons.wikimedia.org/wiki/File:..." />
              <q-input v-model="attrInput.license" label="License" dark outlined dense
                label-color="teal-3" color="teal-3" placeholder="CC BY-SA 4.0" />
              <q-input v-model="attrInput.license_url" label="License deed URL" dark outlined dense
                label-color="teal-3" color="teal-3" placeholder="https://creativecommons.org/licenses/by-sa/4.0/" />
              <q-input v-model="attrInput.changes" label="Modifications (if any)" dark outlined dense
                label-color="teal-3" color="teal-3" placeholder="e.g. cropped" />
            </div>
          </q-expansion-item>

          <q-toggle v-model="addAsPublished" label="Publish immediately" color="teal-3" dark />
          <div class="text-caption text-grey-6 q-mt-xs">Off = saved as draft, visible only in admin</div>
        </div>
      </div>
    </div>

    <!-- Section Add / Edit Dialog -->
    <q-dialog v-model="sectionDialog.open" persistent>
      <q-card style="min-width:360px;background:#1a1a2e;border:1px solid rgba(77,182,172,0.3)">
        <q-card-section>
          <div class="text-h6 text-teal-3">{{ sectionDialog.isNew ? 'Add Section' : 'Edit Section' }}</div>
        </q-card-section>
        <q-card-section class="q-gutter-md">
          <q-input v-model="sectionForm.label" label="Section label *" dark outlined dense
            label-color="teal-3" color="teal-3" @update:model-value="autoSlug" />
          <q-input v-model="sectionForm.slug" label="Slug (category key)"
            dark outlined dense label-color="teal-3" color="teal-3"
            :readonly="!sectionDialog.isNew"
            :hint="sectionDialog.isNew
              ? 'Auto-generated from label, editable'
              : 'Cannot be changed after creation (would unlink existing photos)'" />
          <q-input v-model="sectionForm.description" label="Description (shown on public site)"
            dark outlined dense label-color="teal-3" color="teal-3" />
          <q-input v-model="sectionForm.icon" label="Material icon (e.g. forest, music_note, palette)"
            dark outlined dense label-color="teal-3" color="teal-3" />
          <q-select v-model="sectionForm.color" :options="colorOptions" emit-value map-options
            label="Accent color" dark outlined dense label-color="teal-3" color="teal-3" />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Save" color="teal" :loading="savingSection" @click="saveSection"
            :disable="!sectionForm.slug || !sectionForm.label" />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { GalleryPhoto, GallerySection } from 'src/lib/supabase'
import { storageBucket } from 'src/lib/instance'
import { parsePhotoFilename } from 'src/lib/parsePhotoFilename'

const DEFAULT_SECTIONS: GallerySection[] = [
  { slug: 'outdoor',  label: 'Outdoor Adventures', description: 'Trails, peaks, and wild places',                icon: 'forest',     color: 'green-8' },
  { slug: 'concert',  label: 'Music Concerts',     description: 'Live moments from the festival field',           icon: 'music_note', color: 'amber-8' },
  { slug: 'cuteness', label: 'Daily Cuteness',     description: 'The little things that make the road worth it', icon: 'favorite',   color: 'pink-8'  },
]

const colorOptions = [
  { label: 'Teal',        value: 'teal-3'       },
  { label: 'Amber',       value: 'amber-8'      },
  { label: 'Green',       value: 'green-8'      },
  { label: 'Pink',        value: 'pink-8'       },
  { label: 'Deep Purple', value: 'deep-purple'  },
  { label: 'Blue',        value: 'blue-5'       },
  { label: 'Deep Orange', value: 'deep-orange'  },
  { label: 'Light Blue',  value: 'light-blue-4' },
  { label: 'Red',         value: 'red-5'        },
]

const sections       = ref<GallerySection[]>([...DEFAULT_SECTIONS])
const tab            = ref('')
const photos         = ref<GalleryPhoto[]>([])
const loading        = ref(true)
const urlInput       = ref('')
const batchUrls      = ref('')
const captionInput   = ref('')
const addingBatch    = ref(false)
const uploading      = ref(false)
const fileInput      = ref<HTMLInputElement | null>(null)
const uploadProgress = ref<{ name: string; pct: number }[]>([])
const addAsPublished = ref(true)
const savingSection  = ref(false)

const attrInput = reactive({
  author:      '',
  source_url:  '',
  license:     'CC BY-SA 4.0',
  license_url: 'https://creativecommons.org/licenses/by-sa/4.0/',
  changes:     '',
})

function attrFields() {
  return {
    attribution_author:      attrInput.author      || null,
    attribution_source_url:  attrInput.source_url  || null,
    attribution_license:     attrInput.license      || null,
    attribution_license_url: attrInput.license_url  || null,
    attribution_changes:     attrInput.changes       || null,
  }
}

function clearAttr() {
  attrInput.author      = ''
  attrInput.source_url  = ''
  attrInput.license     = 'CC BY-SA 4.0'
  attrInput.license_url = 'https://creativecommons.org/licenses/by-sa/4.0/'
  attrInput.changes     = ''
}

// ── Attribution review queue ─────────────────────────────────────────────────
const reviewPending = computed(() =>
  photos.value.filter(p => p.attribution_author && !p.attribution_approved)
)

const attrReview = reactive({
  open:   false,
  saving: false,
  photo:  null as GalleryPhoto | null,
  form: {
    author:      '',
    source_url:  '',
    license:     '',
    license_url: '',
    changes:     '',
  },
})

function openAttrReview(photo: GalleryPhoto) {
  attrReview.photo = photo
  attrReview.form  = {
    author:      photo.attribution_author      ?? '',
    source_url:  photo.attribution_source_url  ?? '',
    license:     photo.attribution_license     ?? '',
    license_url: photo.attribution_license_url ?? '',
    changes:     photo.attribution_changes     ?? '',
  }
  attrReview.open = true
}

async function saveAttrReview(approve: boolean) {
  if (!attrReview.photo) return
  attrReview.saving = true
  const updates = {
    attribution_author:      attrReview.form.author      || null,
    attribution_source_url:  attrReview.form.source_url  || null,
    attribution_license:     attrReview.form.license     || null,
    attribution_license_url: attrReview.form.license_url || null,
    attribution_changes:     attrReview.form.changes     || null,
    attribution_approved:    approve,
  }
  await supabase.from('gallery_photos').update(updates).eq('id', attrReview.photo.id)
  const found = photos.value.find(p => p.id === attrReview.photo!.id)
  if (found) Object.assign(found, updates)
  attrReview.saving = false
  attrReview.open   = false
}

const sectionDialog = ref({ open: false, isNew: true, editIndex: -1 })
const sectionForm   = ref<GallerySection>({ slug: '', label: '', description: '', icon: 'photo', color: 'teal-3' })

const currentSection = computed(() => sections.value.find(s => s.slug === tab.value))
const publishedInTab = computed(() => byCategory(tab.value).filter(p =>  p.published).length)
const draftInTab     = computed(() => byCategory(tab.value).filter(p => !p.published).length)

function byCategory(cat: string) {
  return photos.value.filter(p => p.category === cat)
}

function autoSlug(val: string | number | null) {
  if (sectionDialog.value.isNew) {
    sectionForm.value.slug = String(val).toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '')
  }
}

function openAddSection() {
  sectionDialog.value = { open: true, isNew: true, editIndex: -1 }
  sectionForm.value = { slug: '', label: '', description: '', icon: 'photo', color: 'teal-3' }
}

function openEditSection(i: number) {
  sectionDialog.value = { open: true, isNew: false, editIndex: i }
  sectionForm.value = { ...sections.value[i]! }
}

async function saveSection() {
  savingSection.value = true
  const { isNew, editIndex } = sectionDialog.value
  const s = { ...sectionForm.value }
  if (isNew) {
    sections.value.push(s)
  } else {
    sections.value.splice(editIndex, 1, s)
  }
  await supabase.from('site_settings').upsert({
    key: 'gallery_sections', value: sections.value, updated_at: new Date().toISOString(),
  })
  savingSection.value = false
  sectionDialog.value.open = false
  if (isNew) tab.value = s.slug
}

async function moveSection(i: number, dir: -1 | 1) {
  const arr = [...sections.value]
  const tmp = arr[i]!
  arr[i] = arr[i + dir]!
  arr[i + dir] = tmp
  sections.value = arr
  await supabase.from('site_settings').upsert({
    key: 'gallery_sections', value: sections.value, updated_at: new Date().toISOString(),
  })
}

async function removeSection(i: number) {
  sections.value.splice(i, 1)
  await supabase.from('site_settings').upsert({
    key: 'gallery_sections', value: sections.value, updated_at: new Date().toISOString(),
  })
  if (!sections.value.find(s => s.slug === tab.value)) {
    tab.value = sections.value[0]?.slug ?? ''
  }
}

async function loadPhotos() {
  const { data } = await supabase.from('gallery_photos').select('*').order('display_order')
  photos.value = (data as GalleryPhoto[]) ?? []
  loading.value = false
}

async function togglePublished(photo: GalleryPhoto) {
  const newVal = !photo.published
  await supabase.from('gallery_photos').update({ published: newVal }).eq('id', photo.id)
  const found = photos.value.find(p => p.id === photo.id)
  if (found) found.published = newVal
}

async function addByUrl() {
  if (!urlInput.value) return
  const { data } = await supabase.from('gallery_photos').insert({
    category: tab.value,
    url: urlInput.value,
    caption: captionInput.value || null,
    display_order: byCategory(tab.value).length + 1,
    published: addAsPublished.value,
    ...attrFields(),
  }).select().single()
  if (data) photos.value.push(data as GalleryPhoto)
  urlInput.value = ''
  captionInput.value = ''
  clearAttr()
}

async function addBatch() {
  const urls = batchUrls.value.split('\n').map(u => u.trim()).filter(Boolean)
  if (!urls.length) return
  addingBatch.value = true
  const base = byCategory(tab.value).length
  const attr = attrFields()
  const rows = urls.map((url, i) => ({
    category: tab.value, url, caption: null,
    display_order: base + i + 1, published: addAsPublished.value,
    ...attr,
  }))
  const { data } = await supabase.from('gallery_photos').insert(rows).select()
  if (data) photos.value.push(...(data as GalleryPhoto[]))
  batchUrls.value = ''
  addingBatch.value = false
  clearAttr()
}

async function deletePhoto(id: string) {
  await supabase.from('gallery_photos').delete().eq('id', id)
  photos.value = photos.value.filter(p => p.id !== id)
}

function triggerUpload() { fileInput.value?.click() }

async function handleUpload(e: Event) {
  const files = Array.from((e.target as HTMLInputElement).files ?? [])
  if (!files.length) return

  // Tier 1: auto-fill attribution from filename if it follows the naming scheme.
  // Source URL is intentionally left blank — it can't be derived from the filename
  // and must be filled in the review queue (Tier 2).
  const firstFile = files[0]
  if (firstFile) {
    const parsed = parsePhotoFilename(firstFile.name)
    if (parsed?.valid) {
      attrInput.author      = parsed.author
      attrInput.source_url  = ''
      attrInput.license     = parsed.licenseLabel
      attrInput.license_url = parsed.licenseUrl
      attrInput.changes     = parsed.changes ?? ''
    }
  }

  uploading.value = true
  uploadProgress.value = files.map(f => ({ name: f.name, pct: 0 }))
  for (let i = 0; i < files.length; i++) {
    const file = files[i]!
    const ext  = file.name.split('.').pop()
    const path = `gallery/${tab.value}/${Date.now()}-${i}.${ext}`
    const { error } = await supabase.storage.from(storageBucket()).upload(path, file)
    uploadProgress.value[i]!.pct = 50
    if (!error) {
      const { data: urlData } = supabase.storage.from(storageBucket()).getPublicUrl(path)
      const { data: row } = await supabase.from('gallery_photos').insert({
        category: tab.value, url: urlData.publicUrl,
        caption: captionInput.value || null,
        display_order: byCategory(tab.value).length + i + 1,
        published: addAsPublished.value,
        ...attrFields(),
      }).select().single()
      if (row) photos.value.push(row as GalleryPhoto)
    }
    uploadProgress.value[i]!.pct = 100
  }
  uploading.value = false
  uploadProgress.value = []
  captionInput.value = ''
  clearAttr()
}

onMounted(async () => {
  const { data } = await supabase.from('site_settings').select('key,value').eq('key', 'gallery_sections').limit(1)
  if (data?.[0]?.value) sections.value = data[0].value as GallerySection[]
  tab.value = sections.value[0]?.slug ?? 'outdoor'
  void loadPhotos()
})
</script>

<style lang="scss" scoped>
.section-mgr        { background: #1a1a2e; border: 1px solid rgba(77,182,172,0.2); }
.section-mgr-header { color: #b2dfdb !important; }
.section-mgr-card   { background: #14142a; }
.admin-add-panel    { background: #1a1a2e; border: 1px solid rgba(77,182,172,0.2); }

.attr-review        { background: #1a1a2e; border: 1px solid rgba(251,192,45,0.25); }
.attr-review-header { color: #ffe082 !important; }
.attr-review-card   { background: #14142a; }
.attr-review-thumb  { width: 48px; height: 48px; object-fit: cover; border-radius: 4px; }
.attr-dialog-thumb  { width: 80px; height: 80px; object-fit: cover; border-radius: 6px; flex-shrink: 0; }

.admin-photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
  gap: 8px;
}
.admin-thumb {
  position: relative; border-radius: 6px; overflow: hidden; aspect-ratio: 1;
  &:hover .admin-thumb-overlay { opacity: 1; }
  &--draft { opacity: 0.65; outline: 2px solid #ffa000; }
}

.attr-pending-badge {
  position: absolute; top: 4px; right: 4px;
  background: rgba(0,0,0,0.6); border-radius: 50%; padding: 2px;
}
.admin-thumb-img { width: 100%; height: 100%; object-fit: cover; display: block; }
.admin-thumb-overlay {
  position: absolute; inset: 0;
  background: rgba(0,0,0,0.6);
  display: flex; flex-direction: column;
  justify-content: flex-end; align-items: flex-start;
  padding: 6px; opacity: 0; transition: opacity 0.2s;
}
.draft-badge {
  position: absolute; top: 4px; left: 4px;
  font-size: 9px; letter-spacing: 1px;
}
.hidden { display: none; }
</style>

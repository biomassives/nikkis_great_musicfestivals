<template>
  <q-page class="q-pa-lg">

    <!-- ══ LIST VIEW ══════════════════════════════════════════════════════ -->
    <template v-if="view === 'list'">

      <div class="row items-center q-mb-lg">
        <div>
          <div class="text-h5 text-purple-3">Pages</div>
          <div class="text-caption text-grey-5">Custom content pages with rich text, images, video and embeds</div>
        </div>
        <q-space />
        <q-btn color="purple-5" unelevated icon="add" label="New Page" @click="newPage" />
      </div>

      <!-- DB setup notice -->
      <q-banner v-if="setupNeeded" rounded class="setup-banner q-mb-lg">
        <template #avatar><q-icon name="table_chart" color="amber-4" /></template>
        <div>
          Run this SQL once in your Supabase SQL editor to create the <code>custom_pages</code> table.
          <q-btn flat dense size="xs" color="amber-4" icon="content_copy" label="Copy SQL"
            @click="copySetupSql" class="q-ml-sm" />
        </div>
        <template #action>
          <q-btn flat color="amber-4" label="Dismiss" @click="setupNeeded = false" />
        </template>
      </q-banner>

      <div v-if="loading" class="flex flex-center q-py-xl">
        <q-spinner-orbit color="purple-5" size="48px" />
      </div>
      <div v-else-if="!setupNeeded && pages.length === 0"
        class="text-center text-grey-6 q-py-xl">
        No pages yet — click "New Page" to create one.
      </div>

      <div v-else class="row q-col-gutter-md">
        <div v-for="page in pages" :key="page.id" class="col-12 col-sm-6 col-md-4">
          <q-card class="page-card">
            <q-card-section class="q-pb-xs">
              <div class="row items-start">
                <div class="text-h6 text-purple-2 col">{{ page.title || 'Untitled' }}</div>
                <q-badge :color="page.published ? 'teal' : 'grey-7'"
                  :label="page.published ? 'Live' : 'Draft'" class="q-ml-sm" />
              </div>
              <div class="text-caption text-grey-5 q-mt-xs">
                <q-icon name="link" size="11px" class="q-mr-xs" />/{{ page.slug }}
              </div>
              <div v-if="page.nav_parent" class="text-caption text-grey-6 q-mt-xs">
                <q-icon name="account_tree" size="11px" class="q-mr-xs" />under {{ page.nav_parent }}
              </div>
            </q-card-section>
            <q-card-actions align="right">
              <q-btn flat color="grey-5" icon="delete" size="sm" @click="deletePage(page)" />
              <q-btn flat color="purple-4" icon="edit" label="Edit" size="sm" @click="editPage(page)" />
            </q-card-actions>
          </q-card>
        </div>
      </div>

    </template>

    <!-- ══ EDITOR VIEW ══════════════════════════════════════════════════ -->
    <template v-else>

      <!-- Top bar -->
      <div class="row items-center q-mb-lg">
        <q-btn flat round dense icon="arrow_back" color="grey-5" @click="goBack" class="q-mr-sm" />
        <div class="col">
          <div class="text-h5 text-purple-3">{{ editingPage.id ? 'Edit Page' : 'New Page' }}</div>
          <div class="text-caption text-grey-5">
            {{ editingPage.slug ? `Site URL: /${editingPage.slug}` : 'Set a slug below' }}
          </div>
        </div>
        <q-toggle v-model="editingPage.published" label="Published" color="teal-4" dark
          class="q-mr-md" />
        <q-btn color="purple-5" unelevated icon="save" label="Save Page"
          :loading="saving" @click="savePage" />
      </div>

      <!-- Local draft banner -->
      <q-banner v-if="hasDraft" rounded class="draft-banner q-mb-md">
        <template #avatar><q-icon name="edit_note" color="amber-4" /></template>
        You have locally saved draft changes from a previous session.
        <template #action>
          <q-btn flat color="amber-4" label="Restore Draft" @click="restoreDraft" />
          <q-btn flat color="grey-5"  label="Discard"       @click="discardDraft" />
        </template>
      </q-banner>

      <q-banner v-if="saveError" rounded class="error-banner q-mb-md" dense>
        <template #avatar><q-icon name="error" color="red-4" /></template>
        {{ saveError }}
      </q-banner>

      <!-- Page Settings -->
      <div class="text-subtitle2 text-purple-4 text-uppercase ls-2 q-mb-sm">Page Settings</div>
      <q-card class="settings-card q-mb-lg">
        <q-card-section class="q-gutter-md">
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <q-input v-model="editingPage.title" label="Page title *"
                dark outlined dense label-color="purple-3" color="purple-3"
                @update:model-value="v => autoSlug(String(v))" />
            </div>
            <div class="col-12 col-sm-6">
              <q-input v-model="editingPage.slug"
                label="URL slug (letters, numbers, hyphens)"
                dark outlined dense label-color="purple-3" color="purple-3"
                :hint="`Page lives at /${editingPage.slug}`"
                @update:model-value="onSlugInput" />
            </div>
          </div>
          <q-select
            v-model="editingPage.nav_parent"
            :options="navParentOptions"
            option-value="value"
            option-label="label"
            emit-value map-options clearable
            label="Show under nav item (optional)"
            dark outlined dense label-color="purple-3" color="purple-3"
            hint="Published pages with a nav parent appear auto-injected as sub-items in the flyout"
          />
        </q-card-section>
      </q-card>

      <!-- Single rich-text editor -->
      <div class="text-subtitle2 text-purple-4 text-uppercase ls-2 q-mb-sm">Content</div>
      <q-card class="settings-card q-mb-xl">
        <q-card-section class="q-pa-none">
          <QuillEditor
            ref="editorRef"
            :content="editingPage.content"
            content-type="html"
            theme="snow"
            :options="QUILL_OPTIONS"
            placeholder="Write your page content here — headings, paragraphs, lists, links, and images…"
            class="page-wysiwyg"
            @ready="onEditorReady"
            @update:content="(v) => { editingPage.content = String(v) }"
          />
        </q-card-section>
      </q-card>

      <div class="row justify-end q-mb-xl">
        <q-btn color="purple-5" unelevated icon="save" label="Save Page"
          :loading="saving" @click="savePage" />
      </div>

    </template>

    <!-- ── Image Insert Dialog ──────────────────────────────────────────── -->
    <q-dialog v-model="imgDialog.show" persistent>
      <q-card style="min-width:480px;max-width:700px;width:100%" dark class="dialog-card">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6 text-purple-3">Insert Image</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-pt-sm q-pb-none q-px-md">

          <!-- ── Gallery Picker ── -->
          <div class="gallery-picker-section">
            <div class="row items-center q-mb-xs">
              <span class="text-caption text-uppercase text-purple-4 gallery-picker-label">From Gallery</span>
              <q-space />
              <q-spinner-dots v-if="galleryLoading" color="purple-4" size="16px" />
            </div>

            <q-input v-model="gallerySearch" dense dark outlined color="purple-3" label-color="purple-3"
              placeholder="Search by caption…" clearable class="q-mb-xs">
              <template #prepend><q-icon name="search" size="16px" color="grey-5" /></template>
            </q-input>

            <div v-if="galleryCategories.length" class="gallery-cat-row q-mb-xs">
              <q-chip v-for="cat in galleryCategories" :key="cat"
                :color="galleryActiveCategory === cat ? 'purple-6' : 'grey-9'"
                :text-color="galleryActiveCategory === cat ? 'white' : 'grey-5'"
                dense clickable size="sm"
                @click="galleryActiveCategory = galleryActiveCategory === cat ? '' : cat">
                {{ cat }}
              </q-chip>
            </div>

            <div class="gallery-picker-grid">
              <div v-if="filteredGallery.length === 0 && !galleryLoading"
                class="text-grey-6 text-caption text-center q-py-sm gallery-picker-empty">
                No photos found.
              </div>
              <div v-for="photo in filteredGallery" :key="photo.id"
                class="gallery-picker-thumb"
                :class="{ 'gallery-picker-thumb--selected': imgDialog.url === photo.url }"
                :title="photo.caption || photo.category"
                @click="selectGalleryPhoto(photo)">
                <img :src="photo.url" :alt="photo.caption" loading="lazy" />
                <q-icon v-if="imgDialog.url === photo.url" name="check_circle" class="gallery-picker-check" />
              </div>
            </div>
          </div>

          <q-separator dark class="q-my-md" />

          <!-- ── Manual URL / Upload ── -->
          <div class="q-gutter-md q-pb-md">
            <div class="row q-col-gutter-sm items-center">
              <div class="col">
                <q-input v-model="imgDialog.url" label="Image URL"
                  dark outlined dense label-color="purple-3" color="purple-3"
                  placeholder="https://…" clearable />
              </div>
              <div class="col-auto">
                <q-btn color="purple-8" icon="upload" label="Upload" unelevated size="sm"
                  :loading="imgDialog.uploading" @click="triggerImgUpload" />
              </div>
            </div>

            <div v-if="imgDialog.url" class="img-preview-wrap">
              <img :src="imgDialog.url" class="img-preview" />
            </div>

            <q-input v-model="imgDialog.caption" label="Caption (optional)"
              dark outlined dense label-color="purple-3" color="purple-3" />

            <q-input v-model="imgDialog.link" label="Link when clicked (optional)"
              dark outlined dense label-color="purple-3" color="purple-3"
              hint="e.g. full-size image URL or a gallery page — leave blank for no link" />
          </div>

        </q-card-section>

        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Insert" color="purple-5" icon="add_photo_alternate"
            :disable="!imgDialog.url" @click="confirmInsertImage" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Hidden file input for image dialog -->
    <input ref="imgFileInput" type="file" accept="image/*"
      class="hidden" @change="handleImgUpload" />

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { supabase } from 'src/lib/supabase'
import { QuillEditor } from '@vueup/vue-quill'
import '@vueup/vue-quill/dist/vue-quill.snow.css'

const $q = useQuasar()

// ── Types ──────────────────────────────────────────────────────────────────
interface GalleryPhoto {
  id:            string
  category:      string
  url:           string
  caption:       string
  display_order: number
  published:     boolean
}

interface Page {
  id?:        string
  slug:       string
  title:      string
  content:    string   // full HTML from Quill
  published:  boolean
  nav_parent: string | null
  created_at?: string
}

// ── State ──────────────────────────────────────────────────────────────────
const view        = ref<'list' | 'editor'>('list')
const loading     = ref(true)
const saving      = ref(false)
const setupNeeded = ref(false)
const saveError   = ref('')
const pages       = ref<Page[]>([])
const hasDraft    = ref(false)
const localDraft  = ref<Page | null>(null)

const DEFAULT_NAV = [
  { title: 'Photography', link: '/photography' },
  { title: 'Maps',        link: '/maps'         },
  { title: 'Support',     link: '/support'      },
  { title: 'Merch',       link: '/merch'        },
  { title: 'Blog',        link: '/blog'         },
]
const navParentOptions = ref<{ label: string; value: string }[]>(
  DEFAULT_NAV.map(i => ({ label: `${i.title} (${i.link})`, value: i.link }))
)

const editingPage = ref<Page>({
  slug: '', title: '', content: '', published: false, nav_parent: null,
})

let slugTouched: boolean = false
function onSlugInput() { slugTouched = true }

// ── Quill editor ───────────────────────────────────────────────────────────
const editorRef = ref()

const QUILL_OPTIONS = {
  modules: {
    toolbar: [
      [{ header: [1, 2, 3, false] }],
      ['bold', 'italic', 'underline', 'strike'],
      ['blockquote'],
      [{ list: 'ordered' }, { list: 'bullet' }],
      ['link', 'image'],
      ['clean'],
    ],
  },
}

// ── Image dialog ───────────────────────────────────────────────────────────
const imgFileInput = ref<HTMLInputElement | null>(null)
const imgDialog = reactive({
  show:      false,
  url:       '',
  caption:   '',
  link:      '',
  uploading: false,
})
// eslint-disable-next-line @typescript-eslint/no-explicit-any
let pendingQuill: any = null

// ── Gallery picker ─────────────────────────────────────────────────────────
const galleryPhotos         = ref<GalleryPhoto[]>([])
const galleryLoaded         = ref(false)
const galleryLoading        = ref(false)
const gallerySearch         = ref('')
const galleryActiveCategory = ref('')

const galleryCategories = computed(() => {
  const cats = new Set(galleryPhotos.value.map(p => p.category).filter(Boolean))
  return Array.from(cats).sort()
})

const filteredGallery = computed(() => {
  let photos = galleryPhotos.value
  if (galleryActiveCategory.value) {
    photos = photos.filter(p => p.category === galleryActiveCategory.value)
  }
  const q = gallerySearch.value.trim().toLowerCase()
  if (q) {
    photos = photos.filter(p =>
      p.caption?.toLowerCase().includes(q) ||
      p.category?.toLowerCase().includes(q)
    )
  }
  return photos
})

async function loadGallery() {
  if (galleryLoaded.value || galleryLoading.value) return
  galleryLoading.value = true
  const { data } = await supabase
    .from('gallery_photos')
    .select('id, category, url, caption, display_order, published')
    .eq('published', true)
    .order('category')
    .order('display_order')
  if (data) galleryPhotos.value = data as GalleryPhoto[]
  galleryLoaded.value  = true
  galleryLoading.value = false
}

function selectGalleryPhoto(photo: GalleryPhoto) {
  imgDialog.url     = photo.url
  imgDialog.caption = photo.caption || ''
}

// Called by QuillEditor @ready — wire the image toolbar button
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function onEditorReady(quill: any) {
  quill.getModule('toolbar').addHandler('image', () => {
    pendingQuill      = quill
    imgDialog.url     = ''
    imgDialog.caption = ''
    imgDialog.link    = ''
    imgDialog.show    = true
    void loadGallery()
  })
}

function triggerImgUpload() { imgFileInput.value?.click() }

async function handleImgUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  imgDialog.uploading = true
  const ext  = file.name.split('.').pop() ?? 'jpg'
  const path = `pages/${Date.now()}.${ext}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    imgDialog.url = data.publicUrl
  }
  imgDialog.uploading = false
  if (imgFileInput.value) imgFileInput.value.value = ''
}

function confirmInsertImage() {
  if (!pendingQuill || !imgDialog.url) return
  const range = pendingQuill.getSelection(true) as { index: number } | null
  const idx   = range ? range.index : (pendingQuill.getLength() as number) - 1

  const caption  = imgDialog.caption
    ? `<figcaption class="ql-img-caption">${imgDialog.caption}</figcaption>` : ''
  const linkOpen  = imgDialog.link
    ? `<a href="${imgDialog.link}" target="_blank" rel="noopener noreferrer">` : ''
  const linkClose = imgDialog.link ? '</a>' : ''
  const html = `<figure class="ql-custom-figure">${linkOpen}<img src="${imgDialog.url}" alt="${imgDialog.caption || ''}" />${linkClose}${caption}</figure><p><br></p>`

  pendingQuill.clipboard.dangerouslyPasteHTML(idx, html)
  imgDialog.show = false
}

// ── Draft helpers ──────────────────────────────────────────────────────────
function draftKey(id?: string) { return `ngmf_page_draft_${id ?? 'new'}` }

function checkDraft(id?: string) {
  const raw = localStorage.getItem(draftKey(id))
  if (!raw) return
  try {
    localDraft.value = JSON.parse(raw) as Page
    hasDraft.value = true
  } catch { /* ignore corrupted draft */ }
}

function restoreDraft() {
  if (localDraft.value) editingPage.value = localDraft.value
  hasDraft.value = false
  localDraft.value = null
}

function discardDraft() {
  localStorage.removeItem(draftKey(editingPage.value.id))
  hasDraft.value = false
  localDraft.value = null
}

let draftTimer: ReturnType<typeof setTimeout> | null = null
watch(editingPage, () => {
  if (view.value !== 'editor') return
  if (draftTimer) clearTimeout(draftTimer)
  draftTimer = setTimeout(() => {
    localStorage.setItem(draftKey(editingPage.value.id), JSON.stringify(editingPage.value))
  }, 800)
}, { deep: true })

// ── Slug ───────────────────────────────────────────────────────────────────
function autoSlug(title: string) {
  if (slugTouched || editingPage.value.id) return
  editingPage.value.slug = title
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
}

// ── Navigation ─────────────────────────────────────────────────────────────
function newPage() {
  slugTouched = false
  editingPage.value = { slug: '', title: '', content: '', published: false, nav_parent: null }
  checkDraft(undefined)
  view.value = 'editor'
}

function editPage(page: Page) {
  slugTouched = true
  editingPage.value = { ...page }
  hasDraft.value = false; localDraft.value = null
  checkDraft(page.id)
  view.value = 'editor'
}

function goBack() { view.value = 'list' }

// ── Extract content from legacy blocks column ──────────────────────────────
function extractContent(blocks: unknown): string {
  if (!Array.isArray(blocks) || blocks.length === 0) return ''
  const arr = blocks as Array<Record<string, unknown>>
  // New format: single {type:'content', content:'<html>'}
  if (arr[0]?.type === 'content' && typeof arr[0]?.content === 'string') {
    return arr[0].content
  }
  // Legacy multi-block: join all content/text blocks
  return arr
    .filter(b => typeof b.content === 'string')
    .map(b => b.content as string)
    .join('')
}

// ── Save / Delete ──────────────────────────────────────────────────────────
async function savePage() {
  if (!editingPage.value.slug || !editingPage.value.title) {
    saveError.value = 'Title and slug are required.'
    return
  }
  saving.value  = true
  saveError.value = ''

  // Store content inside existing blocks jsonb column — no migration needed
  const payload = {
    slug:       editingPage.value.slug,
    title:      editingPage.value.title,
    blocks:     [{ id: 'main', type: 'content', content: editingPage.value.content }],
    published:  editingPage.value.published,
    nav_parent: editingPage.value.nav_parent || null,
    updated_at: new Date().toISOString(),
  }

  if (editingPage.value.id) {
    const { error } = await supabase.from('custom_pages')
      .update(payload).eq('id', editingPage.value.id)
    if (error) { saveError.value = error.message; saving.value = false; return }
    const idx = pages.value.findIndex(p => p.id === editingPage.value.id)
    if (idx !== -1) Object.assign(pages.value[idx]!, { ...editingPage.value })
  } else {
    const { data, error } = await supabase.from('custom_pages')
      .insert(payload).select().single()
    if (error) { saveError.value = error.message; saving.value = false; return }
    const created = data as { id: string }
    editingPage.value.id = created.id
    pages.value.unshift({ ...editingPage.value })
    localStorage.removeItem(draftKey(undefined))
  }

  localStorage.removeItem(draftKey(editingPage.value.id))
  hasDraft.value = false
  saving.value = false
  $q.notify({ message: 'Page saved', color: 'teal', position: 'top', icon: 'check' })
}

function deletePage(page: Page) {
  $q.dialog({
    title: 'Delete page?',
    message: `"${page.title}" (/${page.slug}) will be permanently deleted.`,
    cancel: true, persistent: true, color: 'negative', dark: true,
  }).onOk(() => {
    void supabase.from('custom_pages').delete().eq('id', page.id as string).then(() => {
      pages.value = pages.value.filter(p => p.id !== page.id)
      if (page.id) localStorage.removeItem(draftKey(page.id))
    })
  })
}

// ── Setup SQL ──────────────────────────────────────────────────────────────
const SETUP_SQL = `-- Run once in Supabase SQL Editor
CREATE TABLE IF NOT EXISTS custom_pages (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  slug       text        UNIQUE NOT NULL,
  title      text        NOT NULL DEFAULT '',
  blocks     jsonb       NOT NULL DEFAULT '[]',
  published  boolean     NOT NULL DEFAULT false,
  nav_parent text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE custom_pages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public reads published pages"
  ON custom_pages FOR SELECT USING (published = true);
CREATE POLICY "Anon manages all pages"
  ON custom_pages FOR ALL USING (true) WITH CHECK (true);`

async function copySetupSql() {
  await navigator.clipboard.writeText(SETUP_SQL)
  $q.notify({ message: 'SQL copied to clipboard', color: 'teal', position: 'top', icon: 'check' })
}

// ── Load ───────────────────────────────────────────────────────────────────
async function loadNavOptions() {
  const { data } = await supabase
    .from('site_settings').select('value')
    .eq('key', 'nav_config').limit(1)
  const row = data?.[0]
  if (Array.isArray(row?.value) && (row?.value as unknown[]).length) {
    navParentOptions.value = (row?.value as { title: string; link: string }[])
      .filter(i => i.link !== '/')
      .map(i => ({ label: `${i.title} (${i.link})`, value: i.link }))
  }
}

onMounted(async () => {
  const { data, error } = await supabase
    .from('custom_pages').select('*').order('created_at', { ascending: false })
  if (error) {
    setupNeeded.value = true
  } else {
    pages.value = ((data as Array<Record<string, unknown>>) ?? []).map(row => ({
      id:         row.id as string,
      slug:       row.slug as string,
      title:      row.title as string,
      content:    extractContent(row.blocks),
      published:  row.published as boolean,
      nav_parent: (row.nav_parent as string | null) ?? null,
      created_at: row.created_at as string,
    }))
  }
  loading.value = false
  void loadNavOptions()
})
</script>

<style lang="scss" scoped>
.page-card {
  background: #1a1a2e;
  border: 1px solid rgba(179,157,219,0.2);
  border-radius: 12px;
  transition: border-color 0.2s;
  cursor: pointer;
  &:hover { border-color: rgba(179,157,219,0.5); }
}

.settings-card {
  background: #1a1a2e;
  border: 1px solid rgba(179,157,219,0.18);
  border-radius: 12px;
}

.dialog-card {
  background: #1a1a2e;
  border: 1px solid rgba(179,157,219,0.25);
  border-radius: 14px;
}

.img-preview-wrap { border-radius: 8px; overflow: hidden; }
.img-preview { width: 100%; max-height: 160px; object-fit: cover; display: block; }

.setup-banner  { background: rgba(255,179,0,0.08); border: 1px solid rgba(255,179,0,0.3); color: #e0f2f1; }
.draft-banner  { background: rgba(255,179,0,0.08); border: 1px solid rgba(255,179,0,0.25); color: #fff8e1; }
.error-banner  { background: rgba(255,82,82,0.1);  border: 1px solid rgba(255,82,82,0.3);  color: #ffcdd2; }

.ls-2 { letter-spacing: 2px; }
.hidden { display: none; }

code {
  background: rgba(255,255,255,0.08); padding: 1px 5px;
  border-radius: 3px; font-size: 11px; color: #b39ddb;
}

/* ── Gallery picker ── */
.gallery-picker-label { letter-spacing: 1.5px; font-size: 11px; }

.gallery-cat-row {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.gallery-picker-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 4px;
  max-height: 192px;
  overflow-y: auto;
  padding-right: 2px;
  scrollbar-width: thin;
  scrollbar-color: rgba(179,157,219,0.3) transparent;
}

.gallery-picker-empty { grid-column: 1 / -1; }

.gallery-picker-thumb {
  position: relative;
  aspect-ratio: 1;
  border-radius: 5px;
  overflow: hidden;
  cursor: pointer;
  border: 2px solid transparent;
  transition: border-color 0.15s, transform 0.1s;

  img { width: 100%; height: 100%; object-fit: cover; display: block; }

  &:hover { border-color: rgba(179,157,219,0.55); transform: scale(1.03); }
  &--selected { border-color: #7c4dff; }
}

.gallery-picker-check {
  position: absolute;
  top: 3px; right: 3px;
  color: #b39ddb;
  font-size: 16px;
  filter: drop-shadow(0 0 3px #000);
}
</style>

<!-- Quill Snow dark-theme overrides — unscoped to reach injected DOM -->
<style lang="scss">
.page-wysiwyg {
  border-radius: 0 0 12px 12px;

  .ql-toolbar.ql-snow {
    background: #131325;
    border: none;
    border-bottom: 1px solid rgba(179,157,219,0.15);
    border-radius: 12px 12px 0 0;

    .ql-stroke              { stroke: rgba(255,255,255,0.55); }
    .ql-fill                { fill:   rgba(255,255,255,0.55); }
    .ql-picker-label        { color:  rgba(255,255,255,0.6);  }
    .ql-picker-label::before { color: rgba(255,255,255,0.6); }

    button:hover .ql-stroke,
    .ql-active  .ql-stroke  { stroke: #b39ddb; }
    button:hover .ql-fill,
    .ql-active  .ql-fill    { fill:   #b39ddb; }
    .ql-picker-label:hover,
    .ql-picker-label.ql-active { color: #b39ddb; }

    .ql-header .ql-picker-item[data-value="1"]::before { content: 'Heading 1'; font-size: 1.3em; font-weight: 700; }
    .ql-header .ql-picker-item[data-value="2"]::before { content: 'Heading 2'; font-size: 1.15em; font-weight: 600; }
    .ql-header .ql-picker-item[data-value="3"]::before { content: 'Heading 3'; }
    .ql-header .ql-picker-item:not([data-value])::before { content: 'Paragraph'; }
    .ql-header .ql-picker-label[data-value="1"]::before { content: 'H1'; }
    .ql-header .ql-picker-label[data-value="2"]::before { content: 'H2'; }
    .ql-header .ql-picker-label[data-value="3"]::before { content: 'H3'; }
    .ql-header .ql-picker-label:not([data-value])::before { content: 'Para'; }

    .ql-picker-options {
      background: #1a1a2e;
      border-color: rgba(179,157,219,0.2);
      .ql-picker-item        { color: rgba(255,255,255,0.7); }
      .ql-picker-item:hover,
      .ql-picker-item.ql-selected { color: #b39ddb; }
    }
  }

  .ql-container.ql-snow {
    background: #0d0d22;
    border: none;
    border-radius: 0 0 12px 12px;
    min-height: 420px;

    .ql-editor {
      color: #e0f2f1;
      font-size: 15px;
      line-height: 1.8;
      min-height: 420px;
      padding: 20px 24px;

      p          { margin-bottom: 0.9em; }
      h1         { font-size: 2em; font-weight: 900; color: #fff; margin: 1.2em 0 0.4em; }
      h2         { font-size: 1.55em; font-weight: 700; color: #fff; margin: 1em 0 0.3em; }
      h3         { font-size: 1.2em; font-weight: 600; color: #fff; margin: 0.9em 0 0.25em; }
      ul, ol     { padding-left: 1.4em; margin-bottom: 0.9em; }
      blockquote {
        border-left: 3px solid #7c4dff;
        color: rgba(255,255,255,0.6);
        padding-left: 12px; margin-left: 0;
      }
      a { color: #b39ddb; }
      img { max-width: 100%; border-radius: 8px; display: block; margin: 8px 0; }

      &.ql-blank::before { color: rgba(255,255,255,0.42) !important; font-style: italic; }
    }
  }
}

/* Inline figure inserted by the image dialog */
.ql-custom-figure {
  margin: 16px 0;
  display: block;

  img {
    max-width: 100%;
    border-radius: 8px;
    display: block;
  }
  a { display: block; }
}

.ql-img-caption {
  font-size: 12px;
  color: rgba(255,255,255,0.45);
  text-align: center;
  margin-top: 6px;
  font-style: italic;
}
</style>

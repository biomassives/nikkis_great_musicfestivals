<template>
  <q-page class="q-pa-lg">

    <!-- ══ LIST VIEW ══════════════════════════════════════════════════════ -->
    <template v-if="view === 'list'">

      <div class="row items-center q-mb-lg">
        <div>
          <div class="text-h5 text-purple-3">Pages</div>
          <div class="text-caption text-grey-5">Custom content pages — images, video, embeds, media links</div>
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
              <div class="text-caption text-grey-7 q-mt-xs">
                {{ page.blocks?.length ?? 0 }} block{{ (page.blocks?.length ?? 0) === 1 ? '' : 's' }}
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
      <q-card class="settings-card q-mb-xl">
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

      <!-- Block list -->
      <div class="text-subtitle2 text-purple-4 text-uppercase ls-2 q-mb-sm">Content Blocks</div>

      <div v-if="editingPage.blocks.length === 0"
        class="text-grey-6 text-center q-py-lg q-mb-md">
        No blocks yet — add one below.
      </div>

      <div v-for="(block, bi) in editingPage.blocks" :key="block.id" class="block-card q-mb-md">

        <!-- Block header row -->
        <div class="block-header">
          <div class="row items-center q-gutter-xs">
            <q-btn flat round dense icon="arrow_upward"   size="xs" color="grey-6"
              :disable="bi === 0"                             @click="moveBlock(bi, -1)" />
            <q-btn flat round dense icon="arrow_downward" size="xs" color="grey-6"
              :disable="bi === editingPage.blocks.length - 1" @click="moveBlock(bi,  1)" />
            <q-chip dense :color="blockMeta(block.type).color" text-color="white"
              :icon="blockMeta(block.type).icon" :label="blockMeta(block.type).label"
              size="sm" class="q-ml-xs" />
          </div>
          <q-btn flat round dense icon="delete" size="sm" color="red-4"
            @click="removeBlock(bi)" />
        </div>

        <!-- Block body -->
        <div class="block-body q-pa-md">

          <!-- HEADING -->
          <template v-if="block.type === 'heading'">
            <div class="row q-col-gutter-sm">
              <div class="col-auto" style="min-width:100px">
                <q-select v-model="block.level" :options="[1,2,3]" label="Level"
                  dark outlined dense label-color="purple-3" color="purple-3" />
              </div>
              <div class="col">
                <q-input v-model="block.text" label="Heading text"
                  dark outlined dense label-color="purple-3" color="purple-3" />
              </div>
            </div>
          </template>

          <!-- TEXT (WYSIWYG — Quill Snow) -->
          <template v-else-if="block.type === 'text'">
            <QuillEditor
              :content="block.content ?? ''"
              content-type="html"
              theme="snow"
              placeholder="Write your content here…"
              class="block-wysiwyg"
              @update:content="(v) => { block.content = String(v) }"
            />
          </template>

          <!-- IMAGE -->
          <template v-else-if="block.type === 'image'">
            <div class="row q-col-gutter-sm items-center q-mb-sm">
              <div class="col">
                <q-input v-model="block.url" label="Image URL"
                  dark outlined dense label-color="purple-3" color="purple-3" clearable />
              </div>
              <div class="col-auto">
                <q-btn color="purple-8" icon="upload" label="Upload" unelevated size="sm"
                  :loading="uploadingImg && uploadingBlockId === block.id"
                  @click="triggerBlockUpload(block.id)" />
              </div>
            </div>
            <div class="row q-col-gutter-sm q-mb-sm">
              <div class="col-8">
                <q-input v-model="block.caption" label="Caption (optional)"
                  dark outlined dense label-color="purple-3" color="purple-3" />
              </div>
              <div class="col-4">
                <q-select v-model="block.width" label="Width"
                  :options="[{label:'Full width',value:'full'},{label:'Wide',value:'wide'},{label:'Medium',value:'medium'}]"
                  option-value="value" option-label="label" emit-value map-options
                  dark outlined dense label-color="purple-3" color="purple-3" />
              </div>
            </div>
            <q-input v-model="block.link" label="Wrap in link (optional)"
              dark outlined dense label-color="purple-3" color="purple-3"
              hint="Makes the image clickable" />
            <div v-if="block.url" class="q-mt-sm">
              <img :src="block.url" style="max-height:110px; border-radius:6px; object-fit:cover;" />
            </div>
          </template>

          <!-- VIDEO -->
          <template v-else-if="block.type === 'video'">
            <q-input v-model="block.url" label="Video URL"
              dark outlined dense label-color="purple-3" color="purple-3"
              hint="YouTube, Vimeo, Internet Archive, or direct .mp4 URL"
              class="q-mb-sm" />
            <q-input v-model="block.caption" label="Caption (optional)"
              dark outlined dense label-color="purple-3" color="purple-3" />
          </template>

          <!-- IFRAME / EMBED -->
          <template v-else-if="block.type === 'iframe'">
            <q-input v-model="block.url" label="Embed URL"
              dark outlined dense label-color="purple-3" color="purple-3"
              hint="nugs.net, archive.org, Bandcamp, SoundCloud, or any embeddable URL"
              class="q-mb-sm" />
            <div class="row q-col-gutter-sm">
              <div class="col">
                <q-input v-model="block.iframe_title" label="Label / description"
                  dark outlined dense label-color="purple-3" color="purple-3" />
              </div>
              <div class="col-auto" style="min-width:140px">
                <q-input v-model.number="block.height" label="Height (px)" type="number"
                  dark outlined dense label-color="purple-3" color="purple-3" />
              </div>
            </div>
          </template>

          <!-- MEDIA LINK -->
          <template v-else-if="block.type === 'media_link'">
            <div class="row q-col-gutter-sm q-mb-sm">
              <div class="col-8">
                <q-input v-model="block.url" label="Destination URL"
                  dark outlined dense label-color="purple-3" color="purple-3" />
              </div>
              <div class="col-4">
                <q-input v-model="block.site_name" label="Site (e.g. nugs.net)"
                  dark outlined dense label-color="purple-3" color="purple-3" />
              </div>
            </div>
            <q-input v-model="block.title" label="Link title"
              dark outlined dense label-color="purple-3" color="purple-3" class="q-mb-sm" />
            <q-input v-model="block.description" label="Short description"
              dark outlined dense label-color="purple-3" color="purple-3" class="q-mb-sm" />
            <q-input v-model="block.thumbnail" label="Thumbnail image URL (optional)"
              dark outlined dense label-color="purple-3" color="purple-3" />
          </template>

          <!-- DIVIDER -->
          <template v-else-if="block.type === 'divider'">
            <div class="text-caption text-grey-6">Horizontal divider line — no settings needed.</div>
          </template>

        </div>
      </div>

      <!-- Add Block toolbar -->
      <div class="add-block-section q-mb-xl">
        <div class="text-caption text-purple-5 text-uppercase ls-1 q-mb-sm">Add Block</div>
        <div class="row q-gutter-sm flex-wrap">
          <q-btn v-for="bt in BLOCK_TYPES" :key="bt.type"
            :icon="bt.icon" :label="bt.label" :color="bt.color"
            outline size="sm" @click="addBlock(bt.type)" />
        </div>
      </div>

      <div class="row justify-end q-mb-xl">
        <q-btn color="purple-5" unelevated icon="save" label="Save Page"
          :loading="saving" @click="savePage" />
      </div>

    </template>

    <!-- Shared hidden file input for block image uploads -->
    <input ref="blockFileInput" type="file" accept="image/*"
      class="hidden" @change="handleBlockUpload" />

  </q-page>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { supabase } from 'src/lib/supabase'
import { QuillEditor } from '@vueup/vue-quill'
import '@vueup/vue-quill/dist/vue-quill.snow.css'

const $q = useQuasar()

// ── Types ──────────────────────────────────────────────────────────────────
type BlockType = 'heading' | 'text' | 'image' | 'video' | 'iframe' | 'media_link' | 'divider'

interface Block {
  id:            string
  type:          BlockType
  level?:        1 | 2 | 3       // heading
  text?:         string           // heading
  content?:      string           // text paragraph
  url?:          string           // image / video / iframe / media_link
  caption?:      string           // image / video
  width?:        'full' | 'wide' | 'medium'  // image
  link?:         string           // image (wraps in <a>)
  iframe_title?: string           // iframe
  height?:       number           // iframe
  title?:        string           // media_link
  description?:  string           // media_link
  thumbnail?:    string           // media_link
  site_name?:    string           // media_link
}

interface Page {
  id?:        string
  slug:       string
  title:      string
  blocks:     Block[]
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

// Default nav items used as immediate options before Supabase loads
const DEFAULT_NAV = [
  { title: 'Photography', link: '/photography' },
  { title: 'Maps',        link: '/maps'         },
  { title: 'Support',     link: '/support'      },
  { title: 'Merch',       link: '/merch'        },
  { title: 'News',        link: '/news'         },
]
const navParentOptions = ref<{ label: string; value: string }[]>(
  DEFAULT_NAV.map(i => ({ label: `${i.title} (${i.link})`, value: i.link }))
)


const editingPage = ref<Page>({
  slug: '', title: '', blocks: [], published: false, nav_parent: null,
})

let slugTouched: boolean = false
function onSlugInput() { slugTouched = true }

// ── Upload state ───────────────────────────────────────────────────────────
const blockFileInput   = ref<HTMLInputElement | null>(null)
const uploadingBlockId = ref('')
const uploadingImg     = ref(false)

// ── Constants ──────────────────────────────────────────────────────────────
const BLOCK_TYPES = [
  { type: 'heading'    as BlockType, icon: 'title',           label: 'Heading',    color: 'purple-8'     },
  { type: 'text'       as BlockType, icon: 'notes',           label: 'Text',       color: 'blue-grey-8'  },
  { type: 'image'      as BlockType, icon: 'image',           label: 'Image',      color: 'teal-8'       },
  { type: 'video'      as BlockType, icon: 'play_circle',     label: 'Video',      color: 'deep-orange-8'},
  { type: 'iframe'     as BlockType, icon: 'code',            label: 'Embed',      color: 'indigo-8'     },
  { type: 'media_link' as BlockType, icon: 'open_in_new',     label: 'Media Link', color: 'green-8'      },
  { type: 'divider'    as BlockType, icon: 'horizontal_rule', label: 'Divider',    color: 'grey-8'       },
]

const BLOCK_META: Record<BlockType, { icon: string; label: string; color: string }> = {
  heading:    { icon: 'title',           label: 'Heading',    color: 'purple-7'    },
  text:       { icon: 'notes',           label: 'Text',       color: 'blue-grey-7' },
  image:      { icon: 'image',           label: 'Image',      color: 'teal-7'      },
  video:      { icon: 'play_circle',     label: 'Video',      color: 'deep-orange-7'},
  iframe:     { icon: 'code',            label: 'Embed',      color: 'indigo-7'    },
  media_link: { icon: 'open_in_new',     label: 'Media Link', color: 'green-7'     },
  divider:    { icon: 'horizontal_rule', label: 'Divider',    color: 'grey-7'      },
}

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
CREATE POLICY "Auth manages all pages"
  ON custom_pages FOR ALL USING (auth.role() = 'authenticated');`

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

// Auto-save to localStorage while editing (debounced 800 ms)
let draftTimer: ReturnType<typeof setTimeout> | null = null
watch(editingPage, () => {
  if (view.value !== 'editor') return
  if (draftTimer) clearTimeout(draftTimer)
  draftTimer = setTimeout(() => {
    localStorage.setItem(draftKey(editingPage.value.id), JSON.stringify(editingPage.value))
  }, 800)
}, { deep: true })

// ── Block helpers ──────────────────────────────────────────────────────────
function blockMeta(type: BlockType) { return BLOCK_META[type] }

function addBlock(type: BlockType) {
  const id = `${Date.now()}-${Math.random().toString(36).slice(2)}`
  const defaults: Record<BlockType, Partial<Block>> = {
    heading:    { level: 2, text: '' },
    text:       { content: '' },
    image:      { url: '', width: 'full', caption: '' },
    video:      { url: '', caption: '' },
    iframe:     { url: '', height: 500, iframe_title: '' },
    media_link: { url: '', title: '', site_name: '' },
    divider:    {},
  }
  editingPage.value.blocks.push({ id, type, ...defaults[type] })
}

function removeBlock(i: number) { editingPage.value.blocks.splice(i, 1) }

function moveBlock(i: number, dir: -1 | 1) {
  const arr = [...editingPage.value.blocks]
  const tmp = arr[i]!; arr[i] = arr[i + dir]!; arr[i + dir] = tmp
  editingPage.value.blocks = arr
}

// ── Slug auto-generate ─────────────────────────────────────────────────────
function autoSlug(title: string) {
  if (slugTouched || editingPage.value.id) return
  editingPage.value.slug = title
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
}

// ── Image upload (shared input for all image blocks) ───────────────────────
function triggerBlockUpload(blockId: string) {
  uploadingBlockId.value = blockId
  blockFileInput.value?.click()
}

async function handleBlockUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file || !uploadingBlockId.value) return
  uploadingImg.value = true
  const ext  = file.name.split('.').pop() ?? 'jpg'
  const path = `pages/${Date.now()}.${ext}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    const block = editingPage.value.blocks.find(b => b.id === uploadingBlockId.value)
    if (block) block.url = data.publicUrl
  }
  uploadingImg.value = false
  uploadingBlockId.value = ''
  if (blockFileInput.value) blockFileInput.value.value = ''
}

// ── Navigation ─────────────────────────────────────────────────────────────
function newPage() {
  slugTouched = false
  editingPage.value = { slug: '', title: '', blocks: [], published: false, nav_parent: null }
  checkDraft(undefined)
  view.value = 'editor'
}

function editPage(page: Page) {
  slugTouched = true
  editingPage.value = { ...page, blocks: page.blocks.map(b => ({ ...b })) }
  hasDraft.value = false; localDraft.value = null
  checkDraft(page.id)
  view.value = 'editor'
}

function goBack() {
  view.value = 'list'
}

// ── Save / Delete ──────────────────────────────────────────────────────────
async function savePage() {
  if (!editingPage.value.slug || !editingPage.value.title) {
    saveError.value = 'Title and slug are required.'
    return
  }
  saving.value  = true
  saveError.value = ''

  const payload = {
    slug:       editingPage.value.slug,
    title:      editingPage.value.title,
    blocks:     editingPage.value.blocks,
    published:  editingPage.value.published,
    nav_parent: editingPage.value.nav_parent || null,
    updated_at: new Date().toISOString(),
  }

  if (editingPage.value.id) {
    const { error } = await supabase.from('custom_pages')
      .update(payload).eq('id', editingPage.value.id)
    if (error) { saveError.value = error.message; saving.value = false; return }
    const idx = pages.value.findIndex(p => p.id === editingPage.value.id)
    if (idx !== -1) Object.assign(pages.value[idx]!, { ...payload, id: editingPage.value.id })
  } else {
    const { data, error } = await supabase.from('custom_pages')
      .insert(payload).select().single()
    if (error) { saveError.value = error.message; saving.value = false; return }
    const created = data as Page
    editingPage.value.id = created.id as string
    pages.value.unshift(created)
    // move draft from 'new' key to actual id key
    localStorage.removeItem(draftKey(undefined))
  }

  // Clear the draft for this page now that it's saved
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
async function copySetupSql() {
  await navigator.clipboard.writeText(SETUP_SQL)
  $q.notify({ message: 'SQL copied to clipboard', color: 'teal', position: 'top', icon: 'check' })
}

// ── Load ───────────────────────────────────────────────────────────────────
async function loadNavOptions() {
  const { data } = await supabase
    .from('site_settings').select('value')
    .eq('key', 'nav_config').maybeSingle()
  // If a saved nav config exists, use it; otherwise the hardcoded defaults stay
  if (Array.isArray(data?.value) && (data?.value as unknown[]).length) {
    navParentOptions.value = (data?.value as { title: string; link: string }[])
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
    pages.value = (data as Page[]) ?? []
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

.block-card {
  background: #1a1a2e;
  border: 1px solid rgba(179,157,219,0.18);
  border-radius: 10px;
  overflow: hidden;
  transition: border-color 0.15s;
  &:hover { border-color: rgba(179,157,219,0.38); }
}

.block-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 8px 12px;
  background: rgba(179,157,219,0.05);
  border-bottom: 1px solid rgba(179,157,219,0.1);
}

.block-body { background: transparent; }


.add-block-section {
  padding: 16px;
  background: rgba(179,157,219,0.04);
  border: 1px dashed rgba(179,157,219,0.18);
  border-radius: 10px;
}

.setup-banner  { background: rgba(255,179,0,0.08); border: 1px solid rgba(255,179,0,0.3); color: #e0f2f1; }
.draft-banner  { background: rgba(255,179,0,0.08); border: 1px solid rgba(255,179,0,0.25); color: #fff8e1; }
.error-banner  { background: rgba(255,82,82,0.1);  border: 1px solid rgba(255,82,82,0.3);  color: #ffcdd2; }

.ls-2 { letter-spacing: 2px; }
.ls-1 { letter-spacing: 1.5px; }
.hidden { display: none; }

code {
  background: rgba(255,255,255,0.08); padding: 1px 5px;
  border-radius: 3px; font-size: 11px; color: #b39ddb;
}
</style>

<!-- Quill Snow dark-theme overrides — must be unscoped to reach injected DOM -->
<style lang="scss">
.block-wysiwyg {
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid rgba(179,157,219,0.25);

  .ql-toolbar.ql-snow {
    background: #131325;
    border-color: rgba(179,157,219,0.22);

    .ql-stroke              { stroke: rgba(255,255,255,0.55); }
    .ql-fill                { fill:   rgba(255,255,255,0.55); }
    .ql-picker-label        { color:  rgba(255,255,255,0.6);  }
    .ql-picker-label::before { color: rgba(255,255,255,0.6);  }

    button:hover .ql-stroke,
    .ql-active  .ql-stroke  { stroke: #b39ddb; }
    button:hover .ql-fill,
    .ql-active  .ql-fill    { fill:   #b39ddb; }
    .ql-picker-label:hover,
    .ql-picker-label.ql-active { color: #b39ddb; }

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
    border-color: rgba(179,157,219,0.22);
    min-height: 160px;

    .ql-editor {
      color: #e0f2f1;
      font-size: 15px;
      line-height: 1.75;
      min-height: 160px;

      p         { margin-bottom: 0.8em; }
      h2, h3, h4 { color: #fff; margin: 1em 0 0.3em; }
      ul, ol     { padding-left: 1.4em; }
      blockquote {
        border-left: 3px solid #7c4dff;
        color: rgba(255,255,255,0.6);
        padding-left: 12px; margin-left: 0;
      }
      a { color: #b39ddb; }

      &.ql-blank::before { color: rgba(255,255,255,0.25); font-style: italic; }
    }
  }
}
</style>

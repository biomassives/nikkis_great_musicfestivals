<template>
  <q-page class="q-pa-lg">
    <div class="row items-center q-mb-lg">
      <div>
        <div class="text-h5 text-teal-3">Story Overlay Editor</div>
        <div class="text-caption text-grey-5">Edit the "Our Full Story" full-screen overlay</div>
      </div>
      <q-space />
      <q-btn color="teal" unelevated icon="save" label="Save" :loading="saving" @click="save" />
    </div>

    <q-banner v-if="saved" rounded class="save-banner q-mb-lg">
      <template #avatar><q-icon name="check_circle" color="teal-4" /></template>
      Changes saved successfully.
    </q-banner>

    <!-- ── IMAGE PANEL ─────────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Image Panel</div>
    <q-card class="settings-card q-mb-xl">
      <q-card-section class="q-gutter-md">

        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Left-panel image</div>
        <div class="row q-col-gutter-md items-center">
          <div class="col">
            <q-input
              v-model="form.image_url"
              label="Image URL"
              dark outlined dense label-color="teal-3" color="teal-3"
              clearable
            />
          </div>
          <div class="col-auto">
            <q-btn color="teal-8" icon="upload" label="Upload" unelevated
              :loading="uploadingImage" @click="triggerImageUpload" />
            <input ref="imageFileInput" type="file" accept="image/*" class="hidden" @change="handleImageUpload" />
          </div>
        </div>
        <div v-if="form.image_url" class="q-mt-xs">
          <img :src="form.image_url" class="img-preview" />
          <div class="text-caption text-grey-5 q-mt-xs">Preview</div>
        </div>

        <q-input
          v-model="form.image_caption"
          label="Image caption (bottom-left)"
          dark outlined dense label-color="teal-3" color="teal-3"
        />

      </q-card-section>
    </q-card>

    <!-- ── TEXT CONTENT ────────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Text Content</div>
    <q-card class="settings-card q-mb-xl">
      <q-card-section class="q-gutter-md">

        <q-input
          v-model="form.eyebrow"
          label="Eyebrow (small uppercase text above title)"
          dark outlined dense label-color="teal-3" color="teal-3"
        />

        <q-input
          v-model="form.title"
          label="Title (use \n for line break)"
          type="textarea"
          :rows="2"
          autogrow
          dark outlined label-color="teal-3" color="teal-3"
          hint="Line breaks render as <br> in the overlay"
        />

        <q-input
          v-model="form.closing"
          label="Closing line (italic, gold)"
          dark outlined dense label-color="teal-3" color="teal-3"
        />

      </q-card-section>
    </q-card>

    <!-- ── BODY ────────────────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Body</div>
    <q-card class="settings-card q-mb-lg">
      <q-card-section>
        <QuillEditor
          :content="form.content"
          content-type="html"
          theme="snow"
          :options="QUILL_OPTIONS"
          placeholder="Write the story here — use headings, bold, lists, links…"
          class="story-wysiwyg"
          @update:content="(v) => { form.content = String(v) }"
        />
      </q-card-section>
    </q-card>

    <div class="row justify-end q-mb-xl">
      <q-btn color="teal" unelevated icon="save" label="Save" :loading="saving" @click="save" />
    </div>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import { QuillEditor } from '@vueup/vue-quill'
import '@vueup/vue-quill/dist/vue-quill.snow.css'
import { DEFAULT_STORY_CONTENT } from 'instance/lovelight/story-default'
import { config as instanceConfig } from 'instance/lovelight/config'
import { storageBucket } from 'src/lib/instance'

const QUILL_OPTIONS = {
  modules: {
    toolbar: [
      [{ header: [1, 2, 3, false] }],
      ['bold', 'italic', 'underline'],
      ['blockquote'],
      [{ list: 'ordered' }, { list: 'bullet' }],
      ['link'],
      ['clean'],
    ],
  },
}

const saving         = ref(false)
const saved          = ref(false)
const uploadingImage = ref(false)
const imageFileInput = ref<HTMLInputElement | null>(null)

const form = reactive({
  image_url:     instanceConfig.defaults.story_image_url,
  image_caption: instanceConfig.defaults.story_image_caption,
  eyebrow:       instanceConfig.defaults.story_eyebrow,
  title:         instanceConfig.defaults.story_title,
  content:       DEFAULT_STORY_CONTENT,
  closing:       instanceConfig.defaults.story_closing,
})

function triggerImageUpload() {
  imageFileInput.value?.click()
}

async function handleImageUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingImage.value = true
  const ext  = file.name.split('.').pop() ?? 'jpg'
  const path = `story/story-img-${Date.now()}.${ext}`
  const { error } = await supabase.storage.from(storageBucket()).upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from(storageBucket()).getPublicUrl(path)
    form.image_url = data.publicUrl
  }
  uploadingImage.value = false
}

async function load() {
  const { data } = await supabase
    .from('site_settings')
    .select('value')
    .eq('key', 'story_overlay')
    .limit(1)
  const row = data?.[0]
  if (row?.value && typeof row.value === 'object') {
    const v = row.value as Record<string, unknown>
    if (typeof v.image_url     === 'string') form.image_url     = v.image_url
    if (typeof v.image_caption === 'string') form.image_caption = v.image_caption
    if (typeof v.eyebrow       === 'string') form.eyebrow       = v.eyebrow
    if (typeof v.title         === 'string') form.title         = v.title
    if (typeof v.closing   === 'string') form.closing   = v.closing
    // New single-content field; fall back to joining legacy paragraphs array
    if (typeof v.content === 'string') {
      form.content = v.content
    } else if (Array.isArray(v.paragraphs) && (v.paragraphs as unknown[]).length > 0) {
      form.content = (v.paragraphs as string[]).map(p => `<p>${p}</p>`).join('')
    }
  }
}

async function save() {
  saving.value = true
  saved.value  = false
  await supabase.from('site_settings').upsert({
    key: 'story_overlay',
    value: {
      image_url:     form.image_url,
      image_caption: form.image_caption,
      eyebrow:       form.eyebrow,
      title:         form.title,
      content:       form.content,
      closing:       form.closing,
    },
    updated_at: new Date().toISOString(),
  })
  saving.value = false
  saved.value  = true
  setTimeout(() => { saved.value = false }, 3000)
}

onMounted(load)
</script>

<style lang="scss" scoped>
.settings-card {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.18);
  border-radius: 12px;
}
.save-banner { background: rgba(77,182,172,0.1); border: 1px solid rgba(77,182,172,0.3); color: #e0f2f1; }
.ls-2 { letter-spacing: 2px; }
.ls-1 { letter-spacing: 1.5px; }
.hidden { display: none; }
.img-preview { max-height: 160px; max-width: 100%; border-radius: 8px; object-fit: cover; }
.para-row { padding: 12px; background: rgba(77,182,172,0.04); border: 1px solid rgba(77,182,172,0.12); border-radius: 8px; }
.para-label { line-height: 28px; color: #4db6ac; min-width: 20px; }
</style>

<style>
/* ── Dark Quill theme for Story editor ─────────────────────── */
.story-wysiwyg .ql-toolbar {
  background: #12122a;
  border: 1px solid rgba(77,182,172,0.25) !important;
  border-bottom: none !important;
  border-radius: 6px 6px 0 0;
}
.story-wysiwyg .ql-toolbar .ql-stroke { stroke: rgba(255,255,255,0.55); }
.story-wysiwyg .ql-toolbar .ql-fill  { fill:   rgba(255,255,255,0.55); }
.story-wysiwyg .ql-toolbar .ql-picker-label { color: rgba(255,255,255,0.55); }
.story-wysiwyg .ql-toolbar button:hover .ql-stroke,
.story-wysiwyg .ql-toolbar .ql-active  .ql-stroke { stroke: #4db6ac; }
.story-wysiwyg .ql-toolbar button:hover .ql-fill,
.story-wysiwyg .ql-toolbar .ql-active  .ql-fill  { fill: #4db6ac; }
.story-wysiwyg .ql-container {
  background: #0e0e26;
  border: 1px solid rgba(77,182,172,0.25) !important;
  border-radius: 0 0 6px 6px;
  min-height: 120px;
}
.story-wysiwyg .ql-editor {
  color: rgba(255,255,255,0.82);
  font-size: 15px;
  line-height: 1.75;
  min-height: 120px;
}
.story-wysiwyg .ql-editor.ql-blank::before {
  color: rgba(255,255,255,0.25);
  font-style: italic;
}
</style>

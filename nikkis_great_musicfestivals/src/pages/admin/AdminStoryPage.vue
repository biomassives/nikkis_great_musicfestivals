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

    <!-- ── PARAGRAPHS ──────────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Body Paragraphs</div>
    <q-card class="settings-card q-mb-lg">
      <q-card-section>
        <div class="text-caption text-grey-5 q-mb-md">
          Each paragraph supports rich text — bold, italic, links, lists.
        </div>

        <div v-for="(para, i) in form.paragraphs" :key="i" class="para-row q-mb-md">
          <div class="row items-start q-gutter-xs q-mb-xs">
            <div class="text-caption text-teal-5 text-weight-bold para-label">{{ i + 1 }}.</div>
            <q-space />
            <q-btn flat dense round icon="arrow_upward"   color="grey-5" size="sm" :disable="i === 0"                          @click="moveParagraph(i, -1)" />
            <q-btn flat dense round icon="arrow_downward" color="grey-5" size="sm" :disable="i === form.paragraphs.length - 1" @click="moveParagraph(i,  1)" />
            <q-btn flat dense round icon="delete"         color="red-4"  size="sm"                                             @click="removeParagraph(i)" />
          </div>
          <QuillEditor
            :content="form.paragraphs[i] ?? ''"
            content-type="html"
            theme="snow"
            class="story-wysiwyg"
            @update:content="(v) => { form.paragraphs[i] = String(v) }"
          />
        </div>

        <q-btn
          icon="add"
          label="Add Paragraph"
          color="teal-7"
          outline
          size="sm"
          class="q-mt-sm"
          @click="addParagraph"
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

const saving         = ref(false)
const saved          = ref(false)
const uploadingImage = ref(false)
const imageFileInput = ref<HTMLInputElement | null>(null)

const DEFAULT_PARAGRAPHS: string[] = [
  'We first followed the circus in the summer of 1991, somewhere between Buckeye Lake and Deer Creek, when the corn was high and the highway smelled of rain and burning sage. By the time the boys kicked into the second set, ten thousand souls had abandoned their ordinary selves in the grass — trading the weight of the week for something the setlist could never quite contain. A door swinging open in the middle of a Tuesday in July.',
  "Nikki's Great Music Festivals grew out of that first lot. Not the parking lot exactly — that particular sacred, chaotic marketplace of grilled cheese and miracles — but the feeling it generated: that community is not a thing you join but a thing you build, stake by stake, set by set, across the geography of a country that reveals itself differently from the back of a tour bus than it does from an office window.",
  "The mission was never complicated. Get people to the music. Get the music to people who couldn't get to it on their own. Senior communities in rural Tennessee deserve to hear live bluegrass with the same urgency as a festival field in Colorado. The joy is not scarce. It only needs moving.",
  'We have now logged eleven summers, forty-two states, and more campground friendships than any spreadsheet could hold. The artists who have let us carry their work into living rooms and rec halls and outdoor stages cut into hillsides — Billy Strings reeling off a twenty-minute reprise at elevation, Leftover Salmon burning through \u201cEuphoria\u201d while lightning flickered on the western ridge, the Stringdusters playing an unannounced third set because nobody wanted to go home — these are the facts our calendar doesn\u2019t quite capture.',
  'Every trail we walk and every show we document feeds back into the same current. The photography is evidence. The maps are memory. The newsletter is the letter you write home when home has temporarily relocated to a meadow in the mountains.',
  'What the calendar does capture is this: we keep going. The road is the purpose. The faces at the front of the stage and the back of the lot are the same faces — wide open, ears out, looking for the note that unlocks whatever needed unlocking.',
]

const form = reactive({
  image_url:     'https://picsum.photos/seed/mountain-evening/900/1400',
  image_caption: 'On the road',
  eyebrow:       'Our Full Story',
  title:         'The Music\nNever Stopped',
  paragraphs:    [...DEFAULT_PARAGRAPHS] as string[],
  closing:       'Come with us.',
})

function addParagraph() {
  form.paragraphs.push('')
}

function removeParagraph(i: number) {
  form.paragraphs.splice(i, 1)
}

function moveParagraph(i: number, dir: -1 | 1) {
  const arr = [...form.paragraphs]
  const tmp = arr[i]!
  arr[i] = arr[i + dir]!
  arr[i + dir] = tmp
  form.paragraphs = arr
}

function triggerImageUpload() {
  imageFileInput.value?.click()
}

async function handleImageUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingImage.value = true
  const ext  = file.name.split('.').pop() ?? 'jpg'
  const path = `story/story-img-${Date.now()}.${ext}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    form.image_url = data.publicUrl
  }
  uploadingImage.value = false
}

async function load() {
  const { data } = await supabase
    .from('site_settings')
    .select('value')
    .eq('key', 'story_overlay')
    .maybeSingle()
  if (data?.value && typeof data.value === 'object') {
    const v = data.value as Record<string, unknown>
    if (typeof v.image_url     === 'string') form.image_url     = v.image_url
    if (typeof v.image_caption === 'string') form.image_caption = v.image_caption
    if (typeof v.eyebrow       === 'string') form.eyebrow       = v.eyebrow
    if (typeof v.title         === 'string') form.title         = v.title
    if (typeof v.closing       === 'string') form.closing       = v.closing
    if (Array.isArray(v.paragraphs) && (v.paragraphs as unknown[]).length > 0) {
      form.paragraphs = v.paragraphs as string[]
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
      paragraphs:    [...form.paragraphs],
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

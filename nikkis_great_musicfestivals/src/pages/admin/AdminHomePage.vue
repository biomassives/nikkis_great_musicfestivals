<template>
  <q-page class="q-pa-lg">
    <div class="row items-center q-mb-lg">
      <div>
        <div class="text-h5 text-teal-3">Homepage Manager</div>
        <div class="text-caption text-grey-5">Content · Artists · Appearance · SEO</div>
      </div>
      <q-space />
      <q-btn color="teal" unelevated icon="save" label="Save All" :loading="saving" @click="saveAll" />
    </div>

    <q-banner v-if="saved" rounded class="save-banner q-mb-lg">
      <template #avatar><q-icon name="check_circle" color="teal-4" /></template>
      Changes saved successfully.
    </q-banner>

    <!-- ── CONTENT ─────────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Page Content</div>
    <q-card class="settings-card q-mb-xl">
      <q-card-section class="q-gutter-md">

        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Hero</div>
        <q-input v-model="content.hero_title"
          label="Hero Title" dark outlined dense label-color="teal-3" color="teal-3" />
        <q-input v-model="content.mission_statement"
          label="Mission Statement" type="textarea" autogrow dark outlined dense
          label-color="teal-3" color="teal-3"
          hint="Shown as the blockquote under the title" />
        <div class="row q-col-gutter-md">
          <div class="col-6">
            <q-input v-model="content.cta_story_label" label="CTA — Story button" dark outlined dense label-color="teal-3" color="teal-3" />
          </div>
          <div class="col-6">
            <q-input v-model="content.cta_tour_label" label="CTA — Tour button" dark outlined dense label-color="teal-3" color="teal-3" />
          </div>
        </div>

        <q-separator dark class="q-my-sm" />
        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Artists Section Header</div>
        <div class="row q-col-gutter-md">
          <div class="col-6">
            <q-input v-model="content.artists_label" label="Section eyebrow" dark outlined dense label-color="teal-3" color="teal-3" />
          </div>
          <div class="col-6">
            <q-input v-model="content.artists_title" label="Section heading" dark outlined dense label-color="teal-3" color="teal-3" />
          </div>
        </div>

        <q-separator dark class="q-my-sm" />
        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Newsletter Section</div>
        <q-input v-model="content.subscribe_title" label="Subscribe heading" dark outlined dense label-color="teal-3" color="teal-3" />
        <q-input v-model="content.subscribe_body"
          label="Subscribe description" type="textarea" autogrow dark outlined dense
          label-color="teal-3" color="teal-3" />

      </q-card-section>
    </q-card>

    <!-- ── WELCOME SPLASH ─────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Welcome Splash</div>
    <q-card class="settings-card q-mb-xl">
      <q-card-section class="q-gutter-md">

        <div class="text-caption text-grey-5 q-mb-xs">
          Full-screen overlay shown once per browser session when visitors first arrive.
        </div>

        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Background Image</div>
        <div class="row q-col-gutter-md items-center">
          <div class="col">
            <q-input v-model="welcome.image_url"
              label="Background image URL"
              dark outlined dense label-color="teal-3" color="teal-3" clearable />
          </div>
          <div class="col-auto">
            <q-btn color="teal-8" icon="upload" label="Upload" unelevated
              :loading="uploadingWelcome" @click="triggerWelcomeUpload" />
            <input ref="welcomeFileInput" type="file" accept="image/*" class="hidden" @change="handleWelcomeUpload" />
          </div>
        </div>
        <div v-if="welcome.image_url" class="q-mt-xs">
          <img :src="welcome.image_url" class="bg-preview" />
        </div>

        <q-separator dark class="q-my-sm" />
        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Text</div>
        <q-input v-model="welcome.eyebrow"
          label="Eyebrow (small text above title)"
          dark outlined dense label-color="teal-3" color="teal-3" />
        <q-input v-model="welcome.title"
          label="Title (use ↵ Enter for line breaks)"
          type="textarea" :rows="2" autogrow
          dark outlined label-color="teal-3" color="teal-3" />
        <q-input v-model="welcome.tagline"
          label="Tagline (italic quote below title)"
          type="textarea" :rows="2" autogrow
          dark outlined label-color="teal-3" color="teal-3" />

        <q-separator dark class="q-my-sm" />
        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Button</div>
        <div class="row q-col-gutter-md items-center">
          <div class="col">
            <q-input v-model="welcome.button_label"
              label="Button label"
              dark outlined dense label-color="teal-3" color="teal-3" />
          </div>
          <div class="col-auto column items-center" style="gap:4px">
            <div class="text-caption text-grey-5">Color</div>
            <input type="color" v-model="welcome.button_color" class="color-picker" title="Button border & text color" />
          </div>
        </div>
        <!-- Live preview -->
        <div class="welcome-preview">
          <div class="wp-eyebrow">{{ welcome.eyebrow }}</div>
          <div class="wp-title" style="white-space: pre-line">{{ welcome.title }}</div>
          <div class="wp-tagline">{{ welcome.tagline }}</div>
          <button class="wp-btn" :style="`border-color:${welcome.button_color}; color:${welcome.button_color}`">
            {{ welcome.button_label }} →
          </button>
        </div>

      </q-card-section>
    </q-card>

    <!-- ── ARTIST PROFILES ─────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Artist Profiles</div>
    <q-card class="settings-card q-mb-xl">
      <q-card-section>
        <div class="row items-center q-mb-md">
          <div class="text-caption text-grey-5 col">Each artist becomes an accordion panel on the homepage</div>
          <q-btn icon="add" label="Add Artist" color="teal-7" outline size="sm" @click="openAddArtist" />
        </div>
        <q-list separator dark style="background:transparent">
          <q-item v-for="(artist, i) in artists" :key="artist.id" dense class="q-py-sm">
            <q-item-section avatar>
              <q-icon :name="artist.icon || 'music_note'" :color="artist.icon_color" size="22px" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-grey-2 text-weight-medium">{{ artist.name }}</q-item-label>
              <q-item-label caption class="text-grey-6">{{ artist.subtitle }}</q-item-label>
            </q-item-section>
            <q-item-section side>
              <div class="row q-gutter-xs">
                <q-btn flat dense round icon="arrow_upward"   color="grey-5" size="sm" :disable="i === 0"                   @click="moveArtist(i, -1)" />
                <q-btn flat dense round icon="arrow_downward" color="grey-5" size="sm" :disable="i === artists.length - 1" @click="moveArtist(i,  1)" />
                <q-btn flat dense round icon="edit"   color="teal-4" size="sm" @click="openEditArtist(i)" />
                <q-btn flat dense round icon="delete" color="red-4"  size="sm" @click="removeArtist(i)" :disable="artists.length <= 1" />
              </div>
            </q-item-section>
          </q-item>
          <q-item v-if="artists.length === 0">
            <q-item-section class="text-grey-6 text-center q-py-md">No artists yet</q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>

    <!-- ── APPEARANCE ──────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Background & Theme</div>
    <q-card class="settings-card q-mb-xl">
      <q-card-section class="q-gutter-md">

        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Background Image</div>
        <div class="text-caption text-grey-6 q-mb-sm">
          Paste a URL or upload. Overlays on top of the SVG pattern.
        </div>
        <div class="row q-col-gutter-md items-center">
          <div class="col">
            <q-input v-model="appearance.bg_image_url"
              label="Image URL (leave blank for SVG pattern only)"
              dark outlined dense label-color="teal-3" color="teal-3"
              clearable />
          </div>
          <div class="col-auto">
            <q-btn color="teal-8" icon="upload" label="Upload" unelevated
              :loading="uploadingBg" @click="triggerBgUpload" />
            <input ref="bgFileInput" type="file" accept="image/*" class="hidden" @change="handleBgUpload" />
          </div>
        </div>
        <div v-if="appearance.bg_image_url" class="q-mt-xs">
          <img :src="appearance.bg_image_url" class="bg-preview" />
          <div class="text-caption text-grey-5 q-mt-xs">Preview</div>
        </div>

        <q-separator dark class="q-my-sm" />
        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">SVG Pattern</div>
        <q-select v-model="appearance.bg_variant"
          :options="bgVariantOptions" emit-value map-options
          label="Background pattern" dark outlined dense label-color="teal-3" color="teal-3" />
        <q-item dark dense class="q-pa-none">
          <q-item-section>
            <q-item-label class="text-grey-3">Pattern opacity</q-item-label>
            <q-item-label caption class="text-grey-6">{{ Math.round((appearance.bg_opacity ?? 0.09) * 100) }}%</q-item-label>
          </q-item-section>
          <q-item-section>
            <q-slider v-model="appearance.bg_opacity" :min="0.02" :max="0.3" :step="0.01"
              color="teal-3" dark />
          </q-item-section>
        </q-item>

        <q-separator dark class="q-my-sm" />
        <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Footer Scene</div>
        <q-toggle v-model="appearance.footer_default_night"
          label="Default to night scene on load"
          color="teal-3" dark />
        <div class="text-caption text-grey-6">Day/night still follows the site's dark-mode toggle; this controls the initial state for visitors whose preference is unknown.</div>

      </q-card-section>
    </q-card>

    <!-- ── SEO & SOCIAL ────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">SEO & Social</div>

    <q-list bordered class="seo-accordion rounded-borders q-mb-xl">

      <q-expansion-item icon="search" label="Search engine basics" header-class="seo-header" default-opened>
        <q-card class="seo-card">
          <q-card-section class="q-gutter-md">
            <q-input v-model="seo.site_name" label="Site name" dark outlined dense label-color="teal-3" color="teal-3" />
            <q-input v-model="seo.meta_description"
              label="Meta description"
              type="textarea" autogrow dark outlined dense label-color="teal-3" color="teal-3"
              :hint="`${seo.meta_description?.length ?? 0} chars — aim for 150–160`"
              counter maxlength="160" />
            <q-input v-model="seo.meta_keywords"
              label="Meta keywords (comma-separated)"
              dark outlined dense label-color="teal-3" color="teal-3" />
            <q-input v-model="seo.og_url"
              label="Canonical URL"
              dark outlined dense label-color="teal-3" color="teal-3"
              hint="e.g. https://nikkisgreatmusicfestivals.vercel.app" />
          </q-card-section>
        </q-card>
      </q-expansion-item>

      <q-separator dark />

      <q-expansion-item icon="share" label="Open Graph (Facebook, LinkedIn, Slack…)" header-class="seo-header">
        <q-card class="seo-card">
          <q-card-section class="q-gutter-md">
            <q-input v-model="seo.og_title"
              label="og:title"
              dark outlined dense label-color="teal-3" color="teal-3"
              :hint="`${seo.og_title?.length ?? 0} chars`" />
            <q-input v-model="seo.og_description"
              label="og:description"
              type="textarea" autogrow dark outlined dense label-color="teal-3" color="teal-3"
              :hint="`${seo.og_description?.length ?? 0} chars — aim for 100–200`" />

            <div class="text-caption text-grey-5 q-mb-xs">og:image — recommended 1200×630 px</div>
            <div class="row q-col-gutter-md items-center">
              <div class="col">
                <q-input v-model="seo.og_image"
                  label="og:image URL"
                  dark outlined dense label-color="teal-3" color="teal-3" clearable />
              </div>
              <div class="col-auto">
                <q-btn color="teal-8" icon="upload" label="Upload" unelevated
                  :loading="uploadingOg" @click="triggerOgUpload" />
                <input ref="ogFileInput" type="file" accept="image/*" class="hidden" @change="handleOgUpload" />
              </div>
            </div>
            <div v-if="seo.og_image" class="q-mt-xs og-preview-wrap">
              <img :src="seo.og_image" class="og-preview" />
              <div class="text-caption text-grey-5 q-mt-xs">Preview (1200×630 target)</div>
            </div>
          </q-card-section>
        </q-card>
      </q-expansion-item>

      <q-separator dark />

      <q-expansion-item icon="tag" label="Twitter / X Card" header-class="seo-header">
        <q-card class="seo-card">
          <q-card-section class="q-gutter-md">
            <q-select v-model="seo.twitter_card"
              :options="twitterCardOptions" emit-value map-options
              label="Card type" dark outlined dense label-color="teal-3" color="teal-3"
              hint="summary_large_image shows a big banner — recommended" />
            <q-input v-model="seo.twitter_site"
              label="twitter:site (your @handle, optional)"
              dark outlined dense label-color="teal-3" color="teal-3" />
            <q-input v-model="seo.twitter_creator"
              label="twitter:creator (@author handle, optional)"
              dark outlined dense label-color="teal-3" color="teal-3" />
          </q-card-section>
        </q-card>
      </q-expansion-item>

    </q-list>

    <div class="row justify-end">
      <q-btn color="teal" unelevated icon="save" label="Save All" :loading="saving" @click="saveAll" />
    </div>

    <!-- ── Artist Add / Edit Dialog ───────────────────────── -->
    <q-dialog v-model="artistDialog.open" persistent>
      <q-card style="min-width:460px; max-width:580px; background:#1a1a2e; border:1px solid rgba(77,182,172,0.3)">
        <q-card-section>
          <div class="text-h6 text-teal-3">{{ artistDialog.isNew ? 'Add Artist' : 'Edit Artist' }}</div>
        </q-card-section>
        <q-card-section class="q-gutter-md" style="max-height:72vh; overflow-y:auto">

          <div class="row q-col-gutter-md">
            <div class="col-8">
              <q-input v-model="artistForm.name" label="Artist name *"
                dark outlined dense label-color="teal-3" color="teal-3"
                @update:model-value="autoArtistId" />
            </div>
            <div class="col-4">
              <q-input v-model="artistForm.id" label="Slug *"
                dark outlined dense label-color="teal-3" color="teal-3"
                :readonly="!artistDialog.isNew"
                hint="Auto-generated" />
            </div>
          </div>

          <q-input v-model="artistForm.subtitle" label="Genre / subtitle (e.g. Progressive Bluegrass · Newgrass)"
            dark outlined dense label-color="teal-3" color="teal-3" />

          <div class="row q-col-gutter-md">
            <div class="col-7">
              <q-input v-model="artistForm.icon" label="Icon (Material icon name)"
                dark outlined dense label-color="teal-3" color="teal-3"
                hint="e.g. music_note, queue_music, guitar, mic, star">
                <template #prepend>
                  <q-icon :name="artistForm.icon || 'music_note'" :color="artistForm.icon_color" />
                </template>
              </q-input>
            </div>
            <div class="col-5">
              <q-select v-model="artistForm.icon_color" :options="accentColorOptions" emit-value map-options
                label="Accent color" dark outlined dense label-color="teal-3" color="teal-3">
                <template #prepend>
                  <q-icon name="circle" :color="artistForm.icon_color" />
                </template>
              </q-select>
            </div>
          </div>

          <div class="row q-col-gutter-md">
            <div class="col-7">
              <q-input v-model="artistForm.badge_text" label="Badge label (e.g. Headline, Legacy Act)"
                dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
            <div class="col-5">
              <q-select v-model="artistForm.badge_color" :options="accentColorOptions" emit-value map-options
                label="Badge color" dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
          </div>

          <q-input v-model="artistForm.bio_main" label="Main bio paragraph" type="textarea" :rows="4"
            dark outlined label-color="teal-3" color="teal-3" />

          <q-input v-model="artistForm.bio_sub" label="Secondary paragraph (festival experience, tips, etc.)"
            type="textarea" :rows="3" dark outlined label-color="teal-3" color="teal-3" />

          <q-input v-model="artistForm.songsStr"
            label='Highlight songs (comma-separated)'
            dark outlined dense label-color="teal-3" color="teal-3"
            hint='e.g. Home, Dust in a Baggie, Meet Me at the Creek' />

        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Save Artist" color="teal"
            :disable="!artistForm.name || !artistForm.id"
            @click="saveArtistDialog" />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { HomepageArtist } from 'src/lib/supabase'

const saving         = ref(false)
const saved          = ref(false)
const uploadingBg    = ref(false)
const uploadingOg    = ref(false)
const uploadingWelcome = ref(false)
const bgFileInput      = ref<HTMLInputElement | null>(null)
const ogFileInput      = ref<HTMLInputElement | null>(null)
const welcomeFileInput = ref<HTMLInputElement | null>(null)

// ── Options ─────────────────────────────────────────────────────────────────
const bgVariantOptions = [
  { label: 'Home — Mardi-Gras spiral',      value: 'home'        },
  { label: 'Support — Soundwave rings',     value: 'support'     },
  { label: 'News — Diagonal ink grid',      value: 'news'        },
  { label: 'Photography — Lens aperture',   value: 'photography' },
  { label: 'Maps — Topographic contours',   value: 'maps'        },
  { label: 'Merch — Diamond lattice',       value: 'merch'       },
]

const twitterCardOptions = [
  { label: 'summary_large_image (big banner — recommended)', value: 'summary_large_image' },
  { label: 'summary (small square thumbnail)',               value: 'summary'             },
]

const accentColorOptions = [
  { label: 'Amber',       value: 'amber'       },
  { label: 'Deep Orange', value: 'deep-orange' },
  { label: 'Purple',      value: 'purple'      },
  { label: 'Teal',        value: 'teal'        },
  { label: 'Indigo',      value: 'indigo'      },
  { label: 'Green',       value: 'green'       },
  { label: 'Pink',        value: 'pink'        },
  { label: 'Blue',        value: 'blue'        },
  { label: 'Red',         value: 'red'         },
]

// ── Default artist data (used if not yet saved to Supabase) ─────────────────
const DEFAULT_ARTISTS: HomepageArtist[] = [
  {
    id: 'billy-strings', name: 'Billy Strings',
    subtitle: 'Progressive Bluegrass · Newgrass · Psychedelic',
    icon: 'music_note', icon_color: 'amber',
    badge_text: 'Headline', badge_color: 'amber',
    bio_main: "William Apostol — known to the world as Billy Strings — is a Grammy-winning flatpicker who bends time with a guitar. Raised on the old-time music of Michigan and west of the Blue Ridge, he has become one of the most electrifying live performers in any genre, threading jaw-dropping technique through dark folk imagery and untethered improvisation.",
    bio_sub: "At Nikki's festivals, Billy's sets tend to stretch deep into the night — the jam-grass crowd locks in, and the field turns into something that feels less like a concert and more like a ritual. Bring layers. Bring patience. Let the third set happen to you.",
    songs: ['Home', 'Dust in a Baggie', 'Meet Me at the Creek'],
  },
  {
    id: 'leftover-salmon', name: 'Leftover Salmon',
    subtitle: 'Polyethnic Cajun Slamgrass · Roots · Mountain Folk',
    icon: 'water', icon_color: 'deep-orange',
    badge_text: 'Legacy Act', badge_color: 'deep-orange',
    bio_main: 'Colorado\'s Leftover Salmon invented "Polyethnic Cajun Slamgrass" — a label that sounds like a joke until you hear it, and then it makes perfect sense. Vince Herman and Mark Vann started cooking something strange and wonderful in the early \'90s, and the band has been a cornerstone of the jam scene ever since.',
    bio_sub: "Festival crowds who've seen Leftover Salmon dozens of times will tell you: no two shows are the same. The energy is communal, the musicianship is staggering, and the party starts before the first note lands. Pack a cowboy hat. Hydrate. Dance until your knees forget they have feelings.",
    songs: ['Zombie Jamboree', 'Salmon Run', 'Euphoria'],
  },
  {
    id: 'stringdusters', name: 'The Infamous Stringdusters',
    subtitle: 'Grammy Bluegrass · Acoustic Jam · Americana',
    icon: 'star', icon_color: 'purple',
    badge_text: 'Grammy Winners', badge_color: 'purple',
    bio_main: "The Infamous Stringdusters have spent two decades proving that bluegrass is not a museum piece. Grammy-winning and perpetually evolving, the band writes originals that sound traditional until they don't, and then they improvise in ways that should not work but absolutely do.",
    bio_sub: 'Their sets at outdoor festivals have a particular magic: acoustic instruments carrying over acres of open field, five-part harmonies landing like a surprise. The Dusters reward attentive listening and reward dancing in equal measure.',
    songs: ['Fork in the Road', 'Silver Sky', 'Things You Left Behind'],
  },
]

// ── Data ────────────────────────────────────────────────────────────────────
const welcome = reactive({
  image_url:    'https://picsum.photos/seed/bluegrass-evening/1920/1080',
  eyebrow:      'Welcome to',
  title:        "Nikki's Great\nMusic Festivals",
  tagline:      '"Helping to improve lives by improving access to great music, community, and the outdoors."',
  button_label: 'Enter the Festival',
  button_color: '#ffffff',
})

const content = reactive({
  hero_title:         "Nikki's Great Music Festivals",
  mission_statement:  'Helping to improve lives by improving access to great music, community, and the outdoors.',
  cta_story_label:    'Our Full Story',
  cta_tour_label:     'Explore the Tour',
  artists_label:      'Artist Interviews',
  artists_title:      'Featured Artists',
  subscribe_title:    'Join the Newsletter Adventure',
  subscribe_body:     'Show dates, artist interviews, trail reports, and community stories — straight to your inbox.',
})

const artists = ref<HomepageArtist[]>([...DEFAULT_ARTISTS])

const appearance = reactive({
  bg_image_url:         null as string | null,
  bg_variant:           'home',
  bg_opacity:           0.09,
  footer_default_night: false,
})

const seo = reactive({
  site_name:        "Nikki's Great Music Festivals",
  og_title:         "Nikki's Great Music Festivals — Tour Maps, Live Music & Community",
  og_description:   'Follow the festival trail — tour maps, artist interviews, photography, and community across the US.',
  og_image:         null as string | null,
  og_url:           'https://nikkisgreatmusicfestivals.vercel.app',
  meta_description: "Festival tour maps, artist interviews, trail photography and community — Nikki's Great Music Festivals.",
  meta_keywords:    'music festivals, bluegrass, outdoor concerts, Billy Strings, Leftover Salmon, Stringdusters',
  twitter_card:     'summary_large_image',
  twitter_site:     null as string | null,
  twitter_creator:  null as string | null,
})

// ── Artist dialog ────────────────────────────────────────────────────────────
const artistDialog = ref({ open: false, isNew: true, editIndex: -1 })
const artistForm   = reactive({
  id: '', name: '', subtitle: '',
  icon: 'music_note', icon_color: 'amber',
  badge_text: '', badge_color: 'amber',
  bio_main: '', bio_sub: '', songsStr: '',
})

function autoArtistId(val: string | number | null) {
  if (artistDialog.value.isNew) {
    artistForm.id = String(val).toLowerCase()
      .replace(/\s+/g, '-')
      .replace(/[^a-z0-9-]/g, '')
  }
}

function openAddArtist() {
  artistDialog.value = { open: true, isNew: true, editIndex: -1 }
  Object.assign(artistForm, {
    id: '', name: '', subtitle: '',
    icon: 'music_note', icon_color: 'amber',
    badge_text: '', badge_color: 'amber',
    bio_main: '', bio_sub: '', songsStr: '',
  })
}

function openEditArtist(i: number) {
  artistDialog.value = { open: true, isNew: false, editIndex: i }
  const a = artists.value[i]!
  Object.assign(artistForm, {
    id: a.id, name: a.name, subtitle: a.subtitle,
    icon: a.icon, icon_color: a.icon_color,
    badge_text: a.badge_text, badge_color: a.badge_color,
    bio_main: a.bio_main, bio_sub: a.bio_sub,
    songsStr: a.songs.join(', '),
  })
}

function saveArtistDialog() {
  const songs = artistForm.songsStr.split(',').map(s => s.trim()).filter(Boolean)
  const saved: HomepageArtist = {
    id: artistForm.id, name: artistForm.name, subtitle: artistForm.subtitle,
    icon: artistForm.icon, icon_color: artistForm.icon_color,
    badge_text: artistForm.badge_text, badge_color: artistForm.badge_color,
    bio_main: artistForm.bio_main, bio_sub: artistForm.bio_sub, songs,
  }
  const { isNew, editIndex } = artistDialog.value
  if (isNew) {
    artists.value.push(saved)
  } else {
    artists.value.splice(editIndex, 1, saved)
  }
  artistDialog.value.open = false
}

function removeArtist(i: number) {
  artists.value.splice(i, 1)
}

function moveArtist(i: number, dir: -1 | 1) {
  const arr = [...artists.value]
  const tmp = arr[i]!
  arr[i] = arr[i + dir]!
  arr[i + dir] = tmp
  artists.value = arr
}

// ── Settings load / save ─────────────────────────────────────────────────────
async function loadSettings() {
  const { data } = await supabase.from('site_settings').select('key, value')
  for (const row of (data ?? []) as { key: string; value: unknown }[]) {
    if (row.key === 'homepage_content')    Object.assign(content,    row.value as object)
    if (row.key === 'homepage_appearance') Object.assign(appearance, row.value as object)
    if (row.key === 'homepage_seo')        Object.assign(seo,        row.value as object)
    if (row.key === 'welcome_overlay')     Object.assign(welcome,    row.value as object)
    if (row.key === 'homepage_artists' && Array.isArray(row.value) && row.value.length) {
      artists.value = row.value as HomepageArtist[]
    }
  }
}

async function saveAll() {
  saving.value = true
  saved.value  = false
  await Promise.all([
    supabase.from('site_settings').upsert({ key: 'homepage_content',    value: { ...content    }, updated_at: new Date().toISOString() }),
    supabase.from('site_settings').upsert({ key: 'homepage_appearance', value: { ...appearance }, updated_at: new Date().toISOString() }),
    supabase.from('site_settings').upsert({ key: 'homepage_seo',        value: { ...seo        }, updated_at: new Date().toISOString() }),
    supabase.from('site_settings').upsert({ key: 'homepage_artists',    value: artists.value,     updated_at: new Date().toISOString() }),
    supabase.from('site_settings').upsert({ key: 'welcome_overlay',     value: { ...welcome    }, updated_at: new Date().toISOString() }),
  ])
  saving.value = false
  saved.value  = true
  setTimeout(() => { saved.value = false }, 3000)
}

function triggerBgUpload()      { bgFileInput.value?.click()      }
function triggerOgUpload()      { ogFileInput.value?.click()      }
function triggerWelcomeUpload() { welcomeFileInput.value?.click() }

async function handleBgUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingBg.value = true
  const path = `homepage/bg-${Date.now()}.${file.name.split('.').pop() ?? 'jpg'}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    appearance.bg_image_url = data.publicUrl
  }
  uploadingBg.value = false
}

async function handleWelcomeUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingWelcome.value = true
  const path = `homepage/welcome-${Date.now()}.${file.name.split('.').pop() ?? 'jpg'}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    welcome.image_url = data.publicUrl
  }
  uploadingWelcome.value = false
}

async function handleOgUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingOg.value = true
  const path = `homepage/og-${Date.now()}.${file.name.split('.').pop() ?? 'jpg'}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    seo.og_image = data.publicUrl
  }
  uploadingOg.value = false
}

onMounted(loadSettings)
</script>

<style lang="scss" scoped>
.settings-card {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.18);
  border-radius: 12px;
}
.seo-accordion {
  background: #1a1a2e;
  border-color: rgba(77,182,172,0.2) !important;
  border-radius: 12px;
}
.seo-header  { background: #1a1a2e; color: #b2dfdb; }
.seo-card    { background: #14142a; border-top: 1px solid rgba(77,182,172,0.12); }
.save-banner { background: rgba(77,182,172,0.1); border: 1px solid rgba(77,182,172,0.3); color: #e0f2f1; }
.ls-2 { letter-spacing: 2px; }
.ls-1 { letter-spacing: 1.5px; }
.hidden { display: none; }
.bg-preview { max-height: 120px; max-width: 100%; border-radius: 8px; object-fit: cover; }
.og-preview-wrap { max-width: 480px; }
.og-preview { width: 100%; border-radius: 8px; aspect-ratio: 1200/630; object-fit: cover; }
.color-picker {
  width: 40px; height: 40px; border: none; padding: 0;
  border-radius: 8px; cursor: pointer; background: none;
}
.welcome-preview {
  margin-top: 8px;
  background: linear-gradient(to top, rgba(0,0,0,0.82) 0%, rgba(0,0,0,0.5) 100%);
  border-radius: 10px;
  padding: 24px 32px;
  display: flex; flex-direction: column; align-items: center;
  text-align: center; gap: 10px;
}
.wp-eyebrow {
  font-size: 11px; font-weight: 700; letter-spacing: 4px;
  text-transform: uppercase; color: rgba(255,215,0,0.85);
}
.wp-title {
  font-size: 28px; font-weight: 900; line-height: 1.1;
  color: #fff; letter-spacing: -0.5px;
}
.wp-tagline {
  font-size: 13px; font-weight: 300; color: rgba(255,255,255,0.7);
  font-style: italic; max-width: 380px;
}
.wp-btn {
  background: rgba(255,255,255,0.1);
  border: 2px solid currentColor;
  font-size: 12px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; padding: 10px 24px;
  border-radius: 999px; cursor: default;
}
</style>

<template>
  <q-page class="home-page relative overflow-hidden">
    <PageBackground :variant="bgVariant" :opacity="bgOpacity" :imageUrl="bgImageUrl" />

    <WelcomeOverlay />
    <StoryOverlay v-model="showStory" />

    <div class="page-content q-pa-lg">

      <!-- HERO -->
      <header class="q-mb-xl q-pt-lg row items-center justify-center q-gutter-xl">
        <div class="col-12 col-md-4 flex flex-center">
          <SpirographLogo :size="200" :spin="true" class="hero-logo" />
        </div>
        <div class="col-12 col-md-7 text-left">
          <div class="text-h2 text-bold text-primary q-mb-md">{{ content.hero_title }}</div>
          <div class="mission-statement text-h5 q-mb-lg" style="max-width: 800px">
            "{{ content.mission_statement }}"
          </div>
          <div class="row q-gutter-sm">
            <q-btn :label="content.cta_story_label" color="secondary" outline @click="showStory = true" />
            <q-btn :label="content.cta_tour_label" color="primary" unelevated :to="'/maps'" />
          </div>
        </div>
      </header>

      <!-- ARTIST INTERVIEWS -->
      <section class="q-mb-xl">
        <div class="section-label q-mb-xs">{{ content.artists_label }}</div>
        <div class="text-h4 text-bold q-mb-lg">{{ content.artists_title }}</div>

        <q-list bordered class="artist-accordion rounded-borders overflow-hidden">
          <template v-for="(artist, i) in artists" :key="artist.id">
            <q-expansion-item
              :default-opened="i === 0"
              group="artists"
              header-class="artist-header"
            >
              <template #header>
                <div class="row items-center full-width q-gutter-md">
                  <div class="artist-icon-wrap">
                    <q-icon :name="artist.icon || 'music_note'" :color="artist.icon_color" size="44px" />
                  </div>
                  <div class="text-left">
                    <div class="text-h6 text-bold" :class="artistTextClass(artist.icon_color)">{{ artist.name }}</div>
                    <div class="text-caption text-grey-7">{{ artist.subtitle }}</div>
                  </div>
                  <q-space />
                  <q-badge :color="artist.badge_color" :label="artist.badge_text" class="q-mr-md" />
                </div>
              </template>
              <q-card class="artist-card">
                <q-card-section class="text-left">
                  <p class="text-body1">{{ artist.bio_main }}</p>
                  <p class="text-body2 text-grey-8">{{ artist.bio_sub }}</p>
                  <div class="row q-gutter-sm q-mt-md">
                    <q-chip
                      v-for="song in artist.songs" :key="song"
                      icon="music_note"
                      :color="chipColor(artist.icon_color)"
                      :text-color="chipTextColor(artist.icon_color)"
                    >{{ song }}</q-chip>
                  </div>
                </q-card-section>
              </q-card>
            </q-expansion-item>
            <q-separator v-if="i < artists.length - 1" />
          </template>

          <q-item v-if="artists.length === 0" class="q-py-xl">
            <q-item-section class="text-grey-6 text-center">No artists yet — check back soon.</q-item-section>
          </q-item>
        </q-list>
      </section>

      <!-- NEWSLETTER SUBSCRIBE FOOTER -->
      <section id="subscribe-bottom" class="subscribe-section q-pa-xl text-center q-mb-xl rounded-borders">
        <div class="section-label q-mb-xs">Stay Connected</div>
        <div class="text-h4 text-bold q-mb-sm">{{ content.subscribe_title }}</div>
        <div class="text-body1 text-grey-7 q-mb-xl" style="max-width: 540px; margin: 0 auto 32px;">
          {{ content.subscribe_body }}
        </div>
        <div class="row justify-center q-gutter-md items-start">
          <q-input
            v-model="email"
            type="email"
            placeholder="your@email.com"
            outlined dense
            class="subscribe-input"
            :error="!!emailError"
            :error-message="emailError"
            hide-bottom-space
          />
          <q-btn
            label="Subscribe"
            color="secondary"
            unelevated
            :loading="subscribing"
            :disable="subscribed"
            @click="subscribe"
            icon-right="send"
          />
        </div>
        <div v-if="subscribed" class="text-positive q-mt-md text-body2">
          You're in! We'll be in touch soon.
        </div>
        <div class="q-mt-xl text-caption text-grey-5">No spam. Unsubscribe anytime.</div>
      </section>

    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useMeta } from 'quasar'
import { supabase } from 'src/lib/supabase'
import type { HomepageArtist } from 'src/lib/supabase'
import PageBackground  from 'src/components/PageBackground.vue'
import SpirographLogo  from 'src/components/SpirographLogo.vue'
import WelcomeOverlay  from 'src/components/WelcomeOverlay.vue'
import StoryOverlay    from 'src/components/StoryOverlay.vue'

const showStory = ref(false)

// ── Settings loaded from Supabase (fallbacks = hardcoded defaults) ──────────
const content = reactive({
  hero_title:        "Nikki's Great Music Festivals",
  mission_statement: 'Helping to improve lives by improving access to great music, community, and the outdoors.',
  cta_story_label:   'Our Full Story',
  cta_tour_label:    'Explore the Tour',
  artists_label:     'Artist Interviews',
  artists_title:     'Featured Artists',
  subscribe_title:   'Join the Newsletter Adventure',
  subscribe_body:    'Show dates, artist interviews, trail reports, and community stories — straight to your inbox.',
})

const artists = ref<HomepageArtist[]>([
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
])

const seo = reactive({
  site_name:        "Nikki's Great Music Festivals",
  og_title:         "Nikki's Great Music Festivals — Tour Maps, Live Music & Community",
  og_description:   'Follow the festival trail — tour maps, artist interviews, photography, and community across the US.',
  og_image:         '',
  og_url:           'https://nikkisgreatmusicfestivals.vercel.app',
  meta_description: "Festival tour maps, artist interviews, trail photography and community — Nikki's Great Music Festivals.",
  meta_keywords:    'music festivals, bluegrass, outdoor concerts, Billy Strings, Leftover Salmon',
  twitter_card:     'summary_large_image',
  twitter_site:     '',
  twitter_creator:  '',
})

const bgImageUrl = ref<string | null>(null)
const bgVariant  = ref<'home'|'support'|'news'|'photography'|'maps'|'merch'>('home')
const bgOpacity  = ref(0.09)

// ── Color helpers for artist chips ──────────────────────────────────────────
function artistTextClass(color: string): string {
  const map: Record<string, string> = {
    'amber':       'text-amber-8',
    'deep-orange': 'text-deep-orange-8',
    'purple':      'text-purple-9',
    'teal':        'text-teal-4',
    'indigo':      'text-indigo-7',
    'green':       'text-green-7',
    'pink':        'text-pink-7',
    'blue':        'text-blue-7',
    'red':         'text-red-7',
  }
  return map[color] ?? 'text-teal-3'
}

function chipColor(color: string): string {
  const map: Record<string, string> = {
    'amber': 'amber-2', 'deep-orange': 'orange-2', 'purple': 'purple-2',
    'teal': 'teal-1', 'indigo': 'indigo-1', 'green': 'green-1',
    'pink': 'pink-1', 'blue': 'blue-1', 'red': 'red-1',
  }
  return map[color] ?? 'teal-1'
}

function chipTextColor(color: string): string {
  const map: Record<string, string> = {
    'amber': 'brown-9', 'deep-orange': 'deep-orange-9', 'purple': 'purple-10',
    'teal': 'teal-9', 'indigo': 'indigo-9', 'green': 'green-9',
    'pink': 'pink-9', 'blue': 'blue-9', 'red': 'red-9',
  }
  return map[color] ?? 'teal-9'
}

// ── Reactive meta tags ───────────────────────────────────────────────────────
useMeta(() => ({
  title: seo.og_title,
  meta: {
    charset:       { charset: 'utf-8' },
    description:   { name: 'description',    content: seo.meta_description },
    keywords:      { name: 'keywords',        content: seo.meta_keywords },
    ogSiteName:    { property: 'og:site_name',content: seo.site_name },
    ogType:        { property: 'og:type',     content: 'website' },
    ogUrl:         { property: 'og:url',      content: seo.og_url },
    ogTitle:       { property: 'og:title',    content: seo.og_title },
    ogDescription: { property: 'og:description', content: seo.og_description },
    ogImage:       { property: 'og:image',    content: seo.og_image || '' },
    twitterCard:   { name: 'twitter:card',    content: seo.twitter_card },
    twitterTitle:  { name: 'twitter:title',   content: seo.og_title },
    twitterDesc:   { name: 'twitter:description', content: seo.og_description },
    twitterImage:  { name: 'twitter:image',   content: seo.og_image || '' },
    ...(seo.twitter_site    ? { twitterSite:    { name: 'twitter:site',    content: seo.twitter_site    } } : {}),
    ...(seo.twitter_creator ? { twitterCreator: { name: 'twitter:creator', content: seo.twitter_creator } } : {}),
  },
}))

// ── Load settings on mount ───────────────────────────────────────────────────
async function loadSettings() {
  const { data } = await supabase
    .from('site_settings')
    .select('key, value')
    .in('key', ['homepage_content', 'homepage_seo', 'homepage_appearance', 'homepage_artists'])
  for (const row of (data ?? []) as { key: string; value: unknown }[]) {
    if (row.key === 'homepage_content')    Object.assign(content, row.value as object)
    if (row.key === 'homepage_seo')        Object.assign(seo,     row.value as object)
    if (row.key === 'homepage_appearance') {
      const v = row.value as Record<string, unknown>
      if (v['bg_image_url'] != null) bgImageUrl.value = v['bg_image_url'] as string
      if (v['bg_variant']   != null) bgVariant.value  = v['bg_variant'] as typeof bgVariant.value
      if (v['bg_opacity']   != null) bgOpacity.value  = v['bg_opacity'] as number
    }
    if (row.key === 'homepage_artists' && Array.isArray(row.value) && (row.value as unknown[]).length) {
      artists.value = row.value as HomepageArtist[]
    }
  }
}

onMounted(() => { void loadSettings() })

// ── Newsletter subscribe ─────────────────────────────────────────────────────
const email       = ref('')
const subscribing = ref(false)
const subscribed  = ref(false)
const emailError  = ref('')

async function subscribe() {
  emailError.value = ''
  if (!email.value || !/\S+@\S+\.\S+/.test(email.value)) {
    emailError.value = 'Please enter a valid email'
    return
  }
  subscribing.value = true
  await supabase.from('newsletter_subscribers').upsert({ email: email.value })
  subscribing.value = false
  subscribed.value = true
}
</script>

<style lang="scss" scoped>
.home-page    { min-height: 100vh; }
.page-content { position: relative; z-index: 1; }

.section-label {
  font-size: 11px; font-weight: 700; letter-spacing: 3px;
  text-transform: uppercase; color: #ab47bc;
}

.hero-logo {
  filter: drop-shadow(0 0 18px rgba(124,77,255,0.4)) drop-shadow(3px 3px 0 rgba(0,0,0,0.15));
  transition: filter 0.4s ease;
  &:hover { filter: drop-shadow(0 0 28px rgba(124,77,255,0.7)) drop-shadow(3px 3px 0 rgba(0,0,0,0.25)); }
}

.mission-statement {
  line-height: 1.4; font-weight: 300; color: #2c3e50;
  border-left: 4px solid #ffd700; padding-left: 20px;
}

.artist-accordion {
  max-width: 860px; margin: 0 auto;
  background: rgba(255,255,255,0.88);
  backdrop-filter: blur(6px);
}
.artist-header    { padding: 16px 20px; &:hover { background: rgba(0,0,0,0.03); } }
.artist-icon-wrap { flex-shrink: 0; }
.artist-card      { background: rgba(255,255,255,0.6); border-top: 1px solid rgba(0,0,0,0.06); }

.subscribe-section {
  max-width: 700px; margin: 0 auto;
  background: linear-gradient(135deg, rgba(75,0,130,0.06), rgba(255,215,0,0.08), rgba(0,143,57,0.06));
  border: 1px solid rgba(171, 71, 188, 0.2);
}
.subscribe-input { min-width: 280px; background: white; border-radius: 8px; }
</style>

<style lang="scss">
body.body--dark {
  .artist-accordion {
    background: rgba(13, 0, 30, 0.92) !important;
    border-color: rgba(255, 255, 255, 0.12) !important;
  }
  .artist-card {
    background: rgba(8, 0, 20, 0.75) !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
  }
  .artist-header:hover { background: rgba(255, 255, 255, 0.05) !important; }
  .artist-accordion .text-amber-8        { color: #ffc107 !important; }
  .artist-accordion .text-deep-orange-8  { color: #ff8a50 !important; }
  .artist-accordion .text-purple-9       { color: #ce93d8 !important; }
  .artist-accordion .text-grey-7,
  .artist-accordion .text-grey-8         { color: rgba(255,255,255,0.6) !important; }
  .mission-statement { color: rgba(224, 242, 241, 0.85) !important; }
  .subscribe-input   { background: rgba(255, 255, 255, 0.08) !important; }
}
</style>

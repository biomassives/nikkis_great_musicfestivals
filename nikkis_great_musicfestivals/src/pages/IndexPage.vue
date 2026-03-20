<template>
  <q-page class="home-page relative overflow-hidden">
    <PageBackground variant="home" />

    <div class="page-content q-pa-lg">

      <!-- HERO -->
      <header class="q-mb-xl q-pt-lg row items-center justify-center q-gutter-xl">
        <div class="col-12 col-md-4 flex flex-center">
          <SpirographLogo :size="200" :spin="true" class="hero-logo" />
        </div>
        <div class="col-12 col-md-7 text-left">
          <div class="text-h2 text-bold text-primary q-mb-md">Nikki's Great Music Festivals</div>
          <div class="mission-statement text-h5 q-mb-lg" style="max-width: 800px">
            "Helping to improve lives by improving access to great music, community, and the outdoors."
          </div>
          <div class="row q-gutter-sm">
            <q-btn label="Our Full Story" color="secondary" outline />
            <q-btn label="Explore the Tour" color="primary" unelevated :to="'/maps'" />
          </div>
        </div>
      </header>

      <!-- ARTIST INTERVIEWS -->
      <section class="q-mb-xl">
        <div class="section-label q-mb-xs">Artist Interviews</div>
        <div class="text-h4 text-bold q-mb-lg">Featured Artists</div>

        <q-list bordered class="artist-accordion rounded-borders overflow-hidden">

          <!-- Billy Strings -->
          <q-expansion-item v-model="openArtist.billyStrings" group="artists" header-class="artist-header">
            <template v-slot:header>
              <div class="row items-center full-width q-gutter-md">
                <div class="artist-icon-wrap">
                  <svg width="48" height="48" viewBox="0 0 100 100">
                    <circle cx="50" cy="50" r="44" fill="none" stroke="#ffd700" stroke-width="2" stroke-dasharray="6 3"/>
                    <path d="M30 65 Q50 25 70 65" fill="none" stroke="#ffd700" stroke-width="3"/>
                    <line x1="35" y1="65" x2="65" y2="65" stroke="#ffd700" stroke-width="2"/>
                    <line x1="50" y1="30" x2="50" y2="65" stroke="#ffd700" stroke-width="1.5" stroke-dasharray="3 2"/>
                  </svg>
                </div>
                <div class="text-left">
                  <div class="text-h6 text-bold text-yellow-9">Billy Strings</div>
                  <div class="text-caption text-grey-7">Progressive Bluegrass · Newgrass · Psychedelic</div>
                </div>
                <q-space />
                <q-badge color="amber" text-color="black" label="Headline" class="q-mr-md" />
              </div>
            </template>
            <q-card class="artist-card">
              <q-card-section class="text-left">
                <p class="text-body1">William Apostol — known to the world as <strong>Billy Strings</strong> — is a Grammy-winning flatpicker who bends time with a guitar. Raised on the old-time music of Michigan and west of the Blue Ridge, he has become one of the most electrifying live performers in any genre, threading jaw-dropping technique through dark folk imagery and untethered improvisation.</p>
                <p class="text-body2 text-grey-8">At Nikki's festivals, Billy's sets tend to stretch deep into the night — the jam-grass crowd locks in, and the field turns into something that feels less like a concert and more like a ritual. Bring layers. Bring patience. Let the third set happen to you.</p>
                <div class="row q-gutter-sm q-mt-md">
                  <q-chip icon="music_note" color="amber-2" text-color="brown-9">Home</q-chip>
                  <q-chip icon="music_note" color="amber-2" text-color="brown-9">Dust in a Baggie</q-chip>
                  <q-chip icon="music_note" color="amber-2" text-color="brown-9">Meet Me at the Creek</q-chip>
                </div>
              </q-card-section>
            </q-card>
          </q-expansion-item>

          <q-separator />

          <!-- Leftover Salmon -->
          <q-expansion-item v-model="openArtist.leftoverSalmon" group="artists" header-class="artist-header">
            <template v-slot:header>
              <div class="row items-center full-width q-gutter-md">
                <div class="artist-icon-wrap">
                  <svg width="48" height="48" viewBox="0 0 100 100">
                    <ellipse cx="50" cy="50" rx="44" ry="28" fill="none" stroke="#ff8c69" stroke-width="2"/>
                    <path d="M15 50 Q30 35 50 50 Q70 65 85 50" fill="none" stroke="#ff8c69" stroke-width="3"/>
                    <circle cx="78" cy="44" r="3" fill="#ff8c69"/>
                    <path d="M82 50 L95 42 L95 58 Z" fill="#ff8c69"/>
                  </svg>
                </div>
                <div class="text-left">
                  <div class="text-h6 text-bold text-deep-orange-8">Leftover Salmon</div>
                  <div class="text-caption text-grey-7">Polyethnic Cajun Slamgrass · Roots · Mountain Folk</div>
                </div>
                <q-space />
                <q-badge color="deep-orange" label="Legacy Act" class="q-mr-md" />
              </div>
            </template>
            <q-card class="artist-card">
              <q-card-section class="text-left">
                <p class="text-body1">Colorado's <strong>Leftover Salmon</strong> invented "Polyethnic Cajun Slamgrass" — a label that sounds like a joke until you hear it, and then it makes perfect sense. Vince Herman and Mark Vann started cooking something strange and wonderful in the early '90s, and the band has been a cornerstone of the jam scene ever since.</p>
                <p class="text-body2 text-grey-8">Festival crowds who've seen Leftover Salmon dozens of times will tell you: no two shows are the same. The energy is communal, the musicianship is staggering, and the party starts before the first note lands. Pack a cowboy hat. Hydrate. Dance until your knees forget they have feelings.</p>
                <div class="row q-gutter-sm q-mt-md">
                  <q-chip icon="music_note" color="orange-2" text-color="deep-orange-9">Zombie Jamboree</q-chip>
                  <q-chip icon="music_note" color="orange-2" text-color="deep-orange-9">Salmon Run</q-chip>
                  <q-chip icon="music_note" color="orange-2" text-color="deep-orange-9">Euphoria</q-chip>
                </div>
              </q-card-section>
            </q-card>
          </q-expansion-item>

          <q-separator />

          <!-- Infamous Stringdusters -->
          <q-expansion-item v-model="openArtist.stringDusters" group="artists" header-class="artist-header">
            <template v-slot:header>
              <div class="row items-center full-width q-gutter-md">
                <div class="artist-icon-wrap">
                  <svg width="48" height="48" viewBox="0 0 100 100">
                    <polygon points="50,8 92,32 92,68 50,92 8,68 8,32" fill="none" stroke="#6a0dad" stroke-width="2"/>
                    <line x1="50" y1="8" x2="50" y2="92" stroke="#6a0dad" stroke-width="1" stroke-dasharray="4 3"/>
                    <line x1="8" y1="50" x2="92" y2="50" stroke="#6a0dad" stroke-width="1" stroke-dasharray="4 3"/>
                    <circle cx="50" cy="50" r="10" fill="none" stroke="#9c27b0" stroke-width="2"/>
                  </svg>
                </div>
                <div class="text-left">
                  <div class="text-h6 text-bold text-purple-9">The Infamous Stringdusters</div>
                  <div class="text-caption text-grey-7">Grammy Bluegrass · Acoustic Jam · Americana</div>
                </div>
                <q-space />
                <q-badge color="purple" label="Grammy Winners" class="q-mr-md" />
              </div>
            </template>
            <q-card class="artist-card">
              <q-card-section class="text-left">
                <p class="text-body1"><strong>The Infamous Stringdusters</strong> have spent two decades proving that bluegrass is not a museum piece. Grammy-winning and perpetually evolving, the band writes originals that sound traditional until they don't, and then they improvise in ways that should not work but absolutely do.</p>
                <p class="text-body2 text-grey-8">Their sets at outdoor festivals have a particular magic: acoustic instruments carrying over acres of open field, five-part harmonies landing like a surprise. The Dusters reward attentive listening and reward dancing in equal measure.</p>
                <div class="row q-gutter-sm q-mt-md">
                  <q-chip icon="music_note" color="purple-2" text-color="purple-10">Fork in the Road</q-chip>
                  <q-chip icon="music_note" color="purple-2" text-color="purple-10">Silver Sky</q-chip>
                  <q-chip icon="music_note" color="purple-2" text-color="purple-10">Things You Left Behind</q-chip>
                </div>
              </q-card-section>
            </q-card>
          </q-expansion-item>

        </q-list>
      </section>

      <!-- NEWSLETTER SUBSCRIBE FOOTER -->
      <section id="subscribe-bottom" class="subscribe-section q-pa-xl text-center q-mb-xl rounded-borders">
        <div class="section-label q-mb-xs">Stay Connected</div>
        <div class="text-h4 text-bold q-mb-sm">Join the Newsletter Adventure</div>
        <div class="text-body1 text-grey-7 q-mb-xl" style="max-width: 540px; margin: 0 auto 32px;">
          Show dates, artist interviews, trail reports, and community stories — straight to your inbox.
        </div>
        <div class="row justify-center q-gutter-md items-start">
          <q-input
            v-model="email"
            type="email"
            placeholder="your@email.com"
            outlined
            dense
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
import { ref, reactive } from 'vue'
import { supabase } from 'src/lib/supabase'
import PageBackground  from 'src/components/PageBackground.vue'
import SpirographLogo  from 'src/components/SpirographLogo.vue'

const openArtist = reactive({ billyStrings: true, leftoverSalmon: false, stringDusters: false })

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
.home-page  { min-height: 100vh; }
.page-content { position: relative; z-index: 1; }

.section-label {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 3px;
  text-transform: uppercase;
  color: #ab47bc;
}

.hero-logo {
  filter: drop-shadow(0 0 18px rgba(124,77,255,0.4)) drop-shadow(3px 3px 0 rgba(0,0,0,0.15));
  transition: filter 0.4s ease;
  &:hover { filter: drop-shadow(0 0 28px rgba(124,77,255,0.7)) drop-shadow(3px 3px 0 rgba(0,0,0,0.25)); }
}

.mission-statement {
  line-height: 1.4;
  font-weight: 300;
  color: #2c3e50;
  border-left: 4px solid #ffd700;
  padding-left: 20px;
}

.artist-accordion {
  max-width: 860px;
  margin: 0 auto;
  background: rgba(255,255,255,0.88);
  backdrop-filter: blur(6px);
}
.artist-header  { padding: 16px 20px; &:hover { background: rgba(0,0,0,0.03); } }
.artist-icon-wrap { flex-shrink: 0; filter: drop-shadow(0 0 6px rgba(0,0,0,0.15)); }
.artist-card { background: rgba(255,255,255,0.6); border-top: 1px solid rgba(0,0,0,0.06); }

.subscribe-section {
  max-width: 700px;
  margin: 0 auto;
  background: linear-gradient(135deg, rgba(75,0,130,0.06), rgba(255,215,0,0.08), rgba(0,143,57,0.06));
  border: 1px solid rgba(171, 71, 188, 0.2);
}
.subscribe-input { min-width: 280px; background: white; border-radius: 8px; }
</style>

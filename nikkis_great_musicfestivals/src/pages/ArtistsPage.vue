<template>
  <q-page class="artists-page q-pa-lg">

    <!-- Header -->
    <div class="artists-header text-center q-mb-xl">
      <div class="artists-eyebrow">Full Roster</div>
      <h1 class="artists-title">Artist Index</h1>
      <div class="artists-rule" />
      <p class="artists-sub">
        The complete lineup across all six tour regions — from headline acts to campfire pickin' heroes.
      </p>
    </div>

    <!-- Featured section -->
    <div class="roster-section q-mb-xl">
      <div class="roster-label">
        <q-icon name="star" size="16px" class="q-mr-xs" />Featured Artists
      </div>
      <div class="artist-grid">
        <router-link
          v-for="(artist, i) in featured"
          :key="artist.id"
          :to="`/artists/${artist.id}`"
          class="artist-card reveal"
          :class="`stagger-${(i % 3) + 1}`"
          :style="`--ac: ${artistColor(artist.icon_color)}`"
        >
          <div class="artist-card-accent" />
          <div class="artist-card-body">
            <div class="artist-card-top">
              <div class="artist-icon-circle"
                :style="`background: ${artistColor(artist.icon_color)}22`">
                <q-icon :name="artist.icon" size="28px"
                  :style="`color: ${artistColor(artist.icon_color)}`" />
              </div>
              <q-badge :color="artist.badge_color" :label="artist.badge_text" />
            </div>
            <div class="artist-name">{{ artist.name }}</div>
            <div class="artist-subtitle">{{ artist.subtitle }}</div>
            <div class="artist-genres row q-gutter-xs q-mt-sm q-mb-sm">
              <q-chip v-for="g in artist.genres.slice(0,3)" :key="g"
                dense size="xs" outline
                :style="`color: ${artistColor(artist.icon_color)}; border-color: ${artistColor(artist.icon_color)}44`"
              >{{ g }}</q-chip>
            </div>
            <p class="artist-bio">{{ artist.bio_main.slice(0, 130) }}…</p>
            <div class="artist-more">
              Read more <q-icon name="arrow_forward" size="12px" />
            </div>
          </div>
        </router-link>
      </div>
    </div>

    <!-- Also on tour -->
    <div class="roster-section">
      <div class="roster-label">
        <q-icon name="explore" size="16px" class="q-mr-xs" />Also On Tour
      </div>
      <div class="artist-grid artist-grid--small">
        <router-link
          v-for="(artist, i) in others"
          :key="artist.id"
          :to="`/artists/${artist.id}`"
          class="artist-card artist-card--sm reveal"
          :class="`stagger-${(i % 4) + 1}`"
          :style="`--ac: ${artistColor(artist.icon_color)}`"
        >
          <div class="artist-card-accent" />
          <div class="artist-card-body">
            <div class="artist-card-top">
              <div class="artist-icon-circle artist-icon-circle--sm"
                :style="`background: ${artistColor(artist.icon_color)}22`">
                <q-icon :name="artist.icon" size="22px"
                  :style="`color: ${artistColor(artist.icon_color)}`" />
              </div>
              <q-badge :color="artist.badge_color" :label="artist.badge_text" size="xs" />
            </div>
            <div class="artist-name">{{ artist.name }}</div>
            <div class="artist-subtitle">{{ artist.subtitle }}</div>
            <div class="artist-more q-mt-sm">
              Artist page <q-icon name="arrow_forward" size="12px" />
            </div>
          </div>
        </router-link>
      </div>
    </div>

  </q-page>
</template>

<script setup lang="ts">
import { computed, onMounted, nextTick } from 'vue'
import { ARTISTS } from 'src/lib/artists'

const COLOR_MAP: Record<string, string> = {
  amber: '#ffc107', 'deep-orange': '#ff6d00', purple: '#9c27b0',
  teal: '#009688', indigo: '#3f51b5', green: '#4caf50',
  pink: '#e91e63', blue: '#2196f3', red: '#f44336',
}
function artistColor(c: string): string { return COLOR_MAP[c] ?? '#7c4dff' }

const featured = computed(() => ARTISTS.filter(a => a.featured))
const others    = computed(() => ARTISTS.filter(a => !a.featured))

// Scroll reveal
let revealObserver: IntersectionObserver | null = null
function initReveal() {
  revealObserver?.disconnect()
  revealObserver = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible')
        revealObserver?.unobserve(entry.target)
      }
    }
  }, { threshold: 0.06 })
  document.querySelectorAll('.reveal').forEach(el => revealObserver!.observe(el))
}

onMounted(() => { void nextTick(initReveal) })
</script>

<style lang="scss" scoped>
.artists-page { max-width: 1200px; margin: 0 auto; min-height: 100vh; padding-top: 48px; }

// Scroll reveal
.reveal {
  opacity: 0; transform: translateY(28px);
  transition: opacity 0.55s ease, transform 0.55s ease;
  &.is-visible { opacity: 1; transform: none; }
}
@for $i from 1 through 6 { .stagger-#{$i} { transition-delay: #{$i * 0.08}s; } }

// Header
.artists-eyebrow {
  font-size: 10px; font-weight: 900; letter-spacing: 4px;
  text-transform: uppercase; color: #ab47bc; margin-bottom: 10px;
}
.artists-title {
  font-size: clamp(2rem, 4vw, 2.8rem);
  font-weight: 900; margin: 0 0 16px;
}
.artists-rule {
  width: 60px; height: 4px; border-radius: 2px;
  background: linear-gradient(90deg, #7c4dff, #ffd700);
  margin: 0 auto 20px;
}
.artists-sub {
  max-width: 520px; margin: 0 auto; opacity: 0.65; font-size: 1rem; line-height: 1.6;
}

// Roster section label
.roster-section { max-width: 1100px; margin: 0 auto; }
.roster-label {
  font-size: 11px; font-weight: 800; letter-spacing: 3px;
  text-transform: uppercase; color: rgba(255,255,255,0.35);
  border-bottom: 1px solid rgba(255,255,255,0.08);
  padding-bottom: 10px; margin-bottom: 24px;
  display: flex; align-items: center;
}

// Artist grid
.artist-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  @media (max-width: 860px) { grid-template-columns: repeat(2, 1fr); }
  @media (max-width: 540px) { grid-template-columns: 1fr; }
}
.artist-grid--small {
  grid-template-columns: repeat(4, 1fr);
  @media (max-width: 900px) { grid-template-columns: repeat(2, 1fr); }
  @media (max-width: 480px) { grid-template-columns: 1fr; }
}

// Artist card
.artist-card {
  display: block; text-decoration: none; color: inherit;
  border-radius: 16px; overflow: hidden;
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.09);
  transition: transform 0.3s cubic-bezier(0.22,1,0.36,1), box-shadow 0.3s, border-color 0.3s;
  &:hover {
    transform: translateY(-6px);
    box-shadow: 0 20px 44px rgba(0,0,0,0.22);
    border-color: var(--ac, rgba(124,77,255,0.5));
  }
}
.artist-card-accent { height: 4px; background: var(--ac, #7c4dff); }
.artist-card-body   { padding: 18px; }
.artist-card-top    { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
.artist-icon-circle {
  width: 48px; height: 48px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  border: 1.5px solid var(--ac, #7c4dff);
  &--sm { width: 38px; height: 38px; }
}
.artist-name     { font-size: 1.1rem; font-weight: 900; margin-bottom: 3px; }
.artist-subtitle { font-size: 10px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; opacity: 0.45; margin-bottom: 8px; }
.artist-bio      { font-size: 0.85rem; line-height: 1.6; opacity: 0.7; margin: 0; }
.artist-genres   { flex-wrap: wrap; }
.artist-more {
  font-size: 11px; font-weight: 700; letter-spacing: 1px;
  color: var(--ac, #7c4dff); display: flex; align-items: center; gap: 4px;
  margin-top: 12px;
}
</style>

<style lang="scss">
body.body--light {
  .artist-card {
    background: rgba(255,255,255,0.75) !important;
    border-color: rgba(0,0,0,0.07) !important;
  }
  .roster-label { color: rgba(0,0,0,0.4) !important; border-color: rgba(0,0,0,0.1) !important; }
}
</style>

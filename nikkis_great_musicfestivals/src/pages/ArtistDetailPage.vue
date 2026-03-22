<template>
  <q-page class="artist-detail-page">

    <div v-if="!artist" class="flex flex-center q-py-xl">
      <q-spinner-orbit color="primary" size="48px" />
    </div>

    <template v-else>

      <!-- Back nav -->
      <div class="detail-back q-pa-lg q-pb-none">
        <q-btn flat dense icon="arrow_back" label="All Artists" :to="'/artists'" color="primary" />
      </div>

      <!-- Hero strip -->
      <div class="detail-hero q-pa-lg q-pt-md">
        <div class="detail-hero-inner">

          <div class="detail-icon-wrap">
            <div class="detail-icon-ring" :style="`border-color: ${color}44`">
              <div class="detail-icon-bg" :style="`background: ${color}1a`">
                <q-icon :name="artist.icon" size="52px" :style="`color: ${color}`" />
              </div>
            </div>
          </div>

          <div class="detail-hero-text">
            <div class="detail-eyebrow">
              <q-badge :color="artist.badge_color" :label="artist.badge_text" class="q-mr-sm" />
              <span v-if="artist.featured" class="featured-mark">
                <q-icon name="star" size="12px" />Featured Artist
              </span>
            </div>
            <h1 class="detail-name">{{ artist.name }}</h1>
            <div class="detail-subtitle">{{ artist.subtitle }}</div>
            <div class="detail-meta row q-gutter-md q-mt-sm">
              <span><q-icon name="place" size="14px" /> {{ artist.origin }}</span>
              <span><q-icon name="schedule" size="14px" /> Active since {{ artist.active_since }}</span>
            </div>
            <div class="detail-genres row q-gutter-xs q-mt-md">
              <q-chip
                v-for="g in artist.genres" :key="g"
                dense outline
                :style="`color: ${color}; border-color: ${color}55`"
              >{{ g }}</q-chip>
            </div>
          </div>

        </div>
        <div class="detail-hero-rule" :style="`background: linear-gradient(90deg, ${color}, #ffd700, transparent)`" />
      </div>

      <!-- Body -->
      <div class="detail-body q-pa-lg">
        <div class="detail-columns">

          <!-- Left: full bio -->
          <div class="detail-bio-col">
            <div class="detail-section-label">About</div>
            <div
              v-for="(para, i) in bioParas"
              :key="i"
              class="detail-bio-para"
            >{{ para }}</div>
          </div>

          <!-- Right: sidebar -->
          <div class="detail-sidebar">

            <!-- Signature songs -->
            <div class="sidebar-card q-mb-lg">
              <div class="detail-section-label">Signature Songs</div>
              <div v-for="song in artist.songs" :key="song" class="sidebar-song">
                <q-icon name="music_note" size="14px" :style="`color: ${color}`" />
                {{ song }}
              </div>
            </div>

            <!-- Touring regions -->
            <div v-if="artist.touring_regions.length" class="sidebar-card q-mb-lg">
              <div class="detail-section-label">Tour Regions</div>
              <div v-for="rid in artist.touring_regions" :key="rid" class="sidebar-region">
                <router-link :to="`/maps/${rid}`" class="sidebar-region-link">
                  <q-icon name="explore" size="14px" :style="`color: ${color}`" />
                  {{ formatRegionId(rid) }}
                  <q-icon name="arrow_forward" size="12px" class="q-ml-xs" />
                </router-link>
              </div>
            </div>

            <!-- Links -->
            <div v-if="artist.links.length" class="sidebar-card">
              <div class="detail-section-label">Links</div>
              <a
                v-for="link in artist.links" :key="link.label"
                :href="link.url"
                target="_blank" rel="noopener"
                class="sidebar-link"
              >
                <q-icon :name="link.icon" size="14px" :style="`color: ${color}`" />
                {{ link.label }}
                <q-icon name="open_in_new" size="11px" class="q-ml-xs" />
              </a>
            </div>

          </div>
        </div>
      </div>

      <!-- Also in this roster -->
      <div class="detail-also q-pa-lg q-pt-none">
        <div class="detail-section-label q-mb-md">More Artists</div>
        <div class="also-row">
          <router-link
            v-for="a in related"
            :key="a.id"
            :to="`/artists/${a.id}`"
            class="also-chip"
            :style="`--ac: ${artistColor(a.icon_color)}`"
          >
            <q-icon :name="a.icon" size="16px" :style="`color: ${artistColor(a.icon_color)}`" />
            {{ a.name }}
          </router-link>
        </div>
      </div>

    </template>
  </q-page>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { ARTISTS, findArtist } from 'src/lib/artists'

const route  = useRoute()
const artist = computed(() => findArtist(route.params['id'] as string))

const COLOR_MAP: Record<string, string> = {
  amber: '#ffc107', 'deep-orange': '#ff6d00', purple: '#9c27b0',
  teal: '#009688', indigo: '#3f51b5', green: '#4caf50',
  pink: '#e91e63', blue: '#2196f3', red: '#f44336',
}
function artistColor(c: string): string { return COLOR_MAP[c] ?? '#7c4dff' }

const color   = computed(() => artistColor(artist.value?.icon_color ?? ''))
const bioParas = computed(() => (artist.value?.full_bio ?? '').split('\n\n').filter(Boolean))

const related = computed(() =>
  ARTISTS.filter(a => a.id !== artist.value?.id).slice(0, 6)
)

function formatRegionId(id: string): string {
  return id.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase())
}
</script>

<style lang="scss" scoped>
.artist-detail-page { max-width: 1100px; margin: 0 auto; min-height: 100vh; }

// Back
.detail-back { max-width: 1100px; padding-top: 24px; }

// Hero
.detail-hero { max-width: 1100px; }
.detail-hero-inner {
  display: flex; align-items: flex-start; gap: 32px; flex-wrap: wrap;
}
.detail-icon-wrap { flex-shrink: 0; }
.detail-icon-ring {
  width: 100px; height: 100px; border-radius: 50%;
  border: 2px solid transparent;
  display: flex; align-items: center; justify-content: center;
}
.detail-icon-bg {
  width: 88px; height: 88px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
}

.detail-hero-text { flex: 1; min-width: 260px; }
.detail-eyebrow { display: flex; align-items: center; gap: 6px; margin-bottom: 10px; }
.featured-mark {
  font-size: 10px; font-weight: 800; letter-spacing: 2px;
  text-transform: uppercase; color: #ffd700;
  display: flex; align-items: center; gap: 4px;
}
.detail-name {
  font-size: clamp(1.8rem, 4vw, 3rem);
  font-weight: 900; margin: 0 0 6px; line-height: 1.05;
}
.detail-subtitle {
  font-size: 11px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; opacity: 0.45; margin-bottom: 4px;
}
.detail-meta {
  font-size: 12px; opacity: 0.55;
  display: flex; flex-wrap: wrap;
  span { display: flex; align-items: center; gap: 4px; }
}
.detail-genres { flex-wrap: wrap; }
.detail-hero-rule { height: 3px; border-radius: 2px; margin-top: 28px; width: 100%; }

// Body
.detail-body { max-width: 1100px; padding-top: 36px; }
.detail-columns {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 40px;
  @media (max-width: 820px) { grid-template-columns: 1fr; }
}

.detail-section-label {
  font-size: 10px; font-weight: 900; letter-spacing: 3px;
  text-transform: uppercase; color: rgba(255,255,255,0.3);
  margin-bottom: 14px; border-bottom: 1px solid rgba(255,255,255,0.07);
  padding-bottom: 6px;
}
.detail-bio-para {
  font-size: 1rem; line-height: 1.75; opacity: 0.82;
  margin-bottom: 22px;
}

// Sidebar
.sidebar-card {
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 14px; padding: 18px;
}
.sidebar-song {
  display: flex; align-items: center; gap: 8px;
  font-size: 0.92rem; padding: 6px 0;
  border-bottom: 1px solid rgba(255,255,255,0.05);
  &:last-child { border-bottom: none; }
}
.sidebar-region { padding: 4px 0; }
.sidebar-region-link {
  font-size: 0.9rem; display: flex; align-items: center; gap: 6px;
  color: inherit; text-decoration: none; opacity: 0.75;
  transition: opacity 0.2s;
  &:hover { opacity: 1; }
}
.sidebar-link {
  display: flex; align-items: center; gap: 6px;
  font-size: 0.9rem; color: inherit; text-decoration: none;
  opacity: 0.7; padding: 6px 0;
  border-bottom: 1px solid rgba(255,255,255,0.05);
  transition: opacity 0.2s;
  &:hover { opacity: 1; }
  &:last-child { border-bottom: none; }
}

// Also row
.detail-also { max-width: 1100px; padding-top: 12px; padding-bottom: 40px; }
.also-row { display: flex; flex-wrap: wrap; gap: 10px; }
.also-chip {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 6px 14px; border-radius: 999px;
  background: rgba(255,255,255,0.05);
  border: 1px solid var(--ac, rgba(124,77,255,0.3));
  font-size: 13px; font-weight: 700;
  color: inherit; text-decoration: none;
  transition: background 0.2s, border-color 0.2s;
  &:hover { background: rgba(255,255,255,0.1); border-color: var(--ac, #7c4dff); }
}
</style>

<style lang="scss">
body.body--light {
  .sidebar-card {
    background: rgba(0,0,0,0.04) !important;
    border-color: rgba(0,0,0,0.08) !important;
  }
  .detail-section-label { color: rgba(0,0,0,0.35) !important; }
  .detail-bio-para { color: rgba(26,10,46,0.85) !important; }
  .also-chip {
    background: rgba(0,0,0,0.04) !important;
    &:hover { background: rgba(0,0,0,0.08) !important; }
  }
}
</style>

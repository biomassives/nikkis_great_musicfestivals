<template>
  <section class="ap-section q-pa-lg">

    <!-- ── Section header ──────────────────────────────────────────────── -->
    <div class="text-center q-mb-xl">
      <div class="ap-eyebrow">Listening Room</div>
      <h2 class="ap-title">From the Archive</h2>
      <div class="ap-rule" />
      <p class="ap-sub">
        Freely streamable recordings from the Internet Archive —
        classic jazz 78s, legendary live shows, and contemporary picks.
      </p>
    </div>

    <!-- ── Visual filmstrip (curated ARCHIVE_SHOWS — have reliable art) ── -->
    <div class="ap-filmstrip" role="listbox" aria-label="Browse shows">
      <button
        v-for="show in ARCHIVE_SHOWS"
        :key="show.id"
        role="option"
        :aria-selected="selectedId === show.id"
        class="ap-slide"
        :class="{ 'ap-slide--on': selectedId === show.id }"
        :title="show.label"
        @click="selectedId = show.id"
      >
        <div class="ap-slide-art">
          <img
            :src="`https://archive.org/services/img/${show.id}`"
            :alt="show.label"
            class="ap-slide-img"
            loading="lazy"
            @error="hideImg"
          />
          <!-- fallback sits behind image; visible when img fails or hasn't loaded -->
          <div class="ap-slide-fallback" aria-hidden="true">
            <q-icon name="album" size="24px" />
          </div>
        </div>
        <div class="ap-slide-label">{{ artistName(show.label) }}</div>
      </button>
    </div>

    <!-- ── Main card ───────────────────────────────────────────────────── -->
    <div class="ap-card">

      <!-- Tracklist sidebar -->
      <aside class="ap-tracklist" aria-label="Track list">
        <template v-for="group in trackGroups" :key="group.label">
          <div class="ap-group-label">{{ group.label }}</div>
          <button
            v-for="show in group.shows"
            :key="show.id"
            class="ap-track"
            :class="{ 'ap-track--on': selectedId === show.id }"
            @click="selectedId = show.id"
          >{{ show.label }}</button>
        </template>
      </aside>

      <!-- Embed + art area -->
      <div class="ap-embed">

        <!-- Art banner with cross-fade transition -->
        <div class="ap-art" :class="{ 'ap-art--error': artError }">
          <Transition name="ap-art-swap">
            <img
              v-if="!artError"
              :key="selectedId"
              :src="`https://archive.org/services/img/${selectedId}`"
              :alt="currentShow?.label"
              class="ap-art-img"
              @error="artError = true"
            />
          </Transition>
          <!-- Gradient overlay + metadata -->
          <div class="ap-art-overlay">
            <a
              :href="`https://archive.org/details/${selectedId}`"
              target="_blank" rel="noopener noreferrer"
              class="ap-art-badge"
              @click.stop
            >
              <q-icon name="graphic_eq" size="11px" />
              archive.org
              <q-icon name="open_in_new" size="9px" style="margin-left:2px; opacity:0.7" />
            </a>
            <div class="ap-art-meta">
              <div class="ap-art-now">Now Playing</div>
              <div class="ap-art-title">{{ currentShow?.label }}</div>
            </div>
          </div>
        </div>

        <!-- Archive.org embed player -->
        <div class="ap-frame-wrap">
          <iframe
            :key="selectedId"
            :src="`https://archive.org/embed/${selectedId}`"
            class="ap-frame"
            frameborder="0"
            allow="autoplay"
            allowfullscreen
            title="Archive.org music player"
          />
        </div>

      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import { ARCHIVE_SHOWS } from 'src/lib/archiveShows'
import { ARC_COLLECTIONS_SEED } from 'src/lib/arcCollections'
import type { ArcCollection } from 'src/lib/arcCollections'

// ── Arc collections ───────────────────────────────────────────────────────────
const arcCollections = ref<ArcCollection[]>([])

onMounted(async () => {
  const { data } = await supabase
    .from('site_settings')
    .select('value')
    .eq('key', 'arc_collections')
    .maybeSingle()
  const raw: unknown = data?.value
  arcCollections.value =
    (Array.isArray(raw) ? (raw as ArcCollection[]) : null)
    ?? ARC_COLLECTIONS_SEED
})

// ── Show selection ────────────────────────────────────────────────────────────
const selectedId = ref(ARCHIVE_SHOWS[0]!.id)

// Reset art error state whenever the selected show changes
const artError = ref(false)
watch(selectedId, () => { artError.value = false })

const allShows = computed(() => [
  ...ARCHIVE_SHOWS,
  ...arcCollections.value.flatMap(c => c.entries),
])

const currentShow = computed(() =>
  allShows.value.find(s => s.id === selectedId.value)
)

// ── Track groups ──────────────────────────────────────────────────────────────
interface Group { label: string; shows: { id: string; label: string }[] }

const trackGroups = computed<Group[]>(() => [
  {
    label: 'Classic Jazz · 78 rpm',
    shows: ARCHIVE_SHOWS.filter(s => s.id.startsWith('78_')),
  },
  {
    label: 'Grateful Dead',
    shows: ARCHIVE_SHOWS.filter(s => s.id.startsWith('gd')),
  },
  {
    label: 'Phish · SCI · Contemporary',
    shows: ARCHIVE_SHOWS.filter(
      s => !s.id.startsWith('78_') && !s.id.startsWith('gd')
    ),
  },
  // Arc collections — one group per collection
  ...arcCollections.value.map(c => ({
    label: c.title,
    shows: c.entries,
  })),
].filter(g => g.shows.length > 0))

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Extract artist name — the segment before " · " */
function artistName(label: string): string {
  return label.split(' · ')[0] ?? label
}

/** Hide broken filmstrip images without showing the browser's broken-img icon */
function hideImg(e: Event) {
  if (e.target instanceof HTMLImageElement) e.target.style.display = 'none'
}
</script>

<style lang="scss" scoped>
// ── Section shell ─────────────────────────────────────────────────────────────
.ap-section {
  padding-top: 80px;
  padding-bottom: 80px;
  max-width: 1100px;
  margin: 0 auto;
}

.ap-eyebrow {
  font-size: 10px; font-weight: 900; letter-spacing: 4px;
  text-transform: uppercase; color: #ab47bc; margin-bottom: 10px;
}
.ap-title {
  font-size: clamp(1.6rem, 4vw, 2.4rem);
  font-weight: 900; margin: 0 0 16px; color: inherit;
}
.ap-rule {
  width: 60px; height: 4px; border-radius: 2px;
  background: linear-gradient(90deg, #7c4dff, #ffd700);
  margin: 0 auto 20px;
}
.ap-sub {
  max-width: 540px; margin: 0 auto;
  opacity: 0.7; font-size: 1rem; line-height: 1.6;
}

// ── Filmstrip ─────────────────────────────────────────────────────────────────
.ap-filmstrip {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding: 4px 2px 16px;
  scrollbar-width: thin;
  scrollbar-color: rgba(124,77,255,0.3) transparent;
  &::-webkit-scrollbar { height: 4px; }
  &::-webkit-scrollbar-thumb { background: rgba(124,77,255,0.3); border-radius: 2px; }
}

.ap-slide {
  flex-shrink: 0;
  width: 96px;
  background: transparent;
  border: 2px solid rgba(124,77,255,0.18);
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  padding: 0;
  transition: border-color 0.2s, transform 0.2s, box-shadow 0.2s;

  &:hover {
    border-color: rgba(124,77,255,0.55);
    transform: translateY(-3px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.35);
  }
  &--on {
    border-color: #ffd700;
    box-shadow: 0 0 0 1px #ffd70044, 0 8px 24px rgba(255,215,0,0.18);
  }
}

.ap-slide-art {
  position: relative;
  width: 96px;
  height: 96px;
  background: rgba(124,77,255,0.12);
  overflow: hidden;
}

.ap-slide-img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  z-index: 1;
}

.ap-slide-fallback {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(124,77,255,0.4);
  z-index: 0; // behind image when it loads
}

.ap-slide-label {
  padding: 5px 6px 6px;
  font-size: 9.5px;
  font-weight: 700;
  line-height: 1.3;
  letter-spacing: 0.2px;
  color: rgba(255,255,255,0.55);
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  .ap-slide--on & { color: #ffd700; }
}

// ── Player card ───────────────────────────────────────────────────────────────
.ap-card {
  display: grid;
  grid-template-columns: 240px 1fr;
  border-radius: 20px;
  overflow: hidden;
  border: 1px solid rgba(124,77,255,0.22);
  background: rgba(124,77,255,0.07);
  box-shadow: 0 16px 48px rgba(0,0,0,0.25);

  @media (max-width: 720px) { grid-template-columns: 1fr; }
}

// ── Tracklist sidebar (unchanged) ─────────────────────────────────────────────
.ap-tracklist {
  display: flex;
  flex-direction: column;
  padding: 16px 12px;
  border-right: 1px solid rgba(124,77,255,0.15);
  overflow-y: auto;
  max-height: 600px;

  @media (max-width: 720px) {
    flex-direction: row;
    flex-wrap: nowrap;
    overflow-x: auto;
    overflow-y: hidden;
    max-height: none;
    border-right: none;
    border-bottom: 1px solid rgba(124,77,255,0.15);
    padding: 10px 12px;
    gap: 4px;
  }
}

.ap-group-label {
  font-size: 9px; font-weight: 900; letter-spacing: 2px;
  text-transform: uppercase; color: #ab47bc;
  padding: 10px 8px 4px;
  @media (max-width: 720px) { display: none; }
}

.ap-track {
  background: transparent;
  border: none;
  cursor: pointer;
  text-align: left;
  padding: 7px 10px;
  border-radius: 7px;
  font-size: 11.5px;
  font-weight: 600;
  line-height: 1.35;
  color: rgba(255,255,255,0.6);
  transition: background 0.18s, color 0.18s;
  white-space: nowrap;

  &:hover {
    background: rgba(124,77,255,0.18);
    color: rgba(255,255,255,0.92);
  }
  &--on {
    background: rgba(124,77,255,0.28);
    color: #ffd700;
    font-weight: 700;
  }
}

// ── Embed area ────────────────────────────────────────────────────────────────
.ap-embed {
  display: flex;
  flex-direction: column;
  min-height: 560px;
}

// ── Art banner ────────────────────────────────────────────────────────────────
.ap-art {
  position: relative;
  height: 190px;
  flex-shrink: 0;
  overflow: hidden;
  background: linear-gradient(135deg, #0d0024 0%, #1a0042 100%);

  // Subtle pattern when no art / error fallback
  &--error {
    background:
      repeating-linear-gradient(
        45deg,
        rgba(124,77,255,0.04) 0px,
        rgba(124,77,255,0.04) 1px,
        transparent 1px,
        transparent 10px
      ),
      linear-gradient(135deg, #0d0024 0%, #1a0042 100%);
  }
}

.ap-art-img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center top;
}

// Cross-fade transition between shows
.ap-art-swap-enter-active,
.ap-art-swap-leave-active {
  transition: opacity 0.55s ease;
}
.ap-art-swap-enter-from,
.ap-art-swap-leave-to { opacity: 0; }

// Gradient overlay — fades art into card bg at bottom, plus vignette
.ap-art-overlay {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(to top,  rgba(13,0,36,0.96) 0%, rgba(13,0,36,0.3) 45%, transparent 75%),
    linear-gradient(to right, rgba(0,0,0,0.18) 0%, transparent 30%);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 12px 16px;
}

.ap-art-badge {
  align-self: flex-end;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
  color: rgba(255,215,0,0.7);
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
  background: rgba(0,0,0,0.35);
  backdrop-filter: blur(4px);
  transition: color 0.2s, background 0.2s;
  &:hover { color: #ffd700; background: rgba(0,0,0,0.55); }
}

.ap-art-meta { display: flex; flex-direction: column; gap: 3px; }

.ap-art-now {
  font-size: 8.5px; font-weight: 900; letter-spacing: 3px;
  text-transform: uppercase; color: #ffd700; opacity: 0.8;
}

.ap-art-title {
  font-size: 0.92rem; font-weight: 700;
  color: rgba(255,255,255,0.92);
  line-height: 1.3;
  // Clamp to 2 lines
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

// ── Archive embed frame ───────────────────────────────────────────────────────
.ap-frame-wrap {
  flex: 1;
  background: rgba(0,0,0,0.2);
  min-height: 340px;
}

.ap-frame {
  width: 100%;
  height: 100%;
  min-height: 340px;
  border: none;
  display: block;
}
</style>

<style lang="scss">
/* ── Light-mode overrides (unscoped) ──────────────────────────────────────── */
body.body--light {
  .ap-card {
    background: rgba(255,255,255,0.72) !important;
    border-color: rgba(124,77,255,0.18) !important;
    box-shadow: 0 16px 48px rgba(75,0,130,0.1) !important;
  }
  .ap-track {
    color: rgba(26,10,46,0.65) !important;
    &:hover  { background: rgba(124,77,255,0.1) !important; color: #1a0a2e !important; }
    &--on    { background: rgba(124,77,255,0.15) !important; color: #5a0080 !important; }
  }
  .ap-art-title { color: #fff !important; } // always readable over the dark gradient
  .ap-frame-wrap { background: rgba(124,77,255,0.04) !important; }
  .ap-tracklist {
    border-right-color: rgba(124,77,255,0.12) !important;
    border-bottom-color: rgba(124,77,255,0.12) !important;
  }
  .ap-slide {
    border-color: rgba(124,77,255,0.2) !important;
    &--on { border-color: #f5a623 !important; }
  }
  .ap-slide-label { color: rgba(26,10,46,0.55) !important; }
  .ap-slide--on .ap-slide-label { color: #b34d00 !important; }
}
</style>

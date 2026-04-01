<template>
  <q-page :class="['sdp', $q.dark.isActive ? 'sdp--dark' : 'sdp--light']">

    <!-- ── Header ──────────────────────────────────────────────────────── -->
    <header class="sdp-header">
      <button class="sdp-back" @click="router.push(`/maps/${regionId}`)">
        <q-icon name="west" size="14px" />
        <span>{{ region?.name ?? 'Map' }}</span>
      </button>

      <div class="sdp-title-block">
        <div class="sdp-show-name">{{ show?.name ?? '…' }}</div>
        <div class="sdp-show-date" v-if="show?.date">
          {{ formatDate(show.date) }} &middot; 2026
        </div>
      </div>

      <div class="sdp-header-actions">
        <button class="sdp-hpill" :class="{ 'is-active': isStarred }" @click="toggleStar" title="Give this show a star">
          <q-icon :name="isStarred ? 'star' : 'star_border'" size="15px" />
          <span>{{ starCount }}</span>
        </button>
        <button class="sdp-hpill sdp-hpill--boost" :class="{ 'is-active': isBoosted }" @click="addBoost" title="Boost this show">
          <q-icon name="rocket_launch" size="15px" />
          <span>{{ boostCount }}</span>
        </button>
      </div>
    </header>

    <!-- ── Mondrian color strip ─────────────────────────────────────────── -->
    <div class="sdp-strip">
      <div class="sdp-strip-blk" style="background:#cc1010;flex:3" />
      <div class="sdp-strip-sep" />
      <div class="sdp-strip-blk" style="background:#111;flex:1" />
      <div class="sdp-strip-sep" />
      <div class="sdp-strip-blk" style="background:#ffd600;flex:5" />
      <div class="sdp-strip-sep" />
      <div class="sdp-strip-blk" style="background:#1040a8;flex:2" />
      <div class="sdp-strip-sep" />
      <div class="sdp-strip-blk" style="background:#f5f0e8;flex:7" />
      <div class="sdp-strip-sep" />
      <div class="sdp-strip-blk" style="background:#cc1010;flex:1" />
    </div>

    <!-- ── Hero ────────────────────────────────────────────────────────── -->
    <section class="sdp-hero">
      <div class="sdp-hero-left">
        <div class="sdp-region-tag">
          <q-icon name="place" size="11px" />
          {{ region?.name }} &middot; 2026 Summer Tour
        </div>
        <h1 class="sdp-h1">{{ show?.name ?? '…' }}</h1>
        <div class="sdp-chips" v-if="show?.date">
          <span class="sdp-chip sdp-chip--blue">
            <q-icon name="calendar_month" size="11px" />
            {{ formatDate(show.date) }}, 2026
          </span>
          <span class="sdp-chip sdp-chip--yellow">
            <q-icon name="map" size="11px" />
            {{ region?.name }}
          </span>
        </div>
        <p class="sdp-desc" v-if="show?.description">{{ show.description }}</p>
        <p class="sdp-desc sdp-desc--muted" v-else>No description added for this show yet.</p>
      </div>

      <div class="sdp-engage">
        <!-- Star -->
        <div class="sdp-eng-block" :class="{ 'is-active': isStarred }" @click="toggleStar">
          <q-icon :name="isStarred ? 'star' : 'star_border'" size="38px" class="sdp-eng-icon" />
          <div class="sdp-eng-count">{{ starCount }}</div>
          <div class="sdp-eng-label">Stars</div>
        </div>

        <div class="sdp-eng-divider" />

        <!-- Boost -->
        <div class="sdp-eng-block sdp-eng-block--boost" :class="{ 'is-active': isBoosted }" @click="addBoost">
          <q-icon name="rocket_launch" size="38px" class="sdp-eng-icon" />
          <div class="sdp-eng-count">{{ boostCount }}</div>
          <div class="sdp-eng-label">Boosts</div>
        </div>
      </div>
    </section>

    <!-- ── Body: map + fan board ────────────────────────────────────────── -->
    <section class="sdp-body">

      <!-- Mini map centered on venue -->
      <div class="sdp-map-col">
        <div id="show-detail-map" class="sdp-map" />
        <div v-if="show" class="sdp-map-label">
          <q-icon name="location_on" size="12px" />
          {{ show.lat.toFixed(3) }}, {{ show.lng.toFixed(3) }}
        </div>
      </div>

      <!-- Fan board comments -->
      <div class="sdp-board-col">

        <div class="sdp-board-head">
          <q-icon name="forum" size="13px" />
          <span>Fan Board</span>
          <span class="sdp-board-badge">{{ comments.length }}</span>
          <router-link to="/board" class="sdp-board-viewall">
            View all <q-icon name="arrow_forward" size="11px" />
          </router-link>
        </div>

        <div class="sdp-comment-list" ref="commentListEl">
          <div v-if="loadingComments" class="sdp-empty-state">
            <q-spinner size="20px" />
          </div>
          <div v-else-if="!comments.length" class="sdp-empty-state">
            Be the first to leave a note about this show!
          </div>
          <div v-for="c in comments" :key="c.id" class="sdp-comment">
            <div class="sdp-comment-meta">
              <span class="sdp-comment-author">{{ c.author_name }}</span>
              <span class="sdp-comment-age">{{ commentAge(c.created_at) }}</span>
            </div>
            <p class="sdp-comment-msg">{{ c.message }}</p>
          </div>
        </div>

        <form class="sdp-post-form" @submit.prevent="postComment">
          <input
            v-model="draft.author"
            class="sdp-field"
            placeholder="Your name (optional)"
            maxlength="50"
            autocomplete="nickname"
          />
          <textarea
            v-model="draft.message"
            class="sdp-field sdp-field--ta"
            placeholder="Share a memory or note about this show…"
            maxlength="500"
            rows="3"
          />
          <div class="sdp-form-footer">
            <span class="sdp-char-count">{{ draft.message.length }}/500</span>
            <button
              type="submit"
              class="sdp-submit"
              :disabled="posting || !draft.message.trim()"
            >
              <q-icon name="send" size="12px" />
              Post to board
            </button>
          </div>
        </form>

      </div>
    </section>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { supabase } from 'src/lib/supabase'
import type { MapRegion, MapPoint } from 'src/lib/supabase'

const route  = useRoute()
const router = useRouter()
const $q     = useQuasar()

const regionId = route.params.regionId as string
const showId   = route.params.showId   as string

// ── Data ───────────────────────────────────────────────────────────────────
const region = ref<MapRegion | null>(null)
const show   = ref<MapPoint  | null>(null)

// ── Engagement ────────────────────────────────────────────────────────────
const starCount  = ref(0)
const boostCount = ref(0)
const isStarred  = ref(false)
const isBoosted  = ref(false)

const STAR_KEY  = `show_star_${showId}`
const BOOST_KEY = `show_boost_${showId}`

async function loadEngagement() {
  const [{ count: sc }, { count: bc }] = await Promise.all([
    supabase.from('show_stars').select('*',  { count: 'exact', head: true }).eq('show_id', showId),
    supabase.from('show_boosts').select('*', { count: 'exact', head: true }).eq('show_id', showId),
  ])
  starCount.value  = sc ?? 0
  boostCount.value = bc ?? 0
  isStarred.value  = localStorage.getItem(STAR_KEY)  === '1'
  isBoosted.value  = localStorage.getItem(BOOST_KEY) === '1'
}

async function toggleStar() {
  if (isStarred.value) return
  const { error } = await supabase.from('show_stars').insert({ show_id: showId })
  if (!error) {
    isStarred.value = true
    starCount.value++
    localStorage.setItem(STAR_KEY, '1')
  }
}

async function addBoost() {
  if (isBoosted.value) return
  const { error } = await supabase.from('show_boosts').insert({ show_id: showId })
  if (!error) {
    isBoosted.value = true
    boostCount.value++
    localStorage.setItem(BOOST_KEY, '1')
  }
}

// ── Comments ──────────────────────────────────────────────────────────────
interface ShowComment {
  id: string
  author_name: string
  message: string
  created_at: string
}

const comments        = ref<ShowComment[]>([])
const loadingComments = ref(true)
const posting         = ref(false)
const commentListEl   = ref<HTMLElement | null>(null)
const draft           = reactive({ author: '', message: '' })

async function loadComments() {
  loadingComments.value = true
  const { data } = await supabase
    .from('show_comments')
    .select('id, author_name, message, created_at')
    .eq('show_id', showId)
    .order('created_at', { ascending: true })
    .limit(200)
  comments.value        = (data as ShowComment[]) ?? []
  loadingComments.value = false
}

async function postComment() {
  const msg = draft.message.trim()
  if (!msg || posting.value) return
  posting.value = true
  const { data, error } = await supabase.from('show_comments').insert({
    show_id:     showId,
    author_name: draft.author.trim() || 'Anonymous',
    message:     msg,
  }).select().single()
  posting.value = false
  if (!error && data) {
    comments.value.push(data as ShowComment)
    draft.message = ''
    setTimeout(() => {
      if (commentListEl.value)
        commentListEl.value.scrollTop = commentListEl.value.scrollHeight
    }, 60)
  }
}

function commentAge(d: string): string {
  const mins = Math.floor((Date.now() - new Date(d).getTime()) / 60000)
  if (mins < 1)   return 'just now'
  if (mins < 60)  return `${mins}m ago`
  const hrs = Math.floor(mins / 60)
  if (hrs  < 24)  return `${hrs}h ago`
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

// ── Map ───────────────────────────────────────────────────────────────────
let mapInstance: L.Map | null = null

function initMap() {
  if (!show.value) return
  mapInstance = L.map('show-detail-map', {
    zoomControl: true,
    attributionControl: false,
  }).setView([show.value.lat, show.value.lng], 13)

  L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
    subdomains: 'abcd', maxZoom: 19,
  }).addTo(mapInstance)

  if ($q.dark.isActive) {
    const tp = mapInstance.getPane('tilePane')
    if (tp) tp.style.filter = 'invert(1) hue-rotate(180deg) brightness(0.68) saturate(0.80)'
  }

  L.marker([show.value.lat, show.value.lng], {
    icon: L.divIcon({
      className: '',
      html: `<div style="
        width:32px;height:32px;border-radius:50%;
        background:#cc1010;border:3px solid #111;
        display:flex;align-items:center;justify-content:center;
        font-size:13px;font-weight:900;color:#fff;
        box-shadow:0 3px 12px rgba(0,0,0,0.5);
      ">★</div>`,
      iconSize: [32, 32], iconAnchor: [16, 16],
    }),
  }).addTo(mapInstance)
}

// ── Helpers ───────────────────────────────────────────────────────────────
function formatDate(d: string | null): string {
  if (!d) return ''
  return new Date(d).toLocaleDateString('en-US', { month: 'long', day: 'numeric' })
}

// ── Lifecycle ─────────────────────────────────────────────────────────────
onMounted(async () => {
  const [{ data: rgn }, { data: pt }] = await Promise.all([
    supabase.from('map_regions').select('*').eq('id', regionId).single(),
    supabase.from('map_points').select('*').eq('id', showId).single(),
  ])
  region.value = rgn
  show.value   = pt as MapPoint

  await Promise.all([loadEngagement(), loadComments()])
  initMap()
})

onUnmounted(() => { mapInstance?.remove() })
</script>

<style lang="scss" scoped>
$border: 3px solid #000;
$red:    #cc1010;
$blue:   #1040a8;
$yellow: #ffd600;

.sdp {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  font-family: 'Space Mono', monospace;
}

// ── Header ─────────────────────────────────────────────────────────────────
.sdp-header {
  display: grid;
  grid-template-columns: 140px 1fr auto;
  height: 64px;
  border-bottom: $border;
}

.sdp-back {
  display: flex; align-items: center; gap: 8px;
  padding: 0 16px;
  border: none; border-right: $border;
  background: #000; color: #fff;
  font-size: 11px; font-weight: 800; letter-spacing: 1px; text-transform: uppercase;
  cursor: pointer;
  transition: background 0.15s;
  font-family: inherit;
  &:hover { background: $red; }
}

.sdp-title-block {
  display: flex; flex-direction: column; justify-content: center;
  padding: 0 20px; border-right: $border; min-width: 0;
  .sdp-show-name { font-size: 16px; font-weight: 900; line-height: 1.1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .sdp-show-date { font-size: 11px; color: rgba(0,0,0,0.45); margin-top: 2px; }
}

.sdp-header-actions {
  display: flex; align-items: center; gap: 8px; padding: 0 16px;
}

.sdp-hpill {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 5px 14px;
  border: 2px solid #000; background: #fff;
  font-size: 12px; font-weight: 800;
  cursor: pointer; font-family: inherit;
  transition: all 0.15s;
  &.is-active, &:hover { background: $yellow; }
  &--boost {
    &.is-active, &:hover { background: $blue; color: #fff; }
  }
}

// ── Mondrian strip ─────────────────────────────────────────────────────────
.sdp-strip {
  display: flex; height: 14px;
  border-bottom: $border; overflow: hidden;
}
.sdp-strip-blk { height: 100%; flex-shrink: 0; }
.sdp-strip-sep { width: 3px; flex-shrink: 0; background: #111; }

// ── Hero ───────────────────────────────────────────────────────────────────
.sdp-hero {
  display: flex; border-bottom: $border;
  min-height: 160px;
}

.sdp-hero-left {
  flex: 1; padding: 20px 24px;
  border-right: $border; min-width: 0;
}

.sdp-region-tag {
  display: inline-flex; align-items: center; gap: 4px;
  font-size: 10px; font-weight: 800; letter-spacing: 1.5px;
  color: $red; text-transform: uppercase; margin-bottom: 6px;
}

.sdp-h1 {
  font-size: clamp(20px, 3.5vw, 32px);
  font-weight: 900; line-height: 1.1;
  margin: 0 0 10px;
}

.sdp-chips { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 12px; }

.sdp-chip {
  display: inline-flex; align-items: center; gap: 4px;
  padding: 3px 10px;
  font-size: 10px; font-weight: 800;
  border: 2px solid #000;
  &--blue   { background: $blue;   color: #fff; }
  &--yellow { background: $yellow; color: #000; }
}

.sdp-desc {
  font-size: 13px; line-height: 1.75; color: rgba(0,0,0,0.65); margin: 0;
  &--muted { color: rgba(0,0,0,0.35); font-style: italic; }
}

// ── Engagement panel ───────────────────────────────────────────────────────
.sdp-engage {
  display: flex; flex-direction: column;
  width: 130px; flex-shrink: 0;
  border-left: $border;
}

.sdp-eng-divider { height: 3px; background: #000; flex-shrink: 0; }

.sdp-eng-block {
  flex: 1; display: flex; flex-direction: column;
  align-items: center; justify-content: center; gap: 4px;
  cursor: pointer; padding: 12px 0;
  transition: background 0.15s;

  &:hover,
  &.is-active           { background: $yellow; }
  &--boost {
    &:hover,
    &.is-active         { background: $blue; color: #fff; }
  }
}

.sdp-eng-icon  { pointer-events: none; }

.sdp-eng-count {
  font-size: 22px; font-weight: 900; line-height: 1;
}

.sdp-eng-label {
  font-size: 9px; font-weight: 800; letter-spacing: 1.5px;
  text-transform: uppercase; opacity: 0.6;
}

// ── Body ───────────────────────────────────────────────────────────────────
.sdp-body {
  flex: 1; display: flex; min-height: 420px;
}

// Map column
.sdp-map-col {
  flex: 0 0 44%; position: relative;
  border-right: $border; overflow: hidden;
  @media (max-width: 680px) { flex: 0 0 100%; border-right: none; min-height: 280px; }
}

.sdp-map {
  width: 100%; height: 100%; min-height: 380px;
}

.sdp-map-label {
  position: absolute; bottom: 0; left: 0; right: 0;
  background: rgba(0,0,0,0.72); color: rgba(255,255,255,0.7);
  font-size: 9px; font-weight: 700; letter-spacing: 0.5px;
  padding: 4px 12px;
  display: flex; align-items: center; gap: 4px;
  z-index: 500;
}

// Fan board column
.sdp-board-col {
  flex: 1; display: flex; flex-direction: column; min-width: 0;
  @media (max-width: 680px) { min-height: 400px; }
}

.sdp-board-head {
  display: flex; align-items: center; gap: 8px;
  padding: 10px 16px; border-bottom: $border;
  font-size: 11px; font-weight: 800; letter-spacing: 1px; text-transform: uppercase;
  background: #000; color: #fff; flex-shrink: 0;
}

.sdp-board-badge {
  background: $red; color: #fff;
  padding: 1px 7px; border-radius: 10px; font-size: 10px;
}

.sdp-board-viewall {
  margin-left: auto;
  color: $yellow; font-size: 10px; font-weight: 700;
  text-decoration: none;
  display: flex; align-items: center; gap: 3px;
  &:hover { text-decoration: underline; }
}

.sdp-comment-list {
  flex: 1; overflow-y: auto; padding: 12px 16px;
  display: flex; flex-direction: column; gap: 10px;
  &::-webkit-scrollbar { width: 3px; }
  &::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.15); border-radius: 2px; }
}

.sdp-empty-state {
  flex: 1; display: flex; align-items: center; justify-content: center;
  color: rgba(0,0,0,0.35); font-size: 12px; text-align: center; padding: 24px 0;
}

.sdp-comment {
  border-left: 3px solid $blue;
  padding: 6px 10px;
  background: rgba(16,64,168,0.04);
  border-radius: 0 3px 3px 0;
}

.sdp-comment-meta {
  display: flex; align-items: center; gap: 8px; margin-bottom: 3px;
}

.sdp-comment-author {
  font-size: 11px; font-weight: 800; color: $blue;
}

.sdp-comment-age {
  font-size: 9px; color: rgba(0,0,0,0.32);
}

.sdp-comment-msg {
  font-size: 12px; line-height: 1.65; color: rgba(0,0,0,0.68); margin: 0;
}

// Post form
.sdp-post-form {
  border-top: $border; padding: 12px 16px;
  display: flex; flex-direction: column; gap: 8px; flex-shrink: 0;
}

.sdp-field {
  width: 100%; border: 2px solid #000;
  padding: 7px 10px; font-size: 12px;
  font-family: 'Space Mono', monospace;
  background: #fff; outline: none;
  transition: border-color 0.15s;
  &:focus { border-color: $blue; }
  &--ta { resize: vertical; min-height: 58px; }
}

.sdp-form-footer {
  display: flex; align-items: center; justify-content: space-between;
}

.sdp-char-count {
  font-size: 9px; color: rgba(0,0,0,0.3); font-weight: 600;
}

.sdp-submit {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 7px 18px;
  background: $blue; color: #fff;
  border: 2px solid #000;
  font-size: 11px; font-weight: 800; letter-spacing: 1px; text-transform: uppercase;
  cursor: pointer; font-family: inherit;
  transition: background 0.15s;
  &:hover:not(:disabled) { background: $red; }
  &:disabled { opacity: 0.45; cursor: not-allowed; }
}

// ── Dark mode ──────────────────────────────────────────────────────────────
.sdp--dark {
  background: #0a0a10;

  .sdp-header     { border-bottom-color: #222; }
  .sdp-back       { background: #111; &:hover { background: $red; } }
  .sdp-title-block {
    border-right-color: #222;
    .sdp-show-name { color: #eeeaff; }
    .sdp-show-date { color: rgba(255,255,255,0.35); }
  }
  .sdp-hpill {
    background: #1a1a2e; border-color: #444; color: rgba(255,255,255,0.8);
    &.is-active, &:hover { background: $yellow; color: #000; }
    &--boost { &.is-active, &:hover { background: $blue; color: #fff; } }
  }
  .sdp-strip  { border-bottom-color: #222; }
  .sdp-hero   { border-bottom-color: #222; background: #0d0d18; }
  .sdp-hero-left { border-right-color: #222; }
  .sdp-h1     { color: #eeeaff; }
  .sdp-desc   { color: rgba(255,255,255,0.55); &--muted { color: rgba(255,255,255,0.25); } }
  .sdp-engage { border-left-color: #222; }
  .sdp-eng-divider { background: #222; }
  .sdp-eng-block {
    &:hover:not(.is-active) { background: rgba(255,214,0,0.1); }
    &--boost:hover:not(.is-active) { background: rgba(16,64,168,0.25); }
  }
  .sdp-body          { background: #0a0a10; }
  .sdp-map-col       { border-right-color: #222; }
  .sdp-board-head    { background: #111; border-bottom-color: #222; }
  .sdp-comment-list  { background: #0d0d18; }
  .sdp-empty-state   { color: rgba(255,255,255,0.28); }
  .sdp-comment       { background: rgba(16,64,168,0.12); }
  .sdp-comment-msg   { color: rgba(255,255,255,0.68); }
  .sdp-comment-age   { color: rgba(255,255,255,0.28); }
  .sdp-post-form     { border-top-color: #222; background: #0d0d18; }
  .sdp-field {
    background: #1a1a2e; border-color: #333; color: rgba(255,255,255,0.85);
    &:focus { border-color: $blue; }
    &::placeholder { color: rgba(255,255,255,0.28); }
  }
  .sdp-char-count    { color: rgba(255,255,255,0.25); }
}
</style>

<style>
.sdp-map .leaflet-control-attribution { display: none; }
</style>

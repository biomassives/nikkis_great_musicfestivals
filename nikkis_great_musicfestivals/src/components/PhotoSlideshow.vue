<!--
  PhotoSlideshow — fullscreen overlay with mandala navigation.
  Props:
    photos  : GalleryPhoto[]  — all photos for this slideshow
    startIndex: number        — which photo to open on
  Emits:
    close
-->
<template>
  <teleport to="body">
    <div class="slideshow-overlay" @keydown="onKey" tabindex="0" ref="rootEl">

      <!-- Photo -->
      <transition name="fade-photo" mode="out-in">
        <img
          :key="current"
          :src="photos[current]?.url"
          class="slideshow-img"
          :alt="photos[current]?.caption ?? ''"
        />
      </transition>

      <!-- Gradient vignette -->
      <div class="vignette"></div>

      <!-- Caption bar -->
      <div class="caption-bar" v-if="photos[current]?.caption">
        <span>{{ photos[current]?.caption }}</span>
        <span class="counter">{{ current + 1 }} / {{ photos.length }}</span>
      </div>
      <div class="caption-bar" v-else>
        <span></span>
        <span class="counter">{{ current + 1 }} / {{ photos.length }}</span>
      </div>

      <!-- ── Mandala Nav ── -->
      <div class="mandala-wrap">

        <!-- SVG Mandala (decorative + interactive zones) -->
        <svg class="mandala-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <radialGradient id="mandGrad" cx="50%" cy="50%" r="50%">
              <stop offset="0%"   stop-color="#4b0082" stop-opacity="0.85"/>
              <stop offset="60%"  stop-color="#1a237e" stop-opacity="0.80"/>
              <stop offset="100%" stop-color="#000d1a" stop-opacity="0.70"/>
            </radialGradient>
            <clipPath id="mandClip">
              <circle cx="100" cy="100" r="96"/>
            </clipPath>
          </defs>

          <!-- Base disc -->
          <circle cx="100" cy="100" r="96" fill="url(#mandGrad)" />

          <!-- Decorative petal rings (8-fold) -->
          <g clip-path="url(#mandClip)" opacity="0.25">
            <g v-for="i in 8" :key="i" :transform="`rotate(${i*45} 100 100)`">
              <ellipse cx="100" cy="44" rx="10" ry="24" fill="none" stroke="#7986cb" stroke-width="0.8"/>
            </g>
          </g>

          <!-- Concentric rings -->
          <circle cx="100" cy="100" r="88"  fill="none" stroke="rgba(121,134,203,0.2)" stroke-width="0.6"/>
          <circle cx="100" cy="100" r="72"  fill="none" stroke="rgba(121,134,203,0.25)" stroke-width="0.8"/>
          <circle cx="100" cy="100" r="56"  fill="none" stroke="rgba(121,134,203,0.2)" stroke-width="0.6"/>
          <circle cx="100" cy="100" r="40"  fill="none" stroke="rgba(255,215,0,0.15)"   stroke-width="1"/>

          <!-- Radial spoke lines -->
          <g opacity="0.12">
            <g v-for="i in 12" :key="i" :transform="`rotate(${i*30} 100 100)`">
              <line x1="100" y1="8" x2="100" y2="44" stroke="#7986cb" stroke-width="0.5"/>
            </g>
          </g>

          <!-- ── PREV zone (left arc, r 40-88) ── -->
          <path
            d="M100,100 L12,100 A88,88 0 0,1 100,12 Z"
            fill="transparent"
            class="zone-prev"
            @click.stop="prev"
          />
          <!-- NEXT zone (right arc) -->
          <path
            d="M100,100 L188,100 A88,88 0 0,0 100,12 Z"
            fill="transparent"
            class="zone-next"
            @click.stop="next"
          />
          <!-- PREV lower-left -->
          <path
            d="M100,100 L12,100 A88,88 0 0,0 100,188 Z"
            fill="transparent"
            class="zone-prev"
            @click.stop="prev"
          />
          <!-- NEXT lower-right -->
          <path
            d="M100,100 L188,100 A88,88 0 0,1 100,188 Z"
            fill="transparent"
            class="zone-next"
            @click.stop="next"
          />

          <!-- Zone hover highlights (rendered behind icons) -->
          <path
            d="M100,100 L12,100 A88,88 0 1,1 100,188 Z"
            fill="rgba(89,107,192,0)"
            class="zone-prev-hl"
            pointer-events="none"
          />

          <!-- ── Arrow icons ── -->
          <!-- Prev arrow -->
          <g @click.stop="prev" class="arrow-btn" style="cursor:pointer">
            <circle cx="38" cy="100" r="14" fill="rgba(0,0,0,0.4)"/>
            <polyline points="44,93 35,100 44,107" fill="none" stroke="white" stroke-width="2.5"
              stroke-linecap="round" stroke-linejoin="round"/>
          </g>
          <!-- Next arrow -->
          <g @click.stop="next" class="arrow-btn" style="cursor:pointer">
            <circle cx="162" cy="100" r="14" fill="rgba(0,0,0,0.4)"/>
            <polyline points="156,93 165,100 156,107" fill="none" stroke="white" stroke-width="2.5"
              stroke-linecap="round" stroke-linejoin="round"/>
          </g>

          <!-- ── Center: Frog logo + close ── -->
          <g @click.stop="$emit('close')" style="cursor:pointer" class="center-btn">
            <circle cx="100" cy="100" r="30" fill="rgba(0,0,0,0.55)" />
            <circle cx="100" cy="100" r="30" fill="none" stroke="rgba(255,215,0,0.4)" stroke-width="1"/>
            <!-- Frog outline -->
            <path d="M100 82 A18 18 0 0 1 118 100 A18 18 0 0 1 100 118 A18 18 0 0 1 82 100 A18 18 0 0 1 100 82 Z
                     M100 88 A12 12 0 0 1 112 100 A12 12 0 0 1 100 112 A12 12 0 0 1 88 100 A12 12 0 0 1 100 88 Z
                     M95 97 A2 2 0 1 0 95 101 A2 2 0 1 0 95 97 Z
                     M105 97 A2 2 0 1 0 105 101 A2 2 0 1 0 105 97 Z"
              fill="none" stroke="rgba(255,215,0,0.7)" stroke-width="1.2"/>
            <!-- X icon below frog hint -->
            <text x="100" y="115" text-anchor="middle" font-size="7" fill="rgba(255,255,255,0.4)"
              font-weight="600">ESC</text>
          </g>

        </svg>

        <!-- Site nav links around the mandala base -->
        <div class="mandala-nav-links">
          <router-link v-for="link in navLinks" :key="link.to"
            :to="link.to"
            class="mnav-link"
            @click="$emit('close')"
            :title="link.label"
          >
            <q-icon :name="link.icon" size="16px" />
            <span>{{ link.label }}</span>
          </router-link>
        </div>

      </div>

    </div>
  </teleport>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import type { GalleryPhoto } from 'src/lib/supabase'

const props = defineProps<{ photos: GalleryPhoto[]; startIndex: number }>()
const emit  = defineEmits<{ (e: 'close'): void }>()

const current = ref(props.startIndex)
const rootEl  = ref<HTMLElement | null>(null)

function prev() { current.value = (current.value - 1 + props.photos.length) % props.photos.length }
function next() { current.value = (current.value + 1) % props.photos.length }

function onKey(e: KeyboardEvent) {
  if (e.key === 'ArrowLeft')  prev()
  if (e.key === 'ArrowRight') next()
  if (e.key === 'Escape')     emit('close')
}

onMounted(() => { rootEl.value?.focus() })
onUnmounted(() => { /* nothing */ })

const navLinks = [
  { to: '/',            icon: 'auto_awesome', label: 'Home'    },
  { to: '/photography', icon: 'camera',       label: 'Gallery' },
  { to: '/maps',        icon: 'explore',      label: 'Maps'    },
  { to: '/support',     icon: 'stadium',      label: 'Support' },
  { to: '/blog',        icon: 'forum',        label: 'Blog'    },
]
</script>

<style lang="scss" scoped>
.slideshow-overlay {
  position: fixed; inset: 0; z-index: 9000;
  background: #000;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  outline: none;
}

.slideshow-img {
  position: absolute; inset: 0;
  width: 100%; height: 100%;
  object-fit: contain;
}

.vignette {
  position: absolute; inset: 0;
  background: radial-gradient(ellipse at center, transparent 40%, rgba(0,0,0,0.6) 100%);
  pointer-events: none;
}

.caption-bar {
  position: absolute; bottom: 220px; left: 0; right: 0;
  display: flex; justify-content: space-between; align-items: center;
  padding: 0 32px;
  font-size: 13px; color: rgba(255,255,255,0.75);
  text-shadow: 0 1px 4px rgba(0,0,0,0.8);
}
.counter { font-size: 11px; color: rgba(255,255,255,0.4); }

/* ── Mandala ── */
.mandala-wrap {
  position: absolute; bottom: 0; left: 50%;
  transform: translateX(-50%);
  display: flex; flex-direction: column; align-items: center;
  padding-bottom: 12px;
}

.mandala-svg {
  width: 190px; height: 190px;
  filter: drop-shadow(0 0 20px rgba(57,73,171,0.5));

  .zone-prev, .zone-next { transition: opacity 0.15s; }
  .arrow-btn { transition: opacity 0.2s; opacity: 0.8; &:hover { opacity: 1; } }
  .center-btn { opacity: 0.85; transition: opacity 0.2s; &:hover { opacity: 1; } }
}

.mandala-nav-links {
  display: flex; gap: 16px; margin-top: 6px;
}
.mnav-link {
  display: flex; flex-direction: column; align-items: center; gap: 2px;
  color: rgba(255,255,255,0.45);
  text-decoration: none;
  font-size: 9px; letter-spacing: 1px; text-transform: uppercase;
  transition: color 0.2s;
  &:hover { color: rgba(255,255,255,0.9); }
}

/* Photo fade transition */
.fade-photo-enter-active, .fade-photo-leave-active { transition: opacity 0.25s ease; }
.fade-photo-enter-from, .fade-photo-leave-to       { opacity: 0; }
</style>

<!--
  PageBackground — full-page SVG pattern layer.
  Usage: <PageBackground variant="support" />
  Variants: home | support | news | photography | maps | merch
-->
<template>
  <div class="page-bg-root absolute-full no-pointer-events overflow-hidden" aria-hidden="true">
    <!-- Optional photo background -->
    <img v-if="imageUrl" :src="imageUrl" class="bg-photo absolute-full" alt="" />

    <!-- HOME: Spirograph mosaic — 20 replications in a 5×4 geometric grid.
         Each instance is rotated 18° more than the previous (360°/20),
         so the full set makes one complete rotational cycle across the page. -->
    <svg v-if="variant === 'home'" class="absolute-full" width="100%" height="100%"
      viewBox="0 0 500 400" preserveAspectRatio="xMidYMid slice">
      <defs>
        <!-- The spirograph symbol — all 4 layered traces, no background fill -->
        <symbol id="pgSpiroSym" viewBox="0 0 100 100" overflow="visible">
          <path :d="SPIRO_P1" fill="none" stroke="#ffb300" stroke-width="0.7"  opacity="0.9" />
          <path :d="SPIRO_P2" fill="none" stroke="#e040fb" stroke-width="0.65" opacity="0.85" />
          <path :d="SPIRO_P3" fill="none" stroke="#00bcd4" stroke-width="0.55" opacity="0.8" />
          <path :d="SPIRO_P4" fill="none" stroke="#ff6d00" stroke-width="0.6"  opacity="0.85" />
        </symbol>
      </defs>
      <!-- 20 instances: 5 columns × 4 rows, each rotated i×18° around its centre -->
      <g :opacity="opacity">
        <g
          v-for="(p, i) in SPIRO_GRID" :key="i"
          :transform="`translate(${p.cx}, ${p.cy}) rotate(${p.angle}) translate(-50, -50)`"
        >
          <use href="#pgSpiroSym" x="0" y="0" width="100" height="100" />
        </g>
      </g>
    </svg>

    <!-- SUPPORT: Soundwave / heartbeat rings -->
    <svg v-else-if="variant === 'support'" class="absolute-full pg-pulse" width="100%" height="100%">
      <defs>
        <radialGradient id="pgGradSupport" cx="50%" cy="50%" r="50%">
          <stop offset="0%"   stop-color="#ff7043" />
          <stop offset="60%"  stop-color="#ffd54f" />
          <stop offset="100%" stop-color="#ab47bc" />
        </radialGradient>
        <pattern id="pgPatSupport" patternUnits="userSpaceOnUse" width="200" height="80">
          <path d="M0 40 L20 40 L30 10 L40 70 L50 20 L60 60 L70 35 L80 45 L90 40 L200 40"
            fill="none" stroke="url(#pgGradSupport)" stroke-width="1.5" />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#pgPatSupport)" :opacity="opacity" />
    </svg>

    <!-- NEWS: Diagonal ink-fold grid -->
    <svg v-else-if="variant === 'news'" class="absolute-full" width="100%" height="100%">
      <defs>
        <linearGradient id="pgGradNews" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%"   stop-color="#00bcd4" />
          <stop offset="50%"  stop-color="#3949ab" />
          <stop offset="100%" stop-color="#7b1fa2" />
        </linearGradient>
        <pattern id="pgPatNews" patternUnits="userSpaceOnUse" width="60" height="60" patternTransform="rotate(35)">
          <line x1="0" y1="0" x2="0" y2="60" stroke="url(#pgGradNews)" stroke-width="0.8" />
          <line x1="0" y1="0" x2="60" y2="0" stroke="url(#pgGradNews)" stroke-width="0.3" />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#pgPatNews)" :opacity="opacity" />
    </svg>

    <!-- PHOTOGRAPHY: Lens aperture blades -->
    <svg v-else-if="variant === 'photography'" class="absolute-full pg-slow-spin" width="100%" height="100%">
      <defs>
        <radialGradient id="pgGradPhoto" cx="50%" cy="50%" r="50%">
          <stop offset="0%"   stop-color="#ffb300" />
          <stop offset="70%"  stop-color="#ff7043" />
          <stop offset="100%" stop-color="#1a237e" />
        </radialGradient>
        <pattern id="pgPatPhoto" patternUnits="userSpaceOnUse" width="120" height="120">
          <circle cx="60" cy="60" r="50" fill="none" stroke="url(#pgGradPhoto)" stroke-width="0.8" stroke-dasharray="12 8" />
          <circle cx="60" cy="60" r="30" fill="none" stroke="url(#pgGradPhoto)" stroke-width="0.5" stroke-dasharray="6 10" />
          <line x1="10" y1="60" x2="110" y2="60" stroke="url(#pgGradPhoto)" stroke-width="0.4" />
          <line x1="60" y1="10" x2="60" y2="110" stroke="url(#pgGradPhoto)" stroke-width="0.4" />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#pgPatPhoto)" :opacity="opacity" />
    </svg>

    <!-- MAPS: Topographic contour lines -->
    <svg v-else-if="variant === 'maps'" class="absolute-full" width="100%" height="100%">
      <defs>
        <linearGradient id="pgGradMaps" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%"   stop-color="#43a047" />
          <stop offset="50%"  stop-color="#00acc1" />
          <stop offset="100%" stop-color="#1e88e5" />
        </linearGradient>
        <pattern id="pgPatMaps" patternUnits="userSpaceOnUse" width="300" height="200">
          <path d="M0 100 Q75 60 150 100 T300 100" fill="none" stroke="url(#pgGradMaps)" stroke-width="1" />
          <path d="M0 130 Q75 90 150 130 T300 130" fill="none" stroke="url(#pgGradMaps)" stroke-width="0.6" />
          <path d="M0 70  Q75 30 150 70  T300 70"  fill="none" stroke="url(#pgGradMaps)" stroke-width="0.6" />
          <path d="M0 160 Q75 120 150 160 T300 160" fill="none" stroke="url(#pgGradMaps)" stroke-width="0.4" />
          <path d="M0 40  Q75 0  150 40  T300 40"  fill="none" stroke="url(#pgGradMaps)" stroke-width="0.4" />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#pgPatMaps)" :opacity="opacity" />
    </svg>

    <!-- MERCH: Diamond lattice -->
    <svg v-else-if="variant === 'merch'" class="absolute-full" width="100%" height="100%">
      <defs>
        <linearGradient id="pgGradMerch" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%"   stop-color="#7b1fa2" />
          <stop offset="50%"  stop-color="#ffd700" />
          <stop offset="100%" stop-color="#3949ab" />
        </linearGradient>
        <pattern id="pgPatMerch" patternUnits="userSpaceOnUse" width="60" height="60" patternTransform="rotate(45)">
          <rect x="10" y="10" width="40" height="40" fill="none" stroke="url(#pgGradMerch)" stroke-width="0.8" />
          <circle cx="30" cy="30" r="4" fill="none" stroke="url(#pgGradMerch)" stroke-width="0.6" />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#pgPatMerch)" :opacity="opacity" />
    </svg>

  </div>
</template>

<script setup lang="ts">
import { SPIRO_P1, SPIRO_P2, SPIRO_P3, SPIRO_P4 } from 'src/lib/spirograph'

withDefaults(defineProps<{ variant: string; opacity?: number; imageUrl?: string | null }>(), { opacity: 0.09 })

// 5 columns × 4 rows = 20 instances.
// cx/cy are cell centres in the 500×400 viewBox.
// Each instance is rotated i×18° (360°/20) around its own centre.
const SPIRO_GRID = Array.from({ length: 20 }, (_, i) => ({
  cx:    (i % 5) * 100 + 50,
  cy:    Math.floor(i / 5) * 100 + 50,
  angle: i * 18,
}))
</script>

<style scoped>
.page-bg-root { z-index: 0; }
.bg-photo { width: 100%; height: 100%; object-fit: cover; object-position: center; opacity: 0.18; }

.pg-pulse {
  animation: pgPulse 8s ease-in-out infinite alternate;
}
@keyframes pgPulse {
  from { transform: scaleY(1); }
  to   { transform: scaleY(1.06); }
}

.pg-slow-spin {
  animation: pgSpin 60s linear infinite;
  transform-origin: center center;
}
@keyframes pgSpin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}
</style>

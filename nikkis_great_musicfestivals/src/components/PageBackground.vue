<!--
  PageBackground — full-page SVG pattern layer.
  Usage: <PageBackground variant="support" />
  Variants: home | support | news | photography | maps | merch
-->
<template>
  <div class="page-bg-root absolute-full no-pointer-events overflow-hidden" aria-hidden="true">
    <!-- Optional photo background -->
    <img v-if="imageUrl" :src="imageUrl" class="bg-photo absolute-full" alt="" />

    <!-- HOME: Mardi-Gras spiral -->
    <svg v-if="variant === 'home'" class="absolute-full" width="100%" height="100%">
      <defs>
        <radialGradient id="pgGradHome" cx="50%" cy="50%" r="50%">
          <stop offset="0%"   stop-color="#4b0082" />
          <stop offset="50%"  stop-color="#ffd700" />
          <stop offset="100%" stop-color="#008f39" />
        </radialGradient>
        <pattern id="pgPatHome" patternUnits="userSpaceOnUse" width="150" height="150">
          <path d="M75,75 a37.5,37.5 0 1,0 37.5,37.5 a18.75,18.75 0 1,0 -18.75,-18.75 a9.375,9.375 0 1,0 9.375,9.375"
            fill="none" stroke="url(#pgGradHome)" stroke-width="2.5" />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#pgPatHome)" :opacity="opacity" />
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
withDefaults(defineProps<{ variant: string; opacity?: number; imageUrl?: string | null }>(), { opacity: 0.09 })
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

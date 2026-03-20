<!--
  SpirographLogo — reusable animated spirograph identity mark.
  Uses hypotrochoid geometry with sinusoidal helical orbit modulation.
  mix-blend-mode: multiply on a cream radial-gradient circle gives the
  classic colour-burn intersection effect on all 4 layered traces.

  Props:
    size   — width/height in px (default 120)
    spin   — whether to apply the slow-rotation animation (default false)
    shadow — whether to apply the old-school drop-shadow + glow filter
-->
<template>
  <svg
    :viewBox="`0 0 100 100`"
    :width="size"
    :height="size"
    :class="['spiro-root', { 'spiro-spin': spin, 'spiro-shadow': shadow }]"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
  >
    <defs>
      <radialGradient :id="`sbg-${vid}`" cx="50%" cy="50%" r="50%">
        <stop offset="0%"   stop-color="#fffde7" />
        <stop offset="100%" stop-color="#f3e5f5" />
      </radialGradient>
    </defs>

    <!-- cream disc — colour-burn backdrop -->
    <circle cx="50" cy="50" r="48" :fill="`url(#sbg-${vid})`" />

    <!-- 5-petal helical gold -->
    <path :d="p1" fill="none" stroke="#ffb300" stroke-width="0.7"
          style="mix-blend-mode:multiply" opacity="0.9" />
    <!-- 3-petal helical magenta -->
    <path :d="p2" fill="none" stroke="#e040fb" stroke-width="0.65"
          style="mix-blend-mode:multiply" opacity="0.85" />
    <!-- 7-petal cyan -->
    <path :d="p3" fill="none" stroke="#00bcd4" stroke-width="0.55"
          style="mix-blend-mode:multiply" opacity="0.8" />
    <!-- 4-petal orange -->
    <path :d="p4" fill="none" stroke="#ff6d00" stroke-width="0.6"
          style="mix-blend-mode:multiply" opacity="0.85" />

    <!-- frog centre glyph -->
    <circle cx="50" cy="50" r="7"   fill="none" stroke="#1a0a2e" stroke-width="1.2" />
    <circle cx="47" cy="48" r="1.2" fill="#1a0a2e" />
    <circle cx="53" cy="48" r="1.2" fill="#1a0a2e" />
    <path d="M47 52 Q50 55 53 52" fill="none" stroke="#1a0a2e"
          stroke-width="1" stroke-linecap="round"/>

    <!-- outer dashed border ring -->
    <circle cx="50" cy="50" r="48" fill="none" stroke="#1a0a2e"
            stroke-width="0.4" stroke-dasharray="3 2" />
  </svg>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{ size?: number | string; spin?: boolean; shadow?: boolean }>(),
  { size: 120, spin: false, shadow: false }
)

/* unique gradient ID per instance avoids SVG defs collisions */
const vid = Math.random().toString(36).slice(2, 8)

/* ── Hypotrochoid with sinusoidal helical arm modulation ──────────
   x = (R-r)·cos(t) + d·cos((R-r)/r · t)
   y = (R-r)·sin(t) − d·sin((R-r)/r · t)
   where d = dBase + sinAmp·sin(sinFreq·t)  ← helical wobble
─────────────────────────────────────────────────────────────────── */
function gcd(a: number, b: number): number { return b === 0 ? a : gcd(b, a % b) }

function spiro(R: number, r: number, d: number, amp = 0, freq = 0, n = 500): string {
  const loops = R / gcd(R, r)
  const pts: string[] = []
  for (let i = 0; i <= n; i++) {
    const t  = (i / n) * loops * 2 * Math.PI
    const dv = d + amp * Math.sin(freq * t)
    const x  = (R - r) * Math.cos(t) + dv * Math.cos(((R - r) / r) * t)
    const y  = (R - r) * Math.sin(t) - dv * Math.sin(((R - r) / r) * t)
    pts.push(`${(x + 50).toFixed(1)},${(y + 50).toFixed(1)}`)
  }
  return 'M' + pts.join('L')
}

const p1 = spiro(40,  8, 34, 3, 5,  600)   // 5-petal gold
const p2 = spiro(42, 14, 36, 2, 9,  450)   // 3-petal magenta
const p3 = spiro(35,  5, 30, 2, 7,  700)   // 7-petal cyan
const p4 = spiro(36,  9, 28, 3, 4,  480)   // 4-petal orange
</script>

<style>
.spiro-root { display: block; overflow: visible; }

.spiro-spin {
  animation: spiro-logo-spin 45s linear infinite;
  transform-origin: center center;
}
@keyframes spiro-logo-spin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}

.spiro-shadow {
  filter:
    drop-shadow(4px 4px 0px rgba(0,0,0,0.95))
    drop-shadow(2px 2px 0px rgba(0,0,0,0.7))
    drop-shadow(0 0 18px rgba(124,77,255,0.65))
    drop-shadow(0 0  6px rgba(255,183,0,0.5));
}
</style>

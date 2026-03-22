<!--
  SpirographLogo — reusable animated spirograph identity mark.
  Uses hypotrochoid geometry with sinusoidal helical orbit modulation.
  mix-blend-mode: multiply on the orange→gold radial backdrop gives the
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
      <!-- transparent edge → gold → orange at centre -->
      <radialGradient :id="`sbg-${vid}`" cx="50%" cy="50%" r="50%">
        <stop offset="0%"   stop-color="#ff6d00" stop-opacity="0.88" />
        <stop offset="52%"  stop-color="#ffd700" stop-opacity="0.60" />
        <stop offset="100%" stop-color="#0d0028" stop-opacity="0"    />
      </radialGradient>
      <!-- campfire flame: base orange → tip gold -->
      <linearGradient :id="`fire-${vid}`" x1="0%" y1="100%" x2="0%" y2="0%">
        <stop offset="0%"   stop-color="#ff4500" />
        <stop offset="55%"  stop-color="#ff8c00" />
        <stop offset="100%" stop-color="#ffd700" />
      </linearGradient>
      <!-- moon lit-face: soft cream highlight → gold limb -->
      <radialGradient :id="`moon-${vid}`" cx="38%" cy="30%" r="70%">
        <stop offset="0%"   stop-color="#fffde7" />
        <stop offset="100%" stop-color="#ffd700" />
      </radialGradient>
    </defs>

    <!-- orange→gold radial backdrop (colour-burn base for spiral traces) -->
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

    <!-- ── 8 moon phases in orbital ring ── -->
    <g v-for="m in MOON_RING" :key="m.phase"
       :transform="`translate(${m.cx}, ${m.cy})`">
      <!-- unlit disc -->
      <circle r="4" fill="#1a0a2e" opacity="0.82" />
      <!-- lit face (absent for new moon) -->
      <path v-if="m.litPath" :d="m.litPath"
            :fill="`url(#moon-${vid})`" opacity="0.95" />
      <!-- thin limb ring -->
      <circle r="4" fill="none" stroke="#ffd700" stroke-width="0.35" opacity="0.55" />
    </g>

    <!-- ── Campfire at centre ── -->
    <g transform="translate(50, 51)">
      <!-- crossed logs -->
      <line x1="-7" y1="4.5" x2="7"  y2="2.5" stroke="#7b3810" stroke-width="2"   stroke-linecap="round" />
      <line x1="-6" y1="2.5" x2="6"  y2="4.5" stroke="#5c2a0e" stroke-width="2"   stroke-linecap="round" />
      <!-- left flame -->
      <path d="M-2,3 C-4.5,-1 -3.5,-6 -1.5,-7.5 C-0.8,-5 -1.2,-1 -2,3 Z"
            :fill="`url(#fire-${vid})`" opacity="0.88" />
      <!-- right flame -->
      <path d="M2,3 C4.5,-1 3.5,-6 1.5,-7.5 C0.8,-5 1.2,-1 2,3 Z"
            :fill="`url(#fire-${vid})`" opacity="0.88" />
      <!-- centre flame (tallest) -->
      <path d="M0,3 C-3,-2 -2.5,-7 0,-10.5 C2.5,-7 3,-2 0,3 Z"
            :fill="`url(#fire-${vid})`" opacity="0.96" />
      <!-- incandescent core -->
      <ellipse cx="0" cy="-1.5" rx="1.6" ry="2.4" fill="#fffde7" opacity="0.75" />
    </g>

    <!-- ── Sinusoidal mandala ring (replaces dashed circle) ── -->
    <path :d="ringPath" fill="none" stroke="#1a0a2e" stroke-width="0.45" opacity="0.8" />
  </svg>
</template>

<script setup lang="ts">
import { SPIRO_P1, SPIRO_P2, SPIRO_P3, SPIRO_P4 } from 'src/lib/spirograph'

withDefaults(
  defineProps<{ size?: number | string; spin?: boolean; shadow?: boolean }>(),
  { size: 120, spin: false, shadow: false }
)

/* unique gradient / symbol IDs per instance — avoids SVG defs collisions */
const vid = Math.random().toString(36).slice(2, 8)

const p1 = SPIRO_P1
const p2 = SPIRO_P2
const p3 = SPIRO_P3
const p4 = SPIRO_P4

// ── Moon phase lit-face paths ─────────────────────────────────────────────────
// Radius 4, centred at origin.
// Outer arc traces the lit semicircle; terminator arc closes the crescent/gibbous.
// Phase 0 = new moon (no lit path), phase 4 = full moon.
function moonLitPath(phase: number): string {
  const r  = 4
  // rx of terminator ellipse = r·|cos(45°)| for crescent and gibbous phases
  const rx = parseFloat((r * Math.SQRT1_2).toFixed(2))

  if (phase === 0) return ''
  if (phase === 4) {
    // full circle via two semicircular arcs
    return `M 0,${-r} A ${r},${r} 0 0 1 0,${r} A ${r},${r} 0 0 1 0,${-r}`
  }

  const waxing    = phase < 4
  const termPhase = waxing ? phase : 8 - phase   // normalised 1–3
  const outerSweep = waxing ? 1 : 0              // CW for right-lit, CCW for left-lit

  if (termPhase === 2) {
    // quarter moons: straight vertical terminator
    return `M 0,${-r} A ${r},${r} 0 0 ${outerSweep} 0,${r} L 0,${-r}`
  }

  // crescent (termPhase=1): terminator sweeps 0 (CCW, curves toward dark side)
  // gibbous  (termPhase=3): terminator sweeps 1 (CW,  curves toward lit side)
  const termSweep = termPhase === 3 ? 1 : 0
  return `M 0,${-r} A ${r},${r} 0 0 ${outerSweep} 0,${r} A ${rx},${r} 0 0 ${termSweep} 0,${-r}`
}

// 8 moons evenly spaced in a circular orbit, new moon at top, clockwise
const ORBIT_R = 22
const MOON_RING = Array.from({ length: 8 }, (_, i) => {
  const theta = (i * Math.PI * 2) / 8
  return {
    phase:   i,
    cx:      parseFloat((50 + ORBIT_R * Math.sin(theta)).toFixed(2)),
    cy:      parseFloat((50 - ORBIT_R * Math.cos(theta)).toFixed(2)),
    litPath: moonLitPath(i),
  }
})

// ── Sinusoidal ring path ──────────────────────────────────────────────────────
// Traces a circle of radius R with a sinusoidal radial perturbation:
//   r(t) = R + amp·sin(waves·t)
// giving a mandala-like wavy border instead of the original dashed circle.
function sinusoidalRing(
  cx: number, cy: number,
  R: number, amp: number, waves: number,
  pts = 360,
): string {
  const coords: string[] = []
  for (let i = 0; i <= pts; i++) {
    const t = (i / pts) * 2 * Math.PI
    const r = R + amp * Math.sin(waves * t)
    coords.push(
      `${(cx + r * Math.cos(t)).toFixed(2)},${(cy + r * Math.sin(t)).toFixed(2)}`,
    )
  }
  return 'M' + coords.join('L') + 'Z'
}

// 28 sinusoidal waves, ±2 unit amplitude, centred on the original r=48 circle
const ringPath = sinusoidalRing(50, 50, 48, 2, 28, 360)
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

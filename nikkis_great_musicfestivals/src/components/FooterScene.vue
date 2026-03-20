<!--
  FooterScene — full-width animated SVG landscape.
  Two-colour duotone: deep indigo (sky/mountains) + dark forest (ground).
  Scene left-to-right: lone pine · hammock between two pines · campfire.
  Animated: smoke wisps · fire flicker · stream shimmer · hammock sway.

  Sits below router-view inside q-page-container.
  The .footer-fade gradient above it bridges the page background into the
  SVG's sky colour (#0d0028).
-->
<template>
  <div class="footer-scene-wrap">
    <!-- colour-transition band: page bg → SVG sky -->
    <div class="footer-fade" />

    <svg
      viewBox="0 0 1440 260"
      preserveAspectRatio="xMidYMid slice"
      xmlns="http://www.w3.org/2000/svg"
      class="footer-svg"
      aria-hidden="true"
    >
      <defs>
        <!-- sky gradient -->
        <linearGradient id="fs-sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%"   stop-color="#0d0028" />
          <stop offset="100%" stop-color="#1a0645" />
        </linearGradient>
        <!-- fire glow -->
        <radialGradient id="fs-fireglow" cx="50%" cy="60%" r="50%">
          <stop offset="0%"   stop-color="#ff8f00" stop-opacity="0.45" />
          <stop offset="100%" stop-color="#ff8f00" stop-opacity="0" />
        </radialGradient>
        <!-- stream -->
        <linearGradient id="fs-stream" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%"   stop-color="#1565c0" stop-opacity="0.85" />
          <stop offset="100%" stop-color="#0d3572" stop-opacity="0.7" />
        </linearGradient>
        <!-- moon glow -->
        <radialGradient id="fs-moonglow" cx="50%" cy="50%" r="50%">
          <stop offset="0%"   stop-color="#e8d8ff" stop-opacity="0.2" />
          <stop offset="100%" stop-color="#e8d8ff" stop-opacity="0" />
        </radialGradient>
      </defs>

      <!-- ══ SKY ══════════════════════════════════════════════════ -->
      <rect width="1440" height="260" fill="url(#fs-sky)" />

      <!-- Stars -->
      <g opacity="0.7">
        <circle cx="45"   cy="22"  r="0.9" fill="white" />
        <circle cx="130"  cy="38"  r="0.7" fill="white" />
        <circle cx="210"  cy="14"  r="1"   fill="white" />
        <circle cx="380"  cy="28"  r="0.8" fill="white" />
        <circle cx="490"  cy="10"  r="0.7" fill="white" />
        <circle cx="620"  cy="32"  r="0.9" fill="white" />
        <circle cx="740"  cy="16"  r="0.7" fill="white" />
        <circle cx="850"  cy="40"  r="0.8" fill="white" />
        <circle cx="1010" cy="18"  r="0.9" fill="white" />
        <circle cx="1120" cy="34"  r="0.7" fill="white" />
        <circle cx="1240" cy="12"  r="1"   fill="white" />
        <circle cx="1420" cy="28"  r="0.8" fill="white" />
        <circle cx="690"  cy="55"  r="0.6" fill="white" opacity="0.5" />
        <circle cx="155"  cy="58"  r="0.6" fill="white" opacity="0.4" />
        <circle cx="1300" cy="48"  r="0.7" fill="white" opacity="0.5" />
      </g>

      <!-- Moon + glow -->
      <circle cx="1340" cy="42" r="45"  fill="url(#fs-moonglow)" />
      <circle cx="1340" cy="42" r="20"  fill="#fffce8" opacity="0.92" />
      <circle cx="1350" cy="38" r="17"  fill="#1a0645" />   <!-- crescent mask -->

      <!-- ══ FAR MOUNTAINS ════════════════════════════════════════ -->
      <path d="M0,170 L70,88 L140,152 L230,42 L330,125 L445,58 L555,148
               L660,38 L770,128 L885,52 L1000,132 L1118,46 L1235,130
               L1358,68 L1440,108 L1440,170 Z"
            fill="#1f0858" />

      <!-- ══ NEAR MOUNTAINS ═══════════════════════════════════════ -->
      <path d="M0,170 L52,118 L130,165 L245,78 L355,158 L462,92 L582,162
               L705,82 L822,158 L942,86 L1060,152 L1182,80 L1300,150
               L1384,102 L1440,132 L1440,170 Z"
            fill="#100535" />

      <!-- ══ GROUND ════════════════════════════════════════════════ -->
      <path d="M0,162 Q240,155 480,160 Q720,165 960,157 Q1200,150 1440,160
               L1440,260 L0,260 Z"
            fill="#071409" />

      <!-- Grass highlight line -->
      <path d="M0,162 Q240,156 480,161 Q720,166 960,158 Q1200,151 1440,161"
            fill="none" stroke="#102818" stroke-width="3" opacity="0.8" />

      <!-- ══ STREAM ═════════════════════════════════════════════════
           Filled band — top bank + bottom bank reversed             -->
      <path class="stream-body"
            d="M0,238 Q160,226 320,240 Q480,254 640,236 Q800,220 960,238
               Q1120,254 1280,240 Q1380,232 1440,238
               L1440,252 Q1380,246 1280,254 Q1120,268 960,252
               Q800,236 640,250 Q480,268 320,254
               Q160,240 0,252 Z"
            fill="url(#fs-stream)" />
      <!-- stream shimmer highlight -->
      <path class="stream-shimmer"
            d="M0,240 Q160,228 320,242 Q480,256 640,238 Q800,222 960,240
               Q1120,256 1280,242 Q1380,234 1440,240"
            fill="none" stroke="#42a5f5" stroke-width="1.2" opacity="0.4" />

      <!-- ══ LONE PINE — far left ═══════════════════════════════════ -->
      <g>
        <rect x="117" y="160" width="6" height="18" rx="1" fill="#030b03" />
        <polygon points="100,166 134,166 120,148" fill="#061208" />
        <polygon points="104,152 130,152 120,136" fill="#082010" />
        <polygon points="108,140 128,140 120,124" fill="#0a2812" />
      </g>

      <!-- ══ LEFT HAMMOCK TREE (x=318) ═════════════════════════════ -->
      <g>
        <rect x="313" y="158" width="10" height="24" rx="2" fill="#030b03" />
        <polygon points="284,168 352,168 318,146" fill="#061208" />
        <polygon points="290,152 346,152 318,130" fill="#082010" />
        <polygon points="296,138 340,138 318,116" fill="#0a2812" />
        <polygon points="302,124 334,124 318,105" fill="#0c3014" />
      </g>

      <!-- ══ RIGHT HAMMOCK TREE (x=598) ════════════════════════════ -->
      <g>
        <rect x="593" y="158" width="10" height="24" rx="2" fill="#030b03" />
        <polygon points="564,168 632,168 598,146" fill="#061208" />
        <polygon points="570,152 626,152 598,130" fill="#082010" />
        <polygon points="576,138 620,138 598,116" fill="#0a2812" />
        <polygon points="582,124 614,124 598,105" fill="#0c3014" />
      </g>

      <!-- ══ HAMMOCK ════════════════════════════════════════════════ -->
      <g class="hammock-group">
        <!-- fabric -->
        <path d="M320,158 Q458,188 596,158 L596,162 Q458,192 320,162 Z"
              fill="#3d1f7d" opacity="0.92" />
        <!-- centre stripes -->
        <path d="M320,159 Q458,189 596,159" fill="none"
              stroke="#5c35a8" stroke-width="1.2" stroke-dasharray="6 5" opacity="0.6" />
        <!-- ropes -->
        <line x1="318" y1="158" x2="322" y2="158"
              stroke="#2d1560" stroke-width="2" stroke-linecap="round" />
        <line x1="596" y1="158" x2="592" y2="158"
              stroke="#2d1560" stroke-width="2" stroke-linecap="round" />
        <!-- person silhouette -->
        <ellipse cx="458" cy="183" rx="34"  ry="8"  fill="#0d0028" opacity="0.8" />
        <ellipse cx="458" cy="175" rx="9"   ry="8"  fill="#0d0028" opacity="0.8" />
      </g>

      <!-- ══ CAMPFIRE (x=985) ══════════════════════════════════════ -->
      <!-- glow -->
      <circle cx="985" cy="210" r="52" fill="url(#fs-fireglow)" />

      <!-- logs -->
      <line x1="963" y1="218" x2="1007" y2="208"
            stroke="#2a1505" stroke-width="6" stroke-linecap="round" />
      <line x1="963" y1="208" x2="1007" y2="218"
            stroke="#2a1505" stroke-width="6" stroke-linecap="round" />

      <!-- flames — animated flicker group -->
      <g class="fire-group">
        <!-- base outer flame -->
        <path d="M973,212 Q970,198 975,186 Q980,174 983,182
                 Q986,172 989,182 Q994,192 990,210 Z"
              fill="#e65100" />
        <!-- mid amber flame -->
        <path d="M975,212 Q973,202 977,192 Q981,184 984,190
                 Q987,182 990,190 Q992,200 989,212 Z"
              fill="#ff8f00" />
        <!-- hot yellow inner -->
        <path d="M978,212 Q977,205 980,198 Q983,192 985,197
                 Q987,191 989,197 Q990,204 988,212 Z"
              fill="#ffd600" />
        <!-- small side flickers -->
        <path d="M968,212 Q966,206 969,200 Q972,194 975,198
                 Q975,205 972,212 Z"
              fill="#ff8f00" opacity="0.7" />
        <path d="M996,212 Q998,206 996,200 Q993,194 990,198
                 Q990,205 994,212 Z"
              fill="#ff8f00" opacity="0.7" />
      </g>

      <!-- ══ SMOKE WISPS ════════════════════════════════════════════ -->
      <path class="smoke s1"
            d="M984,180 Q980,164 983,148 Q987,132 981,116"
            fill="none" stroke="rgba(190,160,230,0.55)"
            stroke-width="3.5" stroke-linecap="round" />
      <path class="smoke s2"
            d="M986,180 Q991,163 987,147 Q982,131 988,115"
            fill="none" stroke="rgba(190,160,230,0.45)"
            stroke-width="2.8" stroke-linecap="round" />
      <path class="smoke s3"
            d="M983,181 Q977,163 980,147 Q984,131 978,114"
            fill="none" stroke="rgba(190,160,230,0.38)"
            stroke-width="2.2" stroke-linecap="round" />

    </svg>
  </div>
</template>

<script setup lang="ts">
// No runtime logic — all animation is CSS.
</script>

<style scoped>
/* ── Wrapper ─────────────────────────────────────────────────── */
.footer-scene-wrap { position: relative; width: 100%; }

/* ── Colour-transition bridge ────────────────────────────────── */
.footer-fade {
  height: 90px;
  /* Transitions from the layout light background into the SVG sky */
  background: linear-gradient(to bottom, #f5f0ff 0%, #0d0028 100%);
  pointer-events: none;
}

/* Dark-mode override applied by parent class propagation */
.bg-dark .footer-fade,
.page-dark .footer-fade {
  background: linear-gradient(to bottom, #070014 0%, #0d0028 100%);
}

/* ── SVG ─────────────────────────────────────────────────────── */
.footer-svg {
  display: block;
  width: 100%;
  height: auto;
  /* min-height keeps scene visible on very wide short viewports */
  min-height: 180px;
  background: #0d0028;
}

/* ── Stream shimmer ──────────────────────────────────────────── */
.stream-body    { animation: streamPulse 5s ease-in-out infinite; }
.stream-shimmer { animation: streamPulse 5s ease-in-out infinite reverse; }
@keyframes streamPulse {
  0%, 100% { opacity: 0.75; }
  50%      { opacity: 1; }
}

/* ── Hammock sway ────────────────────────────────────────────── */
.hammock-group {
  animation: hammockSway 5s ease-in-out infinite;
  transform-origin: 458px 172px;
}
@keyframes hammockSway {
  0%, 100% { transform: translateY(0); }
  50%      { transform: translateY(4px); }
}

/* ── Fire flicker ────────────────────────────────────────────── */
.fire-group {
  animation: fireFlicker 0.75s ease-in-out infinite alternate;
  transform-origin: 984px 205px;
}
@keyframes fireFlicker {
  0%   { transform: scaleY(1)    scaleX(1); }
  40%  { transform: scaleY(1.1)  scaleX(0.92); }
  100% { transform: scaleY(0.96) scaleX(1.06); }
}

/* ── Smoke rise ──────────────────────────────────────────────── */
.smoke { animation: smokeRise 3.5s ease-out infinite; }
.s2    { animation-delay: 1.1s; }
.s3    { animation-delay: 2.3s; }

@keyframes smokeRise {
  0%   { transform: translateY(0)    scaleX(1);   opacity: 0; }
  8%   { opacity: 1; }
  75%  { transform: translateY(-28px) scaleX(1.6); opacity: 0.4; }
  100% { transform: translateY(-42px) scaleX(2.2); opacity: 0; }
}
</style>

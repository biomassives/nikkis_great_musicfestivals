<!--
  FooterScene — full-width animated SVG landscape.
  ViewBox: 0 0 1440 390 — 120px of sky above landscape (landscape at translate 0,120).
  Two variants: day (matches #f5f0ff page-light) and night (matches #070014 page-dark).
-->
<template>

  <!-- ════════════ DAY ════════════════════════════════════════════ -->
  <svg v-if="!night"
    viewBox="0 0 1440 390"
    preserveAspectRatio="xMidYMid slice"
    xmlns="http://www.w3.org/2000/svg"
    class="footer-svg footer-svg--day"
    aria-hidden="true"
  >
    <defs>
      <linearGradient id="d-sky" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%"   stop-color="#f5f0ff" />
        <stop offset="30%"  stop-color="#d0eaff" />
        <stop offset="68%"  stop-color="#b8e4f0" />
        <stop offset="100%" stop-color="#d8f0e0" />
      </linearGradient>
      <radialGradient id="d-sunglow" cx="50%" cy="50%" r="50%">
        <stop offset="0%"   stop-color="#fff176" stop-opacity="0.55" />
        <stop offset="100%" stop-color="#ffe066" stop-opacity="0" />
      </radialGradient>
      <linearGradient id="d-stream" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%"   stop-color="#7dd8f0" stop-opacity="0.9" />
        <stop offset="100%" stop-color="#4ab8d8" stop-opacity="0.75" />
      </linearGradient>
      <radialGradient id="d-fireglow" cx="50%" cy="60%" r="50%">
        <stop offset="0%"   stop-color="#ff8f00" stop-opacity="0.28" />
        <stop offset="100%" stop-color="#ff8f00" stop-opacity="0" />
      </radialGradient>
      <linearGradient id="d-ground" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%"   stop-color="#5aaa3a" />
        <stop offset="100%" stop-color="#3a7820" />
      </linearGradient>
    </defs>

    <rect width="1440" height="390" fill="url(#d-sky)" />

    <!-- Sun in upper sky -->
    <circle cx="1260" cy="48"  r="65"  fill="url(#d-sunglow)" />
    <circle cx="1260" cy="48"  r="26"  fill="#fff8c0" opacity="0.95" />
    <circle cx="1260" cy="48"  r="22"  fill="#ffe566" opacity="0.92" />

    <!-- Soft cloud — centre sky -->
    <g opacity="0.68">
      <ellipse cx="680" cy="82"  rx="88" ry="22" fill="rgba(255,255,255,0.62)" />
      <ellipse cx="630" cy="90"  rx="56" ry="16" fill="rgba(255,255,255,0.45)" />
      <ellipse cx="736" cy="87"  rx="62" ry="18" fill="rgba(255,255,255,0.5)"  />
    </g>
    <!-- Wispy cloud — left -->
    <g opacity="0.52">
      <ellipse cx="220" cy="70"  rx="65" ry="17" fill="rgba(255,255,255,0.55)" />
      <ellipse cx="178" cy="76"  rx="42" ry="13" fill="rgba(255,255,255,0.4)"  />
    </g>

    <!-- ── Crop-circle orb sky writer (day) ──────────────────────── -->
    <g v-if="skyText">
      <defs>
        <radialGradient id="d-orb-aura" cx="50%" cy="50%" r="50%">
          <stop offset="0%"   stop-color="#fff8c0" stop-opacity="0.95" />
          <stop offset="30%"  stop-color="#ffd700" stop-opacity="0.6"  />
          <stop offset="100%" stop-color="#ffd700" stop-opacity="0"    />
        </radialGradient>
        <clipPath id="d-sky-reveal">
          <rect x="460" y="47" height="26" width="0">
            <animate attributeName="width"
              values="0;502;502;502;0"
              keyTimes="0;0.62;0.76;0.88;1"
              dur="20s" begin="1s" repeatCount="indefinite" />
          </rect>
        </clipPath>
      </defs>

      <!-- Written text, revealed left-to-right by clip -->
      <g clip-path="url(#d-sky-reveal)">
        <g opacity="0">
          <animate attributeName="opacity"
            values="0;0.72;0.72;0;0"
            keyTimes="0;0.05;0.76;0.88;1"
            dur="20s" begin="1s" repeatCount="indefinite" />
          <a :href="skyLink || undefined" target="_blank" rel="noopener noreferrer">
            <text x="720" y="64" text-anchor="middle"
              fill="none" :stroke="skyColor"
              stroke-width="0.65" stroke-dasharray="3 2"
              font-family="'Courier New', monospace"
              font-size="10" font-weight="700" letter-spacing="2"
            >{{ skyText }}</text>
          </a>
        </g>
      </g>

      <!-- The orb craft -->
      <g opacity="0">
        <animate attributeName="opacity"
          values="0;0.9;0.9;0;0"
          keyTimes="0;0.03;0.62;0.74;1"
          dur="20s" begin="1s" repeatCount="indefinite" />
        <animateTransform attributeName="transform" type="translate"
          values="460,62; 962,62; 962,62; 962,62; 460,62"
          keyTimes="0;0.62;0.76;0.88;1"
          dur="20s" begin="1s" repeatCount="indefinite" />
        <!-- Pulsing halo -->
        <circle r="12" fill="url(#d-orb-aura)" opacity="0.42">
          <animate attributeName="r"       values="10;15;10" dur="2.4s" repeatCount="indefinite" />
          <animate attributeName="opacity" values="0.42;0.16;0.42" dur="2.4s" repeatCount="indefinite" />
        </circle>
        <!-- Core -->
        <circle r="3.5" fill="#fffde0" opacity="0.95" />
        <circle r="5.5" fill="none" stroke="#ffd700" stroke-width="0.45" opacity="0.38" />
        <!-- Spinning equatorial ring -->
        <ellipse rx="9" ry="2.8" fill="none" stroke="rgba(255,215,0,0.68)" stroke-width="0.85">
          <animateTransform attributeName="transform" type="rotate"
            values="0 0 0;360 0 0" dur="3.5s" repeatCount="indefinite" />
        </ellipse>
        <!-- Writing beam (angled down-left toward text) -->
        <line x1="0" y1="4" x2="-4" y2="12"
          stroke="#ffd700" stroke-width="1.2" stroke-linecap="round" opacity="0.32">
          <animate attributeName="opacity" values="0.32;0.7;0.32" dur="1.8s" repeatCount="indefinite" />
        </line>
        <!-- Particle trail -->
        <circle cx="-10" cy="1"  r="1.8" fill="#ffd700" opacity="0.62" />
        <circle cx="-19" cy="0"  r="1.2" fill="#ffd700" opacity="0.38" />
        <circle cx="-28" cy="-1" r="0.8" fill="#ffd700" opacity="0.18" />
      </g>
    </g>

    <!-- Landscape shifted 120px down -->
    <g transform="translate(0, 120)">

      <!-- Mountain layer 1 — distant haze -->
      <path opacity="0.65" fill="#b8d0de"
            d="M-10,178 C 42,172  88,162 138,166 C178,170 210,148 258,134
               C298,122 332,130 372,142 C408,153 435,136 475,122
               C510,109 545,116 582,128 C615,139 644,124 684,112
               C718,101 754,108 795,120 C832,131 860,118 900,107
               C936, 97 972,105 1010,116 C1045,126 1072,114 1112,106
               C1148, 99 1183,108 1222,120 C1258,131 1292,122 1335,132
               C1368,140 1405,152 1440,162 L1440,178 Z" />

      <!-- Mountain layer 2 — far peaks, sage-grey -->
      <path fill="#8ab5a5"
            d="M-10,178 C 18,172  48,158  82,152 C110,147 138,118 178, 96
               C212, 78 244, 88 280,108 C310,125 335,108 372, 86
               C404, 68 436, 78 472, 98 C503,115 528, 96 566, 74
               C600, 55 635, 66 672, 89 C704,110 728, 90 765, 68
               C798, 50 834, 62 872, 85 C906,106 932, 88 968, 65
               C1000, 46 1038, 60 1078, 84 C1112,105 1138, 88 1175, 68
               C1208, 52 1242, 70 1278, 95 C1308,116 1336,105 1370,118
               C1398,130 1422,148 1440,160 L1440,178 Z" />

      <!-- Mountain layer 3 — mid-range forest -->
      <path fill="#4e8862"
            d="M-10,178 C 14,175  36,168  62,162 C 85,156 108,132 142,112
               C170, 95 196,104 226,122 C252,138 272,120 305,100
               C332, 84 358, 94 388,115 C414,133 436,118 466,100
               C492, 85 516, 95 545,115 C570,132 592,118 624,100
               C652, 85 676, 70 714, 56 C748, 44 780, 58 816, 80
               C848,100 872, 84 908, 65 C940, 49 976, 64 1012, 90
               C1044,112 1066, 98 1100, 80 C1130, 65 1158, 82 1192,105
               C1220,126 1244,112 1278,128 C1305,142 1330,132 1362,145
               C1388,156 1416,164 1440,170 L1440,178 Z" />

      <!-- Mountain layer 4 — near foothills -->
      <path fill="#2e6038"
            d="M-10,178 C 22,176  52,172  84,170 C110,168 135,158 166,152
               C192,147 216,156 244,163 C266,168 288,160 314,154
               C336,149 358,157 384,163 C406,168 426,162 452,156
               C474,151 498,160 524,166 C546,171 570,167 598,162
               C622,158 648,164 676,170 C700,174 724,172 752,168
               C775,165 800,170 828,174 C850,177 874,177 900,177
               L1440,177 L1440,178 Z" />

      <!-- Meadow ground -->
      <path fill="url(#d-ground)"
            d="M-10,176 Q 240,169 480,174 Q 720,179 960,171
               Q1200,164 1440,172 L1440,270 L-10,270 Z" />
      <path fill="none" stroke="#78c048" stroke-width="2.5" opacity="0.55"
            d="M-10,176 Q 240,170 480,175 Q 720,180 960,172 Q1200,165 1440,173" />

      <!-- Wildflowers -->
      <g opacity="0.7">
        <circle cx="80"   cy="192" r="2.2" fill="#ff6b6b" />
        <circle cx="145"  cy="198" r="1.8" fill="#ffd700" />
        <circle cx="228"  cy="188" r="2"   fill="#ff85a8" />
        <circle cx="310"  cy="200" r="1.6" fill="#ffd700" />
        <circle cx="480"  cy="193" r="2"   fill="#ff6b6b" />
        <circle cx="555"  cy="202" r="1.8" fill="#a0e8a0" />
        <circle cx="648"  cy="190" r="2.2" fill="#ffd700" />
        <circle cx="730"  cy="198" r="1.6" fill="#ff85a8" />
        <circle cx="860"  cy="194" r="2"   fill="#ffd700" />
        <circle cx="1080" cy="196" r="1.8" fill="#ff6b6b" />
        <circle cx="1165" cy="202" r="2"   fill="#ffd700" />
        <circle cx="1310" cy="190" r="1.6" fill="#ff85a8" />
        <circle cx="1390" cy="198" r="2"   fill="#ffd700" />
      </g>

      <!-- Stream -->
      <path class="stream-body" fill="url(#d-stream)"
            d="M  0,242 Q 150,230 290,244 Q 440,258 590,240
               Q 730,224 875,242 Q1020,258 1160,244 Q1320,230 1440,242
               L1440,256 Q1320,244 1160,258 Q1020,272 875,256
               Q 730,240 590,254 Q 440,270 290,258 Q 150,244   0,256 Z" />
      <path class="stream-shimmer" fill="none"
            stroke="#a8e8f8" stroke-width="1.5" opacity="0.5"
            d="M0,244 Q 150,232 290,246 Q 440,260 590,242
               Q 730,226 875,244 Q1020,260 1160,246 Q1320,232 1440,244" />

      <!-- Lone pine — far left -->
      <g>
        <rect x="118" y="164" width="5" height="16" rx="1" fill="#1a3a10" />
        <polygon points="103,170 133,170 118,154" fill="#224c16" />
        <polygon points="106,157 130,157 118,143" fill="#2a6018" />
        <polygon points="110,145 126,145 118,131" fill="#327020" />
      </g>
      <!-- Small tree far right -->
      <g>
        <rect x="1318" y="168" width="5" height="12" rx="1" fill="#1a3a10" />
        <polygon points="1305,173 1331,173 1318,160" fill="#224c16" />
        <polygon points="1308,162 1328,162 1318,150" fill="#2a6018" />
        <polygon points="1311,152 1325,152 1318,140" fill="#327020" />
      </g>

      <!-- Left hammock tree -->
      <g>
        <rect x="317" y="160" width="10" height="22" rx="2" fill="#162e0e" />
        <polygon points="288,170 358,170 322,148" fill="#1e4212" />
        <polygon points="293,155 350,155 322,133" fill="#265818" />
        <polygon points="299,141 344,141 322,120" fill="#2e6e1e" />
        <polygon points="305,127 338,127 322,107" fill="#347a22" />
        <polygon points="311,113 332,113 322, 96" fill="#3a8228" />
      </g>
      <!-- Right hammock tree -->
      <g>
        <rect x="599" y="160" width="10" height="22" rx="2" fill="#162e0e" />
        <polygon points="570,170 638,170 604,148" fill="#1e4212" />
        <polygon points="575,155 634,155 604,133" fill="#265818" />
        <polygon points="581,141 628,141 604,120" fill="#2e6e1e" />
        <polygon points="587,127 622,127 604,107" fill="#347a22" />
        <polygon points="593,114 616,114 604, 97" fill="#3a8228" />
      </g>

      <!-- Hammock -->
      <g class="hammock-group">
        <path d="M324,160 Q462,192 602,160 L602,165 Q462,197 324,165 Z"
              fill="#5c2d91" opacity="0.88" />
        <path d="M324,161 Q462,193 602,161" fill="none"
              stroke="#8b55cc" stroke-width="1.4" stroke-dasharray="7 6" opacity="0.55" />
        <ellipse cx="462" cy="186" rx="36" ry="8"   fill="#1a0a2e" opacity="0.55" />
        <ellipse cx="462" cy="178" rx=" 9" ry="8.5" fill="#1a0a2e" opacity="0.55" />
      </g>

      <!-- Campfire -->
      <circle cx="990" cy="218" r="44" fill="url(#d-fireglow)" />
      <line x1="968" y1="226" x2="1012" y2="215" stroke="#4a2808" stroke-width="6" stroke-linecap="round" />
      <line x1="968" y1="215" x2="1012" y2="226" stroke="#4a2808" stroke-width="6" stroke-linecap="round" />
      <g class="fire-group">
        <path d="M977,218 Q974,204 979,192 Q984,180 987,188 Q990,178 993,188 Q997,198 994,216 Z" fill="#e65100" />
        <path d="M979,218 Q977,208 981,198 Q985,190 988,196 Q991,188 994,196 Q996,205 993,218 Z" fill="#ff8f00" />
        <path d="M982,218 Q981,210 984,203 Q987,197 989,201 Q991,196 993,201 Q994,208 992,218 Z" fill="#ffcc02" />
      </g>

      <!-- ═══ CAMPFIRE COMPANIONS (day) ════════════════════════════════════ -->

      <!-- COOLER — Set 2: Deep Forest lid + Clear Sky body -->
      <g>
        <path d="M907,221 Q910,217 914,221" fill="none" stroke="#1e4530" stroke-width="2.5" stroke-linecap="round"/>
        <rect x="898" y="221" width="28" height="5"  rx="2.5" fill="#2D6A4F"/>
        <rect x="900" y="225" width="24" height="14" rx="3"   fill="#48CAE4"/>
        <rect x="903" y="228" width="18" height="2.5" rx="1.2" fill="white" opacity="0.30"/>
        <rect x="909" y="222" width="5"  height="3"  rx="1.2" fill="#1e4530"/>
        <rect x="901" y="237" width="6"  height="3"  rx="1.5" fill="#1a3040"/>
        <rect x="916" y="237" width="6"  height="3"  rx="1.5" fill="#1a3040"/>
      </g>

      <!-- PERSON 1 — left of fire · Set 1: Electric Ember + Festival Violet + Sun Gold -->
      <g>
        <!-- hat -->
        <rect x="938" y="191" width="16" height="12" rx="3"   fill="#8338EC"/>
        <rect x="934" y="201" width="24" height="4"  rx="2"   fill="#8338EC"/>
        <rect x="938" y="199" width="16" height="3"           fill="#FFB703"/>
        <!-- head + face -->
        <circle cx="946" cy="210" r="8.5" fill="#f4a261"/>
        <circle cx="943" cy="209" r="1.3" fill="#2a1408"/>
        <circle cx="949" cy="209" r="1.3" fill="#2a1408"/>
        <path d="M943,213 Q946,215 949,213" fill="none" stroke="#2a1408" stroke-width="1" stroke-linecap="round"/>
        <!-- jacket + collar scarf -->
        <rect x="937" y="218" width="18" height="16" rx="3"   fill="#E85D04"/>
        <rect x="937" y="218" width="18" height="5"  rx="2"   fill="#FFB703"/>
        <!-- arms -->
        <rect x="951" y="220" width="5" height="13" rx="2.5" fill="#E85D04" transform="rotate(-28,953,221)"/>
        <rect x="929" y="222" width="5" height="10" rx="2.5" fill="#E85D04" transform="rotate(14,931,223)"/>
        <!-- lap + feet -->
        <rect x="930" y="231" width="32" height="9" rx="4.5" fill="#3d2b1a"/>
        <rect x="929" y="237" width="12" height="6" rx="3"   fill="#1e1008"/>
        <rect x="944" y="237" width="12" height="6" rx="3"   fill="#1e1008"/>
      </g>

      <!-- PERSON 2 — right of fire · Set 2: Canyon Terra jacket + Deep Forest hat + Clear Sky accent -->
      <g>
        <!-- hat -->
        <rect x="1030" y="188" width="16" height="12" rx="3"  fill="#2D6A4F"/>
        <rect x="1026" y="198" width="24" height="4"  rx="2"  fill="#2D6A4F"/>
        <rect x="1030" y="196" width="16" height="3"          fill="#48CAE4"/>
        <!-- head + face -->
        <circle cx="1038" cy="207" r="8.5" fill="#e09878"/>
        <circle cx="1034" cy="206" r="1.3" fill="#2a1408"/>
        <circle cx="1041" cy="206" r="1.3" fill="#2a1408"/>
        <path d="M1035,210 Q1038,212 1041,210" fill="none" stroke="#2a1408" stroke-width="1" stroke-linecap="round"/>
        <!-- jacket + collar -->
        <rect x="1029" y="215" width="18" height="16" rx="3"  fill="#F4845F"/>
        <rect x="1029" y="215" width="18" height="5"  rx="2"  fill="#2D6A4F"/>
        <!-- left arm + enamel mug -->
        <rect x="1018" y="218" width="11" height="4"  rx="2"  fill="#e09878"/>
        <rect x="1008" y="215" width="9"  height="8"  rx="2"  fill="#48CAE4"/>
        <path d="M1017,218 Q1021,218 1021,221 Q1021,224 1017,224" fill="none" stroke="#48CAE4" stroke-width="1.6"/>
        <rect x="1009" y="215" width="9"  height="2"  rx="1"  fill="#2D6A4F"/>
        <!-- right arm -->
        <rect x="1043" y="220" width="5" height="10" rx="2.5" fill="#F4845F" transform="rotate(12,1045,220)"/>
        <!-- lap + feet -->
        <rect x="1023" y="228" width="32" height="9" rx="4.5" fill="#264653"/>
        <rect x="1022" y="234" width="12" height="6" rx="3"   fill="#1e2a30"/>
        <rect x="1037" y="235" width="12" height="6" rx="3"   fill="#1e2a30"/>
      </g>

      <!-- DOG — lying beside fire, right side · warm tan + brown markings -->
      <g>
        <!-- curled tail arching up behind body -->
        <path d="M1072,233 C1063,228 1060,219 1065,213 C1070,208 1077,213 1073,221"
              fill="none" stroke="#D4A574" stroke-width="6" stroke-linecap="round"/>
        <!-- body -->
        <rect x="1070" y="228" width="30" height="12" rx="6" fill="#D4A574"/>
        <!-- saddle marking -->
        <ellipse cx="1079" cy="233" rx="7" ry="4.5" fill="#8B5E3C" opacity="0.52"/>
        <!-- neck + head -->
        <rect x="1093" y="222" width="12" height="11" rx="4" fill="#D4A574"/>
        <circle cx="1100" cy="222" r="10.5" fill="#D4A574"/>
        <!-- floppy ear -->
        <ellipse cx="1093" cy="215" rx="4.5" ry="7" fill="#8B5E3C" transform="rotate(-18,1093,215)"/>
        <!-- snout -->
        <ellipse cx="1107" cy="225" rx="7.5" ry="5" fill="#c49060"/>
        <!-- nose -->
        <ellipse cx="1112" cy="223" rx="3.5" ry="2.5" fill="#1a0800"/>
        <circle  cx="1111" cy="222" r="1"              fill="white" opacity="0.38"/>
        <!-- eye + glint -->
        <circle cx="1098" cy="218" r="2.2" fill="#1a0800"/>
        <circle cx="1098.7" cy="217" r="0.7" fill="white" opacity="0.6"/>
        <!-- front paws -->
        <rect x="1073" y="237" width="11" height="5" rx="3" fill="#c49060"/>
        <rect x="1088" y="238" width="11" height="5" rx="3" fill="#c49060"/>
      </g>

      <!-- Smoke wisps -->
      <path class="smoke-wisp w1"
            d="M990,184 C988,177 993,170 990,163 C987,156 992,149 990,142 C988,135 992,128 990,121"
            fill="none" stroke="rgba(175,175,175,0.62)" stroke-width="3.2" stroke-linecap="round" />
      <path class="smoke-wisp w2"
            d="M992,184 C994,177 989,170 992,163 C995,156 990,149 993,142 C995,135 991,128 993,121"
            fill="none" stroke="rgba(175,175,175,0.52)" stroke-width="2.6" stroke-linecap="round" />
      <path class="smoke-wisp w3"
            d="M988,184 C986,177 991,170 988,163 C985,156 990,149 987,142 C985,135 989,128 987,121"
            fill="none" stroke="rgba(175,175,175,0.44)" stroke-width="2.1" stroke-linecap="round" />
    </g>
  </svg>

  <!-- ════════════ NIGHT ══════════════════════════════════════════ -->
  <svg v-else
    viewBox="0 0 1440 390"
    preserveAspectRatio="xMidYMid slice"
    xmlns="http://www.w3.org/2000/svg"
    class="footer-svg footer-svg--night"
    aria-hidden="true"
  >
    <defs>
      <linearGradient id="n-sky" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%"   stop-color="#070014" />
        <stop offset="38%"  stop-color="#0d1a2e" />
        <stop offset="74%"  stop-color="#0a2018" />
        <stop offset="100%" stop-color="#081a10" />
      </linearGradient>
      <radialGradient id="n-moonglow" cx="50%" cy="50%" r="50%">
        <stop offset="0%"   stop-color="#c8e8ff" stop-opacity="0.28" />
        <stop offset="100%" stop-color="#c8e8ff" stop-opacity="0" />
      </radialGradient>
      <linearGradient id="n-stream" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%"   stop-color="#1e4a7a" stop-opacity="0.85" />
        <stop offset="100%" stop-color="#102840" stop-opacity="0.7" />
      </linearGradient>
      <radialGradient id="n-fireglow" cx="50%" cy="55%" r="50%">
        <stop offset="0%"   stop-color="#ff7000" stop-opacity="0.65" />
        <stop offset="60%"  stop-color="#ff4500" stop-opacity="0.22" />
        <stop offset="100%" stop-color="#ff4500" stop-opacity="0" />
      </radialGradient>
      <linearGradient id="n-ground" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%"   stop-color="#0d2b10" />
        <stop offset="100%" stop-color="#071508" />
      </linearGradient>
    </defs>

    <rect width="1440" height="390" fill="url(#n-sky)" />

    <!-- Stars — original cluster near top -->
    <g>
      <circle cx="45"   cy="18"  r="1"   fill="white" opacity="0.88" />
      <circle cx="130"  cy="32"  r="0.7" fill="white" opacity="0.7" />
      <circle cx="198"  cy="11"  r="1.1" fill="white" opacity="0.95" />
      <circle cx="290"  cy="26"  r="0.6" fill="white" opacity="0.55" />
      <circle cx="380"  cy="8"   r="0.8" fill="white" opacity="0.8" />
      <circle cx="455"  cy="38"  r="0.7" fill="white" opacity="0.6" />
      <circle cx="540"  cy="14"  r="1"   fill="white" opacity="0.9" />
      <circle cx="620"  cy="28"  r="0.6" fill="white" opacity="0.5" />
      <circle cx="710"  cy="9"   r="0.9" fill="white" opacity="0.85" />
      <circle cx="800"  cy="35"  r="0.7" fill="white" opacity="0.65" />
      <circle cx="880"  cy="16"  r="1"   fill="white" opacity="0.8" />
      <circle cx="960"  cy="42"  r="0.6" fill="white" opacity="0.55" />
      <circle cx="1050" cy="12"  r="0.8" fill="white" opacity="0.75" />
      <circle cx="1140" cy="30"  r="0.7" fill="white" opacity="0.6" />
      <circle cx="80"   cy="52"  r="0.5" fill="white" opacity="0.4" />
      <circle cx="340"  cy="48"  r="0.5" fill="white" opacity="0.38" />
      <circle cx="670"  cy="50"  r="0.6" fill="white" opacity="0.42" />
      <circle cx="940"  cy="55"  r="0.5" fill="white" opacity="0.38" />
      <circle cx="1220" cy="22"  r="0.9" fill="white" opacity="0.78" />
    </g>
    <!-- Extra stars filling the sky up to y=115 -->
    <g>
      <circle cx="72"   cy="72"  r="0.8" fill="white" opacity="0.62" />
      <circle cx="165"  cy="88"  r="0.6" fill="white" opacity="0.48" />
      <circle cx="245"  cy="65"  r="1"   fill="white" opacity="0.75" />
      <circle cx="328"  cy="92"  r="0.7" fill="white" opacity="0.55" />
      <circle cx="412"  cy="76"  r="0.8" fill="white" opacity="0.65" />
      <circle cx="500"  cy="108" r="0.6" fill="white" opacity="0.42" />
      <circle cx="582"  cy="80"  r="0.9" fill="white" opacity="0.7" />
      <circle cx="652"  cy="112" r="0.7" fill="white" opacity="0.48" />
      <circle cx="735"  cy="72"  r="0.8" fill="white" opacity="0.6" />
      <circle cx="818"  cy="100" r="0.6" fill="white" opacity="0.45" />
      <circle cx="894"  cy="68"  r="1"   fill="white" opacity="0.78" />
      <circle cx="1060" cy="84"  r="0.7" fill="white" opacity="0.55" />
      <circle cx="1138" cy="110" r="0.8" fill="white" opacity="0.6" />
      <circle cx="1192" cy="70"  r="0.6" fill="white" opacity="0.48" />
      <circle cx="1318" cy="90"  r="0.8" fill="white" opacity="0.62" />
      <circle cx="34"   cy="110" r="1.1" fill="white" opacity="0.82" />
      <circle cx="1024" cy="95"  r="1"   fill="white" opacity="0.72" />
      <circle cx="1420" cy="62"  r="0.9" fill="white" opacity="0.65" />
    </g>

    <!-- Crescent moon -->
    <circle cx="1280" cy="45" r="52"  fill="url(#n-moonglow)" />
    <circle cx="1280" cy="45" r="22"  fill="#f0f4ff" opacity="0.94" />
    <circle cx="1293" cy="41" r="19"  fill="#070014" />

    <!-- ── Crop-circle orb sky writer (night) ────────────────────── -->
    <g v-if="skyText">
      <defs>
        <radialGradient id="n-orb-aura" cx="50%" cy="50%" r="50%">
          <stop offset="0%"   stop-color="#fff8e0" stop-opacity="0.98" />
          <stop offset="28%"  stop-color="#ffd700" stop-opacity="0.65" />
          <stop offset="100%" stop-color="#ffd700" stop-opacity="0"    />
        </radialGradient>
        <clipPath id="n-sky-reveal">
          <rect x="460" y="47" height="26" width="0">
            <animate attributeName="width"
              values="0;502;502;502;0"
              keyTimes="0;0.62;0.76;0.88;1"
              dur="20s" begin="1s" repeatCount="indefinite" />
          </rect>
        </clipPath>
      </defs>

      <!-- Written text, revealed left-to-right by clip -->
      <g clip-path="url(#n-sky-reveal)">
        <g opacity="0">
          <animate attributeName="opacity"
            values="0;0.78;0.78;0;0"
            keyTimes="0;0.05;0.76;0.88;1"
            dur="20s" begin="1s" repeatCount="indefinite" />
          <a :href="skyLink || undefined" target="_blank" rel="noopener noreferrer">
            <text x="720" y="64" text-anchor="middle"
              fill="none" :stroke="skyColor"
              stroke-width="0.65" stroke-dasharray="3 2"
              font-family="'Courier New', monospace"
              font-size="10" font-weight="700" letter-spacing="2"
            >{{ skyText }}</text>
          </a>
        </g>
      </g>

      <!-- The orb craft -->
      <g opacity="0">
        <animate attributeName="opacity"
          values="0;0.92;0.92;0;0"
          keyTimes="0;0.03;0.62;0.74;1"
          dur="20s" begin="1s" repeatCount="indefinite" />
        <animateTransform attributeName="transform" type="translate"
          values="460,62; 962,62; 962,62; 962,62; 460,62"
          keyTimes="0;0.62;0.76;0.88;1"
          dur="20s" begin="1s" repeatCount="indefinite" />
        <!-- Pulsing halo (brighter against dark sky) -->
        <circle r="13" fill="url(#n-orb-aura)" opacity="0.55">
          <animate attributeName="r"       values="11;17;11" dur="2.2s" repeatCount="indefinite" />
          <animate attributeName="opacity" values="0.55;0.2;0.55" dur="2.2s" repeatCount="indefinite" />
        </circle>
        <!-- Core -->
        <circle r="3.5" fill="#fffde0" opacity="0.98" />
        <circle r="5.5" fill="none" stroke="#ffd700" stroke-width="0.5" opacity="0.45" />
        <!-- Spinning equatorial ring -->
        <ellipse rx="9" ry="2.8" fill="none" stroke="rgba(255,215,0,0.75)" stroke-width="0.9">
          <animateTransform attributeName="transform" type="rotate"
            values="0 0 0;360 0 0" dur="3.5s" repeatCount="indefinite" />
        </ellipse>
        <!-- Writing beam -->
        <line x1="0" y1="4" x2="-4" y2="12"
          stroke="#ffd700" stroke-width="1.2" stroke-linecap="round" opacity="0.4">
          <animate attributeName="opacity" values="0.4;0.82;0.4" dur="1.8s" repeatCount="indefinite" />
        </line>
        <!-- Particle trail -->
        <circle cx="-10" cy="1"  r="1.8" fill="#ffd700" opacity="0.7"  />
        <circle cx="-19" cy="0"  r="1.2" fill="#ffd700" opacity="0.44" />
        <circle cx="-28" cy="-1" r="0.8" fill="#ffd700" opacity="0.22" />
      </g>
    </g>

    <!-- Landscape shifted 120px down -->
    <g transform="translate(0, 120)">

      <!-- Mountain layer 1 -->
      <path opacity="0.55" fill="#2a4858"
            d="M-10,178 C 42,172  88,162 138,166 C178,170 210,148 258,134
               C298,122 332,130 372,142 C408,153 435,136 475,122
               C510,109 545,116 582,128 C615,139 644,124 684,112
               C718,101 754,108 795,120 C832,131 860,118 900,107
               C936, 97 972,105 1010,116 C1045,126 1072,114 1112,106
               C1148, 99 1183,108 1222,120 C1258,131 1292,122 1335,132
               C1368,140 1405,152 1440,162 L1440,178 Z" />

      <!-- Mountain layer 2 -->
      <path fill="#1e4438"
            d="M-10,178 C 18,172  48,158  82,152 C110,147 138,118 178, 96
               C212, 78 244, 88 280,108 C310,125 335,108 372, 86
               C404, 68 436, 78 472, 98 C503,115 528, 96 566, 74
               C600, 55 635, 66 672, 89 C704,110 728, 90 765, 68
               C798, 50 834, 62 872, 85 C906,106 932, 88 968, 65
               C1000, 46 1038, 60 1078, 84 C1112,105 1138, 88 1175, 68
               C1208, 52 1242, 70 1278, 95 C1308,116 1336,105 1370,118
               C1398,130 1422,148 1440,160 L1440,178 Z" />

      <!-- Mountain layer 3 -->
      <path fill="#163824"
            d="M-10,178 C 14,175  36,168  62,162 C 85,156 108,132 142,112
               C170, 95 196,104 226,122 C252,138 272,120 305,100
               C332, 84 358, 94 388,115 C414,133 436,118 466,100
               C492, 85 516, 95 545,115 C570,132 592,118 624,100
               C652, 85 676, 70 714, 56 C748, 44 780, 58 816, 80
               C848,100 872, 84 908, 65 C940, 49 976, 64 1012, 90
               C1044,112 1066, 98 1100, 80 C1130, 65 1158, 82 1192,105
               C1220,126 1244,112 1278,128 C1305,142 1330,132 1362,145
               C1388,156 1416,164 1440,170 L1440,178 Z" />

      <!-- Mountain layer 4 -->
      <path fill="#0c2618"
            d="M-10,178 C 22,176  52,172  84,170 C110,168 135,158 166,152
               C192,147 216,156 244,163 C266,168 288,160 314,154
               C336,149 358,157 384,163 C406,168 426,162 452,156
               C474,151 498,160 524,166 C546,171 570,167 598,162
               C622,158 648,164 676,170 C700,174 724,172 752,168
               C775,165 800,170 828,174 C850,177 874,177 900,177
               L1440,177 L1440,178 Z" />

      <!-- Meadow ground -->
      <path fill="url(#n-ground)"
            d="M-10,176 Q 240,169 480,174 Q 720,179 960,171
               Q1200,164 1440,172 L1440,270 L-10,270 Z" />
      <path fill="none" stroke="#1a4020" stroke-width="2" opacity="0.5"
            d="M-10,176 Q 240,170 480,175 Q 720,180 960,172 Q1200,165 1440,173" />

      <!-- Fireflies -->
      <g opacity="0.55">
        <circle cx="80"   cy="192" r="1.4" fill="#a0ffb0" />
        <circle cx="145"  cy="198" r="1.1" fill="#c8ffd0" />
        <circle cx="310"  cy="200" r="1.2" fill="#a0ffb0" />
        <circle cx="480"  cy="193" r="1.4" fill="#c8ffd0" />
        <circle cx="648"  cy="190" r="1.2" fill="#a0ffb0" />
        <circle cx="860"  cy="194" r="1.4" fill="#c8ffd0" />
        <circle cx="1165" cy="202" r="1.1" fill="#a0ffb0" />
        <circle cx="1390" cy="198" r="1.2" fill="#c8ffd0" />
      </g>

      <!-- Stream (moonlit) -->
      <path class="stream-body" fill="url(#n-stream)"
            d="M  0,242 Q 150,230 290,244 Q 440,258 590,240
               Q 730,224 875,242 Q1020,258 1160,244 Q1320,230 1440,242
               L1440,256 Q1320,244 1160,258 Q1020,272 875,256
               Q 730,240 590,254 Q 440,270 290,258 Q 150,244   0,256 Z" />
      <path class="stream-shimmer" fill="none"
            stroke="#4db8e8" stroke-width="1.4" opacity="0.32"
            d="M0,244 Q 150,232 290,246 Q 440,260 590,242
               Q 730,226 875,244 Q1020,260 1160,246 Q1320,232 1440,244" />

      <!-- Lone pine -->
      <g>
        <rect x="118" y="164" width="5" height="16" rx="1" fill="#081808" />
        <polygon points="103,170 133,170 118,154" fill="#0c2210" />
        <polygon points="106,157 130,157 118,143" fill="#102a14" />
        <polygon points="110,145 126,145 118,131" fill="#143218" />
      </g>
      <!-- Small pine far right -->
      <g>
        <rect x="1318" y="168" width="5" height="12" rx="1" fill="#081808" />
        <polygon points="1305,173 1331,173 1318,160" fill="#0c2210" />
        <polygon points="1308,162 1328,162 1318,150" fill="#102a14" />
        <polygon points="1311,152 1325,152 1318,140" fill="#143218" />
      </g>

      <!-- Left hammock tree -->
      <g>
        <rect x="317" y="160" width="10" height="22" rx="2" fill="#071007" />
        <polygon points="288,170 358,170 322,148" fill="#0c1e0c" />
        <polygon points="293,155 350,155 322,133" fill="#102810" />
        <polygon points="299,141 344,141 322,120" fill="#143214" />
        <polygon points="305,127 338,127 322,107" fill="#183818" />
        <polygon points="311,113 332,113 322, 96" fill="#1c401c" />
      </g>
      <!-- Right hammock tree -->
      <g>
        <rect x="599" y="160" width="10" height="22" rx="2" fill="#071007" />
        <polygon points="570,170 638,170 604,148" fill="#0c1e0c" />
        <polygon points="575,155 634,155 604,133" fill="#102810" />
        <polygon points="581,141 628,141 604,120" fill="#143214" />
        <polygon points="587,127 622,127 604,107" fill="#183818" />
        <polygon points="593,114 616,114 604, 97" fill="#1c401c" />
      </g>

      <!-- Hammock -->
      <g class="hammock-group">
        <path d="M324,160 Q462,192 602,160 L602,165 Q462,197 324,165 Z"
              fill="#2e1060" opacity="0.9" />
        <path d="M324,161 Q462,193 602,161" fill="none"
              stroke="#6040a0" stroke-width="1.4" stroke-dasharray="7 6" opacity="0.55" />
        <ellipse cx="462" cy="186" rx="36" ry="8"   fill="#0d0028" opacity="0.7" />
        <ellipse cx="462" cy="178" rx=" 9" ry="8.5" fill="#0d0028" opacity="0.7" />
      </g>

      <!-- Campfire -->
      <circle cx="990" cy="218" r="60" fill="url(#n-fireglow)" />
      <line x1="968" y1="226" x2="1012" y2="215" stroke="#1a0c04" stroke-width="6" stroke-linecap="round" />
      <line x1="968" y1="215" x2="1012" y2="226" stroke="#1a0c04" stroke-width="6" stroke-linecap="round" />
      <g class="fire-group">
        <path d="M977,218 Q974,204 979,192 Q984,180 987,188 Q990,178 993,188 Q997,198 994,216 Z" fill="#e65100" />
        <path d="M979,218 Q977,208 981,198 Q985,190 988,196 Q991,188 994,196 Q996,205 993,218 Z" fill="#ff8f00" />
        <path d="M982,218 Q981,210 984,203 Q987,197 989,201 Q991,196 993,201 Q994,208 992,218 Z" fill="#ffd600" />
      </g>

      <!-- ═══ CAMPFIRE COMPANIONS (night) — firelit, deeper palette ══════════ -->

      <!-- COOLER — night: same forms, slightly deeper tones -->
      <g>
        <path d="M907,221 Q910,217 914,221" fill="none" stroke="#133226" stroke-width="2.5" stroke-linecap="round"/>
        <rect x="898" y="221" width="28" height="5"  rx="2.5" fill="#1d4d38"/>
        <rect x="900" y="225" width="24" height="14" rx="3"   fill="#2a8faa"/>
        <rect x="903" y="228" width="18" height="2.5" rx="1.2" fill="white" opacity="0.18"/>
        <rect x="909" y="222" width="5"  height="3"  rx="1.2" fill="#133226"/>
        <rect x="901" y="237" width="6"  height="3"  rx="1.5" fill="#0e2030"/>
        <rect x="916" y="237" width="6"  height="3"  rx="1.5" fill="#0e2030"/>
      </g>

      <!-- PERSON 1 — night: fire-warm amber glow on jacket, violet hat glows -->
      <g>
        <!-- hat -->
        <rect x="938" y="191" width="16" height="12" rx="3"   fill="#6920d4"/>
        <rect x="934" y="201" width="24" height="4"  rx="2"   fill="#6920d4"/>
        <rect x="938" y="199" width="16" height="3"           fill="#e8a000"/>
        <!-- head + face -->
        <circle cx="946" cy="210" r="8.5" fill="#d4884a"/>
        <circle cx="943" cy="209" r="1.3" fill="#1a0c04"/>
        <circle cx="949" cy="209" r="1.3" fill="#1a0c04"/>
        <path d="M943,213 Q946,215 949,213" fill="none" stroke="#1a0c04" stroke-width="1" stroke-linecap="round"/>
        <!-- jacket + scarf -->
        <rect x="937" y="218" width="18" height="16" rx="3"   fill="#c24800"/>
        <rect x="937" y="218" width="18" height="5"  rx="2"   fill="#e8a000"/>
        <!-- arms -->
        <rect x="951" y="220" width="5" height="13" rx="2.5" fill="#c24800" transform="rotate(-28,953,221)"/>
        <rect x="929" y="222" width="5" height="10" rx="2.5" fill="#c24800" transform="rotate(14,931,223)"/>
        <!-- lap + feet -->
        <rect x="930" y="231" width="32" height="9" rx="4.5" fill="#2a1c0e"/>
        <rect x="929" y="237" width="12" height="6" rx="3"   fill="#130a04"/>
        <rect x="944" y="237" width="12" height="6" rx="3"   fill="#130a04"/>
      </g>

      <!-- PERSON 2 — night: warm fire glow shifts terra to ember orange -->
      <g>
        <!-- hat -->
        <rect x="1030" y="188" width="16" height="12" rx="3"  fill="#1d4d38"/>
        <rect x="1026" y="198" width="24" height="4"  rx="2"  fill="#1d4d38"/>
        <rect x="1030" y="196" width="16" height="3"          fill="#2a8faa"/>
        <!-- head + face -->
        <circle cx="1038" cy="207" r="8.5" fill="#c07858"/>
        <circle cx="1034" cy="206" r="1.3" fill="#1a0c04"/>
        <circle cx="1041" cy="206" r="1.3" fill="#1a0c04"/>
        <path d="M1035,210 Q1038,212 1041,210" fill="none" stroke="#1a0c04" stroke-width="1" stroke-linecap="round"/>
        <!-- jacket + collar -->
        <rect x="1029" y="215" width="18" height="16" rx="3"  fill="#c4622c"/>
        <rect x="1029" y="215" width="18" height="5"  rx="2"  fill="#1d4d38"/>
        <!-- arm + mug glowing warm -->
        <rect x="1018" y="218" width="11" height="4"  rx="2"  fill="#c07858"/>
        <rect x="1008" y="215" width="9"  height="8"  rx="2"  fill="#2a8faa"/>
        <path d="M1017,218 Q1021,218 1021,221 Q1021,224 1017,224" fill="none" stroke="#2a8faa" stroke-width="1.6"/>
        <rect x="1009" y="215" width="9"  height="2"  rx="1"  fill="#1d4d38"/>
        <!-- right arm -->
        <rect x="1043" y="220" width="5" height="10" rx="2.5" fill="#c4622c" transform="rotate(12,1045,220)"/>
        <!-- lap + feet -->
        <rect x="1023" y="228" width="32" height="9" rx="4.5" fill="#142830"/>
        <rect x="1022" y="234" width="12" height="6" rx="3"   fill="#0e1a20"/>
        <rect x="1037" y="235" width="12" height="6" rx="3"   fill="#0e1a20"/>
      </g>

      <!-- DOG — night: same shapes, darker warm tones under firelight -->
      <g>
        <path d="M1072,233 C1063,228 1060,219 1065,213 C1070,208 1077,213 1073,221"
              fill="none" stroke="#b8875a" stroke-width="6" stroke-linecap="round"/>
        <rect x="1070" y="228" width="30" height="12" rx="6" fill="#b8875a"/>
        <ellipse cx="1079" cy="233" rx="7" ry="4.5" fill="#6e4020" opacity="0.55"/>
        <rect x="1093" y="222" width="12" height="11" rx="4" fill="#b8875a"/>
        <circle cx="1100" cy="222" r="10.5" fill="#b8875a"/>
        <ellipse cx="1093" cy="215" rx="4.5" ry="7" fill="#6e4020" transform="rotate(-18,1093,215)"/>
        <ellipse cx="1107" cy="225" rx="7.5" ry="5" fill="#9a6840"/>
        <ellipse cx="1112" cy="223" rx="3.5" ry="2.5" fill="#0e0400"/>
        <circle  cx="1111" cy="222" r="1"              fill="white" opacity="0.3"/>
        <circle cx="1098" cy="218" r="2.2" fill="#0e0400"/>
        <circle cx="1098.7" cy="217" r="0.7" fill="white" opacity="0.5"/>
        <rect x="1073" y="237" width="11" height="5" rx="3" fill="#9a6840"/>
        <rect x="1088" y="238" width="11" height="5" rx="3" fill="#9a6840"/>
      </g>

      <!-- Smoke wisps -->
      <path class="smoke-wisp w1"
            d="M990,184 C988,177 993,170 990,163 C987,156 992,149 990,142 C988,135 992,128 990,121"
            fill="none" stroke="rgba(200,210,220,0.58)" stroke-width="3.2" stroke-linecap="round" />
      <path class="smoke-wisp w2"
            d="M992,184 C994,177 989,170 992,163 C995,156 990,149 993,142 C995,135 991,128 993,121"
            fill="none" stroke="rgba(200,210,220,0.46)" stroke-width="2.6" stroke-linecap="round" />
      <path class="smoke-wisp w3"
            d="M988,184 C986,177 991,170 988,163 C985,156 990,149 987,142 C985,135 989,128 987,121"
            fill="none" stroke="rgba(200,210,220,0.36)" stroke-width="2.1" stroke-linecap="round" />
    </g>
  </svg>

</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'

withDefaults(defineProps<{ night?: boolean }>(), { night: false })

const skyText  = ref('Music Festivals & Nature Camping & Community Building')
const skyLink  = ref('')
const skyColor = ref('#ffd700')

onMounted(async () => {
  const { data } = await supabase
    .from('site_settings').select('value')
    .eq('key', 'footer_sky_text').limit(1)
  const val = (data as { value: unknown }[] | null)?.[0]?.value as Record<string, unknown> | undefined
  if (val) {
    if (typeof val.text  === 'string') skyText.value  = val.text
    if (typeof val.url   === 'string') skyLink.value  = val.url
    if (typeof val.color === 'string') skyColor.value = val.color
  }
})
</script>

<style scoped>
.footer-svg {
  display: block; width: 100%; height: auto; min-height: 220px;
}
.footer-svg--day   { background: #f5f0ff; }
.footer-svg--night { background: #070014; }

.stream-body    { animation: streamPulse 5s ease-in-out infinite; }
.stream-shimmer { animation: streamPulse 5s ease-in-out infinite reverse; }
@keyframes streamPulse {
  0%, 100% { opacity: 0.78; }
  50%      { opacity: 1; }
}

.hammock-group {
  animation: hammockSway 5.5s ease-in-out infinite;
  transform-box: fill-box; transform-origin: center;
}
@keyframes hammockSway {
  0%, 100% { transform: translateY(0); }
  50%      { transform: translateY(4px); }
}

.fire-group {
  animation: fireFlicker 0.8s ease-in-out infinite alternate;
  transform-box: fill-box; transform-origin: center bottom;
}
@keyframes fireFlicker {
  0%   { transform: scaleY(1)    scaleX(1); }
  45%  { transform: scaleY(1.12) scaleX(0.91); }
  100% { transform: scaleY(0.95) scaleX(1.07); }
}

.smoke-wisp {
  animation: wispRise 4.2s ease-out infinite;
  transform-box: fill-box; transform-origin: center bottom;
}
.w2 { animation-delay: 1.4s; }
.w3 { animation-delay: 2.8s; }
@keyframes wispRise {
  0%   { transform: translateY(0);      opacity: 0;    }
  10%  {                                opacity: 0.78; }
  75%  { transform: translateY(-60px);  opacity: 0.28; }
  100% { transform: translateY(-88px);  opacity: 0;    }
}
</style>

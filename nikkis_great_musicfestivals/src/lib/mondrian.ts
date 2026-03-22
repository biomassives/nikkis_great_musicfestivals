// ─── Mondrian SVG compositing engine ─────────────────────────────────────────
// Shared between MapsPage.vue (public display) and AdminMapsPage.vue (editor)

export interface MRect {
  x: number; y: number; w: number; h: number
  fill: string
  img?: true
}

export interface MondrianOpts {
  /** 0–5: override layout (default: hash from regionId) */
  layout?: number | null
  /** Stroke/grid line thickness in SVG units (default: 4) */
  stroke?: number
  /** Indices into `images[]` to feature in collage slots; empty = all */
  featured?: number[]
}

// ── Six layouts ──────────────────────────────────────────────────────────────

// Layout 0 — Midnight Festival (purple dominant)
const L0: MRect[] = [
  { x:   0, y:   0, w: 120, h: 200, fill: '#7c4dff', img: true  },
  { x: 120, y:   0, w: 200, h:  88, fill: '#ffd700', img: true  },
  { x: 120, y:  88, w: 100, h:  62, fill: '#f0ece0'             },
  { x: 220, y:  88, w: 100, h:  62, fill: '#4dd0c4', img: true  },
  { x: 120, y: 150, w:  64, h:  50, fill: '#0d0028'             },
  { x: 184, y: 150, w:  76, h:  50, fill: '#c8a8ff'             },
  { x: 260, y: 150, w:  60, h:  50, fill: '#12122a'             },
]

// Layout 1 — Golden Hour (southwest earth tones)
const L1: MRect[] = [
  { x:   0, y:   0, w:  80, h:  70, fill: '#d4850a', img: true  },
  { x:  80, y:   0, w: 160, h:  70, fill: '#f5ede0', img: true  },
  { x: 240, y:   0, w:  80, h:  70, fill: '#1c1c24'             },
  { x:   0, y:  70, w: 140, h:  72, fill: '#9e2a0f', img: true  },
  { x: 140, y:  70, w: 180, h:  72, fill: '#e05c2a', img: true  },
  { x:   0, y: 142, w:  60, h:  58, fill: '#f5ede0'             },
  { x:  60, y: 142, w:  80, h:  58, fill: '#b07c10'             },
  { x: 140, y: 142, w: 100, h:  58, fill: '#c8a060'             },
  { x: 240, y: 142, w:  80, h:  58, fill: '#1c1c24'             },
]

// Layout 2 — Pacific Coast (deep teal / seafoam / clay)
const L2: MRect[] = [
  { x:   0, y:   0, w: 120, h:  72, fill: '#006070', img: true  },
  { x: 120, y:   0, w:  60, h:  36, fill: '#4dd0c4'             },
  { x: 120, y:  36, w:  60, h:  36, fill: '#e0f0f4'             },
  { x: 180, y:   0, w: 140, h: 120, fill: '#1a3828', img: true  },
  { x:   0, y:  72, w: 120, h:  48, fill: '#e0f0f4', img: true  },
  { x:   0, y: 120, w: 180, h:  80, fill: '#3a5060'             },
  { x: 180, y: 120, w:  80, h:  80, fill: '#c86040'             },
  { x: 260, y: 120, w:  60, h:  80, fill: '#4dd0c4'             },
]

// Layout 3 — Bold Primaries (classic Mondrian energy)
const L3: MRect[] = [
  { x:   0, y:   0, w: 100, h:  80, fill: '#7c4dff', img: true  },
  { x: 100, y:   0, w: 120, h:  80, fill: '#0a0a14', img: true  },
  { x: 220, y:   0, w: 100, h:  80, fill: '#ffd700'             },
  { x:   0, y:  80, w: 320, h:  42, fill: '#f5f0e8'             },
  { x:   0, y: 122, w: 150, h:  78, fill: '#d42010', img: true  },
  { x: 150, y: 122, w: 100, h:  78, fill: '#c8a8ff'             },
  { x: 250, y: 122, w:  70, h:  78, fill: '#0a0a14'             },
]

// Layout 4 — Autumn Appalachian (rust, amber, deep forest)
const L4: MRect[] = [
  { x:   0, y:   0, w: 160, h: 130, fill: '#8b2010', img: true  },
  { x:   0, y: 130, w: 160, h:  70, fill: '#c47a10', img: true  },
  { x: 160, y:   0, w: 160, h:  60, fill: '#f5ede0'             },
  { x: 160, y:  60, w:  80, h:  80, fill: '#1e4028', img: true  },
  { x: 240, y:  60, w:  80, h:  80, fill: '#c89030'             },
  { x: 160, y: 140, w: 160, h:  60, fill: '#1a1212'             },
]

// Layout 5 — Deep Indigo Night (electric purple / teal / gold)
const L5: MRect[] = [
  { x:   0, y:   0, w:  80, h:  67, fill: '#7c4dff', img: true  },
  { x:  80, y:   0, w:  80, h:  67, fill: '#050510'             },
  { x: 160, y:   0, w: 160, h:  67, fill: '#0a0a1e', img: true  },
  { x:   0, y:  67, w:  80, h:  66, fill: '#c0d8f0'             },
  { x:  80, y:  67, w:  80, h:  66, fill: '#4dd0c4', img: true  },
  { x: 160, y:  67, w:  80, h:  66, fill: '#050510'             },
  { x: 240, y:  67, w:  80, h:  66, fill: '#c060d0'             },
  { x:   0, y: 133, w: 160, h:  67, fill: '#ffd700', img: true  },
  { x: 160, y: 133, w:  80, h:  67, fill: '#7c4dff'             },
  { x: 240, y: 133, w:  80, h:  67, fill: '#0a0a1e'             },
]

export const MONDRIAN_LAYOUTS: MRect[][] = [L0, L1, L2, L3, L4, L5]

export const MONDRIAN_NAMES = [
  'Midnight Festival',
  'Golden Hour',
  'Pacific Coast',
  'Bold Primaries',
  'Autumn Appalachian',
  'Deep Indigo Night',
]

// Two-color swatches for the admin palette picker (primary, secondary)
export const MONDRIAN_SWATCHES: [string, string][] = [
  ['#7c4dff', '#ffd700'],
  ['#d4850a', '#e05c2a'],
  ['#006070', '#4dd0c4'],
  ['#7c4dff', '#d42010'],
  ['#8b2010', '#c47a10'],
  ['#7c4dff', '#4dd0c4'],
]

// ── Generator ────────────────────────────────────────────────────────────────

export function hashRegionId(id: string): number {
  return id.split('').reduce((n, c) => n + c.charCodeAt(0), 0)
}

export function resolveLayout(regionId: string, override?: number | null): number {
  if (override !== null && override !== undefined && override >= 0 && override < MONDRIAN_LAYOUTS.length) {
    return override
  }
  return hashRegionId(regionId) % MONDRIAN_LAYOUTS.length
}

export function mondrianSvg(
  regionId: string,
  images: string[],
  opts?: MondrianOpts,
): string {
  const stroke     = opts?.stroke ?? 4
  const layoutIdx  = resolveLayout(regionId, opts?.layout)
  const layout     = MONDRIAN_LAYOUTS[layoutIdx]!
  const safeId     = regionId.replace(/[^a-z0-9]/gi, '_')

  // Only the "featured" images appear in collage slots; empty = use all
  const usable: string[] = opts?.featured?.length
    ? (opts.featured.map(i => images[i]).filter(Boolean) as string[])
    : images

  let imgSlotIdx = 0
  const defs: string[] = []
  const els:  string[] = []

  layout.forEach((r, i) => {
    if (r.img && usable.length > 0) {
      const url  = usable[imgSlotIdx % usable.length]!
      imgSlotIdx++
      const cpId = `cp_${safeId}_${i}`
      defs.push(
        `<clipPath id="${cpId}"><rect x="${r.x}" y="${r.y}" width="${r.w}" height="${r.h}"/></clipPath>`,
      )
      els.push(
        `<image x="${r.x}" y="${r.y}" width="${r.w}" height="${r.h}" href="${url}" preserveAspectRatio="xMidYMid slice" clip-path="url(#${cpId})"/>`,
        `<rect x="${r.x}" y="${r.y}" width="${r.w}" height="${r.h}" fill="none" stroke="#111" stroke-width="${stroke}"/>`,
      )
    } else {
      els.push(
        `<rect x="${r.x}" y="${r.y}" width="${r.w}" height="${r.h}" fill="${r.fill}" stroke="#111" stroke-width="${stroke}" stroke-linejoin="miter"/>`,
      )
    }
  })

  const defsStr = defs.length ? `<defs>${defs.join('')}</defs>` : ''
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 200" width="100%" height="100%" preserveAspectRatio="xMidYMid slice">${defsStr}${els.join('')}</svg>`
}

// ─── Spirograph path generator ───────────────────────────────────────────────
// Shared between SpirographLogo.vue and PageBackground.vue.
// Hypotrochoid with sinusoidal helical arm modulation:
//   x = (R-r)·cos(t) + d·cos((R-r)/r · t)
//   y = (R-r)·sin(t) − d·sin((R-r)/r · t)
//   where d = dBase + sinAmp·sin(sinFreq·t)

function gcd(a: number, b: number): number { return b === 0 ? a : gcd(b, a % b) }

export function spiro(R: number, r: number, d: number, amp = 0, freq = 0, n = 500): string {
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

export const SPIRO_P1 = spiro(40,  8, 34, 3, 5,  600)  // 5-petal gold
export const SPIRO_P2 = spiro(42, 14, 36, 2, 9,  450)  // 3-petal magenta
export const SPIRO_P3 = spiro(35,  5, 30, 2, 7,  700)  // 7-petal cyan
export const SPIRO_P4 = spiro(36,  9, 28, 3, 4,  480)  // 4-petal orange

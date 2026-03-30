<template>
  <q-page class="support-page relative overflow-hidden">
    <PageBackground variant="support" />

    <div class="page-content q-pa-lg">

      <div class="text-center q-py-xl">
        <div class="section-label q-mb-xs">{{ cfg.section_label }}</div>
        <div class="text-h3 text-bold q-mb-sm">{{ cfg.heading }}</div>
        <div class="text-body1 text-grey-7" style="max-width:600px; margin:0 auto">
          {{ cfg.description }}
        </div>
      </div>

      <!-- KICKSTARTER CAMPAIGN BANNER -->
      <div v-if="cfg.kickstarter_url || true" class="ks-banner q-mb-xl" style="max-width:780px; margin:0 auto">

        <!-- Layer 2: background SVG art -->
        <svg class="ks-bg-svg" viewBox="0 0 780 340" xmlns="http://www.w3.org/2000/svg"
             aria-hidden="true" preserveAspectRatio="xMidYMid slice">
          <defs>
            <radialGradient id="ks-glow-green" cx="65%" cy="30%" r="45%">
              <stop offset="0%" stop-color="#05ce78" stop-opacity="0.28" />
              <stop offset="100%" stop-color="#05ce78" stop-opacity="0" />
            </radialGradient>
            <radialGradient id="ks-glow-purple" cx="15%" cy="75%" r="38%">
              <stop offset="0%" stop-color="#a020f0" stop-opacity="0.2" />
              <stop offset="100%" stop-color="#a020f0" stop-opacity="0" />
            </radialGradient>
          </defs>

          <!-- ambient glows -->
          <rect width="780" height="340" fill="url(#ks-glow-green)" />
          <rect width="780" height="340" fill="url(#ks-glow-purple)" />

          <!-- SPIRO_P3 (7-petal cyan) — upper right, large -->
          <g transform="translate(500, -18) scale(2.3)">
            <path :d="SPIRO_P3" fill="none" stroke="#00e5ff" stroke-width="0.55" opacity="0.13" />
          </g>

          <!-- SPIRO_P1 (5-petal gold) — lower left, medium -->
          <g transform="translate(-35, 155) scale(1.8)">
            <path :d="SPIRO_P1" fill="none" stroke="#ffd700" stroke-width="0.55" opacity="0.1" />
          </g>

          <!-- SPIRO_P2 (3-petal magenta) — top left corner -->
          <g transform="translate(-25, -35) scale(1.4)">
            <path :d="SPIRO_P2" fill="none" stroke="#e040fb" stroke-width="0.5" opacity="0.08" />
          </g>

          <!-- static stars -->
          <circle cx="122" cy="28"  r="1.3" fill="#fff" opacity="0.65" />
          <circle cx="315" cy="16"  r="0.8" fill="#fff" opacity="0.50" />
          <circle cx="575" cy="22"  r="1.1" fill="#fff" opacity="0.55" />
          <circle cx="705" cy="50"  r="1.6" fill="#fff" opacity="0.38" />
          <circle cx="42"  cy="145" r="0.9" fill="#fff" opacity="0.50" />
          <circle cx="762" cy="215" r="1.2" fill="#fff" opacity="0.45" />
          <circle cx="655" cy="298" r="0.9" fill="#fff" opacity="0.42" />
          <circle cx="198" cy="308" r="1.4" fill="#fff" opacity="0.55" />
          <circle cx="418" cy="318" r="0.7" fill="#fff" opacity="0.38" />
          <circle cx="540" cy="140" r="1.0" fill="#fff" opacity="0.48" />
          <circle cx="88"  cy="250" r="0.8" fill="#fff" opacity="0.42" />

          <!-- twinkling coloured stars -->
          <circle cx="482" cy="78" r="1.5" fill="#05ce78" opacity="0.7">
            <animate attributeName="opacity" values="0.7;0.1;0.7" dur="3.2s" repeatCount="indefinite" />
          </circle>
          <circle cx="242" cy="58" r="1.0" fill="#7df9ff" opacity="0.6">
            <animate attributeName="opacity" values="0.6;0.12;0.6" dur="2.7s" begin="0.8s" repeatCount="indefinite" />
          </circle>
          <circle cx="638" cy="172" r="1.3" fill="#ffd700" opacity="0.5">
            <animate attributeName="opacity" values="0.5;0.05;0.5" dur="4.1s" begin="1.5s" repeatCount="indefinite" />
          </circle>
          <circle cx="355" cy="295" r="1.0" fill="#e040fb" opacity="0.5">
            <animate attributeName="opacity" values="0.5;0.08;0.5" dur="3.6s" begin="0.4s" repeatCount="indefinite" />
          </circle>

          <!-- pulse rings emanating from upper-right spiro center -->
          <circle cx="624" cy="110" r="28" fill="none" stroke="#05ce78" stroke-width="0.9" opacity="0">
            <animate attributeName="r"       values="28;82"  dur="3.4s" repeatCount="indefinite" />
            <animate attributeName="opacity" values="0.35;0" dur="3.4s" repeatCount="indefinite" />
          </circle>
          <circle cx="624" cy="110" r="28" fill="none" stroke="#05ce78" stroke-width="0.9" opacity="0">
            <animate attributeName="r"       values="28;82"  dur="3.4s" begin="1.7s" repeatCount="indefinite" />
            <animate attributeName="opacity" values="0.35;0" dur="3.4s" begin="1.7s" repeatCount="indefinite" />
          </circle>
        </svg>

        <!-- Layer 3: content -->
        <div class="ks-content text-center">
          <div class="ks-eyebrow q-mb-sm">Campaign</div>
          <div class="ks-rocket q-mb-sm" aria-hidden="true">🚀</div>
          <div class="ks-title q-mb-md">Back Us on Kickstarter</div>
          <div class="ks-desc q-mb-lg">
            Help us reach our goal of <strong>$38,000</strong> by <strong>May 10, 2026</strong> to fund concerts at senior facilities,
            community art programs, and festival accessibility initiatives.
          </div>
          <div class="ks-pills row items-center justify-center q-gutter-md q-mb-lg">
            <div class="ks-pill ks-pill--green">
              <span class="ks-pill-num">$38,000</span>
              <span class="ks-pill-label">Goal</span>
            </div>
            <div class="ks-pill ks-pill--blue">
              <span class="ks-pill-num">May 10</span>
              <span class="ks-pill-label">Deadline</span>
            </div>
          </div>
          <q-btn
            v-if="cfg.kickstarter_url"
            :href="cfg.kickstarter_url"
            target="_blank"
            label="Back This Project on Kickstarter"
            unelevated
            icon="launch"
            class="ks-cta-btn q-px-xl"
          />
          <div v-else class="ks-coming-soon q-mt-xs">Kickstarter campaign link coming soon</div>
        </div>
      </div>

      <!-- BILLING INTERVAL TOGGLE -->
      <div class="flex flex-center q-mb-xl">
        <div class="interval-toggle">
          <button
            :class="['interval-btn', { 'interval-btn--active': interval === 'month' }]"
            @click="interval = 'month'"
          >Monthly</button>
          <button
            :class="['interval-btn', { 'interval-btn--active': interval === 'year' }]"
            @click="interval = 'year'"
          >Annual <span class="save-tag">save 2 mo</span></button>
        </div>
      </div>

      <!-- TIER CARDS -->
      <div class="row q-col-gutter-lg justify-center q-mb-xl">
        <div v-for="tier in cfg.tiers" :key="tier.id" class="col-12 col-sm-6 col-md-4" style="max-width:340px">
          <q-card
            class="tier-card"
            :class="{ 'tier-card--featured': tier.featured }"
          >
            <div v-if="tier.featured" class="featured-ribbon">Most Popular</div>

            <q-card-section class="text-center q-pt-xl q-pb-md">
              <div class="tier-icon q-mb-md">
                <svg width="56" height="56" viewBox="0 0 100 100">
                  <circle cx="50" cy="50" r="44" fill="none" :stroke="tier.color" stroke-width="2" stroke-dasharray="6 3" />
                  <text x="50" y="58" text-anchor="middle" font-size="32" :fill="tier.color">{{ tier.emoji }}</text>
                </svg>
              </div>
              <div class="text-h6 text-bold q-mb-xs" :style="`color:${tier.color}`">{{ tier.name }}</div>
              <div class="price-display q-mb-xs">
                <span class="text-h3 text-bold">${{ interval === 'month' ? tier.monthly : tier.annual }}</span>
                <span class="text-caption text-grey-6"> / {{ interval === 'month' ? 'mo' : 'yr' }}</span>
              </div>
              <div v-if="interval === 'year'" class="text-caption text-positive q-mb-sm">
                Save ${{ (tier.monthly * 12) - tier.annual }} vs monthly
              </div>
            </q-card-section>

            <q-separator />

            <q-card-section>
              <q-list dense>
                <q-item v-for="perk in tier.perks" :key="perk" dense class="q-py-xs">
                  <q-item-section avatar>
                    <q-icon name="check_circle" :color="tier.featured ? 'secondary' : 'positive'" size="18px" />
                  </q-item-section>
                  <q-item-section class="text-body2">{{ perk }}</q-item-section>
                </q-item>
              </q-list>
            </q-card-section>

            <q-card-actions class="q-pa-md">
              <q-btn
                :label="tier.featured ? 'Join Now' : 'Get Started'"
                :color="tier.featured ? 'secondary' : 'primary'"
                :outline="!tier.featured"
                class="full-width"
                :loading="checkingOut === tier.id"
                @click="checkout(tier)"
                unelevated
              />
            </q-card-actions>
          </q-card>
        </div>
      </div>

      <!-- $1,000 CORPORATE SPONSOR -->
      <div class="sponsor-section q-pa-xl rounded-borders text-center q-mb-xl" style="max-width:700px; margin:0 auto">
        <div class="sponsor-crown q-mb-md">👑</div>
        <div class="section-label q-mb-xs">Presenting Sponsor</div>
        <div class="text-h4 text-bold q-mb-xs sponsor-title">$1,000 Community Sponsor</div>
        <div class="text-body1 q-mb-lg" style="color:rgba(255,255,255,0.75); max-width:480px; margin:0 auto">
          Your logo featured on <strong>all marketing materials</strong> — flyers, social media, event signage, and the website — as an official community supporter.
        </div>
        <q-list dense class="text-left q-mb-lg" style="max-width:360px; margin:0 auto">
          <q-item v-for="perk in sponsorPerks" :key="perk" dense class="q-py-xs">
            <q-item-section avatar>
              <q-icon name="star" color="yellow-6" size="18px" />
            </q-item-section>
            <q-item-section class="text-body2" style="color:rgba(255,255,255,0.85)">{{ perk }}</q-item-section>
          </q-item>
        </q-list>
        <q-btn
          label="Become a Sponsor"
          color="yellow-8"
          text-color="black"
          unelevated
          icon="workspace_premium"
          class="q-px-xl text-weight-bold"
          :loading="checkingOut === 'sponsor'"
          @click="checkoutSponsor"
        />
      </div>

      <!-- CUSTOM AMOUNT -->
      <div class="custom-section q-pa-xl rounded-borders text-center q-mb-xl" style="max-width:600px; margin:0 auto">
        <div class="section-label q-mb-sm">Custom Support</div>
        <div class="text-h6 q-mb-md">Choose your own amount</div>
        <div class="row justify-center items-start q-gutter-md flex-wrap">
          <q-input
            v-model.number="customAmount"
            type="number"
            prefix="$"
            outlined
            dense
            style="width:140px"
            :rules="[v => v > 0 || 'Enter an amount']"
            hide-bottom-space
          />
          <div class="interval-toggle interval-toggle--sm">
            <button
              :class="['interval-btn', { 'interval-btn--active': interval === 'month' }]"
              @click="interval = 'month'"
            >Monthly</button>
            <button
              :class="['interval-btn', { 'interval-btn--active': interval === 'year' }]"
              @click="interval = 'year'"
            >Annual</button>
          </div>
          <q-btn
            label="Contribute"
            color="primary"
            unelevated
            :loading="checkingOut === 'custom'"
            :disable="!customAmount || customAmount <= 0"
            @click="checkoutCustom"
          />
        </div>
      </div>

      <!-- MEMBER PERKS SUMMARY -->
      <div class="perks-summary q-pa-xl rounded-borders q-mb-xl" style="max-width:860px; margin:0 auto">
        <div class="text-h5 text-bold text-center q-mb-lg">All Members Receive</div>
        <div class="row q-col-gutter-lg justify-center">
          <div v-for="perk in cfg.globalPerks" :key="perk.title" class="col-12 col-sm-6 col-md-3 text-center">
            <q-icon :name="perk.icon" size="36px" :color="perk.color" class="q-mb-sm" />
            <div class="text-weight-bold q-mb-xs">{{ perk.title }}</div>
            <div class="text-caption text-grey-7">{{ perk.desc }}</div>
          </div>
        </div>
      </div>

    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import PageBackground from 'src/components/PageBackground.vue'
import { supabase } from 'src/lib/supabase'
import { SPIRO_P1, SPIRO_P2, SPIRO_P3 } from 'src/lib/spirograph'

const interval     = ref<'month' | 'year'>('month')
const customAmount = ref<number | null>(null)
const checkingOut  = ref<string | null>(null)

// ── Types ────────────────────────────────────────────────────────────────────
interface Tier {
  id:           string
  name:         string
  emoji:        string
  color:        string
  featured:     boolean
  monthly:      number
  annual:       number
  stripe_month: string
  stripe_year:  string
  perks:        string[]
}

interface GlobalPerk {
  icon:  string
  color: string
  title: string
  desc:  string
}

// ── Defaults ─────────────────────────────────────────────────────────────────
const DEFAULT_TIERS: Tier[] = [
  {
    id: 'supporter', name: 'Supporter', emoji: '🌱', color: '#43a047',
    featured: false, monthly: 5, annual: 50,
    stripe_month: 'price_supporter_monthly', stripe_year: 'price_supporter_annual',
    perks: [
      'Monthly newsletter',
      'Festival community access',
      'Early show announcements',
      'Member-only Discord',
    ],
  },
  {
    id: 'friend', name: 'Festival Friend', emoji: '🎸', color: '#7b1fa2',
    featured: true, monthly: 15, annual: 150,
    stripe_month: 'price_friend_monthly', stripe_year: 'price_friend_annual',
    perks: [
      'Everything in Supporter',
      'Monthly merch gift',
      'Art donated to seniors on your behalf',
      'Artist interview archives',
      'Priority merch access',
      'Name on supporter wall',
    ],
  },
  {
    id: 'champion', name: 'Champion', emoji: '🌟', color: '#e65100',
    featured: false, monthly: 25, annual: 250,
    stripe_month: 'price_champion_monthly', stripe_year: 'price_champion_annual',
    perks: [
      'Everything in Festival Friend',
      'Original art sent to you monthly',
      'Art donated to a senior facility in your name',
      'Behind-the-scenes updates',
      'Annual virtual meet & greet',
      'Direct mission input',
    ],
  },
]

const DEFAULT_GLOBAL_PERKS: GlobalPerk[] = [
  { icon: 'newspaper',     color: 'indigo-6',      title: 'Newsletter',     desc: 'Show dates, stories, trail reports' },
  { icon: 'style',         color: 'deep-orange-6', title: 'Merch Gifts',    desc: 'Monthly surprises for friends+' },
  { icon: 'photo_library', color: 'amber-7',       title: 'Photo Archives', desc: 'Exclusive concert photography' },
  { icon: 'people',        color: 'teal-6',        title: 'Community',      desc: 'Connect with fellow festival fans' },
]

const sponsorPerks = [
  'Logo on all printed marketing flyers & event signage',
  'Logo featured on the website sponsor wall',
  'Dedicated social media shout-out',
  'All Champion tier membership benefits included',
  'Direct partnership recognition with Nikki',
]

// ── Config (loaded from Supabase, falls back to defaults) ─────────────────────
const cfg = reactive({
  section_label:   'Help Us Grow',
  heading:         'Support the Mission',
  description:     'Every membership directly funds accessibility programs, senior facility concerts, and community building at festivals.',
  kickstarter_url: '' as string,
  tiers:           DEFAULT_TIERS.map(t => ({ ...t, perks: [...t.perks] })) as Tier[],
  globalPerks:     DEFAULT_GLOBAL_PERKS.map(p => ({ ...p })) as GlobalPerk[],
})

onMounted(async () => {
  const { data } = await supabase
    .from('site_settings')
    .select('value')
    .eq('key', 'support_content')
    .limit(1)
  const row = data?.[0]
  if (row?.value && typeof row.value === 'object') {
    const v = row.value as Record<string, unknown>
    if (typeof v.section_label   === 'string') cfg.section_label   = v.section_label
    if (typeof v.heading         === 'string') cfg.heading         = v.heading
    if (typeof v.description     === 'string') cfg.description     = v.description
    if (typeof v.kickstarter_url === 'string') cfg.kickstarter_url = v.kickstarter_url
    if (Array.isArray(v.tiers) && (v.tiers as unknown[]).length > 0) {
      cfg.tiers = v.tiers as Tier[]
    }
    if (Array.isArray(v.global_perks) && (v.global_perks as unknown[]).length > 0) {
      cfg.globalPerks = v.global_perks as GlobalPerk[]
    }
  }
})

// ── Checkout ──────────────────────────────────────────────────────────────────
async function checkout(tier: Tier) {
  checkingOut.value = tier.id
  const priceId = interval.value === 'month' ? tier.stripe_month : tier.stripe_year
  await redirectToStripe({ priceId, mode: 'subscription' })
  checkingOut.value = null
}

async function checkoutSponsor() {
  checkingOut.value = 'sponsor'
  await redirectToStripe({ customAmount: 100000, interval: 'year', mode: 'payment', description: 'Community Sponsor – logo on all marketing' })
  checkingOut.value = null
}

async function checkoutCustom() {
  if (!customAmount.value || customAmount.value <= 0) return
  checkingOut.value = 'custom'
  await redirectToStripe({ customAmount: customAmount.value * 100, interval: interval.value, mode: 'subscription' })
  checkingOut.value = null
}

async function redirectToStripe(params: Record<string, unknown>) {
  try {
    const res = await fetch('/api/stripe-checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    })
    const { url, error } = await res.json() as { url?: string; error?: string }
    if (error) { console.error(error); return }
    if (url) window.location.href = url
  } catch (e) {
    console.error('Checkout error', e)
  }
}
</script>

<style lang="scss" scoped>
/* ── Page shell ─────────────────────────────────────────────────── */
.support-page   { min-height: 100vh; }
.page-content   { position: relative; z-index: 1; }

.section-label {
  font-size: 11px; font-weight: 700; letter-spacing: 3px;
  text-transform: uppercase; color: #e64a19; display: block;
}

/* ── Interval pill toggle ───────────────────────────────────────── */
.interval-toggle {
  display: inline-flex;
  border-radius: 999px;
  border: 2px solid #1a1a2e;
  overflow: hidden;
  background: #fff;

  &--sm .interval-btn { padding: 6px 16px; font-size: 13px; }
}

.interval-btn {
  padding: 9px 22px;
  border: none;
  background: transparent;
  color: #1a1a2e;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.18s, color 0.18s;
  white-space: nowrap;

  &--active {
    background: #1a1a2e;
    color: #fff;
  }
  &:not(.interval-btn--active):hover {
    background: rgba(26,26,46,0.06);
  }
}

.save-tag {
  display: inline-block;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 0.5px;
  background: #e64a19;
  color: #fff;
  padding: 1px 6px;
  border-radius: 8px;
  margin-left: 5px;
  vertical-align: middle;
}

/* ── Tier cards ─────────────────────────────────────────────────── */
.tier-card {
  border-radius: 16px;
  border: 1px solid rgba(0,0,0,0.08);
  transition: transform 0.25s ease, box-shadow 0.25s ease;
  position: relative;
  overflow: visible;
  &:hover { transform: translateY(-4px); box-shadow: 0 16px 40px rgba(0,0,0,0.12); }
  &--featured {
    border-color: #7b1fa2;
    box-shadow: 0 8px 32px rgba(123,31,162,0.2);
  }
}

.featured-ribbon {
  position: absolute; top: -12px; left: 50%; transform: translateX(-50%);
  background: #7b1fa2; color: white;
  font-size: 11px; font-weight: 700; letter-spacing: 1px;
  padding: 4px 16px; border-radius: 20px; white-space: nowrap;
}

/* ── Kickstarter campaign banner ────────────────────────────────── */
.ks-banner {
  position: relative;
  overflow: hidden;
  border-radius: 22px;
  background:
    radial-gradient(ellipse 62% 72% at 70% 28%, rgba(5, 150, 80, 0.30) 0%, transparent 65%),
    radial-gradient(ellipse 50% 58% at 16% 78%, rgba(100, 0, 180, 0.20) 0%, transparent 55%),
    linear-gradient(155deg, #08001e 0%, #0d1d40 50%, #041510 100%);
  border: 1px solid rgba(5, 206, 120, 0.42);
  box-shadow:
    0 0 0 1px rgba(5, 206, 120, 0.08),
    0 0 55px rgba(5, 206, 120, 0.15),
    0 24px 80px rgba(5, 0, 40, 0.5),
    inset 0 1px 0 rgba(255, 255, 255, 0.06);
  animation: ks-flicker-in 2.4s ease forwards;
}

.ks-bg-svg {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.ks-content {
  position: relative;
  z-index: 1;
  padding: 54px 48px 48px;
}

.ks-eyebrow {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 3.5px;
  text-transform: uppercase;
  color: #05ce78;
  display: block;
}

.ks-rocket {
  font-size: 54px;
  display: inline-block;
  line-height: 1;
  filter: drop-shadow(0 0 18px rgba(5, 206, 120, 0.55));
  animation: rocket-float 2.8s ease-in-out infinite;
}

.ks-title {
  font-size: clamp(1.8rem, 4vw, 2.5rem);
  font-weight: 800;
  color: #fff;
  line-height: 1.1;
  letter-spacing: -0.5px;
  text-shadow: 0 0 45px rgba(5, 206, 120, 0.38);
}

.ks-desc {
  font-size: 1.05rem;
  color: rgba(255, 255, 255, 0.70);
  max-width: 530px;
  margin: 0 auto;
  line-height: 1.65;
  strong { color: #fff; }
}

.ks-pills { flex-wrap: wrap; }

.ks-pill {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 11px 30px;
  border-radius: 14px;
  min-width: 115px;
  backdrop-filter: blur(6px);
  &--green {
    background: rgba(5, 206, 120, 0.14);
    border: 1px solid rgba(5, 206, 120, 0.40);
  }
  &--blue {
    background: rgba(100, 180, 255, 0.11);
    border: 1px solid rgba(100, 180, 255, 0.33);
  }
}
.ks-pill-num {
  font-size: 1.4rem;
  font-weight: 800;
  color: #fff;
  letter-spacing: -0.5px;
}
.ks-pill-label {
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.48);
  margin-top: 3px;
}

.ks-cta-btn {
  background: linear-gradient(135deg, #05ce78 0%, #00a85a 100%) !important;
  color: #fff !important;
  font-weight: 700;
  font-size: 1rem;
  letter-spacing: 0.3px;
  border-radius: 50px !important;
  box-shadow: 0 5px 28px rgba(5, 206, 120, 0.42) !important;
  transition: box-shadow 0.22s, transform 0.22s;
  &:hover {
    box-shadow: 0 10px 44px rgba(5, 206, 120, 0.65) !important;
    transform: translateY(-2px);
  }
}

.ks-coming-soon {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.35);
  letter-spacing: 0.5px;
}

/* flicker-in entrance */
@keyframes ks-flicker-in {
  0%   { opacity: 0; }
  6%   { opacity: 0.28; }
  9%   { opacity: 0.04; }
  14%  { opacity: 0.52; }
  18%  { opacity: 0.13; }
  23%  { opacity: 0.74; }
  26%  { opacity: 0.43; }
  33%  { opacity: 0.88; }
  37%  { opacity: 0.65; }
  46%  { opacity: 0.96; }
  53%  { opacity: 0.80; }
  63%  { opacity: 1; }
  100% { opacity: 1; }
}

/* rocket float */
@keyframes rocket-float {
  0%, 100% { transform: translateY(0) rotate(-12deg); }
  50%       { transform: translateY(-11px) rotate(-7deg); }
}

/* ── Sponsor section ────────────────────────────────────────────── */
.sponsor-section {
  background: linear-gradient(135deg, #1a0042 0%, #2d0066 100%);
  border: 2px solid #ffd700;
  box-shadow: 0 0 40px rgba(255,215,0,0.15);
}
.sponsor-crown { font-size: 48px; line-height: 1; }
.sponsor-title { color: #ffd700; }

/* ── Custom & perks sections ────────────────────────────────────── */
.custom-section {
  background: rgba(255,112,67,0.05);
  border: 1px dashed rgba(230,74,25,0.3);
}

.perks-summary {
  background: rgba(123,31,162,0.04);
  border: 1px solid rgba(123,31,162,0.1);
  border-radius: 16px;
}
</style>

<style lang="scss">
/* ── Full dark mode ─────────────────────────────────────────────── */
body.body--dark {
  .support-page {
    background: #0d0020 !important;
  }

  /* Headings and body text */
  .support-page .text-h3,
  .support-page .text-h5,
  .support-page .text-h6,
  .support-page .text-body1,
  .support-page .text-body2,
  .support-page .text-weight-bold {
    color: rgba(255,255,255,0.92) !important;
  }
  .support-page .text-grey-7 { color: rgba(255,255,255,0.55) !important; }
  .support-page .text-grey-6 { color: rgba(255,255,255,0.45) !important; }

  /* Interval pill — invert to: white border, white active, dark text on inactive */
  .support-page .interval-toggle {
    background: transparent;
    border-color: rgba(255,255,255,0.75);
  }
  .support-page .interval-btn {
    color: rgba(255,255,255,0.65);
    &--active {
      background: #fff;
      color: #0d0020;
    }
    &:not(.interval-btn--active):hover {
      background: rgba(255,255,255,0.08);
      color: #fff;
    }
  }

  /* Tier cards */
  .support-page .tier-card {
    background: #1a1035 !important;
    border-color: rgba(255,255,255,0.1) !important;
    &--featured {
      border-color: #9c27b0 !important;
      box-shadow: 0 8px 32px rgba(156,39,176,0.25) !important;
    }
    &:hover { box-shadow: 0 16px 40px rgba(0,0,0,0.4) !important; }
  }
  .support-page .q-separator { background: rgba(255,255,255,0.1) !important; }

  /* Custom amount section */
  .support-page .custom-section {
    background: rgba(230,74,25,0.08) !important;
    border-color: rgba(230,74,25,0.25) !important;
  }

  /* Perks summary */
  .support-page .perks-summary {
    background: rgba(156,39,176,0.1) !important;
    border-color: rgba(156,39,176,0.2) !important;
  }

  /* Quasar input in dark context */
  .support-page .q-field__native,
  .support-page .q-field__prefix {
    color: rgba(255,255,255,0.85) !important;
  }
}
</style>

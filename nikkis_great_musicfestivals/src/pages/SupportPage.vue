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
      'Quarterly photo print',
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

// ── Config (loaded from Supabase, falls back to defaults) ─────────────────────
const cfg = reactive({
  section_label: 'Help Us Grow',
  heading:       'Support the Mission',
  description:   'Every membership directly funds accessibility programs, senior facility concerts, and community building at festivals.',
  tiers:         DEFAULT_TIERS.map(t => ({ ...t, perks: [...t.perks] })) as Tier[],
  globalPerks:   DEFAULT_GLOBAL_PERKS.map(p => ({ ...p })) as GlobalPerk[],
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
    if (typeof v.section_label === 'string') cfg.section_label = v.section_label
    if (typeof v.heading       === 'string') cfg.heading       = v.heading
    if (typeof v.description   === 'string') cfg.description   = v.description
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
.support-page   { min-height: 100vh; background: #fff8f2; }
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

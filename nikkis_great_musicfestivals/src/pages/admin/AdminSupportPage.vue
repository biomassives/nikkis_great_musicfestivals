<template>
  <q-page class="q-pa-lg">
    <div class="row items-center q-mb-lg">
      <div>
        <div class="text-h5 text-teal-3">Support Page Editor</div>
        <div class="text-caption text-grey-5">Membership tiers, pricing, perks</div>
      </div>
      <q-space />
      <q-btn color="teal" unelevated icon="save" label="Save All" :loading="saving" @click="save" />
    </div>

    <q-banner v-if="saved" rounded class="save-banner q-mb-lg">
      <template #avatar><q-icon name="check_circle" color="teal-4" /></template>
      Changes saved successfully.
    </q-banner>

    <!-- ── HEADER ──────────────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Page Header</div>
    <q-card class="settings-card q-mb-xl">
      <q-card-section class="q-gutter-md">
        <q-input v-model="header.section_label" label="Section label (eyebrow)"
          dark outlined dense label-color="teal-3" color="teal-3" />
        <q-input v-model="header.heading" label="Heading"
          dark outlined dense label-color="teal-3" color="teal-3" />
        <q-input v-model="header.description" label="Description" type="textarea" autogrow
          dark outlined label-color="teal-3" color="teal-3" />
      </q-card-section>
    </q-card>

    <!-- ── TIERS ───────────────────────────────────────────────── -->
    <div class="row items-center q-mb-sm">
      <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 col">Membership Tiers</div>
      <q-btn icon="add" label="Add Tier" color="teal-7" outline size="sm" @click="addTier" />
    </div>

    <q-list bordered class="tiers-accordion rounded-borders q-mb-xl">
      <template v-for="(tier, ti) in tiers" :key="tier.id || ti">
        <q-expansion-item
          :label="`${tier.emoji || '?'} ${tier.name || 'Untitled tier'}`"
          header-class="tier-header"
          expand-icon-class="text-teal-4"
        >
          <q-card class="tier-card-inner">
            <q-card-section class="q-gutter-md">

              <!-- Identity -->
              <div class="text-caption text-teal-5 text-uppercase ls-1">Identity</div>
              <div class="row q-col-gutter-md">
                <div class="col-8">
                  <q-input v-model="tier.name" label="Tier name *"
                    dark outlined dense label-color="teal-3" color="teal-3" />
                </div>
                <div class="col-4">
                  <q-input v-model="tier.emoji" label="Emoji"
                    dark outlined dense label-color="teal-3" color="teal-3" />
                </div>
              </div>
              <div class="row q-col-gutter-md">
                <div class="col-6">
                  <q-input
                    v-model="tier.id"
                    label="Slug (id, locked after first save)"
                    dark outlined dense label-color="teal-3" color="teal-3"
                  />
                </div>
                <div class="col-6 row items-center q-gutter-sm">
                  <div class="text-caption text-grey-5">Accent color</div>
                  <input type="color" v-model="tier.color" class="color-picker" title="Tier accent color" />
                  <span class="text-caption text-grey-5">{{ tier.color }}</span>
                  <q-toggle v-model="tier.featured" label="Featured" color="teal-3" dark class="q-ml-sm" />
                </div>
              </div>

              <q-separator dark class="q-my-xs" />

              <!-- Pricing -->
              <div class="text-caption text-teal-5 text-uppercase ls-1">Pricing</div>
              <div class="row q-col-gutter-md">
                <div class="col-6">
                  <q-input v-model.number="tier.monthly" label="Monthly price ($)" type="number"
                    dark outlined dense label-color="teal-3" color="teal-3" />
                </div>
                <div class="col-6">
                  <q-input v-model.number="tier.annual" label="Annual price ($)" type="number"
                    dark outlined dense label-color="teal-3" color="teal-3" />
                </div>
              </div>
              <div class="row q-col-gutter-md">
                <div class="col-6">
                  <q-input v-model="tier.stripe_month" label="Stripe price ID — monthly"
                    dark outlined dense label-color="teal-3" color="teal-3" />
                </div>
                <div class="col-6">
                  <q-input v-model="tier.stripe_year" label="Stripe price ID — annual"
                    dark outlined dense label-color="teal-3" color="teal-3" />
                </div>
              </div>

              <q-separator dark class="q-my-xs" />

              <!-- Perks -->
              <div class="text-caption text-teal-5 text-uppercase ls-1 q-mb-xs">Tier Perks</div>
              <div v-for="(perk, pi) in tier.perks" :key="pi" class="row items-center q-gutter-xs q-mb-xs">
                <div class="col">
                  <q-input v-model="tier.perks[pi]" :label="`Perk ${pi + 1}`"
                    dark outlined dense label-color="teal-3" color="teal-3" />
                </div>
                <q-btn flat dense round icon="delete" color="red-4" size="sm" @click="removeTierPerk(ti, pi)" />
              </div>
              <q-btn icon="add" label="Add Perk" color="teal-7" outline size="sm" class="q-mt-xs" @click="addTierPerk(ti)" />

              <q-separator dark class="q-my-sm" />

              <!-- Tier actions -->
              <div class="row q-gutter-sm">
                <q-btn flat dense round icon="arrow_upward"   color="grey-5" size="sm" :disable="ti === 0"               @click="moveTier(ti, -1)" />
                <q-btn flat dense round icon="arrow_downward" color="grey-5" size="sm" :disable="ti === tiers.length - 1" @click="moveTier(ti,  1)" />
                <q-space />
                <q-btn flat label="Delete Tier" color="red-4" size="sm" @click="removeTier(ti)" />
              </div>

            </q-card-section>
          </q-card>
        </q-expansion-item>
        <q-separator dark v-if="ti < tiers.length - 1" />
      </template>

      <q-item v-if="tiers.length === 0" class="q-py-md">
        <q-item-section class="text-grey-6 text-center">No tiers yet — add one above.</q-item-section>
      </q-item>
    </q-list>

    <!-- ── GLOBAL PERKS ────────────────────────────────────────── -->
    <div class="row items-center q-mb-sm">
      <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 col">Global Perks (All Members)</div>
      <q-btn icon="add" label="Add Perk" color="teal-7" outline size="sm" @click="addGlobalPerk" />
    </div>

    <q-card class="settings-card q-mb-xl">
      <q-card-section>
        <div v-for="(perk, pi) in globalPerks" :key="pi" class="perk-row q-mb-md">
          <div class="row items-center q-gutter-xs q-mb-xs">
            <div class="text-caption text-teal-5 text-weight-bold" style="min-width:20px">{{ pi + 1 }}.</div>
            <q-space />
            <q-btn flat dense round icon="arrow_upward"   color="grey-5" size="sm" :disable="pi === 0"                      @click="moveGlobalPerk(pi, -1)" />
            <q-btn flat dense round icon="arrow_downward" color="grey-5" size="sm" :disable="pi === globalPerks.length - 1" @click="moveGlobalPerk(pi,  1)" />
            <q-btn flat dense round icon="delete"         color="red-4"  size="sm"                                          @click="removeGlobalPerk(pi)" />
          </div>
          <div class="row q-col-gutter-md">
            <div class="col-6">
              <q-input v-model="perk.icon" label="Material icon name"
                dark outlined dense label-color="teal-3" color="teal-3">
                <template #prepend>
                  <q-icon :name="perk.icon || 'star'" :color="perk.color || 'teal'" size="18px" />
                </template>
              </q-input>
            </div>
            <div class="col-6">
              <q-input v-model="perk.color" label="Quasar color (e.g. teal-6)"
                dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
          </div>
          <div class="row q-col-gutter-md q-mt-xs">
            <div class="col-6">
              <q-input v-model="perk.title" label="Title"
                dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
            <div class="col-6">
              <q-input v-model="perk.desc" label="Description"
                dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
          </div>
        </div>

        <div v-if="globalPerks.length === 0" class="text-grey-6 text-center q-py-md">
          No global perks yet.
        </div>
      </q-card-section>
    </q-card>

    <div class="row justify-end q-mb-xl">
      <q-btn color="teal" unelevated icon="save" label="Save All" :loading="saving" @click="save" />
    </div>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'

const saving = ref(false)
const saved  = ref(false)

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

// ── State ─────────────────────────────────────────────────────────────────────
const header = reactive({
  section_label: 'Help Us Grow',
  heading:       'Support the Mission',
  description:   'Every membership directly funds accessibility programs, senior facility concerts, and community building at festivals.',
})

const tiers       = ref<Tier[]>(DEFAULT_TIERS.map(t => ({ ...t, perks: [...t.perks] })))
const globalPerks = ref<GlobalPerk[]>(DEFAULT_GLOBAL_PERKS.map(p => ({ ...p })))

// ── Tier helpers ──────────────────────────────────────────────────────────────
function addTier() {
  tiers.value.push({
    id: `tier-${Date.now()}`, name: '', emoji: '🎵', color: '#4db6ac',
    featured: false, monthly: 10, annual: 100,
    stripe_month: '', stripe_year: '',
    perks: [],
  })
}
function removeTier(i: number) { tiers.value.splice(i, 1) }
function moveTier(i: number, dir: -1 | 1) {
  const arr = [...tiers.value]
  const tmp = arr[i]!; arr[i] = arr[i + dir]!; arr[i + dir] = tmp
  tiers.value = arr
}
function addTierPerk(ti: number)              { tiers.value[ti]!.perks.push('') }
function removeTierPerk(ti: number, pi: number) { tiers.value[ti]!.perks.splice(pi, 1) }

// ── Global perk helpers ───────────────────────────────────────────────────────
function addGlobalPerk() {
  globalPerks.value.push({ icon: 'star', color: 'teal-6', title: '', desc: '' })
}
function removeGlobalPerk(i: number) { globalPerks.value.splice(i, 1) }
function moveGlobalPerk(i: number, dir: -1 | 1) {
  const arr = [...globalPerks.value]
  const tmp = arr[i]!; arr[i] = arr[i + dir]!; arr[i + dir] = tmp
  globalPerks.value = arr
}

// ── Load / Save ───────────────────────────────────────────────────────────────
async function load() {
  const { data } = await supabase
    .from('site_settings')
    .select('value')
    .eq('key', 'support_content')
    .single()
  if (data?.value && typeof data.value === 'object') {
    const v = data.value as Record<string, unknown>
    if (v.section_label !== undefined) header.section_label = v.section_label as string
    if (v.heading       !== undefined) header.heading       = v.heading as string
    if (v.description   !== undefined) header.description   = v.description as string
    if (Array.isArray(v.tiers) && (v.tiers as unknown[]).length > 0) {
      tiers.value = v.tiers as Tier[]
    }
    if (Array.isArray(v.global_perks) && (v.global_perks as unknown[]).length > 0) {
      globalPerks.value = v.global_perks as GlobalPerk[]
    }
  }
}

async function save() {
  saving.value = true
  saved.value  = false
  await supabase.from('site_settings').upsert({
    key: 'support_content',
    value: {
      section_label: header.section_label,
      heading:       header.heading,
      description:   header.description,
      tiers:         tiers.value.map(t => ({ ...t, perks: [...t.perks] })),
      global_perks:  globalPerks.value.map(p => ({ ...p })),
    },
    updated_at: new Date().toISOString(),
  })
  saving.value = false
  saved.value  = true
  setTimeout(() => { saved.value = false }, 3000)
}

onMounted(load)
</script>

<style lang="scss" scoped>
.settings-card {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.18);
  border-radius: 12px;
}
.tiers-accordion {
  background: #1a1a2e;
  border-color: rgba(77,182,172,0.2) !important;
  border-radius: 12px;
}
.tier-header    { background: #1a1a2e; color: #b2dfdb; }
.tier-card-inner { background: #14142a; border-top: 1px solid rgba(77,182,172,0.12); }
.save-banner { background: rgba(77,182,172,0.1); border: 1px solid rgba(77,182,172,0.3); color: #e0f2f1; }
.ls-2 { letter-spacing: 2px; }
.ls-1 { letter-spacing: 1.5px; }
.perk-row {
  padding: 12px;
  background: rgba(77,182,172,0.04);
  border: 1px solid rgba(77,182,172,0.12);
  border-radius: 8px;
}
.color-picker {
  width: 36px; height: 36px; border: none; padding: 0;
  border-radius: 6px; cursor: pointer; background: none;
}
</style>

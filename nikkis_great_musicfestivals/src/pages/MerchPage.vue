<template>
  <q-page class="merch-page relative overflow-hidden">
    <PageBackground variant="merch" :opacity="0.07" />

    <div class="page-content q-pa-lg">

      <!-- Header -->
      <div class="text-center q-py-xl">
        <div class="section-label q-mb-xs">Made with love on the road</div>
        <div class="text-h3 text-bold q-mb-sm">Merch &amp; Goods</div>
        <div class="text-body1 text-grey-7 q-mb-lg">Handmade art, festival photography, and curated finds from our travels</div>
      </div>

      <div v-if="loading" class="flex flex-center q-py-xl">
        <q-spinner-orbit color="amber" size="48px" />
      </div>

      <template v-else>
        <!-- Category tabs -->
        <q-tabs
          v-model="tab"
          align="center"
          active-color="deep-purple"
          indicator-color="amber"
          class="merch-tabs q-mb-xl"
          dense
        >
          <q-tab
            v-for="sec in sections"
            :key="sec.slug"
            :name="sec.slug"
            :icon="sec.icon"
            :label="sec.label"
          />
        </q-tabs>

        <!-- Tab panels -->
        <q-tab-panels v-model="tab" animated transition-prev="fade" transition-next="fade" class="merch-panels">
          <q-tab-panel
            v-for="sec in sections"
            :key="sec.slug"
            :name="sec.slug"
            class="q-pa-none"
          >
            <div class="panel-intro row items-center q-mb-xl q-gutter-md">
              <q-icon :name="sec.icon" size="48px" class="panel-icon" :style="`color:${getColor(sec.color)}`" />
              <div>
                <div class="text-h5 text-bold" :style="`color:${getColor(sec.color)}`">{{ sec.label }}</div>
                <div class="text-caption text-grey-6">{{ sec.description }}</div>
              </div>
            </div>

            <div class="merch-grid">
              <div v-for="item in itemsBySection(sec.slug)" :key="item.id" class="merch-card">
                <div class="merch-card-img-wrap">
                  <img
                    :src="item.image_url ?? `https://picsum.photos/seed/${item.id}/400/400`"
                    :alt="item.name"
                    class="merch-card-img"
                  />
                  <div v-if="item.badge"    class="merch-card-badge" :style="`background:${getColor(sec.color)}`">
                    {{ item.badge }}
                  </div>
                  <div v-if="item.sold_out" class="merch-card-soldout">Sold Out</div>
                </div>
                <div class="merch-card-body">
                  <div class="merch-card-name">{{ item.name }}</div>
                  <div class="merch-card-desc">{{ item.description }}</div>
                  <div class="merch-card-footer">
                    <div class="merch-card-price" :style="`color:${getColor(sec.color)}`">{{ item.price }}</div>
                    <button
                      v-if="!item.sold_out"
                      class="merch-card-btn"
                      :style="`background:${getColor(sec.color)}`"
                      @click="inquire(item.name)"
                    >Inquire</button>
                    <button v-else class="merch-card-btn merch-card-btn--disabled" disabled>Sold Out</button>
                  </div>
                </div>
              </div>

              <div v-if="itemsBySection(sec.slug).length === 0" class="text-grey-5 text-center q-py-xl col-span-full">
                Nothing here yet — check back soon!
              </div>
            </div>
          </q-tab-panel>
        </q-tab-panels>

        <!-- Inquiry CTA -->
        <div class="inquiry-cta text-center q-py-xl q-mt-xl">
          <div class="text-h6 text-bold q-mb-sm">Looking for something specific?</div>
          <div class="text-body2 text-grey-7 q-mb-lg">
            Many items are one-of-a-kind. Reach out and we'll let you know what's available.
          </div>
          <q-btn
            label="Send an Inquiry"
            icon="mail_outline"
            color="deep-purple"
            unelevated
            size="md"
            class="q-mr-sm"
            href="mailto:nikki@nikkisgreatmusicfestivals.com"
          />
          <q-btn
            label="Support the Tour"
            icon="favorite"
            color="amber-8"
            outline
            size="md"
            :to="'/support'"
          />
        </div>
      </template>

    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import PageBackground from 'src/components/PageBackground.vue'
import { supabase } from 'src/lib/supabase'
import type { MerchItem, MerchSection } from 'src/lib/supabase'

const $q      = useQuasar()
const loading = ref(true)
const items   = ref<MerchItem[]>([])
const tab     = ref('')

const sections = ref<MerchSection[]>([
  { slug: 'art',    label: 'Art We Make', description: 'Original paintings, prints, and handcrafted pieces created during the tour',  icon: 'palette',      color: 'deep-purple' },
  { slug: 'photos', label: 'Photos',      description: 'Limited-edition festival prints, framed and fine art options available',       icon: 'photo_camera', color: 'amber-8'     },
  { slug: 'other',  label: 'Other Stuff', description: 'Trail finds, festival collectibles, and curated goods from the road',          icon: 'star',         color: 'deep-orange' },
])

const colorMap: Record<string, string> = {
  'teal-3':       '#80cbc4',
  'teal-4':       '#26a69a',
  'amber-8':      '#ff8f00',
  'green-8':      '#2e7d32',
  'pink-8':       '#ad1457',
  'deep-purple':  '#7b1fa2',
  'blue-5':       '#2196f3',
  'deep-orange':  '#e65100',
  'light-blue-4': '#29b6f6',
  'red-5':        '#f44336',
}
function getColor(c: string) { return colorMap[c] ?? '#7b1fa2' }

function itemsBySection(slug: string) {
  return items.value.filter(i => i.category === slug)
}

function inquire(name: string) {
  $q.notify({ message: `"${name}" — contact us to purchase!`, color: 'dark', icon: 'shopping_cart', position: 'top' })
}

onMounted(async () => {
  const [itemsRes, sectionsRes] = await Promise.all([
    supabase.from('merch_items').select('*').eq('published', true).order('display_order'),
    supabase.from('site_settings').select('key,value').eq('key', 'merch_sections').limit(1),
  ])
  items.value = (itemsRes.data as MerchItem[]) ?? []
  if (sectionsRes.data?.[0]?.value) sections.value = sectionsRes.data[0].value as MerchSection[]
  tab.value = sections.value[0]?.slug ?? 'art'
  loading.value = false
})
</script>

<style lang="scss" scoped>
.merch-page   { min-height: 100vh; }
.page-content { position: relative; z-index: 1; max-width: 1200px; margin: 0 auto; }

.section-label {
  font-size: 11px; font-weight: 700; letter-spacing: 3px;
  text-transform: uppercase; color: #7b1fa2;
}

:deep(.merch-tabs .q-tab) {
  font-size: 13px; letter-spacing: 1px; font-weight: 600;
  text-transform: uppercase; opacity: 0.6;
  &.q-tab--active { opacity: 1; }
}

.merch-panels { background: transparent !important; box-shadow: none !important; }
.panel-intro  { border-left: 3px solid rgba(0,0,0,0.12); padding-left: 16px; }

.merch-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 24px;
  padding-bottom: 32px;
}
.col-span-full { grid-column: 1 / -1; }

.merch-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  display: flex; flex-direction: column;
  transition: transform 0.2s, box-shadow 0.2s;
  &:hover { transform: translateY(-3px); box-shadow: 0 6px 20px rgba(0,0,0,0.13); }
}

.merch-card-img-wrap { position: relative; aspect-ratio: 1; overflow: hidden; }
.merch-card-img {
  width: 100%; height: 100%; object-fit: cover; display: block;
  transition: transform 0.3s ease;
  .merch-card:hover & { transform: scale(1.04); }
}
.merch-card-badge {
  position: absolute; top: 10px; left: 10px;
  color: #fff; font-size: 10px; font-weight: 700;
  letter-spacing: 1px; text-transform: uppercase;
  padding: 3px 8px; border-radius: 4px;
}
.merch-card-soldout {
  position: absolute; inset: 0;
  background: rgba(0,0,0,0.45);
  color: #fff; font-size: 14px; font-weight: 700;
  letter-spacing: 2px; text-transform: uppercase;
  display: flex; align-items: center; justify-content: center;
}
.merch-card-body {
  padding: 14px 16px 16px; display: flex; flex-direction: column; flex: 1;
}
.merch-card-name   { font-weight: 700; font-size: 15px; color: #1a1a1a; margin-bottom: 6px; }
.merch-card-desc   { font-size: 12px; color: #666; line-height: 1.5; flex: 1; }
.merch-card-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 12px; }
.merch-card-price  { font-weight: 800; font-size: 17px; }
.merch-card-btn {
  border: none; outline: none; cursor: pointer;
  color: #fff; font-size: 12px; font-weight: 700;
  letter-spacing: 1px; text-transform: uppercase;
  padding: 6px 14px; border-radius: 6px;
  transition: opacity 0.15s;
  &:hover { opacity: 0.82; }
  &--disabled { background: #ccc !important; cursor: default; opacity: 0.6; &:hover { opacity: 0.6; } }
}

.inquiry-cta { border-top: 1px solid rgba(0,0,0,0.08); }
</style>

<style lang="scss">
body.body--dark {
  .merch-page { background: #0d0a00 !important; }

  .merch-page .section-label { color: #ce93d8 !important; }
  .merch-page .text-h3, .merch-page .text-h5, .merch-page .text-bold { color: rgba(255,255,255,0.9) !important; }
  .merch-page .text-grey-7, .merch-page .text-grey-6 { color: rgba(255,255,255,0.5) !important; }

  .merch-page .panel-intro { border-left-color: rgba(255,255,255,0.15) !important; }

  .merch-page .merch-card {
    background: #1e1a0a !important;
    box-shadow: 0 2px 12px rgba(0,0,0,0.4) !important;
    &:hover { box-shadow: 0 6px 20px rgba(0,0,0,0.5) !important; }
  }
  .merch-page .merch-card-name { color: rgba(255,255,255,0.9) !important; }
  .merch-page .merch-card-desc { color: rgba(255,255,255,0.55) !important; }

  .merch-page .inquiry-cta { border-top-color: rgba(255,255,255,0.1) !important; }
  .merch-page .text-h6, .merch-page .text-body2 { color: rgba(255,255,255,0.8) !important; }
}
</style>

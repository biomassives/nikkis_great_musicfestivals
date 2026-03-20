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

      <!-- Category tabs -->
      <q-tabs
        v-model="tab"
        align="center"
        active-color="deep-purple"
        indicator-color="amber"
        class="merch-tabs q-mb-xl"
        dense
      >
        <q-tab name="art"    icon="palette"      label="Art We Make" />
        <q-tab name="photos" icon="photo_camera" label="Photos"      />
        <q-tab name="other"  icon="star"         label="Other Stuff" />
      </q-tabs>

      <!-- Tab panels -->
      <q-tab-panels v-model="tab" animated transition-prev="fade" transition-next="fade" class="merch-panels">

        <!-- ART WE MAKE -->
        <q-tab-panel name="art" class="q-pa-none">
          <div class="panel-intro row items-center q-mb-xl q-gutter-md">
            <svg width="48" height="48" viewBox="0 0 100 100" class="panel-icon flex-shrink-0">
              <circle cx="50" cy="50" r="42" fill="none" stroke="#7b1fa2" stroke-width="2.5"/>
              <circle cx="35" cy="38" r="7"  fill="#7b1fa2" opacity="0.6"/>
              <circle cx="62" cy="30" r="5"  fill="#ffd700" opacity="0.8"/>
              <circle cx="68" cy="58" r="6"  fill="#ab47bc" opacity="0.7"/>
              <circle cx="38" cy="65" r="5"  fill="#ff7043" opacity="0.7"/>
              <path d="M35 38 Q48 22 62 30 Q80 40 68 58 Q58 75 38 65 Q20 55 35 38Z"
                fill="none" stroke="#7b1fa2" stroke-width="1.5" stroke-dasharray="4 3"/>
            </svg>
            <div>
              <div class="text-h5 text-bold art-color">Art We Make</div>
              <div class="text-caption text-grey-6">Original paintings, prints, and handcrafted pieces created during the tour</div>
            </div>
          </div>
          <div class="merch-grid">
            <div v-for="item in artItems" :key="item.id" class="merch-card">
              <div class="merch-card-img-wrap">
                <img :src="item.image" :alt="item.name" class="merch-card-img" />
                <div v-if="item.badge"   class="merch-card-badge art-bg">{{ item.badge }}</div>
                <div v-if="item.soldOut" class="merch-card-soldout">Sold Out</div>
              </div>
              <div class="merch-card-body">
                <div class="merch-card-name">{{ item.name }}</div>
                <div class="merch-card-desc">{{ item.description }}</div>
                <div class="merch-card-footer">
                  <div class="merch-card-price art-color">{{ item.price }}</div>
                  <button v-if="!item.soldOut" class="merch-card-btn art-bg" @click="inquire(item.name)">Inquire</button>
                  <button v-else class="merch-card-btn merch-card-btn--disabled" disabled>Sold Out</button>
                </div>
              </div>
            </div>
          </div>
        </q-tab-panel>

        <!-- PHOTOS -->
        <q-tab-panel name="photos" class="q-pa-none">
          <div class="panel-intro row items-center q-mb-xl q-gutter-md">
            <svg width="48" height="48" viewBox="0 0 100 100" class="panel-icon flex-shrink-0">
              <rect x="10" y="25" width="80" height="60" rx="8" fill="none" stroke="#ff8f00" stroke-width="2.5"/>
              <circle cx="50" cy="55" r="18" fill="none" stroke="#ff8f00" stroke-width="2"/>
              <circle cx="50" cy="55" r="10" fill="none" stroke="#ffd700" stroke-width="1.5"/>
              <circle cx="50" cy="55" r="4"  fill="#ff8f00" opacity="0.7"/>
              <path d="M35 25 L42 12 L58 12 L65 25" fill="none" stroke="#ff8f00" stroke-width="2"/>
              <circle cx="78" cy="38" r="4" fill="#ffd700"/>
            </svg>
            <div>
              <div class="text-h5 text-bold photo-color">Photos</div>
              <div class="text-caption text-grey-6">Limited-edition festival prints, framed and fine art options available</div>
            </div>
          </div>
          <div class="merch-grid">
            <div v-for="item in photoItems" :key="item.id" class="merch-card">
              <div class="merch-card-img-wrap">
                <img :src="item.image" :alt="item.name" class="merch-card-img" />
                <div v-if="item.badge"   class="merch-card-badge photo-bg">{{ item.badge }}</div>
                <div v-if="item.soldOut" class="merch-card-soldout">Sold Out</div>
              </div>
              <div class="merch-card-body">
                <div class="merch-card-name">{{ item.name }}</div>
                <div class="merch-card-desc">{{ item.description }}</div>
                <div class="merch-card-footer">
                  <div class="merch-card-price photo-color">{{ item.price }}</div>
                  <button v-if="!item.soldOut" class="merch-card-btn photo-bg" @click="inquire(item.name)">Inquire</button>
                  <button v-else class="merch-card-btn merch-card-btn--disabled" disabled>Sold Out</button>
                </div>
              </div>
            </div>
          </div>
        </q-tab-panel>

        <!-- OTHER STUFF -->
        <q-tab-panel name="other" class="q-pa-none">
          <div class="panel-intro row items-center q-mb-xl q-gutter-md">
            <svg width="48" height="48" viewBox="0 0 100 100" class="panel-icon flex-shrink-0">
              <polygon points="50,8 61,35 90,35 68,57 76,84 50,68 24,84 32,57 10,35 39,35"
                fill="none" stroke="#e65100" stroke-width="2.5"/>
              <polygon points="50,22 57,40 76,40 62,52 67,70 50,60 33,70 38,52 24,40 43,40"
                fill="#e65100" opacity="0.15"/>
            </svg>
            <div>
              <div class="text-h5 text-bold other-color">Other Stuff</div>
              <div class="text-caption text-grey-6">Trail finds, festival collectibles, and curated goods from the road</div>
            </div>
          </div>
          <div class="merch-grid">
            <div v-for="item in otherItems" :key="item.id" class="merch-card">
              <div class="merch-card-img-wrap">
                <img :src="item.image" :alt="item.name" class="merch-card-img" />
                <div v-if="item.badge"   class="merch-card-badge other-bg">{{ item.badge }}</div>
                <div v-if="item.soldOut" class="merch-card-soldout">Sold Out</div>
              </div>
              <div class="merch-card-body">
                <div class="merch-card-name">{{ item.name }}</div>
                <div class="merch-card-desc">{{ item.description }}</div>
                <div class="merch-card-footer">
                  <div class="merch-card-price other-color">{{ item.price }}</div>
                  <button v-if="!item.soldOut" class="merch-card-btn other-bg" @click="inquire(item.name)">Inquire</button>
                  <button v-else class="merch-card-btn merch-card-btn--disabled" disabled>Sold Out</button>
                </div>
              </div>
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

    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useQuasar } from 'quasar'
import PageBackground from 'src/components/PageBackground.vue'

const $q  = useQuasar()
const tab = ref('art')

interface MerchItem {
  id: string
  name: string
  description: string
  price: string
  image: string
  badge?: string
  soldOut?: boolean
}

function inquire(name: string) {
  $q.notify({ message: `"${name}" — contact us to purchase!`, color: 'dark', icon: 'shopping_cart', position: 'top' })
}

const artItems: MerchItem[] = [
  { id: 'art-1', name: 'Mountain Mandala — Original',
    description: 'Ink and watercolour on 140lb cold-press. 9"×9". Signed, unframed.',
    price: '$180', image: 'https://picsum.photos/seed/art1/400/400', badge: 'Original' },
  { id: 'art-2', name: 'Stage Glow — Print',
    description: 'Giclee print of oil pastel stage-light study. 8"×10". Archival paper.',
    price: '$45', image: 'https://picsum.photos/seed/art2/400/400' },
  { id: 'art-3', name: 'Desert Road Triptych',
    description: 'Set of three 5"×7" prints depicting the Southwest drive. Signed edition of 50.',
    price: '$75 / set', image: 'https://picsum.photos/seed/art3/400/400', badge: 'Limited' },
  { id: 'art-4', name: 'Festival Camp — Acrylic',
    description: 'Small acrylic on wood panel. 6"×6". One of a kind.',
    price: '$120', image: 'https://picsum.photos/seed/art4/400/400', soldOut: true },
  { id: 'art-5', name: 'Frog in the Rain — Sticker Sheet',
    description: '8 hand-drawn stickers on premium vinyl. Waterproof.',
    price: '$12', image: 'https://picsum.photos/seed/art5/400/400' },
  { id: 'art-6', name: 'Tour Journal Zine Vol. 1',
    description: 'Hand-stapled 28-page zine with sketches, maps, and notes from the road.',
    price: '$15', image: 'https://picsum.photos/seed/art6/400/400', badge: 'New' },
]

const photoItems: MerchItem[] = [
  { id: 'photo-1', name: 'Billy Strings — Stage Right',
    description: '12"×16" fine art print, fuji crystal archive paper, ready to frame.',
    price: '$65', image: 'https://picsum.photos/seed/photo1/400/400', badge: 'Fan Fave' },
  { id: 'photo-2', name: 'Sunrise Over the Field',
    description: 'Early morning campground mist. 11"×14" lustre print.',
    price: '$55', image: 'https://picsum.photos/seed/photo2/400/400' },
  { id: 'photo-3', name: 'Crowd Hands — Panoramic',
    description: 'Wide-angle crowd shot during a full-field singalong. 20"×8".',
    price: '$80', image: 'https://picsum.photos/seed/photo3/400/400', badge: 'Limited' },
  { id: 'photo-4', name: 'Trail Light — Framed',
    description: 'Pacific Northwest trail shot. 8"×10" in natural walnut frame.',
    price: '$130', image: 'https://picsum.photos/seed/photo4/400/400' },
  { id: 'photo-5', name: 'Night Stage — 4×6 Set',
    description: 'Pack of 10 concert postcards. Great for mailing or framing.',
    price: '$20', image: 'https://picsum.photos/seed/photo5/400/400' },
  { id: 'photo-6', name: 'Mountain Camp Portrait',
    description: 'Medium format scan, 16"×20" metallic print. Gallery-ready.',
    price: '$150', image: 'https://picsum.photos/seed/photo6/400/400', soldOut: true },
]

const otherItems: MerchItem[] = [
  { id: 'other-1', name: 'Enamel Festival Pin Set',
    description: '4-pin set with frog, mandala, mountain, and music note designs.',
    price: '$28', image: 'https://picsum.photos/seed/other1/400/400', badge: 'Bestseller' },
  { id: 'other-2', name: 'Hand-dyed Bandana',
    description: 'Tie-dye cotton bandana in festival-purple and gold. One per dye.',
    price: '$22', image: 'https://picsum.photos/seed/other2/400/400' },
  { id: 'other-3', name: 'Trail Stone — Collected',
    description: 'Single smooth river stone collected on the PCT stretch. Tiny card included.',
    price: '$8', image: 'https://picsum.photos/seed/other3/400/400' },
  { id: 'other-4', name: "Nikki's Great Festivals Tote",
    description: 'Heavy cotton tote with screen-printed frog logo. 15"×17". Natural.',
    price: '$30', image: 'https://picsum.photos/seed/other4/400/400', badge: 'New' },
  { id: 'other-5', name: 'Road Playlist Vol. 3 — Cassette',
    description: 'Curated driving playlist on actual cassette. Limited run of 40.',
    price: '$18', image: 'https://picsum.photos/seed/other5/400/400', badge: 'Limited' },
  { id: 'other-6', name: 'Festival Seed Packet Bundle',
    description: 'Wildflower seed mixes gathered at Great Plains sites. 5 varieties.',
    price: '$14', image: 'https://picsum.photos/seed/other6/400/400' },
]
</script>

<style lang="scss" scoped>
.merch-page   { min-height: 100vh; background: #faf8f2; }
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

.panel-intro { border-left: 3px solid rgba(0,0,0,0.12); padding-left: 16px; }

/* Accent colours */
.art-color   { color: #7b1fa2; }
.photo-color { color: #ff8f00; }
.other-color { color: #e65100; }
.art-bg      { background: #7b1fa2; }
.photo-bg    { background: #ff8f00; }
.other-bg    { background: #e65100; }

/* Product grid */
.merch-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 24px;
  padding-bottom: 32px;
}

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
.merch-card-name { font-weight: 700; font-size: 15px; color: #1a1a1a; margin-bottom: 6px; }
.merch-card-desc { font-size: 12px; color: #666; line-height: 1.5; flex: 1; }
.merch-card-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 12px; }
.merch-card-price { font-weight: 800; font-size: 17px; }
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

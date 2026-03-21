<template>
  <q-page class="photo-page relative overflow-hidden">
    <PageBackground variant="photography" />

    <div class="page-content q-pa-lg">
      <div class="text-center q-py-xl">
        <div class="section-label q-mb-xs">Through the Lens</div>
        <div class="text-h3 text-bold q-mb-sm">Photography</div>
        <div class="text-body1 text-grey-7">Outdoor adventures, live music, and the beauty of everyday moments</div>
      </div>

      <div v-if="loading" class="flex flex-center q-py-xl">
        <q-spinner-orbit color="amber" size="48px" />
      </div>

      <template v-else>
        <section
          v-for="sec in sections"
          :key="sec.slug"
          class="photo-section q-mb-xl"
        >
          <div class="section-header q-mb-lg">
            <q-icon :name="sec.icon" size="32px" :color="sec.color" class="section-icon" />
            <div>
              <div class="text-h5 text-bold" :class="`text-${sec.color}`">{{ sec.label }}</div>
              <div class="text-caption text-grey-6">{{ sec.description }}</div>
            </div>
          </div>

          <div v-if="byCategory(sec.slug).length === 0" class="text-grey-5 q-py-lg">
            No photos yet — check back soon.
          </div>
          <div v-else class="photo-grid">
            <div
              v-for="(photo, i) in byCategory(sec.slug)"
              :key="photo.id"
              class="photo-thumb"
              @click="openSlideshow(sec.slug, i)"
            >
              <q-img :src="photo.url" :ratio="1" class="thumb-img">
                <div class="thumb-overlay">
                  <q-icon name="zoom_in" size="28px" color="white" />
                  <div v-if="photo.caption" class="thumb-caption">{{ photo.caption }}</div>
                </div>
              </q-img>
            </div>
          </div>
        </section>
      </template>
    </div>

    <!-- Slideshow -->
    <PhotoSlideshow
      v-if="slideshow.open"
      :photos="slideshow.photos"
      :start-index="slideshow.index"
      @close="slideshow.open = false"
    />
  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import PageBackground from 'src/components/PageBackground.vue'
import PhotoSlideshow from 'src/components/PhotoSlideshow.vue'
import { supabase } from 'src/lib/supabase'
import type { GalleryPhoto, GallerySection } from 'src/lib/supabase'

const loading = ref(true)
const photos  = ref<GalleryPhoto[]>([])

const sections = ref<GallerySection[]>([
  { slug: 'outdoor',  label: 'Outdoor Adventures', description: 'Trails, peaks, and wild places',                icon: 'forest',     color: 'green-8' },
  { slug: 'concert',  label: 'Music Concerts',     description: 'Live moments from the festival field',           icon: 'music_note', color: 'amber-8' },
  { slug: 'cuteness', label: 'Daily Cuteness',     description: 'The little things that make the road worth it', icon: 'favorite',   color: 'pink-8'  },
])

const slideshow = reactive({
  open:   false,
  photos: [] as GalleryPhoto[],
  index:  0,
})

onMounted(async () => {
  const [photosRes, sectionsRes] = await Promise.all([
    supabase.from('gallery_photos').select('*').eq('published', true).order('display_order'),
    supabase.from('site_settings').select('key,value').eq('key', 'gallery_sections').limit(1),
  ])
  photos.value   = (photosRes.data as GalleryPhoto[]) ?? []
  if (sectionsRes.data?.[0]?.value) sections.value = sectionsRes.data[0].value as GallerySection[]
  loading.value = false
})

function byCategory(slug: string) {
  return photos.value.filter(p => p.category === slug)
}

function openSlideshow(slug: string, index: number) {
  slideshow.photos = byCategory(slug)
  slideshow.index  = index
  slideshow.open   = true
}
</script>

<style lang="scss" scoped>
.photo-page   { min-height: 100vh; background: #fafaf5; }
.page-content { position: relative; z-index: 1; }

.section-label {
  font-size: 11px; font-weight: 700; letter-spacing: 3px;
  text-transform: uppercase; color: #e65100;
}

.section-header {
  display: flex; align-items: center; gap: 16px;
}
.section-icon { flex-shrink: 0; }

.photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 12px;
}

.photo-thumb {
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  position: relative;

  .thumb-img {
    border-radius: 8px;
    transition: transform 0.3s ease;
  }
  &:hover .thumb-img { transform: scale(1.03); }

  .thumb-overlay {
    position: absolute; inset: 0;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    opacity: 0; transition: opacity 0.25s;
    border-radius: 8px;
    gap: 6px;
  }
  &:hover .thumb-overlay {
    opacity: 1;
    background: rgba(0,0,0,0.35);
  }

  .thumb-caption {
    color: white; font-size: 11px; font-weight: 600;
    text-align: center; padding: 0 8px;
    text-shadow: 0 1px 3px rgba(0,0,0,0.8);
    max-width: 90%;
  }
}
</style>

<style lang="scss">
body.body--dark {
  .photo-page { background: #080a04 !important; }

  .photo-page .section-label { color: #ff8a65 !important; }
  .photo-page .text-h3, .photo-page .text-body1 { color: rgba(255,255,255,0.9) !important; }
  .photo-page .text-grey-6, .photo-page .text-grey-7 { color: rgba(255,255,255,0.5) !important; }

  /* Section headers */
  .photo-page .text-h5 { color: rgba(255,255,255,0.85) !important; }
  .photo-page .text-caption { color: rgba(255,255,255,0.45) !important; }
}
</style>

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
        <!-- SECTION: Outdoor Adventures -->
        <section class="photo-section q-mb-xl">
          <div class="section-header q-mb-lg">
            <svg width="32" height="32" viewBox="0 0 100 100" class="section-icon">
              <polygon points="50,10 90,85 10,85" fill="none" stroke="#43a047" stroke-width="4" />
              <line x1="50" y1="30" x2="50" y2="65" stroke="#43a047" stroke-width="2"/>
            </svg>
            <div>
              <div class="text-h5 text-bold text-green-8">Documenting Outdoor Adventures</div>
              <div class="text-caption text-grey-6">Trails, peaks, and wild places</div>
            </div>
          </div>
          <div class="photo-grid">
            <div
              v-for="(photo, i) in byCategory('outdoor')"
              :key="photo.id"
              class="photo-thumb"
              @click="openSlideshow('outdoor', i)"
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

        <!-- SECTION: Music Concerts -->
        <section class="photo-section q-mb-xl">
          <div class="section-header q-mb-lg">
            <svg width="32" height="32" viewBox="0 0 100 100" class="section-icon">
              <circle cx="50" cy="50" r="40" fill="none" stroke="#ffb300" stroke-width="3" stroke-dasharray="8 4"/>
              <path d="M35 65 Q50 25 65 65" fill="none" stroke="#ffb300" stroke-width="3"/>
              <line x1="40" y1="65" x2="60" y2="65" stroke="#ffb300" stroke-width="2"/>
            </svg>
            <div>
              <div class="text-h5 text-bold text-amber-8">Music Concerts</div>
              <div class="text-caption text-grey-6">Live moments from the festival field</div>
            </div>
          </div>
          <div class="photo-grid">
            <div
              v-for="(photo, i) in byCategory('concert')"
              :key="photo.id"
              class="photo-thumb"
              @click="openSlideshow('concert', i)"
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

        <!-- SECTION: Daily Cuteness -->
        <section class="photo-section q-mb-xl">
          <div class="section-header q-mb-lg">
            <svg width="32" height="32" viewBox="0 0 100 100" class="section-icon">
              <circle cx="50" cy="50" r="30" fill="none" stroke="#e91e63" stroke-width="3"/>
              <circle cx="38" cy="44" r="5" fill="#e91e63"/>
              <circle cx="62" cy="44" r="5" fill="#e91e63"/>
              <path d="M38 62 Q50 72 62 62" fill="none" stroke="#e91e63" stroke-width="2.5" stroke-linecap="round"/>
            </svg>
            <div>
              <div class="text-h5 text-bold text-pink-8">Daily Cuteness</div>
              <div class="text-caption text-grey-6">The little things that make the road worth it</div>
            </div>
          </div>
          <div class="photo-grid">
            <div
              v-for="(photo, i) in byCategory('cuteness')"
              :key="photo.id"
              class="photo-thumb"
              @click="openSlideshow('cuteness', i)"
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
import type { GalleryPhoto } from 'src/lib/supabase'

const loading = ref(true)
const photos  = ref<GalleryPhoto[]>([])

const slideshow = reactive({
  open:   false,
  photos: [] as GalleryPhoto[],
  index:  0,
})

onMounted(async () => {
  const { data } = await supabase
    .from('gallery_photos')
    .select('*')
    .order('display_order')
  photos.value = (data as GalleryPhoto[]) ?? []
  loading.value = false
})

function byCategory(cat: GalleryPhoto['category']) {
  return photos.value.filter(p => p.category === cat)
}

function openSlideshow(cat: GalleryPhoto['category'], index: number) {
  slideshow.photos = byCategory(cat)
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
.section-icon {
  flex-shrink: 0;
  filter: drop-shadow(0 0 6px rgba(0,0,0,0.15));
}

/* Responsive masonry-style grid */
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
    background: rgba(0,0,0,0);
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    transition: background 0.25s;
    opacity: 0;
    transition: opacity 0.25s;
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

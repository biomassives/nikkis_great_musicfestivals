<template>
  <q-page class="custom-page">

    <div v-if="loading" class="flex flex-center q-py-xl">
      <q-spinner-orbit color="purple-5" size="48px" />
    </div>

    <div v-else-if="!page" class="flex flex-center column q-py-xl text-center">
      <q-icon name="search_off" size="72px" color="grey-7" class="q-mb-md" />
      <div class="text-h5 text-grey-5">Page not found</div>
      <div class="text-caption text-grey-6 q-mt-sm">{{ slug }}</div>
      <q-btn flat color="purple-4" label="Go home" to="/" class="q-mt-lg" />
    </div>

    <template v-else>
      <div class="page-content">
        <div v-for="block in page.blocks" :key="block.id" class="block-render">

          <!-- HEADING -->
          <template v-if="block.type === 'heading'">
            <h1 v-if="block.level === 1" class="block-h1">{{ block.text }}</h1>
            <h2 v-else-if="block.level === 2" class="block-h2">{{ block.text }}</h2>
            <h3 v-else class="block-h3">{{ block.text }}</h3>
          </template>

          <!-- TEXT — rendered as rich HTML from WYSIWYG editor -->
          <!-- Content is admin-authored only, not user-submitted -->
          <div v-else-if="block.type === 'text'"
            class="block-text"
            v-html="block.content" />

          <!-- IMAGE -->
          <div v-else-if="block.type === 'image' && block.url"
            :class="`block-image block-image--${block.width || 'full'}`">
            <a v-if="block.link" :href="block.link" target="_blank" rel="noopener noreferrer">
              <img :src="block.url" :alt="block.caption || ''" />
            </a>
            <img v-else :src="block.url" :alt="block.caption || ''" />
            <p v-if="block.caption" class="block-caption">{{ block.caption }}</p>
          </div>

          <!-- VIDEO -->
          <div v-else-if="block.type === 'video' && block.url" class="block-video-wrap">
            <video v-if="isDirectVideo(block.url)" controls class="block-video-direct">
              <source :src="block.url" />
              Your browser does not support HTML5 video.
            </video>
            <div v-else class="aspect-16x9">
              <iframe :src="toEmbedUrl(block.url)"
                allowfullscreen frameborder="0"
                allow="autoplay; encrypted-media; picture-in-picture" />
            </div>
            <p v-if="block.caption" class="block-caption">{{ block.caption }}</p>
          </div>

          <!-- IFRAME / EMBED -->
          <div v-else-if="block.type === 'iframe' && block.url" class="block-iframe-wrap">
            <p v-if="block.iframe_title" class="block-iframe-title">{{ block.iframe_title }}</p>
            <iframe
              :src="block.url"
              :style="`width:100%; height:${block.height || 500}px; border:none; border-radius:8px;`"
              allowfullscreen
              sandbox="allow-scripts allow-same-origin allow-forms allow-popups"
            />
          </div>

          <!-- MEDIA LINK -->
          <a v-else-if="block.type === 'media_link' && block.url"
            :href="block.url" target="_blank" rel="noopener noreferrer"
            class="block-media-link">
            <img v-if="block.thumbnail" :src="block.thumbnail"
              class="media-link-thumb" alt="" />
            <div class="media-link-text">
              <div v-if="block.site_name" class="media-link-site">{{ block.site_name }}</div>
              <div class="media-link-title">{{ block.title }}</div>
              <div v-if="block.description" class="media-link-desc">{{ block.description }}</div>
            </div>
            <q-icon name="open_in_new" size="18px" class="media-link-arrow" />
          </a>

          <!-- DIVIDER -->
          <hr v-else-if="block.type === 'divider'" class="block-divider" />

        </div>
      </div>
    </template>

  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from 'src/lib/supabase'

type BlockType = 'heading' | 'text' | 'image' | 'video' | 'iframe' | 'media_link' | 'divider'

interface Block {
  id:            string
  type:          BlockType
  level?:        1 | 2 | 3
  text?:         string
  content?:      string
  url?:          string
  caption?:      string
  width?:        'full' | 'wide' | 'medium'
  link?:         string
  iframe_title?: string
  height?:       number
  title?:        string
  description?:  string
  thumbnail?:    string
  site_name?:    string
}

interface Page {
  id:        string
  slug:      string
  title:     string
  blocks:    Block[]
  published: boolean
}

const route   = useRoute()
const loading = ref(true)
const page    = ref<Page | null>(null)
const slug    = ref('')

function isDirectVideo(url: string | undefined): boolean {
  return /\.(mp4|webm|ogg|mov)(\?.*)?$/i.test(url ?? '')
}

function toEmbedUrl(url: string | undefined): string {
  if (!url) return ''
  // YouTube
  const yt = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([A-Za-z0-9_-]{11})/)
  if (yt) return `https://www.youtube.com/embed/${yt[1]}`
  // Vimeo
  const vi = url.match(/vimeo\.com\/(\d+)/)
  if (vi) return `https://player.vimeo.com/video/${vi[1]}`
  // Internet Archive details page → embed
  const ia = url.match(/archive\.org\/details\/([^/?#]+)/)
  if (ia) return `https://archive.org/embed/${ia[1]}`
  // Return as-is (already an embed URL)
  return url
}

async function loadPage(s: string) {
  loading.value = true
  page.value = null
  const { data } = await supabase
    .from('custom_pages')
    .select('*')
    .eq('slug', s)
    .eq('published', true)
    .maybeSingle()
  page.value = data as Page | null
  loading.value = false
}

onMounted(() => {
  slug.value = String(route.params['customSlug'] ?? '')
  void loadPage(slug.value)
})

watch(() => route.params['customSlug'], (s) => {
  slug.value = String(s ?? '')
  void loadPage(slug.value)
})
</script>

<style lang="scss" scoped>
.custom-page { min-height: 100vh; }

.page-content {
  max-width: 860px;
  margin: 0 auto;
  padding: 48px 24px 96px;
}

.block-render { margin-bottom: 32px; }

/* Headings */
.block-h1 { font-size: clamp(28px, 5vw, 48px); font-weight: 900; line-height: 1.1; margin: 0 0 8px; }
.block-h2 { font-size: clamp(22px, 3.5vw, 34px); font-weight: 700; line-height: 1.2; margin: 0 0 6px; }
.block-h3 { font-size: clamp(17px, 2.5vw, 24px); font-weight: 600; line-height: 1.3; margin: 0 0 4px; }

/* Rich text (WYSIWYG output) */
.block-text {
  font-size: 16px; line-height: 1.75;
  color: rgba(255,255,255,0.82);

  :deep(p)          { margin: 0 0 1em; }
  :deep(h2)         { font-size: 1.6em; font-weight: 700; margin: 1.2em 0 0.4em; }
  :deep(h3)         { font-size: 1.3em; font-weight: 600; margin: 1em 0 0.3em; }
  :deep(h4)         { font-size: 1.1em; font-weight: 600; margin: 0.8em 0 0.2em; }
  :deep(ul), :deep(ol) { padding-left: 1.5em; margin: 0 0 1em; }
  :deep(li)         { margin-bottom: 0.3em; }
  :deep(blockquote) {
    border-left: 3px solid #7c4dff;
    margin: 0 0 1em; padding: 8px 16px;
    background: rgba(124,77,255,0.06);
    color: rgba(255,255,255,0.65); font-style: italic;
  }
  :deep(a)          { color: #b39ddb; text-decoration: underline; }
  :deep(code)       { background: rgba(255,255,255,0.08); padding: 1px 5px; border-radius: 3px; font-size: 0.9em; }
  :deep(hr)         { border: none; border-top: 1px solid rgba(255,255,255,0.12); margin: 1.5em 0; }
  :deep(strong)     { color: #fff; }
}

/* Image */
.block-image img {
  width: 100%; height: auto; display: block;
  border-radius: 10px; object-fit: cover;
}
.block-image--full  { width: 100%; }
.block-image--wide  { max-width: 100%; }
.block-image--medium { max-width: 560px; margin: 0 auto; }

/* Caption */
.block-caption {
  font-size: 12px; color: rgba(255,255,255,0.45);
  margin: 8px 0 0; text-align: center; font-style: italic;
}

/* Video */
.block-video-wrap { width: 100%; }
.aspect-16x9 {
  position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden;
  border-radius: 10px;
  iframe {
    position: absolute; top: 0; left: 0; width: 100%; height: 100%;
    border-radius: 10px;
  }
}
.block-video-direct {
  width: 100%; border-radius: 10px; display: block;
}

/* iFrame embed */
.block-iframe-wrap { width: 100%; }
.block-iframe-title {
  font-size: 13px; font-weight: 600; letter-spacing: 1px;
  color: rgba(255,255,255,0.55); margin: 0 0 10px;
  text-transform: uppercase;
}

/* Media link card */
.block-media-link {
  display: flex; align-items: center; gap: 16px;
  padding: 16px 20px;
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(179,157,219,0.25);
  border-radius: 12px;
  text-decoration: none; color: inherit;
  transition: background 0.18s, border-color 0.18s;
  &:hover {
    background: rgba(179,157,219,0.1);
    border-color: rgba(179,157,219,0.5);
  }
}
.media-link-thumb {
  width: 72px; height: 72px; object-fit: cover;
  border-radius: 8px; flex-shrink: 0;
}
.media-link-text { flex: 1; min-width: 0; }
.media-link-site {
  font-size: 10px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; color: #b39ddb; margin-bottom: 4px;
}
.media-link-title {
  font-size: 15px; font-weight: 700; color: #fff;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.media-link-desc {
  font-size: 12px; color: rgba(255,255,255,0.5); margin-top: 2px;
}
.media-link-arrow { color: rgba(255,255,255,0.3); flex-shrink: 0; }

/* Divider */
.block-divider {
  border: none; border-top: 1px solid rgba(255,255,255,0.12);
  margin: 8px 0;
}
</style>

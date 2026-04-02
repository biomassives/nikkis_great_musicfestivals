<template>
  <q-page class="welcome-page">

    <div class="welcome-wrap">

      <!-- ── Cuteness welcome ────────────────────────────────────────── -->
      <template v-if="list === 'cuteness'">

        <div class="paw-stamp">🐾</div>

        <h1 class="welcome-heading">You're on the list.</h1>
        <p class="welcome-sub">
          One sweet photo from the road, every morning.<br>
          Your first delivery arrives tomorrow.
        </p>

        <!-- Preview photo ------------------------------------------------ -->
        <div v-if="previewPhoto" class="preview-wrap">
          <div class="preview-label">A taste of what's coming</div>
          <img
            :src="previewPhoto.url"
            :alt="previewPhoto.caption ?? 'Daily cuteness preview'"
            class="preview-img"
          />
          <div v-if="previewPhoto.caption" class="preview-caption">
            {{ previewPhoto.caption }}
          </div>
        </div>

        <div class="welcome-details">
          <div class="detail-row">
            <q-icon name="schedule" size="18px" class="detail-icon" />
            Delivered every morning
          </div>
          <div class="detail-row">
            <q-icon name="photo_camera" size="18px" class="detail-icon" />
            One photo per email — no clutter
          </div>
          <div class="detail-row">
            <q-icon name="lock_open" size="18px" class="detail-icon" />
            Unsubscribe instantly, any time
          </div>
        </div>

        <div class="welcome-ctas">
          <q-btn
            unelevated color="pink-6" icon="camera" label="Browse the gallery"
            to="/photography"
          />
          <q-btn
            flat color="grey-7" label="Back to home"
            to="/"
          />
        </div>

      </template>

      <!-- ── Generic fallback (newsletter, support, etc.) ───────────── -->
      <template v-else>
        <div class="paw-stamp">🎉</div>
        <h1 class="welcome-heading">You're in!</h1>
        <p class="welcome-sub">Thanks for joining — we'll be in touch.</p>
        <div class="welcome-ctas">
          <q-btn unelevated color="primary" label="Back to home" to="/" />
        </div>
      </template>

    </div>

  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from 'src/lib/supabase'
import type { GalleryPhoto } from 'src/lib/supabase'

const route = useRoute()
const list  = route.params.list as string

const previewPhoto = ref<GalleryPhoto | null>(null)

onMounted(async () => {
  if (list === 'cuteness') {
    // Pick a random published cuteness photo as a preview
    const { data } = await supabase
      .from('gallery_photos')
      .select('*')
      .eq('category', 'cuteness')
      .eq('published', true)
      .order('display_order')
      .limit(10)
    const pool = (data as GalleryPhoto[]) ?? []
    if (pool.length) {
      previewPhoto.value = pool[Math.floor(Math.random() * pool.length)] ?? null
    }
  }
})
</script>

<style lang="scss" scoped>
.welcome-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(160deg, #fff0f6 0%, #fce4ec 60%, #f8bbd0 100%);
}

.welcome-wrap {
  max-width: 520px;
  width: 100%;
  margin: 0 auto;
  padding: 48px 24px 64px;
  text-align: center;
}

.paw-stamp {
  font-size: 64px;
  line-height: 1;
  margin-bottom: 24px;
  animation: stamp 0.4s cubic-bezier(0.36, 0.07, 0.19, 0.97);
}
@keyframes stamp {
  0%   { transform: scale(2.2); opacity: 0; }
  60%  { transform: scale(0.9); }
  100% { transform: scale(1);   opacity: 1; }
}

.welcome-heading {
  font-size: 2.4rem;
  font-weight: 900;
  color: #880e4f;
  margin: 0 0 12px;
  letter-spacing: -0.5px;
}

.welcome-sub {
  font-size: 1.1rem;
  color: #6d4c5e;
  line-height: 1.7;
  margin: 0 0 32px;
}

/* Preview photo */
.preview-wrap {
  margin-bottom: 32px;
}
.preview-label {
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  color: #ec407a;
  margin-bottom: 10px;
}
.preview-img {
  width: 100%;
  max-width: 380px;
  height: 260px;
  object-fit: cover;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(233, 30, 99, 0.18);
}
.preview-caption {
  margin-top: 8px;
  font-size: 12px;
  color: #ad6f86;
  font-style: italic;
}

/* Detail rows */
.welcome-details {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 36px;
  text-align: left;
  max-width: 300px;
  margin-left: auto;
  margin-right: auto;
}
.detail-row {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  color: #6d4c5e;
}
.detail-icon { color: #ec407a; flex-shrink: 0; }

/* CTAs */
.welcome-ctas {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}
</style>

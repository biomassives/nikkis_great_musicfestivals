<template>
  <Teleport to="body">
    <Transition name="welcome-fade">
      <div v-if="visible" class="welcome-overlay" @click="dismiss">

        <img
          class="welcome-bg"
          :src="cfg.image_url"
          alt=""
        />

        <!-- Bottom-up gradient so text is readable -->
        <div class="welcome-vignette" />

        <!-- Centered content — stop click-through -->
        <div class="welcome-body" @click.stop>
          <div class="welcome-eyebrow">{{ cfg.eyebrow }}</div>
          <div class="welcome-title" style="white-space: pre-line">{{ cfg.title }}</div>
          <div class="welcome-tagline">
            {{ cfg.tagline }}
          </div>

          <button
            class="welcome-enter-btn"
            :style="`border-color:${cfg.button_color}; color:${cfg.button_color}`"
            @click="dismiss"
          >
            {{ cfg.button_label }}
            <span class="welcome-arrow">→</span>
          </button>

          <div class="welcome-hint">or click anywhere to continue</div>
        </div>

      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'

const emit = defineEmits<{ dismissed: [] }>()

const SESSION_KEY = 'ngmf_welcomed_v1'
const visible = ref(false)   // stays hidden until config is loaded

const cfg = reactive({
  image_url:    'https://picsum.photos/seed/bluegrass-evening/1920/1080',
  eyebrow:      'Welcome to',
  title:        "Nikki's Great\nMusic Festivals",
  tagline:      '"Helping to improve lives by improving access to great music, community, and the outdoors."',
  button_label: 'Enter the Festival',
  button_color: '#ffffff',
})

onMounted(async () => {
  if (sessionStorage.getItem(SESSION_KEY)) return  // already seen this session — never show

  // Load saved config first, then reveal — prevents old default image flashing
  const { data } = await supabase
    .from('site_settings')
    .select('value')
    .eq('key', 'welcome_overlay')
    .single()
  if (data?.value) Object.assign(cfg, data.value as object)

  visible.value = true   // show only after the correct image URL is in place
})

function dismiss() {
  sessionStorage.setItem(SESSION_KEY, '1')
  visible.value = false
  emit('dismissed')
}
</script>

<style lang="scss" scoped>
.welcome-overlay {
  position: fixed;
  inset: 0;
  z-index: 9000;
  overflow: hidden;
  cursor: pointer;
}

.welcome-bg {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  transform: scale(1.04); /* slight over-scale to allow subtle zoom-in */
  animation: welcome-zoom 8s ease forwards;
}

@keyframes welcome-zoom {
  from { transform: scale(1.04); }
  to   { transform: scale(1.0); }
}

.welcome-vignette {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(to top,  rgba(0,0,0,0.82) 0%,  rgba(0,0,0,0.35) 45%, transparent 75%),
    linear-gradient(to bottom, rgba(0,0,0,0.5) 0%, transparent 30%);
}

.welcome-body {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  padding-bottom: clamp(48px, 8vh, 96px);
  text-align: center;
  cursor: default;
}

.welcome-eyebrow {
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 4px;
  text-transform: uppercase;
  color: rgba(255,215,0,0.85);
  margin-bottom: 12px;
}

.welcome-title {
  font-size: clamp(42px, 7vw, 88px);
  font-weight: 900;
  line-height: 1.08;
  color: #fff;
  text-shadow: 0 4px 32px rgba(0,0,0,0.6), 0 1px 0 rgba(0,0,0,0.4);
  margin-bottom: 20px;
  letter-spacing: -0.5px;
}

.welcome-tagline {
  font-size: clamp(14px, 1.5vw, 18px);
  font-weight: 300;
  color: rgba(255,255,255,0.75);
  line-height: 1.6;
  max-width: 580px;
  margin-bottom: 40px;
  font-style: italic;
}

.welcome-enter-btn {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  background: rgba(255,255,255,0.12);
  border: 2px solid currentColor;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  padding: 14px 36px;
  border-radius: 999px;
  cursor: pointer;
  backdrop-filter: blur(8px);
  transition: background 0.2s, transform 0.2s;
  margin-bottom: 16px;

  &:hover {
    background: rgba(255,255,255,0.22);
    transform: translateY(-2px);
  }
}

.welcome-arrow {
  font-size: 18px;
  transition: transform 0.2s;
  .welcome-enter-btn:hover & { transform: translateX(4px); }
}

.welcome-hint {
  font-size: 11px;
  color: rgba(255,255,255,0.35);
  letter-spacing: 1px;
}

/* ── Transition ─────────────────────────────────────────────────── */
.welcome-fade-enter-active { transition: opacity 0.6s ease; }
.welcome-fade-leave-active { transition: opacity 0.5s ease; }
.welcome-fade-enter-from,
.welcome-fade-leave-to     { opacity: 0; }
</style>

<template>
  <Teleport to="body">
    <Transition name="story-rise">
      <div v-if="modelValue" class="story-overlay">

        <!-- Close -->
        <button class="story-close" @click="close" aria-label="Close">
          <span>×</span>
        </button>

        <div class="story-layout">

          <!-- ── Image panel ──────────────────────────────────────── -->
          <div class="story-img-panel">
            <img
              class="story-img"
              :src="cfg.image_url"
              alt="A beautiful evening in nature"
            />
            <div class="story-img-overlay" />
            <div class="story-img-caption">{{ cfg.image_caption }}</div>
          </div>

          <!-- ── Text panel ───────────────────────────────────────── -->
          <div class="story-text-panel" ref="textPanel">

            <div class="story-eyebrow">{{ cfg.eyebrow }}</div>
            <h1 class="story-title" style="white-space: pre-line">{{ cfg.title }}</h1>
            <div class="story-divider" />

            <div class="story-body">

              <!-- Content is admin-authored only, not user-submitted -->
              <div class="story-body-content" v-html="cfg.content" />

              <p class="story-closing">
                {{ cfg.closing }}
              </p>

            </div>

            <div class="story-footer">
              <button class="story-close-btn" @click="close">
                Close
              </button>
            </div>

          </div>
        </div>

      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'

const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits<{ 'update:modelValue': [value: boolean] }>()

const textPanel = ref<HTMLElement | null>(null)

const DEFAULT_PARAGRAPHS: string[] = [
  'We first followed the circus in the summer of 1991, somewhere between Buckeye Lake and Deer Creek, when the corn was high and the highway smelled of rain and burning sage. By the time the boys kicked into the second set, ten thousand souls had abandoned their ordinary selves in the grass — trading the weight of the week for something the setlist could never quite contain. A door swinging open in the middle of a Tuesday in July.',
  "Nikki's Great Music Festivals grew out of that first lot. Not the parking lot exactly — that particular sacred, chaotic marketplace of grilled cheese and miracles — but the feeling it generated: that community is not a thing you join but a thing you build, stake by stake, set by set, across the geography of a country that reveals itself differently from the back of a tour bus than it does from an office window.",
  "The mission was never complicated. Get people to the music. Get the music to people who couldn't get to it on their own. Senior communities in rural Tennessee deserve to hear live bluegrass with the same urgency as a festival field in Colorado. The joy is not scarce. It only needs moving.",
  'We have now logged eleven summers, forty-two states, and more campground friendships than any spreadsheet could hold. The artists who have let us carry their work into living rooms and rec halls and outdoor stages cut into hillsides — Billy Strings reeling off a twenty-minute reprise at elevation, Leftover Salmon burning through \u201cEuphoria\u201d while lightning flickered on the western ridge, the Stringdusters playing an unannounced third set because nobody wanted to go home — these are the facts our calendar doesn\u2019t quite capture.',
  'Every trail we walk and every show we document feeds back into the same current. The photography is evidence. The maps are memory. The newsletter is the letter you write home when home has temporarily relocated to a meadow in the mountains.',
  'What the calendar does capture is this: we keep going. The road is the purpose. The faces at the front of the stage and the back of the lot are the same faces — wide open, ears out, looking for the note that unlocks whatever needed unlocking.',
]

const cfg = reactive({
  image_url:     'https://picsum.photos/seed/mountain-evening/900/1400',
  image_caption: 'On the road',
  eyebrow:       'Our Full Story',
  title:         'The Music\nNever Stopped',
  content:       DEFAULT_PARAGRAPHS.map(p => `<p>${p}</p>`).join(''),
  closing:       'Come with us.',
})

onMounted(async () => {
  const { data } = await supabase
    .from('site_settings')
    .select('value')
    .eq('key', 'story_overlay')
    .limit(1)
  const row = data?.[0]
  if (row?.value && typeof row.value === 'object') {
    const v = row.value as Record<string, unknown>
    if (typeof v.image_url     === 'string') cfg.image_url     = v.image_url
    if (typeof v.image_caption === 'string') cfg.image_caption = v.image_caption
    if (typeof v.eyebrow       === 'string') cfg.eyebrow       = v.eyebrow
    if (typeof v.title         === 'string') cfg.title         = v.title
    if (typeof v.closing  === 'string') cfg.closing  = v.closing
    if (typeof v.content  === 'string') {
      cfg.content = v.content
    } else if (Array.isArray(v.paragraphs) && (v.paragraphs as unknown[]).length > 0) {
      cfg.content = (v.paragraphs as string[]).map(p => `<p>${p}</p>`).join('')
    }
  }
})

function close() {
  emit('update:modelValue', false)
}

// Scroll text back to top each time the overlay opens
watch(() => props.modelValue, (open) => {
  if (open && textPanel.value) {
    textPanel.value.scrollTop = 0
  }
  // Lock body scroll while open
  document.body.style.overflow = open ? 'hidden' : ''
})

// Keyboard dismiss
function onKey(e: KeyboardEvent) { if (e.key === 'Escape') close() }
watch(() => props.modelValue, (open) => {
  if (open) window.addEventListener('keydown', onKey)
  else       window.removeEventListener('keydown', onKey)
}, { immediate: true })
</script>

<style lang="scss" scoped>
/* ── Shell ──────────────────────────────────────────────────────── */
.story-overlay {
  position: fixed;
  inset: 0;
  z-index: 8000;
  background: #0a0010;
  display: flex;
  overflow: hidden;
}

/* ── Close button ───────────────────────────────────────────────── */
.story-close {
  position: absolute;
  top: 18px;
  right: 20px;
  z-index: 10;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 1.5px solid rgba(255,255,255,0.35);
  background: rgba(0,0,0,0.45);
  color: rgba(255,255,255,0.8);
  font-size: 24px;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  backdrop-filter: blur(6px);
  transition: background 0.2s, border-color 0.2s, color 0.2s;

  &:hover {
    background: rgba(255,255,255,0.15);
    border-color: rgba(255,255,255,0.8);
    color: #fff;
  }
}

/* ── Split layout ───────────────────────────────────────────────── */
.story-layout {
  display: flex;
  width: 100%;
  height: 100%;
}

/* ── Image panel (left, 42%) ────────────────────────────────────── */
.story-img-panel {
  flex: 0 0 42%;
  position: relative;
  overflow: hidden;

  @media (max-width: 768px) { display: none; }
}

.story-img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
}

.story-img-overlay {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(to right,  transparent 60%, #0a0010 100%),
    linear-gradient(to bottom, rgba(0,0,0,0.3) 0%, transparent 40%, rgba(0,0,0,0.2) 100%);
}

.story-img-caption {
  position: absolute;
  bottom: 24px;
  left: 24px;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 3px;
  text-transform: uppercase;
  color: rgba(255,255,255,0.4);
}

/* ── Text panel (right, 58%) ────────────────────────────────────── */
.story-text-panel {
  flex: 1;
  overflow-y: auto;
  padding: clamp(48px, 6vw, 80px) clamp(28px, 5vw, 72px) 48px clamp(28px, 4vw, 64px);
  display: flex;
  flex-direction: column;

  scrollbar-width: thin;
  scrollbar-color: rgba(255,215,0,0.3) transparent;
  &::-webkit-scrollbar { width: 4px; }
  &::-webkit-scrollbar-thumb { background: rgba(255,215,0,0.3); border-radius: 2px; }
}

.story-eyebrow {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 4px;
  text-transform: uppercase;
  color: rgba(255,215,0,0.7);
  margin-bottom: 14px;
}

.story-title {
  font-size: clamp(36px, 4.5vw, 64px);
  font-weight: 900;
  line-height: 1.06;
  color: #fff;
  margin: 0 0 20px;
  letter-spacing: -0.5px;
}

.story-divider {
  width: 56px;
  height: 3px;
  background: linear-gradient(90deg, #ffd700, rgba(255,215,0,0.15));
  border-radius: 2px;
  margin-bottom: 32px;
}

/* ── Body copy ──────────────────────────────────────────────────── */
.story-body {
  flex: 1;

  .story-body-content {
    :deep(p)  {
      font-size: clamp(14px, 1.2vw, 17px);
      line-height: 1.8;
      color: rgba(255,255,255,0.72);
      margin: 0 0 1.1em;
      font-weight: 300;
    }
    :deep(h2) { font-size: clamp(18px, 2vw, 26px); font-weight: 700; color: #fff; margin: 1.4em 0 0.4em; }
    :deep(h3) { font-size: clamp(16px, 1.6vw, 22px); font-weight: 600; color: #fff; margin: 1.2em 0 0.3em; }
    :deep(strong)  { color: #fff; }
    :deep(em)      { color: rgba(255,215,0,0.85); }
    :deep(a)       { color: #80cbc4; text-decoration: underline; }
    :deep(ul), :deep(ol) {
      padding-left: 1.5em; margin: 0 0 1em;
      font-size: clamp(14px, 1.2vw, 17px); line-height: 1.8;
      color: rgba(255,255,255,0.72);
    }
    :deep(blockquote) {
      border-left: 3px solid rgba(255,215,0,0.5);
      padding-left: 16px; margin: 0 0 1em;
      color: rgba(255,255,255,0.6); font-style: italic;
    }
  }

  .story-closing {
    font-size: clamp(18px, 2vw, 26px);
    font-weight: 700;
    font-style: italic;
    color: rgba(255,215,0,0.85);
    margin-top: 8px;
  }
}

/* ── Footer ─────────────────────────────────────────────────────── */
.story-footer {
  padding-top: 32px;
  border-top: 1px solid rgba(255,255,255,0.08);
  margin-top: 8px;
}

.story-close-btn {
  background: transparent;
  border: 1.5px solid rgba(255,255,255,0.3);
  color: rgba(255,255,255,0.55);
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 2px;
  text-transform: uppercase;
  padding: 10px 28px;
  border-radius: 999px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;

  &:hover {
    border-color: rgba(255,255,255,0.7);
    color: #fff;
  }
}

/* ── Transition ─────────────────────────────────────────────────── */
.story-rise-enter-active { transition: opacity 0.35s ease, transform 0.35s ease; }
.story-rise-leave-active { transition: opacity 0.25s ease, transform 0.25s ease; }
.story-rise-enter-from,
.story-rise-leave-to     { opacity: 0; transform: translateY(24px); }
</style>

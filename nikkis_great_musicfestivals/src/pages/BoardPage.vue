<template>
  <q-page :class="['board-page', dark ? 'bp--dark' : 'bp--light']">

    <!-- ── HERO ────────────────────────────────────────────────────── -->
    <div class="bp-hero">
      <div class="bp-hero-inner">
        <div class="bp-eyebrow">Community Space</div>
        <h1 class="bp-title">The Board</h1>
        <p class="bp-sub">
          Share trail reports, show memories, tips, and good vibes with fellow festival friends.
          No account needed — just your voice.
        </p>
      </div>
      <!-- Mondrian accent strip -->
      <div class="bp-strip" aria-hidden="true">
        <div class="bp-strip-seg" style="background:#cc1010;flex:2" />
        <div class="bp-strip-seg" style="background:#000;flex:1" />
        <div class="bp-strip-seg" style="background:#ffd600;flex:3" />
        <div class="bp-strip-seg" style="background:#1040a8;flex:2" />
        <div class="bp-strip-seg" style="background:#000;flex:1" />
        <div class="bp-strip-seg" style="background:#cc1010;flex:1" />
      </div>
    </div>

    <!-- ── PRIVACY NOTICE ──────────────────────────────────────────── -->
    <div class="bp-privacy">
      <q-icon name="shield" size="15px" class="bp-privacy-icon" />
      <span>No accounts. No email collection. Posts are public and community-moderated.</span>
      <span class="bp-priv-sep">·</span>
      <span class="bp-priv-dim">Posts older than 90 days may be pruned to keep the board fresh.</span>
    </div>

    <!-- ── MAIN ────────────────────────────────────────────────────── -->
    <div class="bp-main">

      <!-- Category tabs -->
      <div class="bp-cats">
        <button
          v-for="cat in CATEGORIES" :key="cat.id"
          class="bp-cat" :class="{ 'bp-cat--active': activeCat === cat.id }"
          @click="activeCat = cat.id"
        >
          <q-icon :name="cat.icon" size="13px" />
          {{ cat.label }}
        </button>
      </div>

      <!-- Post form -->
      <div class="bp-form">
        <div class="bp-form-hed">Add to the board</div>
        <div class="bp-form-row">
          <input
            v-model="draft.name"
            class="bp-input"
            placeholder="Your name (optional, max 40 chars)"
            maxlength="40"
          />
          <select v-model="draft.category" class="bp-select">
            <option v-for="c in CATEGORIES.slice(1)" :key="c.id" :value="c.id">{{ c.label }}</option>
          </select>
        </div>
        <textarea
          v-model="draft.message"
          class="bp-textarea"
          :placeholder="`What's on your mind? · ${500 - draft.message.length} chars remaining`"
          maxlength="500"
          rows="3"
        />
        <div class="bp-form-foot">
          <span class="bp-form-priv">
            <q-icon name="lock" size="11px" />
            Stored with no user ID — truly anonymous.
          </span>
          <q-btn
            label="Post"
            color="primary" unelevated size="sm"
            :loading="posting"
            :disable="!draft.message.trim()"
            @click="submit"
          />
        </div>
        <Transition name="bp-msg">
          <div v-if="postError"   class="bp-notice bp-notice--err">{{ postError }}</div>
          <div v-else-if="postOk" class="bp-notice bp-notice--ok">Posted! Thanks for contributing.</div>
        </Transition>
      </div>

      <!-- Sort row -->
      <div class="bp-sort-row">
        <span class="bp-sort-label">Sort:</span>
        <button class="bp-sort-btn" :class="{ active: sort === 'score' }"  @click="sort = 'score'">Top</button>
        <button class="bp-sort-btn" :class="{ active: sort === 'recent' }" @click="sort = 'recent'">Recent</button>
        <span class="bp-count">{{ displayPosts.length }} post{{ displayPosts.length !== 1 ? 's' : '' }}</span>
      </div>

      <!-- Posts -->
      <div v-if="loading" class="bp-center">
        <q-spinner-orbit color="primary" size="40px" />
      </div>
      <div v-else-if="displayPosts.length === 0" class="bp-center bp-empty">
        Nothing here yet — be the first to post!
      </div>
      <div v-else class="bp-posts">
        <div v-for="post in displayPosts" :key="post.id" class="bp-post">

          <!-- Vote column -->
          <div class="bp-vote-col">
            <button
              class="bp-vote-btn"
              :class="{ 'bp-vote-btn--done': hasVoted(post.id) }"
              :title="hasVoted(post.id) ? 'Already vibed' : 'Send a vibe'"
              @click="vote(post)"
            >
              <q-icon
                :name="hasVoted(post.id) ? 'favorite' : 'favorite_border'"
                size="20px"
              />
            </button>
            <span class="bp-score">{{ post.score }}</span>
          </div>

          <!-- Content column -->
          <div class="bp-post-body">
            <div class="bp-post-meta">
              <span class="bp-post-author">{{ post.display_name || 'Community Member' }}</span>
              <span class="bp-post-cat-chip">{{ catLabel(post.category) }}</span>
              <span class="bp-post-time">{{ timeAgo(post.created_at) }}</span>
            </div>
            <p class="bp-post-msg">{{ post.message }}</p>
          </div>

        </div>
      </div>

    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { supabase } from 'src/lib/supabase'
import { sessionKey } from 'src/lib/instance'

const $q   = useQuasar()
const dark = computed(() => $q.dark.isActive)

// ── Categories ───────────────────────────────────────────────────────────────
const CATEGORIES = [
  { id: 'all',     label: 'All',           icon: 'grid_view'         },
  { id: 'general', label: 'General',       icon: 'chat_bubble_outline'},
  { id: 'shows',   label: 'Shows',         icon: 'music_note'        },
  { id: 'trails',  label: 'Trail Reports', icon: 'forest'            },
  { id: 'tips',    label: 'Local Tips',    icon: 'lightbulb_outline' },
]

function catLabel(id: string): string {
  return CATEGORIES.find(c => c.id === id)?.label ?? id
}

// ── Types ────────────────────────────────────────────────────────────────────
interface BoardPost {
  id:           string
  category:     string
  display_name: string
  message:      string
  score:        number
  created_at:   string
}

// ── State ────────────────────────────────────────────────────────────────────
const posts     = ref<BoardPost[]>([])
const loading   = ref(true)
const posting   = ref(false)
const postError = ref('')
const postOk    = ref(false)
const activeCat = ref('all')
const sort      = ref<'score' | 'recent'>('score')

const draft = ref({ name: '', category: 'general', message: '' })

// ── Computed ─────────────────────────────────────────────────────────────────
const displayPosts = computed<BoardPost[]>(() => {
  const list = activeCat.value === 'all'
    ? [...posts.value]
    : posts.value.filter(p => p.category === activeCat.value)
  if (sort.value === 'score') {
    return list.sort((a, b) =>
      b.score - a.score || new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    )
  }
  return list.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
})

// ── Voting ───────────────────────────────────────────────────────────────────
function voteKey(id: string): string { return sessionKey(`board_vote_${id}`) }
function hasVoted(id: string): boolean { return !!localStorage.getItem(voteKey(id)) }

async function vote(post: BoardPost) {
  if (hasVoted(post.id)) return
  const { error } = await supabase.rpc('upvote_board_post', { post_id: post.id })
  if (!error) {
    post.score++
    localStorage.setItem(voteKey(post.id), '1')
  }
}

// ── Posting ──────────────────────────────────────────────────────────────────
async function submit() {
  if (!draft.value.message.trim()) return
  postError.value = ''
  postOk.value = false
  posting.value = true

  const { data, error } = await supabase
    .from('board_posts')
    .insert({
      category:     draft.value.category,
      display_name: draft.value.name.trim() || 'Community Member',
      message:      draft.value.message.trim(),
    })
    .select()
    .single()

  posting.value = false

  if (error) {
    postError.value = 'Could not post — try again in a moment.'
    return
  }

  posts.value.unshift({ ...(data as BoardPost), score: 0 })
  draft.value.message = ''
  draft.value.name    = ''
  postOk.value = true
  setTimeout(() => { postOk.value = false }, 3500)
}

// ── Helpers ──────────────────────────────────────────────────────────────────
function timeAgo(ts: string): string {
  const m = Math.floor((Date.now() - new Date(ts).getTime()) / 60000)
  if (m < 1)   return 'just now'
  if (m < 60)  return `${m}m ago`
  const h = Math.floor(m / 60)
  if (h < 24)  return `${h}h ago`
  const d = Math.floor(h / 24)
  if (d < 30)  return `${d}d ago`
  return `${Math.floor(d / 30)}mo ago`
}

// ── Load ─────────────────────────────────────────────────────────────────────
async function load() {
  loading.value = true
  const { data } = await supabase
    .from('board_posts')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(200)
  posts.value = (data as BoardPost[]) ?? []
  loading.value = false
}

onMounted(() => { void load() })
</script>

<style lang="scss" scoped>
// ── Page shell ───────────────────────────────────────────────────────────────
.board-page { min-height: 100vh; }

// ── Hero ─────────────────────────────────────────────────────────────────────
.bp-hero {
  padding: 72px 24px 48px;
  text-align: center;
  position: relative;
}
.bp-hero-inner { max-width: 640px; margin: 0 auto; }
.bp-eyebrow {
  font-size: 10px; font-weight: 900; letter-spacing: 4px;
  text-transform: uppercase; color: #ffd600; margin-bottom: 12px;
}
.bp-title {
  font-size: clamp(2.2rem, 5vw, 3.4rem);
  font-weight: 900; letter-spacing: -1px; margin: 0 0 16px;
}
.bp-sub {
  font-size: 1.05rem; line-height: 1.65;
  opacity: 0.72; max-width: 500px; margin: 0 auto;
}

// Mondrian strip under hero
.bp-strip {
  display: flex; height: 6px;
  margin-top: 40px;
  border-top: 3px solid #000;
  border-bottom: 3px solid #000;
}
.bp-strip-seg { min-width: 0; }

// ── Privacy notice ────────────────────────────────────────────────────────────
.bp-privacy {
  display: flex; align-items: center; flex-wrap: wrap; gap: 6px;
  padding: 10px 24px;
  background: rgba(0, 200, 140, 0.08);
  border-top: 1px solid rgba(0, 200, 140, 0.22);
  border-bottom: 1px solid rgba(0, 200, 140, 0.22);
  font-size: 12px;
}
.bp-privacy-icon { color: #00c88c; flex-shrink: 0; }
.bp-priv-sep  { color: rgba(255,255,255,0.2); }
.bp-priv-dim  { opacity: 0.5; }

// ── Main content ─────────────────────────────────────────────────────────────
.bp-main { max-width: 800px; margin: 0 auto; padding: 32px 20px 80px; }

// ── Category tabs ─────────────────────────────────────────────────────────────
.bp-cats {
  display: flex; flex-wrap: wrap; gap: 8px;
  margin-bottom: 28px;
}
.bp-cat {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 6px 14px; border-radius: 20px;
  border: 1.5px solid rgba(255,255,255,0.14);
  background: transparent;
  font-size: 11px; font-weight: 700; letter-spacing: 0.5px;
  cursor: pointer; color: inherit;
  transition: border-color 0.2s, background 0.2s, color 0.2s;
  &--active, &:hover {
    border-color: #ffd600;
    background: rgba(255,214,0,0.1);
    color: #ffd600;
  }
}

// ── Post form ─────────────────────────────────────────────────────────────────
.bp-form {
  padding: 20px;
  border: 2px solid rgba(255,255,255,0.1);
  border-radius: 12px;
  margin-bottom: 32px;
  background: rgba(255,255,255,0.03);
}
.bp-form-hed {
  font-size: 11px; font-weight: 900; letter-spacing: 2px;
  text-transform: uppercase; color: #ffd600; margin-bottom: 14px;
}
.bp-form-row {
  display: flex; gap: 10px; margin-bottom: 10px;
  @media (max-width: 500px) { flex-direction: column; }
}
.bp-input, .bp-select, .bp-textarea {
  background: rgba(0,0,0,0.25);
  border: 1.5px solid rgba(255,255,255,0.14);
  border-radius: 8px;
  color: inherit;
  padding: 9px 12px;
  font-size: 13px;
  transition: border-color 0.2s;
  &:focus { outline: none; border-color: #7c4dff; }
}
.bp-input   { flex: 1; min-width: 0; }
.bp-select  {
  flex-shrink: 0; width: 150px; cursor: pointer;
  @media (max-width: 500px) { width: 100%; }
}
.bp-textarea {
  width: 100%; resize: vertical; min-height: 80px;
  font-family: inherit; line-height: 1.5;
}
.bp-form-foot {
  display: flex; align-items: center; justify-content: space-between;
  margin-top: 10px; gap: 12px; flex-wrap: wrap;
}
.bp-form-priv {
  font-size: 11px; opacity: 0.45;
  display: flex; align-items: center; gap: 4px;
}
.bp-notice {
  margin-top: 10px; padding: 9px 14px;
  border-radius: 8px; font-size: 13px;
}
.bp-notice--err { background: rgba(204,16,16,0.15); color: #ff6b6b; border: 1px solid rgba(204,16,16,0.3); }
.bp-notice--ok  { background: rgba(0,200,140,0.12); color: #00c88c; border: 1px solid rgba(0,200,140,0.25); }

// ── Sort row ──────────────────────────────────────────────────────────────────
.bp-sort-row {
  display: flex; align-items: center; gap: 8px;
  margin-bottom: 20px;
  font-size: 12px;
}
.bp-sort-label { opacity: 0.4; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; }
.bp-sort-btn {
  padding: 4px 12px; border-radius: 12px;
  border: 1.5px solid rgba(255,255,255,0.12);
  background: transparent; color: inherit; cursor: pointer;
  font-size: 11px; font-weight: 700; letter-spacing: 0.5px;
  transition: border-color 0.2s, background 0.2s;
  &.active, &:hover { border-color: #7c4dff; background: rgba(124,77,255,0.12); }
}
.bp-count { margin-left: auto; opacity: 0.35; font-size: 11px; }

// ── Loading / empty ───────────────────────────────────────────────────────────
.bp-center { display: flex; justify-content: center; padding: 60px 0; }
.bp-empty  { opacity: 0.45; font-size: 1rem; }

// ── Posts ─────────────────────────────────────────────────────────────────────
.bp-posts { display: flex; flex-direction: column; gap: 2px; }

.bp-post {
  display: flex; gap: 0;
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 10px;
  overflow: hidden;
  transition: border-color 0.2s, background 0.2s;
  &:hover { border-color: rgba(124,77,255,0.3); background: rgba(124,77,255,0.04); }
}

// Vote column
.bp-vote-col {
  display: flex; flex-direction: column; align-items: center;
  justify-content: center; gap: 2px;
  padding: 14px 16px;
  border-right: 1px solid rgba(255,255,255,0.06);
  min-width: 64px;
  flex-shrink: 0;
}
.bp-vote-btn {
  background: none; border: none; cursor: pointer;
  color: rgba(255,255,255,0.3);
  padding: 4px;
  border-radius: 50%;
  transition: color 0.2s, transform 0.15s;
  &:hover:not(.bp-vote-btn--done) {
    color: #ff6b9d;
    transform: scale(1.2);
  }
  &--done { color: #ff6b9d; cursor: default; }
}
.bp-score {
  font-size: 13px; font-weight: 900; letter-spacing: -0.5px;
  opacity: 0.7;
}

// Post body
.bp-post-body { flex: 1; padding: 14px 16px; min-width: 0; }
.bp-post-meta {
  display: flex; align-items: center; flex-wrap: wrap; gap: 6px;
  margin-bottom: 6px;
}
.bp-post-author {
  font-size: 12px; font-weight: 900; letter-spacing: 0.3px;
}
.bp-post-cat-chip {
  font-size: 9px; font-weight: 900; letter-spacing: 1.5px;
  text-transform: uppercase; padding: 2px 7px; border-radius: 10px;
  background: rgba(124,77,255,0.15); color: #ab8fff;
  border: 1px solid rgba(124,77,255,0.22);
}
.bp-post-time {
  font-size: 11px; opacity: 0.38; margin-left: auto;
}
.bp-post-msg {
  font-size: 0.93rem; line-height: 1.6; margin: 0;
  opacity: 0.85; word-break: break-word;
}

// ── Transitions ───────────────────────────────────────────────────────────────
.bp-msg-enter-active, .bp-msg-leave-active { transition: opacity 0.3s, transform 0.3s; }
.bp-msg-enter-from, .bp-msg-leave-to { opacity: 0; transform: translateY(-6px); }
</style>

<style lang="scss">
/* ── Unscoped theme overrides ─────────────────────────────────────────────── */
body.body--light {
  .bp-privacy {
    background: rgba(0, 160, 110, 0.07);
    border-color: rgba(0, 160, 110, 0.18);
  }
  .bp-priv-sep  { color: rgba(26,10,46,0.15); }
  .bp-priv-dim  { color: rgba(26,10,46,0.45); }

  .bp-form {
    background: rgba(0,0,0,0.03);
    border-color: rgba(0,0,0,0.1);
  }
  .bp-input, .bp-select, .bp-textarea {
    background: #fff;
    border-color: rgba(0,0,0,0.15);
    color: #1a0a2e;
  }
  .bp-post {
    border-color: rgba(0,0,0,0.07);
    &:hover { background: rgba(124,77,255,0.04); border-color: rgba(124,77,255,0.2); }
  }
  .bp-vote-col  { border-color: rgba(0,0,0,0.07); }
  .bp-vote-btn  { color: rgba(26,10,46,0.25); }
  .bp-post-author { color: #1a0a2e; }
  .bp-post-msg  { color: rgba(26,10,46,0.82); }
  .bp-title     { color: #1a0a2e; }
  .bp-sub       { color: rgba(26,10,46,0.7); }
  .bp-cat {
    border-color: rgba(0,0,0,0.12);
    color: rgba(26,10,46,0.7);
    &--active, &:hover {
      border-color: #b8860b;
      background: rgba(180,130,0,0.1);
      color: #9a6e00;
    }
  }
  .bp-sort-btn {
    border-color: rgba(0,0,0,0.12);
    color: rgba(26,10,46,0.7);
    &.active, &:hover { border-color: #7c4dff; background: rgba(124,77,255,0.08); color: #5c35b0; }
  }
}
</style>

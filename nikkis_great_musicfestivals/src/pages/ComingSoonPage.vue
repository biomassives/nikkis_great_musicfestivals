<template>
  <div class="cs-page">

    <!-- Subtle radial glow backdrop -->
    <div class="cs-glow" />

    <!-- Main content -->
    <div class="cs-content">
      <SpirographLogo :size="160" spin shadow class="cs-logo" />

      <div class="cs-eyebrow">COMING SOON</div>

      <h1 class="cs-title">
        Nikki's Great<br>Music Festivals
      </h1>

      <p class="cs-tagline">
        "Helping to improve lives by improving access to<br class="cs-br">
        great music, community, and the outdoors."
      </p>

      <div class="cs-season">
        <span class="cs-dot" />
        Summer 2026
        <span class="cs-dot" />
      </div>

      <button class="cs-cta" @click="openDialog">
        Be the first to know
        <span class="cs-arrow">→</span>
      </button>
    </div>

    <!-- Mailing list sign-up dialog -->
    <q-dialog v-model="dialogOpen" @hide="onDialogHide">
      <q-card class="cs-card" dark>

        <!-- Header -->
        <q-card-section>
          <div class="cs-card-title">Stay in the loop</div>
          <div class="cs-card-sub">
            We'll send you one note the moment we go live — no spam, unsubscribe anytime.
          </div>
        </q-card-section>

        <!-- Form -->
        <q-card-section v-if="formState !== 'done' && formState !== 'already'" class="q-pt-none">
          <!-- Honeypot — bots fill this, real users never see it -->
          <input
            v-model="honeypot"
            name="website"
            type="text"
            autocomplete="off"
            tabindex="-1"
            aria-hidden="true"
            class="cs-honeypot"
          />

          <q-input
            v-model="formName"
            label="Your name (optional)"
            outlined dense dark
            color="yellow-6"
            class="q-mb-sm"
            autocomplete="name"
            @keyup.enter="submit"
          />

          <q-input
            ref="emailRef"
            v-model="formEmail"
            type="email"
            label="your@email.com"
            outlined dense dark
            color="yellow-6"
            :error="formState === 'error'"
            :error-message="errorMsg"
            autocomplete="email"
            @keyup.enter="submit"
          />
        </q-card-section>

        <!-- Success state -->
        <q-card-section v-else-if="formState === 'done'" class="text-center q-pt-none q-pb-md">
          <q-icon name="mark_email_unread" color="yellow-6" size="44px" />
          <div class="cs-result-title">
            You're on the list{{ formName ? `, ${formName}` : '' }}!
          </div>
          <div class="cs-result-body">
            We'll send a launch note to <strong>{{ formEmail }}</strong>.
          </div>
        </q-card-section>

        <!-- Already subscribed -->
        <q-card-section v-else-if="formState === 'already'" class="text-center q-pt-none q-pb-md">
          <q-icon name="check_circle" color="yellow-6" size="44px" />
          <div class="cs-result-title">Already on the list!</div>
          <div class="cs-result-body">
            You're already subscribed — we'll see you at launch.
          </div>
        </q-card-section>

        <!-- Actions -->
        <q-card-actions align="right" class="q-px-md q-pb-md">
          <q-btn flat label="Close" color="grey-5" v-close-popup />
          <q-btn
            v-if="formState !== 'done' && formState !== 'already'"
            label="Notify me"
            unelevated
            color="yellow-7"
            text-color="black"
            :loading="formState === 'loading'"
            @click="submit"
          />
        </q-card-actions>

      </q-card>
    </q-dialog>

    <!-- Discreet admin access link -->
    <a href="/admin" class="cs-admin-link">admin</a>

  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import SpirographLogo from 'src/components/SpirographLogo.vue'

type FormState = 'idle' | 'loading' | 'done' | 'already' | 'error'

const dialogOpen = ref(false)
const formState  = ref<FormState>('idle')
const formEmail  = ref('')
const formName   = ref('')
const honeypot   = ref('')
const errorMsg   = ref('')
const emailRef   = ref<{ focus: () => void } | null>(null)

function openDialog() {
  // Clear error if they previously had one, but preserve success/already states
  if (formState.value === 'error') formState.value = 'idle'
  dialogOpen.value = true
}

function onDialogHide() {
  if (formState.value === 'error') formState.value = 'idle'
}

async function submit() {
  const trimmed = formEmail.value.trim().toLowerCase()
  if (!trimmed || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmed)) {
    formState.value = 'error'
    errorMsg.value  = 'Please enter a valid email address'
    emailRef.value?.focus()
    return
  }

  if (honeypot.value.trim()) {
    formState.value = 'done'
    return
  }

  formState.value = 'loading'

  try {
    const res = await fetch('/api/newsletter/subscribe', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email:   trimmed,
        name:    formName.value.trim() || undefined,
        website: honeypot.value,
        lists:   ['newsletter'],
        source:  'coming_soon',
      }),
    })

    if (res.status === 409) {
      formState.value = 'already'
      return
    }

    if (!res.ok) {
      const data = await res.json().catch(() => ({})) as { error?: string }
      formState.value = 'error'
      errorMsg.value  = data.error ?? 'Something went wrong — please try again.'
      return
    }

    const data = await res.json() as { ok: boolean; alreadySubscribed?: boolean }
    formState.value = data.alreadySubscribed ? 'already' : 'done'

  } catch {
    formState.value = 'error'
    errorMsg.value  = 'Connection error — please check your internet and try again.'
  }
}
</script>

<style scoped>
/* ── Full-screen canvas ───────────────────────────────────────────── */
.cs-page {
  min-height: 100vh;
  width: 100%;
  background: #0a0018;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

/* Soft dual-tone glow */
.cs-glow {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 60% 50% at 50% 65%, rgba(204,16,16,0.10) 0%, transparent 70%),
    radial-gradient(ellipse 80% 60% at 50% 35%, rgba(16,64,168,0.08) 0%, transparent 70%);
  pointer-events: none;
}

/* ── Centre column ────────────────────────────────────────────────── */
.cs-content {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 48px 24px;
  max-width: 600px;
  width: 100%;
}

.cs-logo { margin-bottom: 36px; }

.cs-eyebrow {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 5px;
  color: #ffd600;
  margin-bottom: 16px;
}

.cs-title {
  font-size: clamp(38px, 7vw, 76px);
  font-weight: 900;
  line-height: 1.07;
  color: #fff;
  margin: 0 0 20px;
  letter-spacing: -0.5px;
  text-shadow: 0 2px 28px rgba(0,0,0,0.6);
}

.cs-tagline {
  font-size: clamp(13px, 1.4vw, 16px);
  font-weight: 300;
  font-style: italic;
  color: rgba(255,255,255,0.55);
  line-height: 1.75;
  max-width: 460px;
  margin: 0 0 28px;
}

/* Only show the <br> on wider screens */
.cs-br { display: none; }
@media (min-width: 480px) { .cs-br { display: inline; } }

.cs-season {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 4px;
  text-transform: uppercase;
  color: rgba(255,214,0,0.5);
  margin-bottom: 44px;
}

.cs-dot {
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: rgba(255,214,0,0.5);
  display: inline-block;
}

/* ── CTA button ───────────────────────────────────────────────────── */
.cs-cta {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  background: rgba(255,255,255,0.06);
  border: 2px solid rgba(255,214,0,0.65);
  color: #ffd600;
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 2.5px;
  text-transform: uppercase;
  padding: 15px 38px;
  border-radius: 999px;
  cursor: pointer;
  backdrop-filter: blur(8px);
  transition: background 0.2s, transform 0.2s;
}

.cs-cta:hover {
  background: rgba(255,214,0,0.10);
  transform: translateY(-2px);
}

.cs-arrow {
  font-size: 18px;
  transition: transform 0.2s;
}
.cs-cta:hover .cs-arrow { transform: translateX(4px); }

/* ── Dialog card ──────────────────────────────────────────────────── */
.cs-card {
  min-width: 320px;
  max-width: 420px;
  width: 90vw;
  background: #160830;
  border: 1px solid rgba(255,214,0,0.15);
}

.cs-card-title {
  font-size: 1.2rem;
  font-weight: 800;
  color: #ffd600;
  margin-bottom: 6px;
}

.cs-card-sub {
  font-size: 0.83rem;
  color: rgba(255,255,255,0.5);
  line-height: 1.6;
}

/* Input label colour override */
.cs-card :deep(.q-field__label) {
  color: rgba(255,214,0,0.6) !important;
}

/* ── Result states ────────────────────────────────────────────────── */
.cs-result-title {
  font-size: 1.05rem;
  font-weight: 700;
  color: #fff;
  margin: 14px 0 6px;
}

.cs-result-body {
  font-size: 0.85rem;
  color: rgba(255,255,255,0.58);
  line-height: 1.65;
}

/* ── Honeypot ─────────────────────────────────────────────────────── */
.cs-honeypot {
  position: absolute;
  left: -9999px;
  top:  -9999px;
  width: 1px;
  height: 1px;
  overflow: hidden;
  opacity: 0;
  pointer-events: none;
}

/* ── Discreet admin link ──────────────────────────────────────────── */
.cs-admin-link {
  position: fixed;
  bottom: 16px;
  right: 20px;
  font-size: 10px;
  color: rgba(255,255,255,0.12);
  text-decoration: none;
  letter-spacing: 1px;
  transition: color 0.2s;
}
.cs-admin-link:hover { color: rgba(255,255,255,0.38); }
</style>

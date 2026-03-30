<template>
  <div class="nl-signup">

    <!-- ── Idle / form state ──────────────────────────────────────────── -->
    <template v-if="state === 'idle' || state === 'loading' || state === 'error'">
      <slot name="header">
        <div class="nl-title">{{ title }}</div>
        <div class="nl-sub">{{ subtitle }}</div>
      </slot>

      <div class="nl-form q-mt-md">
        <!--
          Honeypot — visually hidden, never touched by real users.
          Bots that auto-fill all fields will populate this; we silently
          discard those submissions. Uses off-screen CSS (not display:none /
          visibility:hidden, which bots can detect).
        -->
        <input
          v-model="honeypot"
          name="website"
          type="text"
          autocomplete="off"
          tabindex="-1"
          aria-hidden="true"
          class="nl-honeypot"
        />

        <q-input
          v-model="name"
          label="Your name (optional)"
          outlined dense
          :dark="dark"
          :color="dark ? 'teal-3' : 'teal'"
          class="q-mb-sm"
          autocomplete="name"
          @keyup.enter="submit"
        />

        <div class="row items-start q-gutter-sm">
          <q-input
            ref="emailRef"
            v-model="email"
            type="email"
            label="your@email.com"
            outlined dense
            class="col"
            :dark="dark"
            :color="dark ? 'teal-3' : 'teal'"
            :error="state === 'error'"
            :error-message="errorMsg"
            autocomplete="email"
            @keyup.enter="submit"
          />
          <q-btn
            label="Subscribe"
            unelevated
            color="teal"
            icon-right="send"
            :loading="state === 'loading'"
            @click="submit"
          />
        </div>

        <div class="nl-fine q-mt-sm">No spam. Unsubscribe anytime.</div>
      </div>
    </template>

    <!-- ── Already subscribed ─────────────────────────────────────────── -->
    <template v-else-if="state === 'already'">
      <div class="nl-result">
        <q-icon name="check_circle" color="teal-4" size="36px" />
        <div class="nl-result-title">Already on the list!</div>
        <div class="nl-result-body">
          {{ email }} is already subscribed — we'll see you in your inbox.
        </div>
      </div>
    </template>

    <!-- ── Success ────────────────────────────────────────────────────── -->
    <template v-else-if="state === 'done'">
      <div class="nl-result">
        <q-icon name="mark_email_unread" color="teal-4" size="36px" />
        <div class="nl-result-title">You're in{{ name ? `, ${name}` : '' }}!</div>
        <div class="nl-result-body">
          Check <strong>{{ email }}</strong> for a welcome note.
          Tour updates and community stories coming your way.
        </div>
      </div>
    </template>

  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

withDefaults(defineProps<{
  title?:    string
  subtitle?: string
  dark?:     boolean
}>(), {
  title:    'Stay in the Loop',
  subtitle: 'Show dates, trail reports, and community stories — straight to your inbox.',
  dark:     true,
})

type State = 'idle' | 'loading' | 'done' | 'already' | 'error'

const state    = ref<State>('idle')
const email    = ref('')
const name     = ref('')
const honeypot = ref('')     // must remain empty — bots fill this
const errorMsg = ref('')
const emailRef = ref<{ focus: () => void } | null>(null)

async function submit() {
  // Client-side validation
  const trimmedEmail = email.value.trim().toLowerCase()
  if (!trimmedEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmedEmail)) {
    state.value    = 'error'
    errorMsg.value = 'Please enter a valid email address'
    emailRef.value?.focus()
    return
  }

  // If the honeypot is filled, silently pretend success (don't alert the bot)
  if (honeypot.value.trim()) {
    state.value = 'done'
    return
  }

  state.value = 'loading'

  try {
    const res = await fetch('/api/newsletter/subscribe', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email:   trimmedEmail,
        name:    name.value.trim() || undefined,
        website: honeypot.value,   // forwarded for server-side honeypot check
        lists:   ['newsletter'],
      }),
    })

    if (res.status === 409) {
      // Already subscribed (we distinguish this on the server)
      state.value = 'already'
      return
    }

    if (!res.ok) {
      const data = await res.json().catch(() => ({})) as { error?: string }
      state.value    = 'error'
      errorMsg.value = data.error ?? 'Something went wrong — please try again.'
      return
    }

    const data = await res.json() as { ok: boolean; alreadySubscribed?: boolean }
    state.value = data.alreadySubscribed ? 'already' : 'done'

  } catch {
    state.value    = 'error'
    errorMsg.value = 'Connection error — please check your internet and try again.'
  }
}
</script>

<style scoped>
/* Input label/placeholder text — site yellow-orange */
:deep(.q-field__label) {
  color: #f5a623 !important;
}

/* Honeypot: off-screen, never visible to humans */
.nl-honeypot {
  position: absolute;
  left: -9999px;
  top:  -9999px;
  width: 1px;
  height: 1px;
  overflow: hidden;
  opacity: 0;
  pointer-events: none;
}

.nl-title {
  font-size: 1.1rem;
  font-weight: 700;
  margin-bottom: 4px;
}
.nl-sub {
  font-size: 0.85rem;
  opacity: 0.65;
  line-height: 1.5;
}
.nl-fine {
  font-size: 10px;
  opacity: 0.35;
  letter-spacing: 0.3px;
}

/* Success / already-subscribed result */
.nl-result {
  text-align: center;
  padding: 8px 0;
}
.nl-result-title {
  font-size: 1.1rem;
  font-weight: 700;
  margin: 10px 0 6px;
}
.nl-result-body {
  font-size: 0.875rem;
  opacity: 0.7;
  line-height: 1.6;
  max-width: 340px;
  margin: 0 auto;
}
</style>

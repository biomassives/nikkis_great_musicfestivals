<template>
  <q-page class="flex flex-center login-page">
    <q-card class="login-card q-pa-xl">
      <div class="text-center q-mb-xl">
        <svg width="64" height="64" viewBox="0 0 100 100" class="login-frog">
          <path d="M50 15 A35 35 0 0 1 85 50 A35 35 0 0 1 50 85 A35 35 0 0 1 15 50 A35 35 0 0 1 50 15 Z"
            fill="none" stroke="#4db6ac" stroke-width="2" stroke-dasharray="4 2"/>
          <path d="M30 50 Q 50 20 70 50 Q 50 80 30 50" fill="none" stroke="#4db6ac" stroke-width="3" />
          <circle cx="42" cy="45" r="2" fill="#4db6ac" />
          <circle cx="58" cy="45" r="2" fill="#4db6ac" />
        </svg>
        <div class="text-h5 text-weight-light q-mt-md text-teal-3">Admin Access</div>
        <div class="text-caption text-grey-5">Nikki's Great Music Festivals</div>
      </div>

      <q-form @submit="login" class="q-gutter-md">
        <q-input
          v-model="email"
          type="email"
          label="Email"
          dark outlined
          label-color="teal-3"
          color="teal-3"
          :rules="[v => !!v || 'Required']"
        />
        <q-input
          v-model="password"
          type="password"
          label="Password"
          dark outlined
          label-color="teal-3"
          color="teal-3"
          :rules="[v => !!v || 'Required']"
        />

        <div v-if="error" class="text-negative text-caption q-mt-sm">{{ error }}</div>

        <q-btn
          type="submit"
          label="Sign In"
          color="teal"
          class="full-width q-mt-lg"
          :loading="loading"
          unelevated
        />
      </q-form>

      <div class="text-center q-mt-lg">
        <q-btn
          flat dense
          label="Forgot password?"
          color="teal-3"
          size="sm"
          :loading="resetLoading"
          @click="sendReset"
        />
        <div v-if="resetSent" class="text-positive text-caption q-mt-sm">Reset email sent — check your inbox.</div>
        <div v-if="resetError" class="text-negative text-caption q-mt-sm">{{ resetError }}</div>
      </div>
    </q-card>
  </q-page>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from 'src/lib/supabase'

const router = useRouter()
const email    = ref('')
const password = ref('')
const loading  = ref(false)
const error    = ref('')

const resetLoading = ref(false)
const resetSent    = ref(false)
const resetError   = ref('')

async function sendReset() {
  if (!email.value) { resetError.value = 'Enter your email above first.'; return }
  resetLoading.value = true
  resetError.value   = ''
  resetSent.value    = false
  const { error: err } = await supabase.auth.resetPasswordForEmail(email.value, {
    redirectTo: `${window.location.origin}/admin/reset-password`,
  })
  resetLoading.value = false
  if (err) { resetError.value = err.message } else { resetSent.value = true }
}

async function login() {
  loading.value = true
  error.value = ''
  const { error: err } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })
  loading.value = false
  if (err) {
    error.value = err.message
  } else {
    void router.push('/admin')
  }
}
</script>

<style lang="scss" scoped>
.login-page { background: #0f0f1a; }
.login-card {
  background: #1a1a2e;
  border: 1px solid rgba(77, 182, 172, 0.3);
  border-radius: 16px;
  width: 100%;
  max-width: 420px;
}
.login-frog {
  filter: drop-shadow(0 0 12px rgba(77, 182, 172, 0.5));
  animation: float 6s ease-in-out infinite;
}
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50%       { transform: translateY(-8px); }
}
</style>

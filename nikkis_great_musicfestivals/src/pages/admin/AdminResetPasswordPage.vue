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
        <div class="text-h5 text-weight-light q-mt-md text-teal-3">
          {{ state === 'success' ? 'Password Updated' : 'Reset Password' }}
        </div>
        <div class="text-caption text-grey-5">Nikki's Great Music Festivals</div>
      </div>

      <!-- Error state (expired / invalid link) -->
      <template v-if="state === 'error'">
        <div class="text-center">
          <q-icon name="error_outline" size="48px" color="negative" class="q-mb-md" />
          <div class="text-body2 text-grey-4 q-mb-lg">{{ errorMsg }}</div>
          <q-btn
            label="Back to Login"
            color="teal"
            unelevated
            class="full-width"
            to="/admin/login"
          />
        </div>
      </template>

      <!-- New password form -->
      <template v-else-if="state === 'form'">
        <q-form @submit="setNewPassword" class="q-gutter-md">
          <q-input
            v-model="newPassword"
            type="password"
            label="New Password"
            dark outlined
            label-color="teal-3"
            color="teal-3"
            :rules="[v => v.length >= 8 || 'At least 8 characters']"
          />
          <q-input
            v-model="confirmPassword"
            type="password"
            label="Confirm Password"
            dark outlined
            label-color="teal-3"
            color="teal-3"
            :rules="[v => v === newPassword || 'Passwords do not match']"
          />

          <div v-if="formError" class="text-negative text-caption q-mt-sm">{{ formError }}</div>

          <q-btn
            type="submit"
            label="Set New Password"
            color="teal"
            class="full-width q-mt-lg"
            :loading="loading"
            unelevated
          />
        </q-form>
      </template>

      <!-- Success state -->
      <template v-else-if="state === 'success'">
        <div class="text-center">
          <q-icon name="check_circle_outline" size="48px" color="teal-3" class="q-mb-md" />
          <div class="text-body2 text-grey-4 q-mb-lg">Your password has been updated. You can now sign in.</div>
          <q-btn
            label="Go to Login"
            color="teal"
            unelevated
            class="full-width"
            to="/admin/login"
          />
        </div>
      </template>

      <!-- Loading state while parsing hash -->
      <template v-else>
        <div class="flex flex-center q-py-xl">
          <q-spinner-orbit color="teal-3" size="48px" />
        </div>
      </template>

    </q-card>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'

type State = 'loading' | 'form' | 'error' | 'success'

const state          = ref<State>('loading')
const newPassword    = ref('')
const confirmPassword = ref('')
const loading        = ref(false)
const errorMsg       = ref('')
const formError      = ref('')

onMounted(async () => {
  // Supabase passes tokens/errors as URL hash fragments
  const hash   = window.location.hash.slice(1)           // strip leading #
  const params = new URLSearchParams(hash)

  const error      = params.get('error')
  const errorCode  = params.get('error_code')
  const accessToken  = params.get('access_token')
  const refreshToken = params.get('refresh_token')
  const type         = params.get('type')

  if (error) {
    const desc = params.get('error_description') ?? error
    if (errorCode === 'otp_expired') {
      errorMsg.value = 'This reset link has expired. Please request a new one from the login page.'
    } else {
      errorMsg.value = decodeURIComponent(desc.replace(/\+/g, ' '))
    }
    state.value = 'error'
    return
  }

  if (accessToken && refreshToken && type === 'recovery') {
    // Establish the recovery session
    const { error: sessionErr } = await supabase.auth.setSession({
      access_token:  accessToken,
      refresh_token: refreshToken,
    })
    if (sessionErr) {
      errorMsg.value = sessionErr.message
      state.value = 'error'
    } else {
      // Clear hash from URL without reloading
      history.replaceState(null, '', window.location.pathname)
      state.value = 'form'
    }
    return
  }

  // No recognisable params — could be a direct navigation to this URL
  errorMsg.value = 'No valid reset token found. Please request a new password reset link.'
  state.value = 'error'
})

async function setNewPassword() {
  formError.value = ''
  loading.value   = true
  const { error } = await supabase.auth.updateUser({ password: newPassword.value })
  loading.value   = false
  if (error) {
    formError.value = error.message
  } else {
    state.value = 'success'
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

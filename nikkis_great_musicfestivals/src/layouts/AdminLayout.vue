<template>
  <q-layout view="hHh lpR fFf">
    <q-header elevated class="admin-header">
      <q-toolbar>
        <q-icon name="music_note" size="22px" class="q-mr-xs" />
        <q-toolbar-title class="text-weight-light ls-1 gt-xs">
          NIKKI'S <span class="text-weight-bold text-caption q-ml-sm admin-badge">ADMIN</span>
        </q-toolbar-title>

        <q-btn flat dense :to="'/admin'"            exact icon="dashboard"         label="Dashboard"  class="q-mx-xs admin-nav-btn gt-sm" />
        <q-btn flat dense :to="'/admin/maps'"             icon="explore"           label="Maps"       class="q-mx-xs admin-nav-btn gt-sm" />
        <q-btn flat dense :to="'/admin/gallery'"          icon="photo_library"     label="Gallery"    class="q-mx-xs admin-nav-btn gt-sm" />
        <q-btn flat dense :to="'/admin/newsletter'"       icon="mark_email_unread" label="Newsletter" class="q-mx-xs admin-nav-btn gt-sm" />
        <q-btn flat dense :to="'/admin/news'"             icon="newspaper"         label="News"       class="q-mx-xs admin-nav-btn gt-sm" />
        <q-btn flat dense :to="'/admin/merch'"            icon="style"             label="Merch"      class="q-mx-xs admin-nav-btn gt-sm" />
        <q-btn flat dense :to="'/admin/home'"             icon="home"              label="Homepage"   class="q-mx-xs admin-nav-btn gt-sm" />

        <!-- Mobile: just icons -->
        <q-btn flat round dense :to="'/admin'"       exact icon="dashboard"         size="sm" class="q-mx-xs lt-md" title="Dashboard" />
        <q-btn flat round dense :to="'/admin/maps'"       icon="explore"           size="sm" class="q-mx-xs lt-md" title="Maps" />
        <q-btn flat round dense :to="'/admin/gallery'"    icon="photo_library"     size="sm" class="q-mx-xs lt-md" title="Gallery" />
        <q-btn flat round dense :to="'/admin/newsletter'" icon="mark_email_unread" size="sm" class="q-mx-xs lt-md" title="Newsletter" />
        <q-btn flat round dense :to="'/admin/news'"       icon="newspaper"         size="sm" class="q-mx-xs lt-md" title="News" />
        <q-btn flat round dense :to="'/admin/merch'"      icon="style"             size="sm" class="q-mx-xs lt-md" title="Merch" />
        <q-btn flat round dense :to="'/admin/home'"       icon="home"              size="sm" class="q-mx-xs lt-md" title="Homepage" />

        <q-separator vertical inset dark class="q-mx-sm" />
        <q-btn flat round icon="open_in_new" :to="'/'" title="View site" size="sm" />
        <q-btn v-if="!session" flat round dense icon="login" color="teal-3" :to="'/admin/login'" title="Log in" size="sm" />
        <q-btn v-if="session"  flat round dense icon="logout" title="Sign out" @click="signOut" size="sm" />
      </q-toolbar>
    </q-header>

    <q-page-container class="admin-bg">
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from 'src/lib/supabase'
import type { Session } from '@supabase/supabase-js'

const router = useRouter()
const session = ref<Session | null>(null)

onMounted(async () => {
  const { data } = await supabase.auth.getSession()
  session.value = data.session
  supabase.auth.onAuthStateChange((_e, s) => { session.value = s })
})

async function signOut() {
  await supabase.auth.signOut()
  void router.push('/admin/login')
}
</script>

<style lang="scss" scoped>
.admin-header {
  background: #1a1a2e;
  border-bottom: 2px solid #4db6ac;
}
.admin-badge {
  background: #4db6ac; color: #1a1a2e;
  padding: 2px 8px; border-radius: 4px; letter-spacing: 2px;
}
.admin-bg { background: #0f0f1a; min-height: 100vh; color: #e0f2f1; }
.ls-1 { letter-spacing: 1px; }
.admin-nav-btn {
  font-size: 11px; letter-spacing: 1px; opacity: 0.7;
  &.router-link-active { opacity: 1; border-bottom: 2px solid #4db6ac; }
}
</style>

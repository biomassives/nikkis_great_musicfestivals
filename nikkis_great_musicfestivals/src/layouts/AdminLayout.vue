<template>
  <q-layout view="hHh lpR fFf">
    <q-header class="admin-header">

      <!-- ── Top bar: brand + utilities ──────────────────────── -->
      <q-toolbar class="admin-top-bar">
        <q-icon name="music_note" size="20px" class="q-mr-xs" />
        <span class="brand-text gt-xs">NIKKI'S</span>
        <span class="admin-badge q-ml-sm gt-xs">ADMIN</span>
        <q-space />
        <q-btn flat round dense :to="'/admin'" exact icon="dashboard" title="Dashboard" size="sm" class="top-btn" />
        <q-separator vertical inset dark class="q-mx-sm" />
        <q-btn flat round icon="open_in_new" :to="'/'" title="View site" size="sm" class="top-btn" />
        <q-btn v-if="!session" flat round dense icon="login"  color="teal-3"  :to="'/admin/login'" title="Log in"    size="sm" class="top-btn" />
        <q-btn v-if="session"  flat round dense icon="logout" color="grey-5"  title="Sign out" @click="signOut"      size="sm" class="top-btn" />
      </q-toolbar>

      <!-- ── Row 1: Content ──────────────────────────────────── -->
      <div class="nav-row nav-row--content">
        <span class="row-label">Content</span>
        <q-btn flat dense :to="'/admin/maps'"       icon="explore"           label="Maps"       class="nav-btn" />
        <q-btn flat dense :to="'/admin/gallery'"    icon="photo_library"     label="Gallery"    class="nav-btn" />
        <q-btn flat dense :to="'/admin/newsletter'" icon="mark_email_unread" label="Newsletter" class="nav-btn" />
        <q-btn flat dense :to="'/admin/news'"       icon="newspaper"         label="News"       class="nav-btn" />
        <q-btn flat dense :to="'/admin/merch'"      icon="style"             label="Merch"      class="nav-btn" />
      </div>

      <!-- ── Row 2: Pages & Config ───────────────────────────── -->
      <div class="nav-row nav-row--config">
        <span class="row-label row-label--config">Pages & Config</span>
        <q-btn flat dense :to="'/admin/home'"    icon="home"         label="Homepage"   class="nav-btn nav-btn--config" />
        <q-btn flat dense :to="'/admin/story'"   icon="auto_stories" label="Our Story"  class="nav-btn nav-btn--config" />
        <q-btn flat dense :to="'/admin/support'" icon="favorite"     label="Support"    class="nav-btn nav-btn--config" />
        <q-btn flat dense :to="'/admin/nav'"     icon="menu"         label="Nav"        class="nav-btn nav-btn--config" />
        <q-btn flat dense :to="'/admin/pages'"   icon="web"          label="Pages"      class="nav-btn nav-btn--config" />
      </div>

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

const router  = useRouter()
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
/* ── Outer header ──────────────────────────────────────────────── */
.admin-header {
  background: #1a1a2e;
  border-bottom: 2px solid rgba(77,182,172,0.5);
}

/* ── Top bar ───────────────────────────────────────────────────── */
.admin-top-bar {
  min-height: 44px;
  padding: 0 12px;
  background: #131325;
  border-bottom: 1px solid rgba(77,182,172,0.12);
}
.brand-text {
  font-size: 13px; font-weight: 300; letter-spacing: 2px;
  color: rgba(255,255,255,0.7);
}
.admin-badge {
  background: #4db6ac; color: #1a1a2e;
  font-size: 9px; font-weight: 800;
  padding: 2px 7px; border-radius: 4px; letter-spacing: 2px;
}
.top-btn { color: rgba(255,255,255,0.5); &:hover { color: #fff; } }

/* ── Shared nav row ────────────────────────────────────────────── */
.nav-row {
  display: flex;
  align-items: center;
  gap: 2px;
  padding: 0 10px;
  min-height: 38px;
  overflow-x: auto;
  scrollbar-width: none;
  &::-webkit-scrollbar { display: none; }
}

/* ── Row 1 — Content (teal accent) ────────────────────────────── */
.nav-row--content {
  background: #1a1a2e;
  border-bottom: 1px solid rgba(77,182,172,0.15);
}

/* ── Row 2 — Config (indigo/purple accent) ─────────────────────── */
.nav-row--config {
  background: #14102a;
}

/* ── Row labels ─────────────────────────────────────────────────── */
.row-label {
  font-size: 9px; font-weight: 800; letter-spacing: 2.5px;
  text-transform: uppercase; color: rgba(77,182,172,0.55);
  margin-right: 6px; flex-shrink: 0; padding-right: 8px;
  border-right: 1px solid rgba(77,182,172,0.15);
}
.row-label--config {
  color: rgba(179,157,219,0.55);
  border-right-color: rgba(179,157,219,0.15);
}

/* ── Nav buttons ────────────────────────────────────────────────── */
.nav-btn {
  font-size: 11px; letter-spacing: 0.5px;
  color: rgba(255,255,255,0.5);
  border-radius: 4px;
  padding: 4px 10px;
  flex-shrink: 0;
  transition: color 0.15s, background 0.15s;

  &:hover { color: #fff; background: rgba(255,255,255,0.06); }

  &.router-link-active {
    color: #4db6ac;
    background: rgba(77,182,172,0.1);
    font-weight: 700;
  }
}

.nav-btn--config {
  &.router-link-active {
    color: #b39ddb;
    background: rgba(179,157,219,0.12);
  }
}

/* ── Page container ─────────────────────────────────────────────── */
.admin-bg { background: #0f0f1a; min-height: 100vh; color: #e0f2f1; }
</style>

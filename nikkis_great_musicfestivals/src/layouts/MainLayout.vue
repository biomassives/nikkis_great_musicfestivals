<template>
  <q-layout view="hHh lpR fFf">

    <!-- ═══ HEADER ════════════════════════════════════════════════ -->
    <q-header class="main-header">
      <q-toolbar class="main-toolbar">
        <button class="burger-btn" @click="menuOpen = true" aria-label="Open navigation">
          <span class="burger-bar" /><span class="burger-bar" /><span class="burger-bar" />
        </button>

        <div class="header-brand">
          <span class="header-brand-nikki">NIKKI'S</span>
          <span class="header-brand-fest">GREAT FESTIVALS</span>
        </div>

        <!-- desktop quick-links -->
        <nav class="desktop-nav gt-sm">
          <router-link
            v-for="link in navLinks" :key="link.link"
            :to="link.link"
            class="desktop-nav-link"
            :style="`--lc:${link.color}`"
          >{{ link.title }}</router-link>
        </nav>

        <q-btn
          flat round dense size="sm"
          :icon="$q.dark.isActive ? 'brightness_5' : 'brightness_3'"
          class="q-ml-sm theme-toggle-btn"
          @click="$q.dark.toggle()"
        />
      </q-toolbar>
    </q-header>

    <!-- ═══ FLYOUT BACKDROP + PANEL ══════════════════════════════ -->
    <Teleport to="body">
      <Transition name="bd">
        <div v-if="menuOpen" class="flyout-backdrop" @click="menuOpen = false" />
      </Transition>

      <Transition name="fly">
        <nav v-if="menuOpen" class="flyout-panel" role="navigation" aria-label="Site navigation">

          <!-- close -->
          <button class="flyout-close" @click="menuOpen = false" aria-label="Close menu">✕</button>

          <!-- spirograph logo -->
          <div class="flyout-logo-wrap">
            <SpirographLogo :size="160" :spin="true" :shadow="true" />
          </div>

          <div class="flyout-brand-label">NIKKI'S<br><span>FESTIVALS</span></div>

          <!-- nav links -->
          <ul class="flyout-links" role="list">
            <template v-for="link in navLinks" :key="link.link">
              <li>
                <router-link
                  :to="link.link"
                  class="flyout-link"
                  :style="`--lc:${link.color}`"
                  @click="menuOpen = false"
                >
                  <q-icon :name="link.icon" class="flyout-link-icon" />
                  <span class="flyout-link-label">{{ link.title }}</span>
                  <span class="flyout-link-arrow">›</span>
                </router-link>
              </li>
              <li v-for="child in link.children" :key="child.link" class="flyout-sublink-li">
                <router-link
                  :to="child.link"
                  class="flyout-sublink"
                  :style="`--lc:${link.color}`"
                  @click="menuOpen = false"
                >
                  <span class="flyout-sublink-dot" :style="`background:${link.color}`" />
                  {{ child.title }}
                </router-link>
              </li>
            </template>
          </ul>

          <!-- newsletter quick-sub -->
          <div class="flyout-newsletter">
            <div class="flyout-nl-label">NEWSLETTER</div>
            <div class="flyout-nl-row">
              <input
                v-model="navEmail"
                type="email"
                placeholder="your@email.com"
                class="flyout-nl-input"
                @keyup.enter="subscribeNav"
              />
              <button class="flyout-nl-btn" @click="subscribeNav">→</button>
            </div>
            <div v-if="subMsg" class="flyout-nl-msg">{{ subMsg }}</div>
          </div>

        </nav>
      </Transition>
    </Teleport>

    <!-- ═══ PAGE CONTAINER ════════════════════════════════════════ -->
    <q-page-container :class="$q.dark.isActive ? 'page-dark' : 'page-light'">
      <!-- Layout-level animated background -->
      <div class="layout-bg absolute-full no-pointer-events overflow-hidden" aria-hidden="true">
        <svg class="layout-bg-svg layer1" width="100%" height="100%">
          <defs>
            <radialGradient id="lbg1" cx="50%" cy="40%" r="60%">
              <stop offset="0%"   stop-color="#7c4dff" stop-opacity="0.18" />
              <stop offset="100%" stop-color="#7c4dff" stop-opacity="0" />
            </radialGradient>
            <pattern id="lbg-circles" patternUnits="userSpaceOnUse" width="400" height="400">
              <circle cx="200" cy="200" r="180" fill="none" stroke="#7c4dff" stroke-width="0.6" stroke-dasharray="12 8" opacity="0.35"/>
              <circle cx="200" cy="200" r="120" fill="none" stroke="#ff6d00" stroke-width="0.4" stroke-dasharray="8 12" opacity="0.25"/>
              <circle cx="200" cy="200" r="60"  fill="none" stroke="#00bcd4" stroke-width="0.4" stroke-dasharray="4 8"  opacity="0.2"/>
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#lbg-circles)" />
          <rect width="100%" height="100%" fill="url(#lbg1)" />
        </svg>
        <svg class="layout-bg-svg layer2" width="100%" height="100%">
          <defs>
            <pattern id="lbg-diamonds" patternUnits="userSpaceOnUse" width="80" height="80" patternTransform="rotate(30)">
              <path d="M40 5 L75 40 L40 75 L5 40 Z" fill="none" stroke="#ffb300" stroke-width="0.5" opacity="0.3"/>
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#lbg-diamonds)" />
        </svg>
      </div>

      <router-view style="position:relative; z-index:1;" />
      <FooterScene :night="$q.dark.isActive" />

      <!-- Site footer bar -->
      <div class="site-footer">
        <span class="site-footer-copy">© 2026 Nikki's Great Music Festivals</span>
        <div class="site-footer-links">
          <router-link to="/support" class="site-footer-link">Support the Mission</router-link>
          <span class="site-footer-sep">·</span>
          <router-link to="/news" class="site-footer-link">News</router-link>
          <span class="site-footer-sep">·</span>
          <router-link to="/admin" class="site-footer-link site-footer-link--admin">Admin</router-link>
        </div>
      </div>
    </q-page-container>

  </q-layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { supabase } from 'src/lib/supabase'
import SpirographLogo from 'src/components/SpirographLogo.vue'
import FooterScene    from 'src/components/FooterScene.vue'

const $q = useQuasar()
const menuOpen = ref(false)
const navEmail = ref('')
const subMsg   = ref('')

/* ── Nav ─────────────────────────────────────────────────────────── */
interface NavChild { title: string; link: string }
interface NavItem  { title: string; icon: string; link: string; color: string; children: NavChild[] }

const navLinks = ref<NavItem[]>([
  { title: 'Home',        icon: 'auto_awesome', link: '/',            color: '#ffd600', children: [] },
  { title: 'Photography', icon: 'camera',       link: '/photography', color: '#ff6d00', children: [] },
  { title: 'Maps',        icon: 'explore',      link: '/maps',        color: '#00e676', children: [] },
  { title: 'Support',     icon: 'favorite',     link: '/support',     color: '#ff4081', children: [] },
  { title: 'Merch',       icon: 'style',        link: '/merch',       color: '#ce93d8', children: [] },
  { title: 'News',        icon: 'forum',        link: '/news',        color: '#00b0ff', children: [] },
])

onMounted(async () => {
  const [navRes, pagesRes] = await Promise.allSettled([
    supabase.from('site_settings').select('value').eq('key', 'nav_config').limit(1),
    supabase.from('custom_pages').select('slug, title, nav_parent').eq('published', true),
  ])

  // Apply saved nav config
  if (navRes.status === 'fulfilled') {
    const navRow = navRes.value.data?.[0]
    if (Array.isArray(navRow?.value) && (navRow?.value as unknown[]).length) {
      navLinks.value = (navRow?.value as NavItem[]).map(item => ({
        ...item,
        children: item.children ?? [],
      }))
    }
  }

  // Auto-inject published custom pages under their nav parent
  if (pagesRes.status === 'fulfilled' && pagesRes.value.data) {
    type PageRow = { slug: string; title: string; nav_parent: string | null }
    for (const p of pagesRes.value.data as PageRow[]) {
      if (!p.nav_parent) continue
      const parent = navLinks.value.find(l => l.link === p.nav_parent)
      if (parent && !parent.children.some(c => c.link === `/${p.slug}`)) {
        parent.children.push({ title: p.title, link: `/${p.slug}` })
      }
    }
  }
})

/* ── Newsletter ──────────────────────────────────────────────────── */
async function subscribeNav() {
  const email = navEmail.value.trim()
  if (!email) return
  const { error } = await supabase.from('newsletter_subscribers').upsert({ email })
  subMsg.value = error ? 'Error — try again' : 'You\'re subscribed!'
  navEmail.value = ''
  setTimeout(() => { subMsg.value = '' }, 3000)
}
</script>

<style lang="scss">
/* ══ HEADER ══════════════════════════════════════════════════════ */
.main-header {
  background: linear-gradient(105deg, #0d0024 0%, #1a0042 55%, #0d1a3a 100%) !important;
  border-bottom: 2px solid #7c4dff;
  box-shadow: 0 2px 20px rgba(124,77,255,0.4) !important;
}
.main-toolbar { padding: 0 16px; min-height: 56px; }

/* Hamburger */
.burger-btn {
  background: transparent; border: none; cursor: pointer;
  display: flex; flex-direction: column; justify-content: center;
  gap: 5px; padding: 8px; border-radius: 6px;
  transition: background 0.2s;
  &:hover { background: rgba(255,255,255,0.12); }
}
.burger-bar {
  display: block; width: 22px; height: 2px;
  background: #ffd600; border-radius: 2px;
  transition: transform 0.25s;
}

/* Brand */
.header-brand {
  display: flex; flex-direction: column; line-height: 1;
  margin-left: 12px;
}
.header-brand-nikki {
  font-size: 10px; letter-spacing: 4px; color: #ffd600;
  font-weight: 900; text-transform: uppercase;
}
.header-brand-fest {
  font-size: 14px; letter-spacing: 2px; color: #fff;
  font-weight: 300; text-transform: uppercase;
}

/* Desktop quick-nav */
.desktop-nav {
  display: flex; align-items: center; gap: 4px; margin-left: auto; margin-right: 8px;
}
.desktop-nav-link {
  text-decoration: none; color: rgba(255,255,255,0.7);
  font-size: 11px; font-weight: 700; letter-spacing: 1.5px;
  text-transform: uppercase; padding: 6px 10px; border-radius: 4px;
  transition: color 0.2s, background 0.2s;
  &:hover, &.router-link-active {
    color: var(--lc, #ffd600);
    background: rgba(255,255,255,0.07);
  }
  &.router-link-exact-active { color: var(--lc, #ffd600); }
}
.theme-toggle-btn { color: rgba(255,255,255,0.6) !important; }

/* ══ FLYOUT BACKDROP ═════════════════════════════════════════════ */
.flyout-backdrop {
  position: fixed; inset: 0; z-index: 9000;
  background: rgba(5, 0, 20, 0.72);
  backdrop-filter: blur(4px);
}
.bd-enter-active, .bd-leave-active { transition: opacity 0.25s ease; }
.bd-enter-from, .bd-leave-to { opacity: 0; }

/* ══ FLYOUT PANEL ════════════════════════════════════════════════ */
.flyout-panel {
  position: fixed; top: 0; left: 0; bottom: 0;
  width: 300px; z-index: 9001;
  background: linear-gradient(180deg, #0d0028 0%, #110036 60%, #0a1a3a 100%);
  border-right: 1px solid rgba(124,77,255,0.4);
  box-shadow: 6px 0 40px rgba(124,77,255,0.25);
  display: flex; flex-direction: column;
  overflow-y: auto;
  padding: 0 0 24px;
}
.fly-enter-active { transition: transform 0.28s cubic-bezier(0.16, 1, 0.3, 1); }
.fly-leave-active { transition: transform 0.22s cubic-bezier(0.4, 0, 1, 1); }
.fly-enter-from, .fly-leave-to { transform: translateX(-100%); }

/* Close button */
.flyout-close {
  position: absolute; top: 14px; right: 14px;
  background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15);
  color: rgba(255,255,255,0.7); cursor: pointer;
  width: 32px; height: 32px; border-radius: 50%;
  font-size: 14px; display: flex; align-items: center; justify-content: center;
  transition: background 0.2s, color 0.2s;
  &:hover { background: rgba(255,77,120,0.3); color: #fff; }
}

/* Spirograph logo */
.flyout-logo-wrap {
  display: flex; justify-content: center;
  padding: 32px 0 12px;
}

/* Brand label below logo */
.flyout-brand-label {
  text-align: center; color: #ffd600;
  font-size: 12px; font-weight: 900; letter-spacing: 4px;
  text-transform: uppercase; line-height: 1.5;
  margin-bottom: 20px;
  span { color: rgba(255,255,255,0.55); font-weight: 300; letter-spacing: 3px; }
}

/* Nav links */
.flyout-links {
  list-style: none; margin: 0; padding: 0 0 8px;
}
.flyout-link {
  display: flex; align-items: center;
  padding: 13px 24px; text-decoration: none;
  color: rgba(255,255,255,0.75);
  border-left: 3px solid transparent;
  transition: background 0.18s, border-color 0.18s, color 0.18s;
  gap: 14px;
  &:hover, &.router-link-active {
    background: rgba(255,255,255,0.06);
    border-left-color: var(--lc, #ffd600);
    color: #fff;
    .flyout-link-icon { color: var(--lc, #ffd600); }
    .flyout-link-arrow { opacity: 1; transform: translateX(3px); }
  }
}
.flyout-link-icon {
  font-size: 20px; color: rgba(255,255,255,0.4);
  transition: color 0.18s; flex-shrink: 0;
}
.flyout-link-label {
  flex: 1; font-size: 13px; font-weight: 700;
  letter-spacing: 2px; text-transform: uppercase;
}
.flyout-link-arrow {
  font-size: 18px; opacity: 0; color: var(--lc, #ffd600);
  transition: opacity 0.18s, transform 0.18s;
}

/* Sub-links */
.flyout-sublink-li { list-style: none; }
.flyout-sublink {
  display: flex; align-items: center; gap: 10px;
  padding: 7px 24px 7px 52px; text-decoration: none;
  color: rgba(255,255,255,0.5);
  font-size: 11px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase;
  border-left: 3px solid transparent;
  transition: background 0.15s, color 0.15s, border-color 0.15s;
  &:hover, &.router-link-active {
    background: rgba(255,255,255,0.04);
    border-left-color: var(--lc, #ffd600);
    color: rgba(255,255,255,0.85);
  }
}
.flyout-sublink-dot {
  width: 5px; height: 5px; border-radius: 50%; flex-shrink: 0; opacity: 0.55;
}

/* Newsletter */
.flyout-newsletter {
  margin: auto 20px 0; padding-top: 20px;
  border-top: 1px solid rgba(255,255,255,0.1);
}
.flyout-nl-label {
  font-size: 9px; font-weight: 900; letter-spacing: 3px;
  color: rgba(255,255,255,0.35); margin-bottom: 8px;
}
.flyout-nl-row { display: flex; gap: 6px; }
.flyout-nl-input {
  flex: 1; background: rgba(255,255,255,0.07);
  border: 1px solid rgba(255,255,255,0.15); border-radius: 6px;
  padding: 8px 12px; color: #fff; font-size: 13px; outline: none;
  &::placeholder { color: rgba(255,255,255,0.3); }
  &:focus { border-color: #7c4dff; }
}
.flyout-nl-btn {
  background: #7c4dff; border: none; border-radius: 6px;
  color: #fff; font-size: 16px; padding: 8px 14px; cursor: pointer;
  transition: background 0.15s;
  &:hover { background: #9c6dff; }
}
.flyout-nl-msg {
  font-size: 11px; color: #a5d6a7; margin-top: 6px;
}

/* ══ PAGE CONTAINER ══════════════════════════════════════════════ */
.page-light { background: linear-gradient(180deg, #d0eaff 0%, #f5f0ff 100%); color: #1a0a2e; }
.page-dark  { background: #070014; color: #e8e0ff; }

/* Layout background animations */
.layout-bg { z-index: 0; }
.layout-bg-svg { position: absolute; inset: 0; }
.layer1 { animation: lbg-drift 90s linear infinite; }
.layer2 { animation: lbg-drift 55s linear infinite reverse; }
@keyframes lbg-drift {
  from { transform: rotate(0deg) scale(1.05); }
  to   { transform: rotate(360deg) scale(1.05); }
}

/* ══ SITE FOOTER BAR ═════════════════════════════════════════════ */
.site-footer {
  display: flex; align-items: center; justify-content: space-between;
  flex-wrap: wrap; gap: 8px;
  padding: 12px 24px;
  background: rgba(0,0,0,0.18);
  border-top: 1px solid rgba(255,255,255,0.06);
  position: relative; z-index: 1;
}
.site-footer-copy {
  font-size: 11px; color: rgba(255,255,255,0.25); letter-spacing: 0.5px;
}
.site-footer-links {
  display: flex; align-items: center; gap: 8px;
}
.site-footer-sep { color: rgba(255,255,255,0.15); font-size: 11px; }
.site-footer-link {
  font-size: 11px; color: rgba(255,255,255,0.3);
  text-decoration: none; letter-spacing: 0.5px;
  transition: color 0.2s;
  &:hover { color: rgba(255,255,255,0.7); }
  &--admin {
    color: rgba(77,182,172,0.45);
    &:hover { color: #4db6ac; }
  }
}
</style>

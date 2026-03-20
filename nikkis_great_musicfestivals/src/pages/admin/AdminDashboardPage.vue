<template>
  <q-page class="q-pa-lg">

    <!-- Not-logged-in banner -->
    <q-banner v-if="!session" rounded class="login-banner q-mb-lg">
      <template #avatar>
        <q-icon name="lock_open" color="amber-4" size="24px" />
      </template>
      <span class="text-weight-medium">Viewing in read-only mode.</span>
      <span class="text-grey-4 q-ml-xs">Log in to create and edit content.</span>
      <template #action>
        <q-btn flat color="amber-4" label="Log In" :to="'/admin/login'" />
      </template>
    </q-banner>

    <!-- Welcome -->
    <div class="row items-center q-mb-xl">
      <div>
        <div class="text-h4 text-teal-3 text-bold">Dashboard</div>
        <div class="text-caption text-grey-5">Welcome back, Nikki · {{ today }}</div>
      </div>
      <q-space />
      <q-btn flat icon="refresh" color="teal-3" @click="loadStats" :loading="loading" label="Refresh" size="sm" />
    </div>

    <!-- Stats row -->
    <div class="row q-col-gutter-md q-mb-xl">
      <div class="col-6 col-sm-4 col-md-2" v-for="stat in stats" :key="stat.label">
        <q-card class="stat-card cursor-pointer" @click="$router.push(stat.route)">
          <q-card-section class="text-center q-pa-md">
            <q-icon :name="stat.icon" :color="stat.color" size="28px" class="q-mb-xs" />
            <div class="stat-num" :style="`color: var(--q-${stat.color})`">
              {{ loading ? '—' : stat.value }}
            </div>
            <div class="stat-label">{{ stat.label }}</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Section cards -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-md">Manage Content</div>
    <div class="row q-col-gutter-lg">
      <div class="col-12 col-sm-6 col-lg-4" v-for="section in sections" :key="section.route">
        <q-card class="section-card" @click="$router.push(section.route)">
          <q-card-section class="row items-center q-pa-lg gap-md">
            <q-icon :name="section.icon" :color="section.color" size="36px" class="q-mr-md" />
            <div class="col">
              <div class="text-h6 text-white text-weight-bold">{{ section.title }}</div>
              <div class="text-caption text-grey-5">{{ section.desc }}</div>
            </div>
            <q-icon name="chevron_right" color="grey-6" size="20px" />
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Recent subscribers -->
    <div class="q-mt-xl">
      <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-md">Recent Subscribers</div>
      <q-card class="recent-card">
        <q-list separator dark style="background:transparent">
          <q-item v-for="sub in recentSubs" :key="sub.email" dense class="q-py-sm">
            <q-item-section avatar>
              <q-icon name="person" color="teal-5" size="18px" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-grey-3" style="font-size:13px">{{ sub.email }}</q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-item-label caption class="text-grey-6">{{ fmtDate(sub.created_at) }}</q-item-label>
            </q-item-section>
          </q-item>
          <q-item v-if="!loading && recentSubs.length === 0">
            <q-item-section class="text-grey-6 text-center q-py-md">No subscribers yet</q-item-section>
          </q-item>
        </q-list>
      </q-card>
    </div>

  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { Session } from '@supabase/supabase-js'

const loading    = ref(true)
const session    = ref<Session | null>(null)
const recentSubs = ref<{ email: string; created_at: string }[]>([])

const counts = ref({ subscribers: 0, photos: 0, regions: 0, shows: 0, news: 0, merch: 0 })

const today = new Date().toLocaleDateString('en-US', { weekday:'long', month:'long', day:'numeric', year:'numeric' })

const stats = [
  { label: 'Subscribers', icon: 'mail',         color: 'teal-4',        route: '/admin/newsletter', get value() { return counts.value.subscribers } },
  { label: 'Photos',      icon: 'photo_library', color: 'amber-4',       route: '/admin/gallery',    get value() { return counts.value.photos } },
  { label: 'Regions',     icon: 'map',           color: 'light-blue-4',  route: '/admin/maps',       get value() { return counts.value.regions } },
  { label: 'Shows',       icon: 'event',         color: 'deep-purple-3', route: '/admin/maps',       get value() { return counts.value.shows } },
  { label: 'News',        icon: 'newspaper',     color: 'green-4',       route: '/admin/news',       get value() { return counts.value.news } },
  { label: 'Merch',       icon: 'style',         color: 'pink-4',        route: '/admin/merch',      get value() { return counts.value.merch } },
]

const sections = [
  { title: 'Festival Maps',    icon: 'explore',           color: 'teal-4',        route: '/admin/maps',       desc: 'Add shows, senior facilities, and nature spots' },
  { title: 'Photo Gallery',    icon: 'photo_library',     color: 'amber-4',       route: '/admin/gallery',    desc: 'Upload and organise photos by category' },
  { title: 'Newsletter',       icon: 'mark_email_unread', color: 'light-blue-4',  route: '/admin/newsletter', desc: 'Compose newsletters and view subscribers' },
  { title: 'News & Updates',   icon: 'newspaper',         color: 'green-4',       route: '/admin/news',       desc: 'Write tour stories and event recaps' },
  { title: 'Merch & Goods',    icon: 'style',             color: 'pink-4',        route: '/admin/merch',      desc: 'Manage art, photo prints, and other items' },
  { title: 'View Public Site', icon: 'open_in_new',       color: 'grey-4',        route: '/',                 desc: 'See how the site looks to visitors' },
]

function fmtDate(d: string) {
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

async function loadStats() {
  loading.value = true
  const [
    { count: subs },
    { count: photos },
    { count: regions },
    { count: shows },
    { count: news },
    { count: merch },
    { data: subsList },
  ] = await Promise.all([
    supabase.from('newsletter_subscribers').select('*', { count: 'exact', head: true }),
    supabase.from('gallery_photos').select('*',          { count: 'exact', head: true }),
    supabase.from('map_regions').select('*',             { count: 'exact', head: true }),
    supabase.from('map_points').select('*',              { count: 'exact', head: true }).eq('category','show'),
    supabase.from('news_articles').select('*',           { count: 'exact', head: true }),
    supabase.from('merch_items').select('*',             { count: 'exact', head: true }),
    supabase.from('newsletter_subscribers').select('email,created_at').order('created_at', { ascending: false }).limit(8),
  ])
  counts.value = {
    subscribers: subs ?? 0,
    photos:      photos ?? 0,
    regions:     regions ?? 0,
    shows:       shows ?? 0,
    news:        news ?? 0,
    merch:       merch ?? 0,
  }
  recentSubs.value = (subsList as { email: string; created_at: string }[]) ?? []
  loading.value = false
}

onMounted(async () => {
  const { data } = await supabase.auth.getSession()
  session.value = data.session
  supabase.auth.onAuthStateChange((_e, s) => { session.value = s })
  void loadStats()
})
</script>

<style lang="scss" scoped>
.login-banner {
  background: rgba(255,180,0,0.08);
  border: 1px solid rgba(255,180,0,0.25);
  color: #e0f2f1;
}
.stat-card {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.18);
  border-radius: 10px;
  transition: border-color 0.2s, transform 0.15s;
  &:hover { border-color: #4db6ac; transform: translateY(-2px); }
}
.stat-num   { font-size: 28px; font-weight: 900; line-height: 1; }
.stat-label { font-size: 10px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: rgba(255,255,255,0.4); margin-top: 4px; }

.section-card {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.15);
  border-radius: 12px;
  cursor: pointer;
  transition: border-color 0.2s, background 0.2s;
  &:hover { border-color: #4db6ac; background: #1e1e38; }
}

.recent-card { background: #1a1a2e; border: 1px solid rgba(77,182,172,0.15); border-radius: 12px; }
.ls-2 { letter-spacing: 2px; }
.gap-md { gap: 12px; }
</style>

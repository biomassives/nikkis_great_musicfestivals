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
      <q-btn flat icon="refresh" color="teal-3" @click="reload" :loading="loading" label="Refresh" size="sm" />
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

    <!-- ═══════════════════════════════════════════════════════════
         GROWTH & ACTIVITY
    ═══════════════════════════════════════════════════════════ -->
    <div class="q-mb-xl">
      <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-md">
        Growth & Activity
        <span class="text-caption text-grey-7 q-ml-xs" style="text-transform:none; letter-spacing:0; font-weight:400">
          — last 30 days
        </span>
      </div>

      <div class="row q-col-gutter-sm">

        <!-- Subscribers -->
        <div class="col-12 col-sm-6 col-md-3">
          <q-card class="growth-card">
            <q-card-section class="q-pa-md">
              <div class="row items-center q-mb-sm">
                <q-icon name="people" color="teal-4" size="16px" class="q-mr-xs" />
                <span class="growth-label text-teal-5">Subscribers</span>
              </div>
              <div v-if="growth.loading" class="growth-num text-grey-7">—</div>
              <div v-else class="growth-num text-teal-3">{{ growth.sub.total }}</div>
              <div class="row q-gutter-xs q-mt-sm">
                <q-badge color="teal-10" text-color="teal-3" style="font-size:9.5px">
                  +{{ growth.loading ? '…' : growth.sub.week }} this week
                </q-badge>
                <q-badge color="teal-10" text-color="teal-3" style="font-size:9.5px">
                  +{{ growth.loading ? '…' : growth.sub.month }} this month
                </q-badge>
              </div>
            </q-card-section>
          </q-card>
        </div>

        <!-- Content added -->
        <div class="col-12 col-sm-6 col-md-3">
          <q-card class="growth-card">
            <q-card-section class="q-pa-md">
              <div class="row items-center q-mb-sm">
                <q-icon name="edit_note" color="amber-4" size="16px" class="q-mr-xs" />
                <span class="growth-label text-amber-5">Content Added</span>
              </div>
              <div class="row q-gutter-md q-mt-xs">
                <div v-for="m in contentMetrics" :key="m.label" class="growth-mini">
                  <div class="growth-mini-num">{{ growth.loading ? '—' : m.value }}</div>
                  <div class="growth-mini-label">{{ m.label }}</div>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </div>

        <!-- Site changes (last 7 days) -->
        <div class="col-12 col-sm-6 col-md-3">
          <q-card class="growth-card">
            <q-card-section class="q-pa-md">
              <div class="row items-center q-mb-sm">
                <q-icon name="history" color="deep-purple-3" size="16px" class="q-mr-xs" />
                <span class="growth-label text-deep-purple-3">Site Changes</span>
              </div>
              <div v-if="growth.loading" class="growth-num text-grey-7">—</div>
              <div v-else class="growth-num text-deep-purple-3">{{ growth.changes }}</div>
              <div class="text-grey-7 q-mt-xs" style="font-size:10px">logged changes · last 7 days</div>
            </q-card-section>
          </q-card>
        </div>

        <!-- Traffic link -->
        <div class="col-12 col-sm-6 col-md-3">
          <a href="https://vercel.com/dashboard" target="_blank" rel="noopener noreferrer"
             class="no-decoration" style="display:block; height:100%">
            <q-card class="growth-card growth-card--link" style="height:100%">
              <q-card-section class="q-pa-md">
                <div class="row items-center q-mb-sm">
                  <q-icon name="bar_chart" color="light-blue-4" size="16px" class="q-mr-xs" />
                  <span class="growth-label text-light-blue-4">Traffic</span>
                  <q-space />
                  <q-icon name="open_in_new" color="grey-7" size="11px" />
                </div>
                <div class="text-grey-5" style="font-size:11px; line-height:1.55">
                  View page views &amp; visitors on the Vercel dashboard.
                </div>
                <div class="text-grey-8 q-mt-sm" style="font-size:10px">
                  Enable: Vercel → Project → Analytics tab
                </div>
              </q-card-section>
            </q-card>
          </a>
        </div>

      </div>
    </div>

    <!-- ── Row 1: Content ─────────────────────────────────────── -->
    <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-md">Publish Content</div>
    <div class="row q-col-gutter-lg q-mb-xl">
      <div class="col-12 col-sm-6 col-lg-4" v-for="section in contentSections" :key="section.route">
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

    <!-- ── Row 2: Pages & Design ───────────────────────────── -->
    <div class="text-subtitle2 text-amber-4 text-uppercase ls-2 q-mb-md">Pages &amp; Design</div>
    <div class="row q-col-gutter-lg q-mb-xl">
      <div class="col-12 col-sm-6 col-lg-4" v-for="section in pageSections" :key="section.route">
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

    <!-- ── Row 3: Automation & Settings ───────────────────── -->
    <div class="text-subtitle2 text-light-blue-4 text-uppercase ls-2 q-mb-md">Automation &amp; Settings</div>
    <div class="row q-col-gutter-lg q-mb-xl">
      <div class="col-12 col-sm-6 col-lg-4" v-for="section in automationSections" :key="section.route">
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
      <!-- Analytics — external link -->
      <div class="col-12 col-sm-6 col-lg-4">
        <a href="https://vercel.com/dashboard" target="_blank" rel="noopener noreferrer" class="no-decoration" style="display:block">
          <q-card class="section-card">
            <q-card-section class="row items-center q-pa-lg gap-md">
              <q-icon name="insights" color="deep-orange-4" size="36px" class="q-mr-md" />
              <div class="col">
                <div class="text-h6 text-white text-weight-bold">Analytics</div>
                <div class="text-caption text-grey-5">Traffic, visitors &amp; page views on Vercel</div>
              </div>
              <q-icon name="open_in_new" color="grey-6" size="18px" />
            </q-card-section>
          </q-card>
        </a>
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

    <!-- ═══════════════════════════════════════════════════════════
         SITE CHANGELOG
    ═══════════════════════════════════════════════════════════ -->
    <div class="q-mt-xl q-pb-xl">

      <!-- Section header -->
      <div class="row items-center no-wrap q-mb-md">
        <div class="text-subtitle2 text-teal-4 text-uppercase ls-2">
          Site Changelog
          <q-badge v-if="!changelogLoading && changelogEntries.length"
            color="grey-8" text-color="grey-4" class="q-ml-sm"
            style="font-size:9px; vertical-align:middle; border-radius:6px">
            {{ changelogEntries.length }}
          </q-badge>
        </div>
        <q-space />
        <q-btn flat dense size="xs" label="Expand All"   color="teal-5"  class="q-mr-xs" @click="expandAll" />
        <q-btn flat dense size="xs" label="Collapse All" color="grey-6"  class="q-mr-sm" @click="collapseAll" />
        <q-btn v-if="session" flat dense size="xs" icon="add" label="Add Entry"
          color="teal-3" @click="openAddDialog" />
      </div>

      <!-- Loading -->
      <div v-if="changelogLoading" class="text-center q-pa-xl">
        <q-spinner-dots color="teal-5" size="28px" />
      </div>

      <!-- Groups -->
      <template v-else>
        <q-card
          v-for="group in changelogGroups" :key="group.dateKey"
          class="changelog-group q-mb-sm"
        >
          <!-- Group header row -->
          <div
            class="changelog-group-hdr row items-center no-wrap q-px-md cursor-pointer"
            @click="toggleGroup(group.dateKey)"
          >
            <q-icon
              :name="openGroups[group.dateKey] ? 'expand_more' : 'chevron_right'"
              size="18px" color="teal-5" class="q-mr-xs"
              style="transition: transform 0.2s"
            />
            <span class="text-grey-3 text-weight-bold" style="font-size:12.5px">{{ group.label }}</span>
            <q-badge color="grey-9" text-color="grey-5" class="q-ml-sm" style="font-size:9px; border-radius:5px">
              {{ group.entries.length }}
            </q-badge>
            <q-space />
            <div class="row q-gutter-xs items-center">
              <q-badge
                v-for="cat in uniqueCategories(group.entries)" :key="cat"
                :color="CAT[cat]?.bg ?? 'grey-9'"
                :text-color="CAT[cat]?.text ?? 'grey-4'"
                style="font-size:8px; padding:1px 5px; border-radius:4px; opacity:0.9"
              >{{ cat }}</q-badge>
            </div>
          </div>

          <!-- Entry list -->
          <q-slide-transition>
            <div v-show="openGroups[group.dateKey]">
              <q-separator dark style="opacity:0.1" />
              <q-list dense dark style="background:transparent">
                <q-item
                  v-for="entry in group.entries" :key="entry.id"
                  class="changelog-entry q-py-xs"
                  clickable v-ripple
                  @click="toggleEntry(entry.id)"
                >
                  <!-- Category icon -->
                  <q-item-section avatar style="min-width:26px; padding-right:10px">
                    <q-icon
                      :name="CAT[entry.category]?.icon ?? 'circle'"
                      :color="CAT[entry.category]?.bg ?? 'grey-6'"
                      size="14px"
                    />
                  </q-item-section>

                  <!-- Summary + expandable body -->
                  <q-item-section>
                    <q-item-label class="text-grey-3 changelog-summary">
                      {{ entry.summary }}
                    </q-item-label>
                    <q-slide-transition>
                      <div v-if="openEntries[entry.id]" class="q-mt-xs">
                        <q-item-label
                          v-if="entry.description"
                          caption class="changelog-desc text-grey-5"
                        >{{ entry.description }}</q-item-label>
                        <div v-if="entry.tags?.length" class="q-mt-xs row q-gutter-xs">
                          <q-badge
                            v-for="t in entry.tags" :key="t"
                            color="grey-9" text-color="teal-3"
                            style="font-size:8px; border-radius:4px"
                          >{{ t }}</q-badge>
                        </div>
                        <q-btn v-if="session"
                          flat round dense icon="delete" color="red-4" size="xs"
                          class="q-mt-xs" style="opacity:0.6"
                          @click.stop="deleteEntry(entry.id)"
                          title="Delete entry"
                        />
                      </div>
                    </q-slide-transition>
                  </q-item-section>

                  <!-- Time + author -->
                  <q-item-section side style="min-width:64px; align-items:flex-end">
                    <div class="text-grey-7" style="font-size:9.5px; white-space:nowrap">
                      {{ fmtTime(entry.created_at) }}
                    </div>
                    <div v-if="entry.author" class="text-grey-8" style="font-size:9px">
                      {{ entry.author }}
                    </div>
                    <q-icon
                      :name="openEntries[entry.id] ? 'unfold_less' : 'unfold_more'"
                      color="grey-8" size="11px" class="q-mt-xs"
                      v-if="entry.description || entry.tags?.length"
                    />
                  </q-item-section>
                </q-item>
              </q-list>
            </div>
          </q-slide-transition>
        </q-card>

        <div v-if="changelogGroups.length === 0"
          class="text-grey-7 text-caption text-center q-pa-xl recent-card"
          style="border-radius:12px">
          No changelog entries yet.
          <span v-if="session" class="text-teal-5 cursor-pointer q-ml-xs" @click="openAddDialog">
            Add the first entry.
          </span>
        </div>
      </template>
    </div>

  </q-page>

  <!-- ── Add Entry dialog ─────────────────────────────────────────────────── -->
  <q-dialog v-model="addDialog.open" persistent>
    <q-card class="add-dialog-card">
      <q-card-section class="row items-center q-pb-sm">
        <q-icon name="add_circle" color="teal-4" size="22px" class="q-mr-sm" />
        <div class="text-subtitle1 text-teal-3 text-weight-bold">Add Changelog Entry</div>
      </q-card-section>
      <q-separator dark style="opacity:0.18" />
      <q-card-section class="q-gutter-sm q-pt-md">
        <q-select
          v-model="addForm.category"
          :options="CATEGORY_OPTIONS"
          option-value="value" option-label="label"
          emit-value map-options
          label="Category"
          dark outlined dense label-color="teal-3" color="teal-3"
        >
          <template #option="scope">
            <q-item v-bind="scope.itemProps">
              <q-item-section avatar style="min-width:28px">
                <q-icon :name="scope.opt.icon" :color="CAT[scope.opt.value]?.bg ?? 'grey-5'" size="16px" />
              </q-item-section>
              <q-item-section>
                <q-item-label>{{ scope.opt.label }}</q-item-label>
              </q-item-section>
            </q-item>
          </template>
        </q-select>
        <q-input
          v-model="addForm.summary" label="Summary"
          placeholder="One-line description of the change"
          dark outlined dense label-color="teal-3" color="teal-3"
        />
        <q-input
          v-model="addForm.description" label="Details (optional)"
          placeholder="Context, links, technical notes…"
          dark outlined dense label-color="teal-3" color="teal-3"
          type="textarea" :rows="3" autogrow
        />
        <q-input
          v-model="addForm.author" label="Author (optional)"
          dark outlined dense label-color="teal-3" color="teal-3"
        />
      </q-card-section>
      <q-card-actions align="right" class="q-pt-none q-pb-md q-pr-md">
        <q-btn flat label="Cancel" color="grey-5" v-close-popup />
        <q-btn unelevated label="Save Entry" color="teal" icon="save"
          :loading="addDialog.saving"
          :disable="!addForm.summary.trim()"
          @click="saveEntry"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { Session } from '@supabase/supabase-js'
import type { ChangelogEntry } from 'src/lib/supabase'

const loading    = ref(true)
const session    = ref<Session | null>(null)
const recentSubs = ref<{ email: string; created_at: string }[]>([])
const counts = ref({ subscribers: 0, photos: 0, regions: 0, shows: 0, news: 0, merch: 0 })

const today = new Date().toLocaleDateString('en-US', { weekday:'long', month:'long', day:'numeric', year:'numeric' })

const stats = [
  { label: 'Subscribers', icon: 'mail',          color: 'teal-4',        route: '/admin/newsletter', get value() { return counts.value.subscribers } },
  { label: 'Photos',      icon: 'photo_library',  color: 'amber-4',       route: '/admin/gallery',    get value() { return counts.value.photos } },
  { label: 'Regions',     icon: 'map',            color: 'light-blue-4',  route: '/admin/maps',       get value() { return counts.value.regions } },
  { label: 'Shows',       icon: 'event',          color: 'deep-purple-3', route: '/admin/maps',       get value() { return counts.value.shows } },
  { label: 'Blog',        icon: 'newspaper',      color: 'green-4',       route: '/admin/blog',       get value() { return counts.value.news } },
  { label: 'Merch',       icon: 'style',          color: 'pink-4',        route: '/admin/merch',      get value() { return counts.value.merch } },
]

const contentSections = [
  { title: 'Festival Maps',         icon: 'explore',        color: 'teal-4',        route: '/admin/maps',       desc: 'Add shows, senior stops, and nature spots to the tour map' },
  { title: 'Photo Gallery',         icon: 'photo_library',  color: 'amber-4',       route: '/admin/gallery',    desc: 'Upload and organise photos by category' },
  { title: 'Blog & Updates',        icon: 'newspaper',      color: 'green-4',       route: '/admin/blog',       desc: 'Write tour stories, recaps, and community posts' },
  { title: 'Merch & Goods',         icon: 'style',          color: 'pink-4',        route: '/admin/merch',      desc: 'Manage art prints, apparel, and other items' },
  { title: 'Archive Collections',   icon: 'library_music',  color: 'deep-purple-3', route: '/admin/archive',    desc: 'Curated archive.org listening rooms, organized by theme and region' },
]

const pageSections = [
  { title: 'Homepage',           icon: 'home',              color: 'teal-3',        route: '/admin/home',       desc: 'Hero, artists, welcome overlay, background, and SEO' },
  { title: 'Our Story',          icon: 'auto_stories',      color: 'deep-purple-3', route: '/admin/story',      desc: 'Full-screen story overlay text and image' },
  { title: 'Support & Funding',  icon: 'favorite',          color: 'red-4',         route: '/admin/support',    desc: 'Membership tiers, Kickstarter goal, and sponsor options' },
  { title: 'Navigation',         icon: 'menu',              color: 'purple-3',       route: '/admin/nav',       desc: 'Rename links, add sub-pages, or reorder the nav' },
  { title: 'Custom Pages',       icon: 'web',               color: 'deep-orange-3', route: '/admin/pages',      desc: 'Build pages with images, video, embeds, and media links' },
]

const automationSections = [
  { title: 'Newsletter & Email', icon: 'mark_email_unread', color: 'light-blue-4',  route: '/admin/newsletter', desc: 'Compose campaigns, view subscribers, and send test emails' },
  { title: 'Artist Profiles',    icon: 'queue_music',       color: 'cyan-4',        route: '/admin/home',       desc: 'Manage the featured artists shown on the homepage grid' },
  { title: 'Site Appearance',    icon: 'tune',              color: 'indigo-3',      route: '/admin/home',       desc: 'Background image, spirograph colors, SEO, and social meta' },
]

function fmtDate(d: string) {
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}
function fmtTime(d: string) {
  return new Date(d).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
}

// ── Growth & Activity ─────────────────────────────────────────────────────────

const growth = reactive({
  loading: true,
  sub:     { total: 0, week: 0, month: 0 },
  content: { news: 0, photos: 0, merch: 0, newsletters: 0 },
  changes: 0,
})

const contentMetrics = computed(() => [
  { label: 'blog',        value: growth.content.news        },
  { label: 'photos',      value: growth.content.photos      },
  { label: 'merch',       value: growth.content.merch       },
  { label: 'newsletters', value: growth.content.newsletters },
])

async function loadGrowth() {
  growth.loading = true
  const weekAgo  = new Date(Date.now() -  7 * 86400000).toISOString()
  const monthAgo = new Date(Date.now() - 30 * 86400000).toISOString()

  const [subTotal, subWeek, subMonth, news, photos, merch, newsletters, changes] = await Promise.all([
    supabase.from('newsletter_subscribers').select('*', { count: 'exact', head: true }),
    supabase.from('newsletter_subscribers').select('*', { count: 'exact', head: true }).gte('created_at', weekAgo),
    supabase.from('newsletter_subscribers').select('*', { count: 'exact', head: true }).gte('created_at', monthAgo),
    supabase.from('news_articles')  .select('*', { count: 'exact', head: true }).gte('created_at', monthAgo),
    supabase.from('gallery_photos') .select('*', { count: 'exact', head: true }).gte('created_at', monthAgo),
    supabase.from('merch_items')    .select('*', { count: 'exact', head: true }).gte('created_at', monthAgo),
    supabase.from('newsletters')    .select('*', { count: 'exact', head: true }).gte('created_at', monthAgo),
    supabase.from('site_changelog') .select('*', { count: 'exact', head: true }).gte('created_at', weekAgo),
  ])

  growth.sub     = { total: subTotal.count ?? 0, week: subWeek.count ?? 0, month: subMonth.count ?? 0 }
  growth.content = { news: news.count ?? 0, photos: photos.count ?? 0, merch: merch.count ?? 0, newsletters: newsletters.count ?? 0 }
  growth.changes = changes.count ?? 0
  growth.loading = false
}

// ── Changelog ─────────────────────────────────────────────────────────────────

interface ChangelogGroup {
  label: string
  dateKey: string
  entries: ChangelogEntry[]
}

const CAT: Record<string, { bg: string; text: string; icon: string }> = {
  code:    { bg: 'deep-purple-3', text: 'white',  icon: 'code'          },
  design:  { bg: 'amber-4',       text: 'black',  icon: 'palette'       },
  content: { bg: 'teal-4',        text: 'white',  icon: 'edit_note'     },
  data:    { bg: 'light-blue-4',  text: 'black',  icon: 'storage'       },
  db:      { bg: 'cyan-5',        text: 'black',  icon: 'dns'           },
  media:   { bg: 'pink-4',        text: 'white',  icon: 'photo_library' },
  fix:     { bg: 'red-4',         text: 'white',  icon: 'build'         },
  other:   { bg: 'grey-7',        text: 'white',  icon: 'more_horiz'    },
}

const CATEGORY_OPTIONS = Object.entries(CAT).map(([value, m]) => ({
  value,
  label: value.charAt(0).toUpperCase() + value.slice(1),
  icon: m.icon,
}))

const changelogLoading = ref(true)
const changelogEntries = ref<ChangelogEntry[]>([])
const openGroups       = reactive<Record<string, boolean>>({})
const openEntries      = reactive<Record<string, boolean>>({})

const changelogGroups = computed<ChangelogGroup[]>(() => {
  const now       = new Date(); now.setHours(0, 0, 0, 0)
  const yesterday = new Date(now); yesterday.setDate(yesterday.getDate() - 1)
  const map       = new Map<string, ChangelogGroup>()

  for (const e of changelogEntries.value) {
    const d = new Date(e.created_at); d.setHours(0, 0, 0, 0)
    const key = d.toISOString().slice(0, 10)
    if (!map.has(key)) {
      const t = d.getTime()
      const label = t === now.getTime()       ? 'Today'
                  : t === yesterday.getTime() ? 'Yesterday'
                  : d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' })
      map.set(key, { label, dateKey: key, entries: [] })
    }
    map.get(key)!.entries.push(e)
  }
  return [...map.values()].sort((a, b) => b.dateKey.localeCompare(a.dateKey))
})

function toggleGroup(key: string) { openGroups[key] = !openGroups[key] }
function toggleEntry(id: string)  { openEntries[id]  = !openEntries[id] }

function expandAll() {
  for (const g of changelogGroups.value) openGroups[g.dateKey] = true
}
function collapseAll() {
  for (const k of Object.keys(openGroups))  delete openGroups[k]
  for (const k of Object.keys(openEntries)) delete openEntries[k]
}

function uniqueCategories(entries: ChangelogEntry[]): string[] {
  return [...new Set(entries.map(e => e.category))]
}

async function loadChangelog() {
  changelogLoading.value = true
  const { data } = await supabase
    .from('site_changelog')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(200)
  changelogEntries.value = (data ?? []) as ChangelogEntry[]
  // Auto-open the most recent group
  if (changelogGroups.value.length > 0) {
    openGroups[changelogGroups.value[0]!.dateKey] = true
  }
  changelogLoading.value = false
}

// ── Add / delete dialog ────────────────────────────────────────────────────────

const addDialog = reactive({ open: false, saving: false })
const addForm   = reactive({ category: 'code', summary: '', description: '', author: '' })

function openAddDialog() {
  Object.assign(addForm, { category: 'code', summary: '', description: '', author: '' })
  addDialog.open = true
}

async function saveEntry() {
  if (!addForm.summary.trim()) return
  addDialog.saving = true
  const { data } = await supabase.from('site_changelog').insert({
    category:    addForm.category,
    summary:     addForm.summary.trim(),
    description: addForm.description.trim() || null,
    author:      addForm.author.trim()      || null,
    tags:        [],
  }).select().single()
  if (data) {
    changelogEntries.value.unshift(data as ChangelogEntry)
    // Open the group this new entry lands in
    const key = new Date(data.created_at).toISOString().slice(0, 10)
    openGroups[key] = true
  }
  addDialog.saving = false
  addDialog.open   = false
}

async function deleteEntry(id: string) {
  await supabase.from('site_changelog').delete().eq('id', id)
  changelogEntries.value = changelogEntries.value.filter(e => e.id !== id)
  delete openEntries[id]
}

// ── Data loading ───────────────────────────────────────────────────────────────

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
    supabase.from('map_points').select('*',              { count: 'exact', head: true }).eq('category', 'show'),
    supabase.from('news_articles').select('*',           { count: 'exact', head: true }),
    supabase.from('merch_items').select('*',             { count: 'exact', head: true }),
    supabase.from('newsletter_subscribers').select('email,created_at').order('created_at', { ascending: false }).limit(8),
  ])
  counts.value = {
    subscribers: subs   ?? 0,
    photos:      photos ?? 0,
    regions:     regions ?? 0,
    shows:       shows  ?? 0,
    news:        news   ?? 0,
    merch:       merch  ?? 0,
  }
  recentSubs.value = (subsList as { email: string; created_at: string }[]) ?? []
  loading.value = false
}

function reload() {
  void loadStats()
  void loadGrowth()
  void loadChangelog()
}

onMounted(async () => {
  const { data } = await supabase.auth.getSession()
  session.value = data.session
  supabase.auth.onAuthStateChange((_e, s) => { session.value = s })
  void loadStats()
  void loadGrowth()
  void loadChangelog()
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

// ── Growth & Activity ─────────────────────────────────────────────────────────
.growth-card {
  background: #161625;
  border: 1px solid rgba(77,182,172,0.12);
  border-radius: 10px;
  height: 100%;
  &--link { transition: border-color 0.2s, background 0.2s; &:hover { border-color: rgba(77,182,172,0.28); background: #1a1a2e; } }
}
.growth-label { font-size: 10px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; }
.growth-num   { font-size: 26px; font-weight: 900; line-height: 1; }
.growth-mini  { text-align: center; min-width: 40px; }
.growth-mini-num   { font-size: 18px; font-weight: 900; line-height: 1; color: #e0f2f1; }
.growth-mini-label { font-size: 9px; font-weight: 700; letter-spacing: 0.5px; text-transform: uppercase; color: rgba(255,255,255,0.3); margin-top: 2px; }
.no-decoration { text-decoration: none; }

// ── Changelog ─────────────────────────────────────────────────────────────────
.changelog-group {
  background: #161625;
  border: 1px solid rgba(77,182,172,0.12);
  border-radius: 10px;
  overflow: hidden;
}
.changelog-group-hdr {
  height: 42px;
  background: rgba(77,182,172,0.03);
  user-select: none;
  transition: background 0.15s;
  &:hover { background: rgba(77,182,172,0.07); }
}
.changelog-entry {
  border-bottom: 1px solid rgba(255,255,255,0.04);
  transition: background 0.12s;
  &:last-child { border-bottom: none; }
  &:hover { background: rgba(77,182,172,0.05); }
}
.changelog-summary {
  font-size: 12.5px;
  line-height: 1.45;
}
.changelog-desc {
  white-space: pre-wrap !important;
  font-size: 11.5px !important;
  line-height: 1.65 !important;
  color: rgba(255,255,255,0.5) !important;
}

.add-dialog-card {
  min-width: 440px;
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.25);
  border-radius: 14px;
  @media (max-width: 480px) { min-width: 90vw; }
}
</style>

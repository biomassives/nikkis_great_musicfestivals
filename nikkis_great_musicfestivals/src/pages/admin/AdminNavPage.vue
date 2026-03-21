<template>
  <q-page class="q-pa-lg">
    <div class="row items-center q-mb-lg">
      <div>
        <div class="text-h5 text-purple-3">Navigation Manager</div>
        <div class="text-caption text-grey-5">Rename links, reorder, add sub-pages, or add entirely new pages</div>
      </div>
      <q-space />
      <q-btn color="purple-5" unelevated icon="save" label="Save" :loading="saving" @click="save" />
    </div>

    <q-banner v-if="saved" rounded class="save-banner q-mb-lg">
      <template #avatar><q-icon name="check_circle" color="teal-4" /></template>
      Navigation saved — changes are live on the site immediately.
    </q-banner>

    <!-- Nav items -->
    <div v-for="(item, i) in items" :key="i" class="nav-card q-mb-md">

      <!-- ── Top row: reorder + main fields ─────────────────── -->
      <div class="nav-card-header">
        <div class="reorder-col">
          <q-btn flat dense round icon="arrow_upward"   color="grey-6" size="xs"
            :disable="i === 0"              @click="moveItem(i, -1)" />
          <q-btn flat dense round icon="arrow_downward" color="grey-6" size="xs"
            :disable="i === items.length-1" @click="moveItem(i,  1)" />
        </div>

        <q-icon :name="item.icon || 'link'" size="22px" class="item-icon-preview" :style="`color:${item.color}`" />

        <div class="col">
          <q-input v-model="item.title" label="Label" dark outlined dense
            label-color="purple-3" color="purple-3" />
        </div>

        <div class="col">
          <q-input v-model="item.link" label="Path (e.g. /maps)" dark outlined dense
            label-color="purple-3" color="purple-3" />
        </div>

        <div style="min-width:130px">
          <q-input v-model="item.icon" label="Icon" dark outlined dense
            label-color="purple-3" color="purple-3">
            <template #prepend>
              <q-icon :name="item.icon || 'link'" size="16px" />
            </template>
          </q-input>
        </div>

        <div class="row items-center q-gutter-xs">
          <input type="color" v-model="item.color" class="color-picker" title="Accent colour" />
          <span class="color-hex text-caption text-grey-6">{{ item.color }}</span>
        </div>

        <q-btn flat round dense icon="delete" color="red-4" size="sm" @click="removeItem(i)"
          title="Remove nav item" />
      </div>

      <!-- ── Sub-pages ────────────────────────────────────────── -->
      <div class="sub-pages-wrap">
        <div class="row items-center q-mb-xs">
          <span class="text-caption text-purple-5 text-uppercase sub-label">Sub-pages</span>
          <q-btn icon="add" flat dense size="xs" color="purple-5" @click="addChild(i)"
            title="Add sub-page" class="q-ml-xs" />
        </div>

        <div v-if="!item.children.length" class="text-caption text-grey-7 q-mb-xs">
          None — click + to add dropdown sub-pages under this link.
        </div>

        <div v-for="(child, ci) in item.children" :key="ci"
          class="row items-center q-gutter-sm q-mb-xs">
          <div class="col">
            <q-input v-model="child.title" :label="`Sub-page ${ci+1} label`" dark outlined dense
              label-color="grey-5" color="grey-5" />
          </div>
          <div class="col">
            <q-input v-model="child.link" label="Path" dark outlined dense
              label-color="grey-5" color="grey-5" />
          </div>
          <q-btn flat round dense icon="arrow_upward"   color="grey-6" size="xs"
            :disable="ci === 0"                       @click="moveChild(i, ci, -1)" />
          <q-btn flat round dense icon="arrow_downward" color="grey-6" size="xs"
            :disable="ci === item.children.length - 1" @click="moveChild(i, ci,  1)" />
          <q-btn flat round dense icon="close" color="red-4" size="xs"
            @click="removeChild(i, ci)" />
        </div>
      </div>

    </div>

    <q-btn icon="add" label="Add Nav Item" color="purple-8" outline class="q-mt-xs q-mb-xl" @click="addItem" />

    <div class="text-caption text-grey-6 q-mb-xl">
      <q-icon name="info" size="14px" class="q-mr-xs" />
      Sub-pages appear as indented links in the flyout menu beneath their parent.
      Top-level links appear in both the flyout and the desktop header bar.
      New routes also need to be added to <code>src/router/routes.ts</code> and a page component created.
    </div>

    <div class="row justify-end q-mb-xl">
      <q-btn color="purple-5" unelevated icon="save" label="Save Navigation" :loading="saving" @click="save" />
    </div>

  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'

const saving = ref(false)
const saved  = ref(false)

interface NavChild { title: string; link: string }
interface NavItem  { title: string; icon: string; link: string; color: string; children: NavChild[] }

const DEFAULT_ITEMS: NavItem[] = [
  { title: 'Home',        icon: 'auto_awesome', link: '/',            color: '#ffd600', children: [] },
  { title: 'Photography', icon: 'camera',       link: '/photography', color: '#ff6d00', children: [] },
  { title: 'Maps',        icon: 'explore',      link: '/maps',        color: '#00e676', children: [] },
  { title: 'Support',     icon: 'favorite',     link: '/support',     color: '#ff4081', children: [] },
  { title: 'Merch',       icon: 'style',        link: '/merch',       color: '#ce93d8', children: [] },
  { title: 'News',        icon: 'forum',        link: '/news',        color: '#00b0ff', children: [] },
]

const items = ref<NavItem[]>(DEFAULT_ITEMS.map(i => ({ ...i, children: [] })))

function addItem() {
  items.value.push({ title: 'New Page', icon: 'link', link: '/new-page', color: '#4db6ac', children: [] })
}

function removeItem(i: number) { items.value.splice(i, 1) }

function moveItem(i: number, dir: -1 | 1) {
  const arr = [...items.value]
  const tmp = arr[i]!; arr[i] = arr[i + dir]!; arr[i + dir] = tmp
  items.value = arr
}

function addChild(i: number) {
  items.value[i]!.children.push({ title: '', link: '' })
}

function removeChild(i: number, ci: number) {
  items.value[i]!.children.splice(ci, 1)
}

function moveChild(i: number, ci: number, dir: -1 | 1) {
  const arr = [...items.value[i]!.children]
  const tmp = arr[ci]!; arr[ci] = arr[ci + dir]!; arr[ci + dir] = tmp
  items.value[i]!.children = arr
}

async function load() {
  const { data } = await supabase
    .from('site_settings').select('value')
    .eq('key', 'nav_config').limit(1)
  const row = data?.[0]
  if (Array.isArray(row?.value) && (row?.value as unknown[]).length) {
    items.value = (row?.value as NavItem[]).map(item => ({
      ...item,
      children: item.children ?? [],
    }))
  }
}

async function save() {
  saving.value = true
  saved.value  = false
  await supabase.from('site_settings').upsert({
    key:        'nav_config',
    value:      items.value,
    updated_at: new Date().toISOString(),
  })
  saving.value = false
  saved.value  = true
  setTimeout(() => { saved.value = false }, 3500)
}

onMounted(load)
</script>

<style lang="scss" scoped>
.nav-card {
  background: #1a1a2e;
  border: 1px solid rgba(179,157,219,0.2);
  border-radius: 12px;
  overflow: hidden;
  transition: border-color 0.2s;
  &:hover { border-color: rgba(179,157,219,0.45); }
}

.nav-card-header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 14px;
  flex-wrap: wrap;
}

.reorder-col {
  display: flex;
  flex-direction: column;
  gap: 0;
  flex-shrink: 0;
}

.item-icon-preview { flex-shrink: 0; }

.sub-pages-wrap {
  padding: 10px 14px 14px;
  background: rgba(179,157,219,0.04);
  border-top: 1px solid rgba(179,157,219,0.1);
}

.sub-label {
  font-size: 9px; font-weight: 800; letter-spacing: 2px;
}

.color-picker {
  width: 32px; height: 32px; border: none; padding: 0;
  border-radius: 6px; cursor: pointer; background: none; flex-shrink: 0;
}
.color-hex { font-size: 10px; }

.save-banner { background: rgba(77,182,172,0.1); border: 1px solid rgba(77,182,172,0.3); color: #e0f2f1; }

code {
  background: rgba(255,255,255,0.08);
  padding: 1px 5px; border-radius: 3px;
  font-size: 11px; color: #b39ddb;
}
</style>

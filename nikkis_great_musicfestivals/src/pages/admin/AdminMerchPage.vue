<template>
  <q-page class="q-pa-lg">
    <div class="row items-center q-mb-md">
      <div>
        <div class="text-h5 text-teal-3 q-mb-xs">Merch Manager</div>
        <div class="text-caption text-grey-5">Manage art, photos, and other goods</div>
      </div>
      <q-space />
      <q-btn color="teal" icon="add" label="Add Item" unelevated @click="resetForm" />
    </div>

    <!-- Sections Manager -->
    <q-expansion-item
      icon="tune"
      label="Manage Sections"
      class="section-mgr q-mb-md rounded-borders"
      header-class="section-mgr-header"
    >
      <q-card class="section-mgr-card">
        <q-card-section>
          <div class="row items-center q-mb-sm">
            <div class="text-caption text-grey-5 col">Sections appear as tabs on the public merch page</div>
            <q-btn icon="add" label="Add Section" color="teal-7" outline size="sm" @click="openAddSection" />
          </div>
          <q-list separator dark style="background:transparent">
            <q-item v-for="(sec, i) in sections" :key="sec.slug" dense class="q-py-sm">
              <q-item-section avatar>
                <q-icon :name="sec.icon" :color="sec.color" size="20px" />
              </q-item-section>
              <q-item-section>
                <q-item-label class="text-grey-2 text-weight-medium">{{ sec.label }}</q-item-label>
                <q-item-label caption class="text-grey-6">{{ sec.description }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <div class="row q-gutter-xs">
                  <q-btn flat dense round icon="edit" color="teal-4" size="sm" @click="openEditSection(i)" />
                  <q-btn flat dense round icon="delete" color="red-4" size="sm"
                    @click="removeSection(i)" :disable="sections.length <= 1" />
                </div>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>
      </q-card>
    </q-expansion-item>

    <!-- Category tabs -->
    <q-tabs v-model="tab" dense align="left" active-color="teal-3" indicator-color="teal-3" class="q-mb-lg">
      <q-tab name="all" icon="apps" label="All" />
      <q-tab v-for="sec in sections" :key="sec.slug" :name="sec.slug" :icon="sec.icon" :label="sec.label" />
    </q-tabs>

    <div class="row q-col-gutter-xl">

      <!-- Item grid -->
      <div class="col-12 col-md-7">
        <div v-if="loading" class="flex flex-center q-py-xl">
          <q-spinner-orbit color="teal" size="40px" />
        </div>
        <div v-else-if="filteredItems.length === 0" class="text-grey-6 text-center q-py-xl">
          No items in this section yet
        </div>
        <div v-else class="admin-merch-grid">
          <div
            v-for="item in filteredItems"
            :key="item.id"
            :class="['merch-thumb', { 'merch-thumb--active': editingId === item.id, 'merch-thumb--draft': !item.published }]"
            @click="openEdit(item)"
          >
            <img
              :src="item.image_url ?? `https://picsum.photos/seed/${item.id}/200/200`"
              class="merch-thumb-img"
              :alt="item.name"
            />
            <div class="merch-thumb-overlay">
              <div class="text-caption text-white text-weight-bold q-px-xs ellipsis" style="max-width:140px">
                {{ item.name }}
              </div>
              <div class="text-caption text-teal-3">{{ item.price ?? '—' }}</div>
              <div class="row q-gutter-xs q-mt-xs">
                <q-badge v-if="item.badge"     color="amber-8" :label="item.badge" />
                <q-badge v-if="item.sold_out"  color="grey-7"  label="Sold Out" />
              </div>
              <q-btn flat round dense icon="delete" color="red-3" size="sm"
                class="q-mt-xs" @click.stop="deleteItem(item.id)" />
            </div>
            <q-badge v-if="!item.published" class="draft-badge" color="amber-8" text-color="black" label="DRAFT" />
          </div>
        </div>
      </div>

      <!-- Form -->
      <div class="col-12 col-md-5">
        <div class="merch-form-panel q-pa-lg rounded-borders">
          <div class="text-subtitle1 text-teal-2 q-mb-md">{{ editingId ? 'Edit Item' : 'Add New Item' }}</div>

          <q-form @submit="save" class="q-gutter-md">

            <q-select
              v-model="form.category"
              :options="categoryOptions"
              emit-value map-options
              label="Section *"
              dark outlined dense
              label-color="teal-3" color="teal-3"
              :rules="[v => !!v || 'Required']"
            />

            <q-input
              v-model="form.name"
              label="Name *"
              dark outlined dense
              label-color="teal-3" color="teal-3"
              :rules="[v => !!v || 'Required']"
            />

            <q-input
              v-model="form.description"
              type="textarea" :rows="3"
              label="Description"
              dark outlined
              label-color="teal-3" color="teal-3"
            />

            <div class="row q-col-gutter-md">
              <div class="col-6">
                <q-input v-model="form.price" label='Price (e.g. "$45")'
                  dark outlined dense label-color="teal-3" color="teal-3" />
              </div>
              <div class="col-6">
                <q-input v-model="form.badge" label='Badge (e.g. "New", "Limited")'
                  dark outlined dense label-color="teal-3" color="teal-3" />
              </div>
            </div>

            <div class="text-caption text-grey-5 q-mb-xs">Image</div>
            <div class="row q-col-gutter-sm items-start">
              <div class="col">
                <q-input v-model="form.image_url" placeholder="https://... or upload →"
                  dark outlined dense label-color="teal-3" color="teal-3" />
              </div>
              <div class="col-auto">
                <q-btn color="teal-8" icon="upload" unelevated dense @click="triggerUpload" :loading="uploading" />
                <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="handleUpload" />
              </div>
            </div>
            <div v-if="form.image_url" class="q-mt-xs">
              <img :src="form.image_url" style="max-height:110px;border-radius:8px;max-width:100%;" />
            </div>

            <div class="row q-gutter-lg">
              <q-toggle v-model="form.sold_out"  label="Sold Out"          color="red"    dark />
              <q-toggle v-model="form.published" label="Published"         color="teal-3" dark />
            </div>
            <div class="text-caption text-grey-6">Unpublished items are staged — visible only in admin</div>

            <div class="row q-gutter-sm q-mt-sm">
              <q-btn type="submit" :label="editingId ? 'Update Item' : 'Add Item'" color="teal" unelevated :loading="saving" />
              <q-btn v-if="editingId" flat label="New" @click="resetForm" />
            </div>

          </q-form>
        </div>
      </div>
    </div>

    <!-- Section Add / Edit Dialog -->
    <q-dialog v-model="sectionDialog.open" persistent>
      <q-card style="min-width:360px;background:#1a1a2e;border:1px solid rgba(77,182,172,0.3)">
        <q-card-section>
          <div class="text-h6 text-teal-3">{{ sectionDialog.isNew ? 'Add Section' : 'Edit Section' }}</div>
        </q-card-section>
        <q-card-section class="q-gutter-md">
          <q-input v-model="sectionForm.label" label="Section label *" dark outlined dense
            label-color="teal-3" color="teal-3" @update:model-value="autoSlug" />
          <q-input v-model="sectionForm.slug" label="Slug (category key)"
            dark outlined dense label-color="teal-3" color="teal-3"
            :readonly="!sectionDialog.isNew"
            :hint="sectionDialog.isNew
              ? 'Auto-generated from label, editable'
              : 'Cannot be changed after creation (would unlink existing items)'" />
          <q-input v-model="sectionForm.description" label="Description (shown on public site)"
            dark outlined dense label-color="teal-3" color="teal-3" />
          <q-input v-model="sectionForm.icon" label="Material icon (e.g. palette, photo_camera, star)"
            dark outlined dense label-color="teal-3" color="teal-3" />
          <q-select v-model="sectionForm.color" :options="colorOptions" emit-value map-options
            label="Accent color" dark outlined dense label-color="teal-3" color="teal-3" />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Save" color="teal" :loading="savingSection" @click="saveSection"
            :disable="!sectionForm.slug || !sectionForm.label" />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { MerchItem, MerchSection } from 'src/lib/supabase'

const DEFAULT_SECTIONS: MerchSection[] = [
  { slug: 'art',    label: 'Art We Make', description: 'Original paintings, prints, and handcrafted pieces created during the tour',  icon: 'palette',      color: 'deep-purple' },
  { slug: 'photos', label: 'Photos',      description: 'Limited-edition festival prints, framed and fine art options available',       icon: 'photo_camera', color: 'amber-8'     },
  { slug: 'other',  label: 'Other Stuff', description: 'Trail finds, festival collectibles, and curated goods from the road',          icon: 'star',         color: 'deep-orange' },
]

const colorOptions = [
  { label: 'Teal',        value: 'teal-3'       },
  { label: 'Amber',       value: 'amber-8'      },
  { label: 'Green',       value: 'green-8'      },
  { label: 'Pink',        value: 'pink-8'       },
  { label: 'Deep Purple', value: 'deep-purple'  },
  { label: 'Blue',        value: 'blue-5'       },
  { label: 'Deep Orange', value: 'deep-orange'  },
  { label: 'Light Blue',  value: 'light-blue-4' },
  { label: 'Red',         value: 'red-5'        },
]

const sections      = ref<MerchSection[]>([...DEFAULT_SECTIONS])
const items         = ref<MerchItem[]>([])
const tab           = ref<string>('all')
const loading       = ref(true)
const saving        = ref(false)
const uploading     = ref(false)
const editingId     = ref<string | null>(null)
const fileInput     = ref<HTMLInputElement | null>(null)
const savingSection = ref(false)

const sectionDialog = ref({ open: false, isNew: true, editIndex: -1 })
const sectionForm   = ref<MerchSection>({ slug: '', label: '', description: '', icon: 'star', color: 'teal-3' })

const categoryOptions = computed(() =>
  sections.value.map(s => ({ label: s.label, value: s.slug }))
)

const filteredItems = computed(() =>
  tab.value === 'all' ? items.value : items.value.filter(i => i.category === tab.value)
)

const emptyForm = () => ({
  category:    sections.value[0]?.slug ?? '',
  name:        '',
  description: '',
  price:       '',
  image_url:   '',
  badge:       '',
  sold_out:    false,
  published:   true,
})
const form = reactive(emptyForm())

function resetForm() {
  editingId.value = null
  Object.assign(form, emptyForm())
}

function openEdit(item: MerchItem) {
  editingId.value = item.id
  Object.assign(form, {
    category:    item.category,
    name:        item.name,
    description: item.description ?? '',
    price:       item.price ?? '',
    image_url:   item.image_url ?? '',
    badge:       item.badge ?? '',
    sold_out:    item.sold_out,
    published:   item.published,
  })
}

async function save() {
  saving.value = true
  const payload = {
    category:    form.category,
    name:        form.name,
    description: form.description || null,
    price:       form.price || null,
    image_url:   form.image_url || null,
    badge:       form.badge || null,
    sold_out:    form.sold_out,
    published:   form.published,
    display_order: editingId.value
      ? (items.value.find(i => i.id === editingId.value)?.display_order ?? 0)
      : items.value.filter(i => i.category === form.category).length + 1,
  }
  if (editingId.value) {
    await supabase.from('merch_items').update(payload).eq('id', editingId.value)
  } else {
    await supabase.from('merch_items').insert(payload)
  }
  await load()
  resetForm()
  saving.value = false
}

async function deleteItem(id: string) {
  await supabase.from('merch_items').delete().eq('id', id)
  items.value = items.value.filter(i => i.id !== id)
}

function triggerUpload() { fileInput.value?.click() }

async function handleUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploading.value = true
  const ext  = file.name.split('.').pop()
  const path = `merch/${form.category}/${Date.now()}.${ext}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    form.image_url = data.publicUrl
  }
  uploading.value = false
}

// ── Section management ───────────────────────────────────────────────────────

function autoSlug(val: string | number | null) {
  if (sectionDialog.value.isNew) {
    sectionForm.value.slug = String(val).toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '')
  }
}

function openAddSection() {
  sectionDialog.value = { open: true, isNew: true, editIndex: -1 }
  sectionForm.value = { slug: '', label: '', description: '', icon: 'star', color: 'teal-3' }
}

function openEditSection(i: number) {
  sectionDialog.value = { open: true, isNew: false, editIndex: i }
  sectionForm.value = { ...sections.value[i]! }
}

async function saveSection() {
  savingSection.value = true
  const { isNew, editIndex } = sectionDialog.value
  const s = { ...sectionForm.value }
  if (isNew) {
    sections.value.push(s)
  } else {
    sections.value.splice(editIndex, 1, s)
  }
  await supabase.from('site_settings').upsert({
    key: 'merch_sections', value: sections.value, updated_at: new Date().toISOString(),
  })
  savingSection.value = false
  sectionDialog.value.open = false
}

async function removeSection(i: number) {
  sections.value.splice(i, 1)
  await supabase.from('site_settings').upsert({
    key: 'merch_sections', value: sections.value, updated_at: new Date().toISOString(),
  })
  if (tab.value !== 'all' && !sections.value.find(s => s.slug === tab.value)) {
    tab.value = 'all'
  }
}

// ── Data loading ─────────────────────────────────────────────────────────────

async function load() {
  const { data } = await supabase.from('merch_items').select('*').order('display_order')
  items.value = (data as MerchItem[]) ?? []
  loading.value = false
}

onMounted(async () => {
  const { data } = await supabase.from('site_settings').select('key,value').eq('key', 'merch_sections').maybeSingle()
  if (data?.value) sections.value = data.value as MerchSection[]
  Object.assign(form, emptyForm())
  void load()
})
</script>

<style lang="scss" scoped>
.section-mgr        { background: #1a1a2e; border: 1px solid rgba(77,182,172,0.2); }
.section-mgr-header { color: #b2dfdb !important; }
.section-mgr-card   { background: #14142a; }

.admin-merch-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
  gap: 10px;
}
.merch-thumb {
  position: relative; border-radius: 8px; overflow: hidden;
  aspect-ratio: 1; cursor: pointer;
  border: 2px solid transparent;
  transition: border-color 0.15s;
  &--active { border-color: #4db6ac; }
  &--draft  { opacity: 0.65; outline: 2px solid #ffa000; }
  &:hover .merch-thumb-overlay { opacity: 1; }
}
.merch-thumb-img { width: 100%; height: 100%; object-fit: cover; display: block; }
.merch-thumb-overlay {
  position: absolute; inset: 0;
  background: rgba(0,0,0,0.7);
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  padding: 8px; opacity: 0; transition: opacity 0.2s;
  text-align: center;
}
.draft-badge {
  position: absolute; top: 4px; left: 4px;
  font-size: 9px; letter-spacing: 1px;
}
.merch-form-panel {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.2);
}
.hidden { display: none; }
</style>

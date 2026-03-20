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

    <!-- Category tabs -->
    <q-tabs v-model="tab" dense align="left" active-color="teal-3" indicator-color="teal-3" class="q-mb-lg">
      <q-tab name="all"    icon="apps"         label="All" />
      <q-tab name="art"    icon="palette"      label="Art" />
      <q-tab name="photos" icon="photo_camera" label="Photos" />
      <q-tab name="other"  icon="star"         label="Other" />
    </q-tabs>

    <div class="row q-col-gutter-xl">

      <!-- Item grid -->
      <div class="col-12 col-md-7">
        <div v-if="loading" class="flex flex-center q-py-xl">
          <q-spinner-orbit color="teal" size="40px" />
        </div>
        <div v-else-if="filteredItems.length === 0" class="text-grey-6 text-center q-py-xl">
          No items in this category yet
        </div>
        <div v-else class="admin-merch-grid">
          <div
            v-for="item in filteredItems"
            :key="item.id"
            :class="['merch-thumb', { 'merch-thumb--active': editingId === item.id }]"
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
                <q-badge v-if="item.badge" color="amber-8" :label="item.badge" />
                <q-badge v-if="item.sold_out" color="grey-7" label="Sold Out" />
              </div>
              <q-btn flat round dense icon="delete" color="red-3" size="sm"
                     class="q-mt-xs" @click.stop="deleteItem(item.id)" />
            </div>
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
              label="Category"
              dark outlined dense
              label-color="teal-3" color="teal-3"
              :rules="[v => !!v || 'Required']"
            />

            <q-input
              v-model="form.name"
              label="Name"
              dark outlined dense
              label-color="teal-3" color="teal-3"
              :rules="[v => !!v || 'Required']"
            />

            <q-input
              v-model="form.description"
              type="textarea"
              :rows="3"
              label="Description"
              dark outlined
              label-color="teal-3" color="teal-3"
            />

            <div class="row q-col-gutter-md">
              <div class="col-6">
                <q-input
                  v-model="form.price"
                  label='Price (e.g. "$45")'
                  dark outlined dense
                  label-color="teal-3" color="teal-3"
                />
              </div>
              <div class="col-6">
                <q-input
                  v-model="form.badge"
                  label='Badge (e.g. "New", "Limited")'
                  dark outlined dense
                  label-color="teal-3" color="teal-3"
                />
              </div>
            </div>

            <!-- Image URL + upload -->
            <div class="text-caption text-grey-5 q-mb-xs">Image</div>
            <div class="row q-col-gutter-sm items-start">
              <div class="col">
                <q-input
                  v-model="form.image_url"
                  placeholder="https://... or upload →"
                  dark outlined dense
                  label-color="teal-3" color="teal-3"
                />
              </div>
              <div class="col-auto">
                <q-btn color="teal-8" icon="upload" unelevated dense @click="triggerUpload" :loading="uploading" />
                <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="handleUpload" />
              </div>
            </div>
            <div v-if="form.image_url" class="q-mt-xs">
              <img :src="form.image_url" style="max-height:110px; border-radius:8px; max-width:100%;" />
            </div>

            <q-toggle v-model="form.sold_out" label="Sold Out" color="red" dark />

            <div class="row q-gutter-sm q-mt-sm">
              <q-btn type="submit" :label="editingId ? 'Update Item' : 'Add Item'" color="teal" unelevated :loading="saving" />
              <q-btn v-if="editingId" flat label="New" @click="resetForm" />
            </div>
          </q-form>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { MerchItem } from 'src/lib/supabase'

const items     = ref<MerchItem[]>([])
const tab       = ref<'all' | 'art' | 'photos' | 'other'>('all')
const loading   = ref(true)
const saving    = ref(false)
const uploading = ref(false)
const editingId = ref<string | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)

const categoryOptions = [
  { label: 'Art We Make', value: 'art'    },
  { label: 'Photos',      value: 'photos' },
  { label: 'Other Stuff', value: 'other'  },
]

const filteredItems = computed(() =>
  tab.value === 'all' ? items.value : items.value.filter(i => i.category === tab.value)
)

const emptyForm = () => ({
  category: 'art' as MerchItem['category'],
  name: '', description: '', price: '',
  image_url: '', badge: '', sold_out: false,
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

async function load() {
  const { data } = await supabase.from('merch_items').select('*').order('display_order')
  items.value = (data as MerchItem[]) ?? []
  loading.value = false
}

onMounted(() => { void load() })
</script>

<style lang="scss" scoped>
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
.merch-form-panel {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.2);
}
.hidden { display: none; }
</style>

<template>
  <q-page class="q-pa-lg">
    <div class="row items-center q-mb-lg">
      <div>
        <div class="text-h5 text-teal-3 q-mb-xs">News Articles</div>
        <div class="text-caption text-grey-5">Write and manage tour stories, event recaps, and updates</div>
      </div>
      <q-space />
      <q-btn color="teal" icon="add" label="New Article" unelevated @click="resetForm" />
    </div>

    <div class="row q-col-gutter-xl">

      <!-- Article list -->
      <div class="col-12 col-md-5">
        <div v-if="loading" class="flex flex-center q-py-xl">
          <q-spinner-orbit color="teal" size="40px" />
        </div>
        <q-list v-else separator dark class="rounded-borders news-list">
          <q-item
            v-for="article in articles"
            :key="article.id"
            class="q-py-md"
            clickable
            :class="{ 'item-active': editingId === article.id }"
            @click="openEdit(article)"
          >
            <q-item-section avatar>
              <q-icon :name="article.icon" :color="article.color" size="22px" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-white text-weight-medium">{{ article.title }}</q-item-label>
              <q-item-label caption class="text-grey-5">{{ article.date ?? 'No date' }}</q-item-label>
              <q-item-label caption>
                <q-badge
                  :color="article.published ? 'positive' : 'grey-7'"
                  :label="article.published ? 'Published' : 'Draft'"
                  class="q-mr-xs"
                />
                <q-badge
                  v-for="tag in article.tags.slice(0,2)"
                  :key="tag"
                  color="indigo-9"
                  :label="tag"
                  class="q-mr-xs"
                />
              </q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-btn flat round dense icon="delete" color="red-4" size="sm" @click.stop="deleteArticle(article.id)" />
            </q-item-section>
          </q-item>
          <q-item v-if="articles.length === 0">
            <q-item-section class="text-grey-6 text-center q-py-xl">No articles yet</q-item-section>
          </q-item>
        </q-list>
      </div>

      <!-- Form -->
      <div class="col-12 col-md-7">
        <div class="news-form-panel q-pa-lg rounded-borders">
          <div class="text-subtitle1 text-teal-2 q-mb-md">{{ editingId ? 'Edit Article' : 'New Article' }}</div>

          <q-form @submit="save" class="q-gutter-md">

            <q-input
              v-model="form.title"
              label="Title"
              dark outlined dense
              label-color="teal-3" color="teal-3"
              :rules="[v => !!v || 'Required']"
            />

            <q-input
              v-model="form.date"
              label='Display Date (e.g. "July 12, 2026")'
              dark outlined dense
              label-color="teal-3" color="teal-3"
            />

            <div class="row q-col-gutter-md">
              <div class="col-6">
                <q-select
                  v-model="form.icon"
                  :options="iconOptions"
                  emit-value map-options
                  label="Icon"
                  dark outlined dense
                  label-color="teal-3" color="teal-3"
                >
                  <template #prepend>
                    <q-icon :name="form.icon" color="teal-3" />
                  </template>
                  <template #option="scope">
                    <q-item v-bind="scope.itemProps">
                      <q-item-section avatar>
                        <q-icon :name="scope.opt.value" color="teal-3" />
                      </q-item-section>
                      <q-item-section>{{ scope.opt.label }}</q-item-section>
                    </q-item>
                  </template>
                </q-select>
              </div>
              <div class="col-6">
                <q-select
                  v-model="form.color"
                  :options="colorOptions"
                  emit-value map-options
                  label="Color"
                  dark outlined dense
                  label-color="teal-3" color="teal-3"
                >
                  <template #prepend>
                    <q-icon name="circle" :color="form.color" />
                  </template>
                </q-select>
              </div>
            </div>

            <q-input
              v-model="form.body"
              type="textarea"
              :rows="6"
              label="Body"
              dark outlined
              label-color="teal-3" color="teal-3"
            />

            <q-input
              v-model="form.tagsStr"
              label='Tags (comma-separated, e.g. "Billy Strings, Red Rocks")'
              dark outlined dense
              label-color="teal-3" color="teal-3"
            />

            <q-input
              v-model="form.image_url"
              label="Image URL (optional)"
              dark outlined dense
              label-color="teal-3" color="teal-3"
            />
            <div v-if="form.image_url" class="q-mt-xs">
              <img :src="form.image_url" style="max-height:120px; border-radius:8px; max-width:100%;" />
            </div>

            <q-toggle
              v-model="form.published"
              label="Published (visible on public site)"
              color="teal"
              dark
            />

            <div class="row q-gutter-sm q-mt-sm">
              <q-btn type="submit" :label="editingId ? 'Update Article' : 'Save Article'" color="teal" unelevated :loading="saving" />
              <q-btn v-if="editingId" flat label="New" @click="resetForm" />
            </div>
          </q-form>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { NewsArticle } from 'src/lib/supabase'

const articles  = ref<NewsArticle[]>([])
const loading   = ref(true)
const saving    = ref(false)
const editingId = ref<string | null>(null)

const iconOptions = [
  { label: 'Star',         value: 'star'          },
  { label: 'Music Note',   value: 'music_note'    },
  { label: 'Festival',     value: 'festival'      },
  { label: 'Landscape',    value: 'landscape'     },
  { label: 'Camera',       value: 'photo_camera'  },
  { label: 'Explore',      value: 'travel_explore'},
  { label: 'Nature',       value: 'emoji_nature'  },
  { label: 'Bolt',         value: 'bolt'          },
  { label: 'Celebration',  value: 'celebration'   },
  { label: 'Campfire',     value: 'local_fire_department' },
]

const colorOptions = [
  { label: 'Amber',        value: 'amber'        },
  { label: 'Deep Orange',  value: 'deep-orange'  },
  { label: 'Purple',       value: 'purple'       },
  { label: 'Teal',         value: 'teal'         },
  { label: 'Indigo',       value: 'indigo'       },
  { label: 'Green',        value: 'green'        },
  { label: 'Pink',         value: 'pink'         },
  { label: 'Blue',         value: 'blue'         },
]

const emptyForm = () => ({
  title: '', date: '', icon: 'star', color: 'amber',
  body: '', tagsStr: '', image_url: '', published: true,
})
const form = reactive(emptyForm())

function resetForm() {
  editingId.value = null
  Object.assign(form, emptyForm())
}

function openEdit(a: NewsArticle) {
  editingId.value = a.id
  Object.assign(form, {
    title: a.title, date: a.date ?? '', icon: a.icon,
    color: a.color, body: a.body ?? '',
    tagsStr: a.tags.join(', '), image_url: a.image_url ?? '',
    published: a.published,
  })
}

async function save() {
  saving.value = true
  const tags = form.tagsStr.split(',').map(t => t.trim()).filter(Boolean)
  const payload = {
    title:     form.title,
    date:      form.date || null,
    icon:      form.icon,
    color:     form.color,
    body:      form.body || null,
    tags,
    image_url: form.image_url || null,
    published: form.published,
  }
  if (editingId.value) {
    await supabase.from('news_articles').update(payload).eq('id', editingId.value)
  } else {
    await supabase.from('news_articles').insert(payload)
  }
  await load()
  resetForm()
  saving.value = false
}

async function deleteArticle(id: string) {
  await supabase.from('news_articles').delete().eq('id', id)
  articles.value = articles.value.filter(a => a.id !== id)
}

async function load() {
  const { data } = await supabase.from('news_articles').select('*').order('created_at', { ascending: false })
  articles.value = (data as NewsArticle[]) ?? []
  loading.value = false
}

onMounted(() => { void load() })
</script>

<style lang="scss" scoped>
.news-list {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.2);
  max-height: calc(100vh - 220px);
  overflow-y: auto;
  &::-webkit-scrollbar { width: 4px; }
  &::-webkit-scrollbar-thumb { background: rgba(77,182,172,0.3); border-radius: 2px; }
}
.item-active { background: rgba(77,182,172,0.08); border-left: 3px solid #4db6ac; }
.news-form-panel {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.2);
}
</style>

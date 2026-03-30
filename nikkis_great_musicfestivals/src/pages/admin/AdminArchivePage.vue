<template>
  <q-page class="q-pa-lg arc-admin">

    <!-- Header -->
    <div class="row items-center q-mb-xl">
      <q-btn flat icon="arrow_back" to="/admin" class="q-mr-md" />
      <div>
        <div class="text-h5 text-deep-purple-3">Archive Collections</div>
        <div class="text-caption text-grey-5">
          Curated archive.org listening rooms · stored in site_settings
        </div>
      </div>
      <q-space />
      <q-btn
        v-if="session"
        color="deep-purple-4" unelevated icon="save" label="Save All"
        :loading="saving"
        @click="saveAll"
      />
    </div>

    <div class="row q-col-gutter-lg">

      <!-- ── Collection list (left) ────────────────────────────── -->
      <div class="col-12 col-md-4">
        <div class="row items-center q-mb-sm">
          <div class="text-subtitle2 text-deep-purple-3 col">
            Collections ({{ collections.length }})
          </div>
          <q-btn
            v-if="session"
            flat dense icon="add" color="deep-purple-3" size="sm"
            label="New"
            @click="addCollection"
          />
        </div>

        <q-list separator dark class="rounded-borders arc-list">
          <q-item
            v-for="col in collections" :key="col.id"
            clickable v-ripple
            :active="selected?.id === col.id"
            active-class="arc-item--active"
            class="arc-list-item"
            @click="selectCollection(col)"
          >
            <q-item-section avatar>
              <q-icon :name="col.icon" :color="col.color" size="22px" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-white" style="font-size:13px; font-weight:600">
                {{ col.title }}
              </q-item-label>
              <q-item-label caption class="text-grey-6" style="font-size:10px">
                {{ col.entries.length }} recording{{ col.entries.length === 1 ? '' : 's' }}
                · {{ col.region_tags.join(', ') || 'no regions' }}
              </q-item-label>
            </q-item-section>
            <q-item-section side v-if="session">
              <q-btn
                flat round dense icon="delete" color="red-4" size="xs"
                @click.stop="removeCollection(col.id)"
              />
            </q-item-section>
          </q-item>
          <q-item v-if="collections.length === 0">
            <q-item-section class="text-grey-6 text-center q-py-lg">
              No collections — click New to add one.
            </q-item-section>
          </q-item>
        </q-list>

        <!-- Region legend -->
        <div class="q-mt-lg q-pa-md arc-legend rounded-borders">
          <div class="text-caption text-grey-5 q-mb-xs" style="letter-spacing:1px; text-transform:uppercase; font-size:9px; font-weight:900">
            Region Tags
          </div>
          <div class="row q-gutter-xs">
            <q-badge
              v-for="r in REGION_OPTIONS" :key="r"
              color="grey-9" text-color="deep-purple-3"
              style="font-size:9px; cursor:default"
            >{{ r }}</q-badge>
          </div>
        </div>
      </div>

      <!-- ── Edit panel (right) ─────────────────────────────────── -->
      <div class="col-12 col-md-8">
        <template v-if="selected">

          <!-- Collection metadata -->
          <div class="arc-panel q-pa-lg rounded-borders q-mb-lg">
            <div class="text-subtitle2 text-deep-purple-3 q-mb-md">Collection Details</div>

            <div class="row q-col-gutter-md">
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="selected.title"
                  label="Title"
                  dark outlined dense
                  label-color="deep-purple-3" color="deep-purple-3"
                  :readonly="!session"
                />
              </div>
              <div class="col-12 col-sm-6">
                <q-input
                  v-model="selected.id"
                  label="Slug (ID)"
                  dark outlined dense
                  label-color="deep-purple-3" color="deep-purple-3"
                  hint="Lowercase, no spaces"
                  :readonly="!session"
                />
              </div>
              <div class="col-12">
                <q-input
                  v-model="selected.style"
                  label="Style / Sub-genre description"
                  dark outlined dense
                  label-color="deep-purple-3" color="deep-purple-3"
                  :readonly="!session"
                />
              </div>
              <div class="col-12 col-sm-4">
                <q-select
                  v-model="selected.icon"
                  :options="ICON_OPTIONS"
                  label="Icon"
                  dark outlined dense emit-value map-options
                  label-color="deep-purple-3" color="deep-purple-3"
                  :readonly="!session"
                >
                  <template #selected>
                    <q-icon :name="selected.icon" size="18px" class="q-mr-xs" />
                    {{ selected.icon }}
                  </template>
                  <template #option="scope">
                    <q-item v-bind="scope.itemProps">
                      <q-item-section avatar>
                        <q-icon :name="scope.opt" size="18px" />
                      </q-item-section>
                      <q-item-section>{{ scope.opt }}</q-item-section>
                    </q-item>
                  </template>
                </q-select>
              </div>
              <div class="col-12 col-sm-4">
                <q-select
                  v-model="selected.color"
                  :options="COLOR_OPTIONS"
                  label="Color"
                  dark outlined dense emit-value map-options
                  label-color="deep-purple-3" color="deep-purple-3"
                  :readonly="!session"
                >
                  <template #selected>
                    <q-badge :color="selected.color" class="q-mr-xs" style="width:12px; height:12px; border-radius:50%; padding:0" />
                    {{ selected.color }}
                  </template>
                  <template #option="scope">
                    <q-item v-bind="scope.itemProps">
                      <q-item-section avatar>
                        <q-badge :color="scope.opt" style="width:14px; height:14px; border-radius:50%; padding:0" />
                      </q-item-section>
                      <q-item-section>{{ scope.opt }}</q-item-section>
                    </q-item>
                  </template>
                </q-select>
              </div>
              <div class="col-12 col-sm-4">
                <q-select
                  v-model="selected.region_tags"
                  :options="REGION_OPTIONS"
                  label="Region Tags"
                  dark outlined dense multiple use-chips
                  label-color="deep-purple-3" color="deep-purple-3"
                  :readonly="!session"
                />
              </div>
            </div>
          </div>

          <!-- Entries list -->
          <div class="arc-panel q-pa-lg rounded-borders">
            <div class="row items-center q-mb-md">
              <div class="text-subtitle2 text-deep-purple-3 col">
                Recordings ({{ selected.entries.length }})
              </div>
              <q-btn
                v-if="session"
                flat dense icon="add" color="deep-purple-3" size="sm"
                label="Add Recording"
                @click="openAddEntry"
              />
            </div>

            <q-list separator dark style="background: transparent">
              <q-item
                v-for="(entry, i) in selected.entries" :key="entry.id"
                class="arc-entry q-py-sm"
              >
                <q-item-section avatar style="min-width:28px">
                  <div class="arc-entry-num">{{ i + 1 }}</div>
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-grey-2" style="font-size:12.5px; font-weight:600; line-height:1.3">
                    {{ entry.label }}
                  </q-item-label>
                  <q-item-label caption class="text-grey-6" style="font-size:10px; font-family: monospace">
                    {{ entry.id }}
                  </q-item-label>
                  <q-item-label v-if="entry.notes" caption class="text-grey-5" style="font-size:10px; margin-top:2px">
                    {{ entry.notes }}
                  </q-item-label>
                </q-item-section>
                <q-item-section side v-if="session">
                  <div class="row q-gutter-xs">
                    <q-btn flat round dense icon="edit" color="deep-purple-3" size="xs"
                           @click="openEditEntry(entry, i)" />
                    <q-btn flat round dense icon="delete" color="red-4" size="xs"
                           @click="removeEntry(i)" />
                  </div>
                </q-item-section>
              </q-item>
              <q-item v-if="selected.entries.length === 0">
                <q-item-section class="text-grey-6 text-center q-py-md">
                  No recordings yet — add one!
                </q-item-section>
              </q-item>
            </q-list>
          </div>

        </template>

        <!-- Placeholder when nothing selected -->
        <div v-else class="arc-empty text-center q-py-xl text-grey-7">
          <q-icon name="library_music" size="48px" class="q-mb-md" style="opacity:0.2" />
          <div>Select a collection to edit</div>
        </div>
      </div>

    </div>

    <!-- ── Add / Edit entry dialog ─────────────────────────────── -->
    <q-dialog v-model="entryDialog.open" persistent>
      <q-card class="arc-dialog" dark>
        <q-card-section>
          <div class="text-h6 text-deep-purple-3">
            {{ entryDialog.editIndex >= 0 ? 'Edit Recording' : 'Add Recording' }}
          </div>
        </q-card-section>
        <q-separator dark />
        <q-card-section class="q-gutter-md">
          <q-input
            v-model="entryForm.id"
            label="Archive.org Identifier"
            hint="The path segment after archive.org/details/"
            dark outlined dense
            label-color="deep-purple-3" color="deep-purple-3"
            placeholder="e.g. gd1977-05-08.shure57..."
          />
          <q-input
            v-model="entryForm.label"
            label="Display Label"
            dark outlined dense
            label-color="deep-purple-3" color="deep-purple-3"
            placeholder="e.g. Grateful Dead · Cornell, May 8 1977"
          />
          <q-input
            v-model="entryForm.notes"
            label="Notes (optional)"
            hint="Shown in admin only — context, clogging vibe, senior angle, etc."
            dark outlined dense autogrow
            label-color="deep-purple-3" color="deep-purple-3"
          />
          <div class="text-caption text-grey-6">
            Tip: paste the full archive.org URL and the identifier will be extracted automatically.
          </div>
        </q-card-section>
        <q-card-actions align="right" class="q-px-lg q-pb-lg">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn
            unelevated :label="entryDialog.editIndex >= 0 ? 'Update' : 'Add'"
            color="deep-purple-4"
            :disable="!entryForm.id.trim() || !entryForm.label.trim()"
            @click="saveEntry"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import { ARC_COLLECTIONS_SEED } from 'src/lib/arcCollections'
import type { ArcCollection, ArcEntry } from 'src/lib/arcCollections'

// ── Auth ────────────────────────────────────────────────────────────────────
const session = ref<unknown>(null)

onMounted(async () => {
  const { data: { session: s } } = await supabase.auth.getSession()
  session.value = s
  await loadCollections()
})

// ── Data ─────────────────────────────────────────────────────────────────────
const collections = ref<ArcCollection[]>([])
const selected    = ref<ArcCollection | null>(null)
const saving      = ref(false)

async function loadCollections() {
  const { data } = await supabase
    .from('site_settings')
    .select('value')
    .eq('key', 'arc_collections')
    .maybeSingle()
  const raw: unknown = data?.value
  collections.value = structuredClone(
    (Array.isArray(raw) ? (raw as ArcCollection[]) : null)
    ?? ARC_COLLECTIONS_SEED
  )
  selected.value = collections.value[0] ?? null
}

async function saveAll() {
  saving.value = true
  await supabase.from('site_settings').upsert({
    key:   'arc_collections',
    value: collections.value,
  }, { onConflict: 'key' })
  saving.value = false
}

// ── Collection CRUD ──────────────────────────────────────────────────────────
function selectCollection(col: ArcCollection) {
  selected.value = col
}

function addCollection() {
  const newCol: ArcCollection = {
    id:          `collection-${Date.now()}`,
    title:       'New Collection',
    style:       '',
    icon:        'library_music',
    color:       'deep-purple',
    region_tags: [],
    entries:     [],
  }
  collections.value.push(newCol)
  selected.value = newCol
}

function removeCollection(id: string) {
  const idx = collections.value.findIndex(c => c.id === id)
  if (idx < 0) return
  collections.value.splice(idx, 1)
  if (selected.value?.id === id) {
    selected.value = collections.value[0] ?? null
  }
}

// ── Entry CRUD ───────────────────────────────────────────────────────────────
const entryDialog = reactive({ open: false, editIndex: -1 })
const entryForm   = reactive({ id: '', label: '', notes: '' })

/** Extract archive.org identifier from a pasted /details/ URL or return as-is */
function normalizeArchiveId(raw: string): string {
  const m = raw.trim().match(/archive\.org\/details\/([^/?#\s]+)/)
  return m ? m[1]! : raw.trim()
}

function openAddEntry() {
  Object.assign(entryForm, { id: '', label: '', notes: '' })
  entryDialog.editIndex = -1
  entryDialog.open = true
}

function openEditEntry(entry: ArcEntry, index: number) {
  Object.assign(entryForm, { id: entry.id, label: entry.label, notes: entry.notes ?? '' })
  entryDialog.editIndex = index
  entryDialog.open = true
}

function saveEntry() {
  if (!selected.value) return
  const entry: ArcEntry = {
    id:    normalizeArchiveId(entryForm.id),
    label: entryForm.label.trim(),
    ...(entryForm.notes.trim() ? { notes: entryForm.notes.trim() } : {}),
  }
  if (entryDialog.editIndex >= 0) {
    selected.value.entries.splice(entryDialog.editIndex, 1, entry)
  } else {
    selected.value.entries.push(entry)
  }
  entryDialog.open = false
}

function removeEntry(index: number) {
  selected.value?.entries.splice(index, 1)
}

// ── Static option lists ──────────────────────────────────────────────────────
const REGION_OPTIONS = [
  'northeast', 'southeast', 'southwest', 'mountainwest', 'pacnw', 'greatlakes',
]

const ICON_OPTIONS = [
  'library_music', 'queue_music', 'music_note', 'album', 'headphones',
  'terrain', 'explore', 'audiotrack', 'mic', 'piano', 'graphic_eq',
]

const COLOR_OPTIONS = [
  'amber', 'orange', 'deep-orange', 'red', 'pink',
  'purple', 'deep-purple', 'indigo', 'blue', 'teal',
  'green', 'cyan', 'brown', 'grey',
]
</script>

<style lang="scss" scoped>
.arc-admin { max-width: 1200px; margin: 0 auto; }

.arc-list {
  background: #12102a;
  border: 1px solid rgba(149, 117, 205, 0.2);
}
.arc-list-item { min-height: 60px; }
.arc-item--active { background: rgba(149, 117, 205, 0.15) !important; }

.arc-legend {
  background: rgba(149, 117, 205, 0.06);
  border: 1px solid rgba(149, 117, 205, 0.12);
}

.arc-panel {
  background: rgba(149, 117, 205, 0.07);
  border: 1px solid rgba(149, 117, 205, 0.18);
}

.arc-entry {
  border-radius: 6px;
  transition: background 0.15s;
  &:hover { background: rgba(149, 117, 205, 0.08); }
}

.arc-entry-num {
  width: 20px; height: 20px;
  border-radius: 50%;
  background: rgba(149, 117, 205, 0.2);
  color: #ce93d8;
  font-size: 9px; font-weight: 900;
  display: flex; align-items: center; justify-content: center;
}

.arc-empty {
  border: 1px dashed rgba(149, 117, 205, 0.2);
  border-radius: 16px;
  padding: 60px 20px;
}

.arc-dialog {
  width: 480px; max-width: 95vw;
  background: #1a1030;
  border: 1px solid rgba(149, 117, 205, 0.25);
}
</style>

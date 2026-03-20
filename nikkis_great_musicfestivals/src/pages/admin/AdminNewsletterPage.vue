<template>
  <q-page class="q-pa-lg">
    <div class="text-h5 text-teal-3 q-mb-xs">Newsletter Manager</div>
    <div class="text-caption text-grey-5 q-mb-lg">Compose newsletters · view subscribers</div>

    <div class="row q-col-gutter-xl">

      <!-- Compose / edit -->
      <div class="col-12 col-md-7">
        <div class="nl-panel q-pa-lg rounded-borders q-mb-lg">
          <div class="text-subtitle2 text-teal-2 q-mb-md">
            {{ editingId ? 'Edit Newsletter' : 'New Newsletter' }}
          </div>
          <q-form @submit="save" class="q-gutter-md">
            <q-input v-model="form.title"   label="Title"   dark outlined label-color="teal-3" color="teal-3"
              :rules="[v => !!v || 'Required']" />
            <q-input v-model="form.subject" label="Email Subject Line" dark outlined label-color="teal-3" color="teal-3" />
            <q-input
              v-model="form.body"
              type="textarea"
              :rows="12"
              label="Body (plain text or markdown)"
              dark outlined
              label-color="teal-3" color="teal-3"
            />
            <div class="row q-gutter-sm">
              <q-btn type="submit" :label="editingId ? 'Update' : 'Save Draft'" color="teal" unelevated :loading="saving" />
              <q-btn
                v-if="editingId"
                label="Mark as Sent"
                color="deep-orange"
                outline
                :loading="marking"
                @click="markSent"
              />
              <q-btn v-if="editingId" flat label="Cancel" @click="resetForm" />
            </div>
          </q-form>
        </div>
      </div>

      <!-- Drafts + Sent list + Subscribers -->
      <div class="col-12 col-md-5">

        <!-- Newsletters list -->
        <div class="nl-panel q-pa-lg rounded-borders q-mb-lg">
          <div class="text-subtitle2 text-teal-2 q-mb-md">All Newsletters ({{ newsletters.length }})</div>
          <q-list separator dark style="background:transparent">
            <q-item
              v-for="nl in newsletters"
              :key="nl.id"
              class="q-py-sm"
              clickable
              @click="editNl(nl)"
            >
              <q-item-section>
                <q-item-label class="text-white text-weight-medium">{{ nl.title }}</q-item-label>
                <q-item-label caption class="text-grey-6">
                  {{ nl.subject ?? '(no subject)' }}
                </q-item-label>
                <q-item-label caption>
                  <q-badge
                    :color="nl.sent_at ? 'positive' : 'grey-7'"
                    :label="nl.sent_at ? `Sent ${formatDate(nl.sent_at)}` : 'Draft'"
                  />
                </q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-btn flat round dense icon="delete" color="red-4" size="sm" @click.stop="deleteNl(nl.id)" />
              </q-item-section>
            </q-item>
            <q-item v-if="newsletters.length === 0">
              <q-item-section class="text-grey-6 text-center q-py-md">No newsletters yet</q-item-section>
            </q-item>
          </q-list>
        </div>

        <!-- Subscribers -->
        <div class="nl-panel q-pa-lg rounded-borders">
          <div class="row items-center q-mb-md">
            <div class="text-subtitle2 text-teal-2 col">Subscribers ({{ subscribers.length }})</div>
            <q-btn flat dense icon="download" color="teal-3" label="Export CSV" @click="exportCsv" size="sm" />
          </div>
          <q-list separator dark style="background:transparent;max-height:220px;overflow-y:auto;">
            <q-item v-for="sub in subscribers" :key="sub.email" dense class="q-py-xs">
              <q-item-section>
                <q-item-label class="text-grey-4" style="font-size:12px">{{ sub.email }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label caption class="text-grey-6" style="font-size:10px">
                  {{ formatDate(sub.created_at) }}
                </q-item-label>
              </q-item-section>
            </q-item>
            <q-item v-if="subscribers.length === 0">
              <q-item-section class="text-grey-6 text-center q-py-md">No subscribers yet</q-item-section>
            </q-item>
          </q-list>
        </div>

      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { Newsletter } from 'src/lib/supabase'

interface Subscriber { email: string; created_at: string }

const newsletters = ref<Newsletter[]>([])
const subscribers = ref<Subscriber[]>([])
const saving   = ref(false)
const marking  = ref(false)
const editingId = ref<string | null>(null)

const emptyForm = () => ({ title: '', subject: '', body: '' })
const form = reactive(emptyForm())

function resetForm() { editingId.value = null; Object.assign(form, emptyForm()) }

function editNl(nl: Newsletter) {
  editingId.value = nl.id
  Object.assign(form, { title: nl.title, subject: nl.subject ?? '', body: nl.body ?? '' })
}

async function save() {
  saving.value = true
  const payload = { title: form.title, subject: form.subject || null, body: form.body || null }
  if (editingId.value) {
    await supabase.from('newsletters').update(payload).eq('id', editingId.value)
  } else {
    await supabase.from('newsletters').insert(payload)
  }
  await loadAll()
  resetForm()
  saving.value = false
}

async function markSent() {
  if (!editingId.value) return
  marking.value = true
  await supabase.from('newsletters').update({ sent_at: new Date().toISOString() }).eq('id', editingId.value)
  await loadAll()
  resetForm()
  marking.value = false
}

async function deleteNl(id: string) {
  await supabase.from('newsletters').delete().eq('id', id)
  newsletters.value = newsletters.value.filter(n => n.id !== id)
}

function formatDate(d: string | null) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function exportCsv() {
  const csv = 'email,subscribed\n' + subscribers.value.map(s => `${s.email},${s.created_at}`).join('\n')
  const blob = new Blob([csv], { type: 'text/csv' })
  const url  = URL.createObjectURL(blob)
  const a    = document.createElement('a'); a.href = url; a.download = 'subscribers.csv'; a.click()
  URL.revokeObjectURL(url)
}

async function loadAll() {
  const [{ data: nls }, { data: subs }] = await Promise.all([
    supabase.from('newsletters').select('*').order('created_at', { ascending: false }),
    supabase.from('newsletter_subscribers').select('*').order('created_at', { ascending: false }),
  ])
  newsletters.value = (nls as Newsletter[]) ?? []
  subscribers.value = (subs as Subscriber[]) ?? []
}

onMounted(() => { void loadAll() })
</script>

<style lang="scss" scoped>
.nl-panel {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.2);
}
</style>

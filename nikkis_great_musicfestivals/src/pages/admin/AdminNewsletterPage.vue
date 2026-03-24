<template>
  <q-page class="q-pa-lg">

    <!-- ══ HEADER ══════════════════════════════════════════════════════════ -->
    <div class="row items-center q-mb-lg">
      <q-btn v-if="nlView === 'edit'" flat round dense icon="arrow_back"
        color="grey-5" @click="nlView = 'list'" class="q-mr-sm" />
      <div>
        <div class="text-h5 text-teal-3">Newsletter</div>
        <div class="text-caption text-grey-5">Email campaigns · daily cuteness · subscriber management</div>
      </div>
      <q-space />
      <div v-if="activeTab === 'newsletter' && nlView === 'list'" class="row q-gutter-sm">
        <q-btn color="teal-6" unelevated icon="add" label="New Issue" @click="newNewsletter" />
      </div>
    </div>

    <!-- Setup banner -->
    <q-banner v-if="setupNeeded" rounded class="setup-banner q-mb-lg">
      <template #avatar><q-icon name="table_chart" color="amber-4" /></template>
      <div>Run this SQL once in Supabase to extend the newsletter tables.
        <q-btn flat dense size="xs" color="amber-4" icon="content_copy" label="Copy SQL"
          @click="copySetupSql" class="q-ml-sm" />
      </div>
      <template #action>
        <q-btn flat color="amber-4" label="Dismiss" @click="setupNeeded = false" />
      </template>
    </q-banner>

    <!-- ══ TABS ═════════════════════════════════════════════════════════════ -->
    <q-tabs v-model="activeTab" dense align="left" class="q-mb-lg nl-tabs"
      active-color="teal-3" indicator-color="teal-5" no-caps>
      <q-tab name="newsletter" icon="newspaper"  label="Newsletter"   />
      <q-tab name="cuteness"   icon="favorite"   label="Daily Cuteness" />
      <q-tab name="templates"  icon="edit_note"  label="Templates"    />
      <q-tab name="subscribers" icon="people"    label="Subscribers"  />
    </q-tabs>

    <!-- ══════════════════════════════════════════════════════════════════════
         TAB: NEWSLETTER
    ═══════════════════════════════════════════════════════════════════════ -->
    <div v-show="activeTab === 'newsletter'">

      <!-- ── LIST SUB-VIEW ── -->
      <template v-if="nlView === 'list'">

        <!-- Stats -->
        <div class="row q-col-gutter-md q-mb-lg">
          <div class="col-6 col-sm-3"><div class="stat-card text-center q-pa-md">
            <div class="text-h4 text-teal-3 text-bold">{{ stats.nlActive }}</div>
            <div class="text-caption text-grey-5">Newsletter Subs</div>
          </div></div>
          <div class="col-6 col-sm-3"><div class="stat-card text-center q-pa-md">
            <div class="text-h4 text-pink-4 text-bold">{{ stats.cuteActive }}</div>
            <div class="text-caption text-grey-5">Cuteness Subs</div>
          </div></div>
          <div class="col-6 col-sm-3"><div class="stat-card text-center q-pa-md">
            <div class="text-h4 text-amber-4 text-bold">{{ newsletters.filter(n=>n.status==='draft').length }}</div>
            <div class="text-caption text-grey-5">Drafts</div>
          </div></div>
          <div class="col-6 col-sm-3"><div class="stat-card text-center q-pa-md">
            <div class="text-h4 text-green-4 text-bold">{{ newsletters.filter(n=>n.status==='sent').length }}</div>
            <div class="text-caption text-grey-5">Sent</div>
          </div></div>
        </div>

        <div v-if="loading" class="flex flex-center q-py-xl">
          <q-spinner-orbit color="teal-5" size="48px" />
        </div>
        <div v-else class="row q-col-gutter-md">
          <div v-for="nl in newsletters" :key="nl.id" class="col-12 col-sm-6 col-md-4">
            <q-card class="nl-card" @click="editNewsletter(nl)">
              <q-card-section class="q-pb-xs">
                <div class="row items-start no-wrap">
                  <div class="col">
                    <div class="text-body1 text-white text-weight-medium">{{ nl.title }}</div>
                    <div class="text-caption text-grey-5 q-mt-xs">{{ nl.subject || '(no subject)' }}</div>
                  </div>
                  <q-badge class="q-ml-sm" :color="nlStatusColor(nl.status)" :label="nl.status" />
                </div>
              </q-card-section>
              <q-card-section class="q-pt-xs q-pb-xs">
                <div class="text-caption text-grey-6">
                  {{ (nl.blocks ?? []).length }} block{{ (nl.blocks ?? []).length !== 1 ? 's' : '' }}
                  <span v-if="nl.sent_at"> · sent {{ fmtDate(nl.sent_at) }}</span>
                  <span v-if="nl.recipient_count"> to {{ nl.recipient_count }}</span>
                </div>
              </q-card-section>
              <q-card-actions align="right">
                <q-btn flat dense icon="delete" color="red-4" size="sm"
                  @click.stop="deleteNewsletter(nl)" />
                <q-btn flat dense icon="science" color="indigo-3" size="sm"
                  title="Send test to myself" @click.stop="sendTestEmailFromList(nl)" />
                <q-btn v-if="nl.status !== 'sent'" flat dense icon="send" color="teal-4"
                  label="Send" size="sm" @click.stop="openSendDialog(nl)" />
              </q-card-actions>
            </q-card>
          </div>
          <div v-if="newsletters.length === 0 && !loading"
            class="col-12 text-center text-grey-6 q-py-xl">
            No newsletters yet — click "New Issue" to start.
          </div>
        </div>
      </template>

      <!-- ── EDIT / COMPOSE SUB-VIEW ── -->
      <template v-else>
        <div class="row q-col-gutter-lg">

          <!-- Left: blocks -->
          <div class="col-12 col-md-8">
            <q-card class="nl-panel q-mb-md">
              <q-card-section class="q-gutter-sm">
                <q-input v-model="nlForm.title" label="Issue title *" dark outlined dense
                  label-color="teal-3" color="teal-3"
                  hint="Internal label — not shown to subscribers" />
                <q-input v-model="nlForm.subject" label="Email subject line" dark outlined dense
                  label-color="teal-3" color="teal-3" />
              </q-card-section>
            </q-card>

            <div class="text-subtitle2 text-teal-4 text-uppercase ls-2 q-mb-sm">Content Blocks</div>

            <div v-if="nlForm.blocks.length === 0"
              class="text-center text-grey-6 q-py-lg nl-panel rounded-borders q-mb-md">
              No blocks yet — add content using the buttons below.
            </div>

            <div v-for="(block, bi) in nlForm.blocks" :key="bi" class="nl-block-card q-mb-sm">
              <div class="row items-center q-pa-sm q-pb-none">
                <q-icon :name="blockIcon(block.type)" :color="blockColor(block.type)" size="18px" class="q-mr-xs" />
                <span class="text-caption text-weight-bold" :class="`text-${blockColor(block.type)}`">
                  {{ blockLabel(block.type) }}
                </span>
                <q-space />
                <q-btn flat round dense icon="arrow_upward"   size="xs" color="grey-5" :disable="bi===0"                        @click="moveBlock(bi,-1)" />
                <q-btn flat round dense icon="arrow_downward" size="xs" color="grey-5" :disable="bi===nlForm.blocks.length-1" @click="moveBlock(bi,1)" />
                <q-btn flat round dense icon="close"          size="xs" color="red-4"  @click="nlForm.blocks.splice(bi,1)" />
              </div>
              <q-card-section class="q-pt-xs q-gutter-sm">
                <template v-if="block.type==='intro'">
                  <q-input v-model="block.title"   label="Heading"   dark outlined dense label-color="teal-3" color="teal-3" />
                  <q-input v-model="block.body"    label="Body text" dark outlined dense type="textarea" :rows="4" label-color="teal-3" color="teal-3" />
                </template>
                <template v-else-if="block.type==='news'">
                  <q-input v-model="block.heading" label="Section heading" dark outlined dense label-color="teal-3" color="teal-3" />
                  <q-select v-model="block.count" :options="[1,2,3,4,5]" label="Number of articles"
                    dark outlined dense label-color="teal-3" color="teal-3" emit-value />
                </template>
                <template v-else-if="block.type==='shows'">
                  <q-input v-model="block.heading" label="Section heading" dark outlined dense label-color="teal-3" color="teal-3" />
                  <div class="text-caption text-grey-6">Auto-fetches upcoming show map points</div>
                </template>
                <template v-else-if="block.type==='spotlight'">
                  <q-input v-model="block.heading"   label="Heading"         dark outlined dense label-color="teal-3" color="teal-3" />
                  <q-input v-model="block.text"      label="Body text"       dark outlined dense type="textarea" :rows="3" label-color="teal-3" color="teal-3" />
                  <q-input v-model="block.image_url" label="Image URL (opt)" dark outlined dense label-color="teal-3" color="teal-3" />
                </template>
                <template v-else-if="block.type==='html'">
                  <q-input v-model="block.content" label="HTML (inline styles for email)"
                    dark outlined dense type="textarea" :rows="6" label-color="teal-3" color="teal-3" />
                </template>
              </q-card-section>
            </div>

            <!-- Add block row -->
            <div class="row q-gutter-xs q-mt-sm">
              <q-btn v-for="bt in BLOCK_TYPES" :key="bt.type"
                :icon="bt.icon" :label="bt.label" flat size="sm" :color="bt.color"
                class="nl-add-btn" @click="addBlock(bt.type)" />
            </div>
          </div>

          <!-- Right: actions -->
          <div class="col-12 col-md-4">
            <q-card class="nl-panel q-mb-md">
              <q-card-section>
                <div class="text-subtitle2 text-teal-3 q-mb-md">Actions</div>
                <div class="q-gutter-sm column">
                  <q-btn color="teal-6" unelevated icon="save" label="Save Draft"
                    :loading="saving" @click="saveNewsletter" class="full-width" />
                  <q-btn color="indigo-5" unelevated icon="science" label="Test to myself"
                    :loading="sendingTest" :disable="!nlForm.title || !nlForm.subject"
                    @click="sendTestEmail" class="full-width" />
                  <q-btn color="deep-orange-7" unelevated icon="send" label="Send Now"
                    :loading="sending" :disable="!nlForm.title || !nlForm.subject"
                    @click="openSendDialog(null)" class="full-width" />
                </div>
              </q-card-section>
            </q-card>
            <q-card class="nl-panel">
              <q-card-section>
                <div class="text-subtitle2 text-teal-3 q-mb-xs">Block Types</div>
                <div v-for="bt in BLOCK_TYPES" :key="bt.type" class="row items-start q-py-xs">
                  <q-icon :name="bt.icon" :color="bt.color" size="15px" class="q-mr-sm q-mt-xs" />
                  <div>
                    <div class="text-caption text-white text-weight-bold">{{ bt.label }}</div>
                    <div class="text-caption text-grey-6" style="font-size:10px">{{ bt.desc }}</div>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </template>
    </div>

    <!-- ══════════════════════════════════════════════════════════════════════
         TAB: DAILY CUTENESS
    ═══════════════════════════════════════════════════════════════════════ -->
    <div v-show="activeTab === 'cuteness'">

      <!-- Header row -->
      <div class="row items-center q-mb-md">
        <div class="text-body1 text-pink-4 text-weight-bold col">{{ calMonthName }}</div>
        <q-btn flat round dense icon="chevron_left" color="grey-4" @click="prevMonth" />
        <q-btn flat round dense icon="chevron_right" color="grey-4" @click="nextMonth" />
        <q-btn flat dense color="teal-4" label="Today" size="sm" @click="goToday" class="q-ml-sm" />
        <q-btn v-if="todayStagedEntry" unelevated color="pink-7" icon="send"
          :label="`Send Today (${stats.cuteActive} subs)`" size="sm"
          :loading="sendingCuteness" class="q-ml-md"
          @click="sendCutenessNow(todayDateStr)" />
      </div>

      <!-- Calendar grid -->
      <div class="cal-grid">
        <div v-for="d in ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']" :key="d"
          class="cal-header">{{ d }}</div>
        <div v-for="(cell, ci) in calDays" :key="ci"
          :class="['cal-cell', {
            'cal-cell--empty':  !cell,
            'cal-cell--today':  cell === todayDateStr,
            'cal-cell--staged': cell && cutenessMap[cell]?.status === 'staged',
            'cal-cell--sent':   cell && cutenessMap[cell]?.status === 'sent',
          }]"
          @click="cell && openCutenessDialog(cell)">
          <span v-if="cell" class="cal-day-num">{{ parseInt(cell.slice(-2)) }}</span>
          <q-icon v-if="cell && cutenessMap[cell]?.status === 'staged'" name="favorite" size="14px" class="cal-icon" />
          <q-icon v-if="cell && cutenessMap[cell]?.status === 'sent'"   name="check_circle" size="14px" class="cal-icon" />
        </div>
      </div>

      <div class="row q-col-gutter-sm q-mt-md text-caption text-grey-5 items-center">
        <span class="cal-legend cal-legend--staged"></span><span>Staged</span>
        <span class="q-ml-sm cal-legend cal-legend--sent"></span><span>Sent</span>
        <span class="q-ml-sm cal-legend cal-legend--today"></span><span>Today</span>
        <span class="q-ml-md text-grey-6">Click any day to stage or edit a cuteness email.</span>
      </div>
    </div>

    <!-- ══════════════════════════════════════════════════════════════════════
         TAB: TEMPLATES
    ═══════════════════════════════════════════════════════════════════════ -->
    <div v-show="activeTab === 'templates'">
      <div class="row q-col-gutter-lg">
        <div v-for="tpl in TEMPLATE_DEFS" :key="tpl.id" class="col-12 col-md-6 col-lg-4">
          <q-card class="nl-panel full-height">
            <q-card-section>
              <div class="text-subtitle2 text-teal-2 q-mb-xs">
                <q-icon :name="tpl.icon" class="q-mr-xs" />{{ tpl.label }}
              </div>
              <div class="text-caption text-grey-6 q-mb-md" style="font-size:11px">{{ tpl.hint }}</div>
              <q-input v-model="tplForms[tpl.id].subject" label="Subject" dark outlined dense
                label-color="teal-3" color="teal-3" class="q-mb-sm" />
              <q-input v-model="tplForms[tpl.id].html_body" label="HTML body"
                dark outlined type="textarea" :rows="14"
                label-color="teal-3" color="teal-3"
                hint="Full HTML email — use inline styles" />
            </q-card-section>
            <q-card-actions align="right">
              <q-btn unelevated color="teal-6" icon="save" label="Save"
                :loading="savingTpl === tpl.id" @click="saveTemplate(tpl.id)" />
            </q-card-actions>
          </q-card>
        </div>
      </div>
    </div>

    <!-- ══════════════════════════════════════════════════════════════════════
         TAB: SUBSCRIBERS
    ═══════════════════════════════════════════════════════════════════════ -->
    <div v-show="activeTab === 'subscribers'">
      <div class="row q-col-gutter-md q-mb-lg">
        <div class="col-4"><div class="stat-card text-center q-pa-md">
          <div class="text-h4 text-teal-3 text-bold">{{ stats.totalActive }}</div>
          <div class="text-caption text-grey-5">Active</div>
        </div></div>
        <div class="col-4"><div class="stat-card text-center q-pa-md">
          <div class="text-h4 text-pink-4 text-bold">{{ stats.cuteActive }}</div>
          <div class="text-caption text-grey-5">Cuteness</div>
        </div></div>
        <div class="col-4"><div class="stat-card text-center q-pa-md">
          <div class="text-h4 text-amber-4 text-bold">{{ subscribers.length }}</div>
          <div class="text-caption text-grey-5">Total</div>
        </div></div>
      </div>

      <div class="row q-gutter-md q-mb-md items-center">
        <q-input v-model="subSearch" dense dark outlined color="teal-3" label-color="teal-3"
          placeholder="Search email or name…" clearable style="min-width:240px">
          <template #prepend><q-icon name="search" size="16px" /></template>
        </q-input>
        <q-select v-model="subFilter"
          :options="[{label:'All',value:'all'},{label:'Newsletter',value:'newsletter'},{label:'Cuteness',value:'cuteness'},{label:'Active only',value:'active'},{label:'Unsubscribed',value:'unsubscribed'}]"
          dark outlined dense color="teal-3" label-color="teal-3" label="Filter"
          emit-value map-options style="min-width:170px" />
        <q-space />
        <q-btn flat dense icon="download" color="teal-4" label="Export CSV" @click="exportCsv" />
      </div>

      <q-card class="nl-panel">
        <q-list separator dark style="background:transparent">
          <q-item dense class="q-py-xs" style="opacity:.6">
            <q-item-section style="max-width:260px"><span class="text-caption text-grey-5 ls-1">EMAIL</span></q-item-section>
            <q-item-section><span class="text-caption text-grey-5 ls-1">NAME</span></q-item-section>
            <q-item-section side><span class="text-caption text-grey-5 ls-1">LISTS</span></q-item-section>
            <q-item-section side><span class="text-caption text-grey-5 ls-1">STATUS</span></q-item-section>
            <q-item-section side><span class="text-caption text-grey-5 ls-1">SINCE</span></q-item-section>
            <q-item-section side></q-item-section>
          </q-item>
          <q-item v-for="sub in filteredSubscribers" :key="sub.email" dense class="q-py-xs">
            <q-item-section style="max-width:260px">
              <q-item-label style="font-size:12px" class="text-grey-3">{{ sub.email }}</q-item-label>
            </q-item-section>
            <q-item-section>
              <q-item-label style="font-size:11px" class="text-grey-5">{{ sub.name || '—' }}</q-item-label>
            </q-item-section>
            <q-item-section side>
              <div class="row q-gutter-xs">
                <q-badge v-if="sub.subscribed_newsletter" color="teal-8"    label="NL"  />
                <q-badge v-if="sub.subscribed_cuteness"   color="pink-8"    label="🐾"  />
              </div>
            </q-item-section>
            <q-item-section side>
              <q-badge :color="sub.status === 'active' ? 'teal' : 'grey-8'" :label="sub.status" />
            </q-item-section>
            <q-item-section side>
              <q-item-label style="font-size:10px" class="text-grey-6">{{ fmtDate(sub.created_at) }}</q-item-label>
            </q-item-section>
            <q-item-section side>
              <div class="row">
                <q-btn v-if="sub.status==='active'" flat round dense icon="person_off"
                  color="orange-4" size="xs" @click="toggleSub(sub,'unsubscribed')" />
                <q-btn v-else flat round dense icon="person_add"
                  color="teal-4" size="xs" @click="toggleSub(sub,'active')" />
                <q-btn flat round dense icon="delete" color="red-4" size="xs"
                  @click="deleteSub(sub)" />
              </div>
            </q-item-section>
          </q-item>
          <q-item v-if="filteredSubscribers.length === 0">
            <q-item-section class="text-center text-grey-6 q-py-lg">No subscribers match filter.</q-item-section>
          </q-item>
        </q-list>
      </q-card>
    </div>

    <!-- ══ SEND CONFIRM DIALOG ══════════════════════════════════════════════ -->
    <q-dialog v-model="sendDialog.show" persistent>
      <q-card dark class="nl-panel" style="min-width:360px">
        <q-card-section>
          <div class="text-h6 text-white q-mb-xs">Send Newsletter</div>
          <div class="text-body2 text-grey-4">
            Send <strong class="text-teal-3">{{ sendDialog.title }}</strong> to
            <strong class="text-teal-3">{{ stats.nlActive }}</strong> active newsletter subscribers.
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Send Now" color="deep-orange-7" icon="send"
            :loading="sending" @click="doSendNewsletter" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- ══ CUTENESS STAGE / EDIT DIALOG ════════════════════════════════════ -->
    <q-dialog v-model="cutenessDialog.show" persistent>
      <q-card dark class="nl-panel" style="min-width:480px;max-width:640px;width:100%">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6 text-pink-3">
            {{ cutenessDialog.editId ? 'Edit Cuteness' : 'Stage Cuteness' }}
            <span class="text-caption text-grey-5 q-ml-sm">{{ cutenessDialog.date }}</span>
          </div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>
        <q-card-section class="q-gutter-md">
          <q-input v-model="cutenessDialog.subject" label="Email subject" dark outlined dense
            label-color="pink-3" color="pink-3" />
          <q-input v-model="cutenessDialog.body_text" label="Message text" dark outlined dense
            type="textarea" :rows="3" label-color="pink-3" color="pink-3"
            hint="Appears above the photo in the email" />

          <!-- Photo picker from gallery -->
          <div>
            <div class="text-caption text-pink-4 text-uppercase ls-1 q-mb-xs">Photo</div>
            <q-input v-model="cutenessDialog.photo_url" label="Photo URL" dark outlined dense
              label-color="pink-3" color="pink-3" class="q-mb-xs" />

            <div v-if="cutenessDialog.photo_url" class="q-mb-sm">
              <img :src="cutenessDialog.photo_url" style="max-width:100%;max-height:140px;border-radius:8px;object-fit:cover;display:block" />
            </div>

            <!-- Gallery picker -->
            <div class="text-caption text-grey-6 q-mb-xs">Or pick from gallery:</div>
            <q-input v-model="cutenessGallerySearch" dense dark outlined color="pink-3"
              placeholder="Search captions…" clearable class="q-mb-xs">
              <template #prepend><q-icon name="search" size="14px" color="grey-5" /></template>
            </q-input>
            <div class="cuteness-gallery-grid">
              <div v-for="photo in filteredCutenessGallery" :key="photo.id"
                class="cuteness-thumb"
                :class="{'cuteness-thumb--sel': cutenessDialog.photo_url === photo.url}"
                :title="photo.caption || photo.category"
                @click="cutenessDialog.photo_url = photo.url; cutenessDialog.caption = photo.caption || ''">
                <img :src="photo.url" :alt="photo.caption || ''" loading="lazy" />
                <q-icon v-if="cutenessDialog.photo_url === photo.url" name="check_circle"
                  class="thumb-check" />
              </div>
              <div v-if="filteredCutenessGallery.length === 0"
                class="text-grey-6 text-caption q-py-sm" style="grid-column:1/-1;text-align:center">
                No photos found
              </div>
            </div>
          </div>

          <q-input v-model="cutenessDialog.caption" label="Photo caption (optional)" dark outlined dense
            label-color="pink-3" color="pink-3" />
        </q-card-section>
        <q-card-actions align="right" class="q-pa-md">
          <q-btn v-if="cutenessDialog.editId" flat icon="delete" color="red-4" label="Remove"
            @click="deleteCutenessEntry" />
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated :label="cutenessDialog.editId ? 'Update' : 'Stage'" color="pink-6"
            icon="favorite" :loading="savingCuteness" :disable="!cutenessDialog.photo_url"
            @click="saveCutenessEntry" />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { supabase } from 'src/lib/supabase'
import type { GalleryPhoto } from 'src/lib/supabase'

const $q = useQuasar()

// ── Types ──────────────────────────────────────────────────────────────────
type BlockType = 'intro' | 'news' | 'shows' | 'spotlight' | 'html'

interface Block {
  type:       BlockType
  title?:     string
  body?:      string
  heading?:   string
  count?:     number
  text?:      string
  image_url?: string
  content?:   string
}

interface NLetter {
  id:              string
  title:           string
  subject:         string | null
  blocks:          Block[] | null
  status:          'draft' | 'sending' | 'sent'
  sent_at:         string | null
  recipient_count: number | null
  created_at:      string
}

interface Subscriber {
  email:                 string
  name:                  string | null
  status:                'active' | 'unsubscribed'
  subscribed_newsletter: boolean
  subscribed_cuteness:   boolean
  created_at:            string
}

interface CutenessEntry {
  id:             string
  scheduled_date: string
  photo_url:      string
  caption:        string | null
  body_text:      string | null
  subject:        string
  status:         'staged' | 'sent' | 'skipped'
  sent_at:        string | null
}

interface EmailTemplate { id: string; subject: string; html_body: string }

// ── State ──────────────────────────────────────────────────────────────────
const activeTab    = ref<'newsletter' | 'cuteness' | 'templates' | 'subscribers'>('newsletter')
const nlView       = ref<'list' | 'edit'>('list')
const loading      = ref(true)
const saving       = ref(false)
const sending      = ref(false)
const sendingTest  = ref(false)
const setupNeeded  = ref(false)

const newsletters    = ref<NLetter[]>([])
const subscribers    = ref<Subscriber[]>([])
const cutenessQueue  = ref<CutenessEntry[]>([])
const galleryPhotos  = ref<GalleryPhoto[]>([])
const galleryLoaded  = ref(false)
const savingTpl      = ref<string | null>(null)
const sendingCuteness = ref(false)
const savingCuteness  = ref(false)

// ── Newsletter form ────────────────────────────────────────────────────────
const editingNlId = ref<string | null>(null)
const nlForm = reactive({ title: '', subject: '', blocks: [] as Block[] })

// ── Send dialog ────────────────────────────────────────────────────────────
const sendDialog = reactive({ show: false, title: '', nlId: null as string | null })

// ── Subscriber search ──────────────────────────────────────────────────────
const subSearch  = ref('')
const subFilter  = ref('all')

// ── Templates ─────────────────────────────────────────────────────────────
const tplForms = reactive<Record<TplId, { subject: string; html_body: string }>>({
  welcome:  { subject: '', html_body: '' },
  weekly:   { subject: '', html_body: '' },
  cuteness: { subject: '', html_body: '' },
})

const TEMPLATE_DEFS = [
  {
    id: 'welcome' as const, icon: 'mark_email_read', label: 'Welcome Email',
    hint: 'Sent when someone subscribes. Variables: {{name}} {{email}} {{unsubscribe_url}}',
  },
  {
    id: 'weekly' as const,  icon: 'newspaper',       label: 'Weekly Digest Wrapper',
    hint: 'Wraps assembled content blocks. Variables: {{name}} {{subject}} {{blocks_html}} {{unsubscribe_url}}',
  },
  {
    id: 'cuteness' as const, icon: 'favorite',       label: 'Daily Cuteness',
    hint: 'Daily photo email. Variables: {{name}} {{photo_url}} {{caption}} {{body_text}} {{date}} {{unsubscribe_url}}',
  },
]
type TplId = (typeof TEMPLATE_DEFS)[number]['id']

// ── Calendar state ─────────────────────────────────────────────────────────
const calYear  = ref(new Date().getFullYear())
const calMonth = ref(new Date().getMonth())

const calMonthName = computed(() =>
  new Date(calYear.value, calMonth.value).toLocaleString('default', { month: 'long', year: 'numeric' })
)

const todayDateStr = new Date().toISOString().slice(0, 10)

const calDays = computed(() => {
  const firstDay   = new Date(calYear.value, calMonth.value, 1).getDay()
  const totalDays  = new Date(calYear.value, calMonth.value + 1, 0).getDate()
  const cells: (string | null)[] = []
  for (let i = 0; i < firstDay; i++) cells.push(null)
  for (let d = 1; d <= totalDays; d++) {
    cells.push(`${calYear.value}-${String(calMonth.value + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`)
  }
  return cells
})

const cutenessMap = computed(() => {
  const m: Record<string, CutenessEntry> = {}
  cutenessQueue.value.forEach(e => { m[e.scheduled_date] = e })
  return m
})

const todayStagedEntry = computed(() =>
  cutenessMap.value[todayDateStr]?.status === 'staged' ? cutenessMap.value[todayDateStr] : null
)

function prevMonth() {
  if (calMonth.value === 0) { calMonth.value = 11; calYear.value-- } else calMonth.value--
}
function nextMonth() {
  if (calMonth.value === 11) { calMonth.value = 0; calYear.value++ } else calMonth.value++
}
function goToday() {
  calYear.value  = new Date().getFullYear()
  calMonth.value = new Date().getMonth()
}

// ── Cuteness dialog ────────────────────────────────────────────────────────
const cutenessDialog = reactive({
  show: false, editId: null as string | null, date: '', photo_url: '',
  caption: '', body_text: '', subject: "🐾 Your Daily Cuteness from Nikki's!",
})

const cutenessGallerySearch = ref('')

const filteredCutenessGallery = computed(() => {
  const q = cutenessGallerySearch.value.trim().toLowerCase()
  let list = galleryPhotos.value
  if (q) list = list.filter(p => p.caption?.toLowerCase().includes(q) || p.category?.toLowerCase().includes(q))
  return list.slice(0, 30) // cap grid for perf
})

async function openCutenessDialog(date: string) {
  await ensureGalleryLoaded()
  const existing = cutenessMap.value[date]
  cutenessGallerySearch.value = ''
  if (existing) {
    Object.assign(cutenessDialog, {
      show: true, editId: existing.id, date,
      photo_url: existing.photo_url, caption: existing.caption ?? '',
      body_text: existing.body_text ?? '', subject: existing.subject,
    })
  } else {
    Object.assign(cutenessDialog, {
      show: true, editId: null, date,
      photo_url: '', caption: '', body_text: '',
      subject: "🐾 Your Daily Cuteness from Nikki's!",
    })
  }
}

async function saveCutenessEntry() {
  if (!cutenessDialog.photo_url) return
  savingCuteness.value = true
  const payload = {
    scheduled_date: cutenessDialog.date,
    photo_url:      cutenessDialog.photo_url,
    caption:        cutenessDialog.caption || null,
    body_text:      cutenessDialog.body_text || null,
    subject:        cutenessDialog.subject,
    status:         'staged',
  }
  if (cutenessDialog.editId) {
    await supabase.from('cuteness_queue').update(payload).eq('id', cutenessDialog.editId)
  } else {
    await supabase.from('cuteness_queue').insert(payload)
  }
  await loadCutenessQueue()
  savingCuteness.value   = false
  cutenessDialog.show    = false
}

async function deleteCutenessEntry() {
  if (!cutenessDialog.editId) return
  await supabase.from('cuteness_queue').delete().eq('id', cutenessDialog.editId)
  await loadCutenessQueue()
  cutenessDialog.show = false
}

async function sendCutenessNow(date: string) {
  sendingCuteness.value = true
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const r    = await fetch('/api/newsletter/send-cuteness', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${session?.access_token ?? ''}` },
      body:    JSON.stringify({ date }),
    })
    const data = await r.json() as { ok?: boolean; sent?: number; error?: string }
    if (data.ok) {
      $q.notify({ message: `Cuteness sent to ${data.sent} subscribers 🐾`, color: 'pink-7', position: 'top', icon: 'favorite' })
      await loadCutenessQueue()
    } else {
      $q.notify({ message: data.error ?? 'Send failed', color: 'red', position: 'top' })
    }
  } catch {
    $q.notify({ message: 'Connection error', color: 'red', position: 'top' })
  }
  sendingCuteness.value = false
}

// ── Stats ──────────────────────────────────────────────────────────────────
const stats = computed(() => ({
  totalActive:  subscribers.value.filter(s => s.status === 'active').length,
  nlActive:     subscribers.value.filter(s => s.status === 'active' && s.subscribed_newsletter).length,
  cuteActive:   subscribers.value.filter(s => s.status === 'active' && s.subscribed_cuteness).length,
  unsubscribed: subscribers.value.filter(s => s.status === 'unsubscribed').length,
}))

// ── Filtered subscribers ───────────────────────────────────────────────────
const filteredSubscribers = computed(() => {
  let list = subscribers.value
  if (subFilter.value === 'newsletter')   list = list.filter(s => s.subscribed_newsletter)
  else if (subFilter.value === 'cuteness') list = list.filter(s => s.subscribed_cuteness)
  else if (subFilter.value === 'active')   list = list.filter(s => s.status === 'active')
  else if (subFilter.value === 'unsubscribed') list = list.filter(s => s.status === 'unsubscribed')
  const q = subSearch.value.trim().toLowerCase()
  if (q) list = list.filter(s => s.email.toLowerCase().includes(q) || (s.name ?? '').toLowerCase().includes(q))
  return list
})

// ── Block types ────────────────────────────────────────────────────────────
const BLOCK_TYPES = [
  { type: 'intro' as BlockType,    icon: 'subject',     color: 'teal-4',   label: 'Intro',     desc: 'Opening heading + body text' },
  { type: 'news' as BlockType,     icon: 'newspaper',   color: 'blue-4',   label: 'News',      desc: 'Auto-pulls recent articles' },
  { type: 'shows' as BlockType,    icon: 'event',       color: 'purple-4', label: 'Shows',     desc: 'Auto-fetches upcoming shows' },
  { type: 'spotlight' as BlockType, icon: 'star',       color: 'amber-4',  label: 'Spotlight', desc: 'Feature with heading + image' },
  { type: 'html' as BlockType,     icon: 'code',        color: 'grey-4',   label: 'HTML',      desc: 'Raw HTML block' },
]

function blockIcon(t: BlockType)  { return BLOCK_TYPES.find(b => b.type === t)?.icon  ?? 'widgets' }
function blockColor(t: BlockType) { return BLOCK_TYPES.find(b => b.type === t)?.color ?? 'grey-5' }
function blockLabel(t: BlockType) { return BLOCK_TYPES.find(b => b.type === t)?.label ?? t }

function addBlock(type: BlockType) {
  const defaults: Record<BlockType, Block> = {
    intro:     { type, title: '', body: '' },
    news:      { type, heading: 'Latest News', count: 3 },
    shows:     { type, heading: 'Upcoming Shows' },
    spotlight: { type, heading: '', text: '', image_url: '' },
    html:      { type, content: '' },
  }
  nlForm.blocks.push({ ...defaults[type] })
}

function moveBlock(i: number, dir: -1 | 1) {
  const j = i + dir
  if (j < 0 || j >= nlForm.blocks.length) return
  const tmp = nlForm.blocks[i]!
  nlForm.blocks[i] = nlForm.blocks[j]!
  nlForm.blocks[j] = tmp
}

// ── Newsletter CRUD ────────────────────────────────────────────────────────
function newNewsletter() {
  editingNlId.value = null
  Object.assign(nlForm, { title: '', subject: '', blocks: [] })
  nlView.value = 'edit'
}

function editNewsletter(nl: NLetter) {
  editingNlId.value = nl.id
  Object.assign(nlForm, {
    title:   nl.title,
    subject: nl.subject ?? '',
    blocks:  (nl.blocks ?? []).map(b => ({ ...b })),
  })
  nlView.value = 'edit'
}

async function saveNewsletter() {
  if (!nlForm.title) return
  saving.value = true
  const payload = { title: nlForm.title, subject: nlForm.subject || null, blocks: nlForm.blocks }
  if (editingNlId.value) {
    await supabase.from('newsletters').update(payload).eq('id', editingNlId.value)
  } else {
    const { data } = await supabase.from('newsletters').insert({ ...payload, status: 'draft' }).select().single()
    if (data) editingNlId.value = (data as { id: string }).id
  }
  await loadNewsletters()
  saving.value = false
  $q.notify({ message: 'Draft saved', color: 'teal', position: 'top', icon: 'save' })
}

function deleteNewsletter(nl: NLetter) {
  $q.dialog({ title: 'Delete?', message: `Delete "${nl.title}"?`, cancel: true, dark: true })
    .onOk(() => {
      void supabase.from('newsletters').delete().eq('id', nl.id).then(() => {
        newsletters.value = newsletters.value.filter(n => n.id !== nl.id)
      })
    })
}

function openSendDialog(nl: NLetter | null) {
  sendDialog.title = nl?.title ?? nlForm.title
  sendDialog.nlId  = nl?.id ?? editingNlId.value
  sendDialog.show  = true
}

async function doSendNewsletter() {
  if (!sendDialog.nlId) {
    // Save first if editing an unsaved draft
    await saveNewsletter()
    sendDialog.nlId = editingNlId.value
  }
  if (!sendDialog.nlId) return
  sending.value = true
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const r    = await fetch('/api/newsletter/send', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${session?.access_token ?? ''}` },
      body:    JSON.stringify({ newsletter_id: sendDialog.nlId }),
    })
    const data = await r.json() as { ok?: boolean; sent?: number; error?: string }
    if (data.ok) {
      $q.notify({ message: `Sent to ${data.sent} subscribers`, color: 'teal', position: 'top', icon: 'send' })
      sendDialog.show = false
      await loadNewsletters()
      nlView.value = 'list'
    } else {
      $q.notify({ message: data.error ?? 'Send failed', color: 'red', position: 'top' })
    }
  } catch {
    $q.notify({ message: 'Connection error', color: 'red', position: 'top' })
  }
  sending.value = false
}

async function callSendTest(nlId: string) {
  sendingTest.value = true
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const r    = await fetch('/api/newsletter/send-test', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${session?.access_token ?? ''}` },
      body:    JSON.stringify({ newsletter_id: nlId }),
    })
    const data = await r.json() as { ok?: boolean; to?: string; mailgun?: boolean; message?: string; error?: string }
    if (data.ok) {
      if (data.mailgun === false) {
        $q.notify({ message: data.message ?? 'Mailgun not configured', color: 'orange', position: 'top', icon: 'warning' })
      } else {
        $q.notify({ message: `Test sent to ${data.to}`, color: 'indigo-5', position: 'top', icon: 'science' })
      }
    } else {
      $q.notify({ message: data.error ?? 'Test send failed', color: 'red', position: 'top' })
    }
  } catch {
    $q.notify({ message: 'Connection error', color: 'red', position: 'top' })
  }
  sendingTest.value = false
}

async function sendTestEmail() {
  // Save first if we have unsaved changes
  if (!editingNlId.value) await saveNewsletter()
  if (!editingNlId.value) return
  await callSendTest(editingNlId.value)
}

async function sendTestEmailFromList(nl: NLetter) {
  await callSendTest(nl.id)
}

// ── Subscriber actions ─────────────────────────────────────────────────────
async function toggleSub(sub: Subscriber, status: 'active' | 'unsubscribed') {
  await supabase.from('newsletter_subscribers').update({ status }).eq('email', sub.email)
  sub.status = status
}

function deleteSub(sub: Subscriber) {
  $q.dialog({ title: 'Remove subscriber?', message: sub.email, cancel: true, dark: true })
    .onOk(() => {
      void supabase.from('newsletter_subscribers').delete().eq('email', sub.email).then(() => {
        subscribers.value = subscribers.value.filter(s => s.email !== sub.email)
      })
    })
}

function exportCsv() {
  const header = 'email,name,status,newsletter,cuteness,subscribed'
  const rows   = subscribers.value.map(s =>
    `${s.email},${s.name ?? ''},${s.status},${s.subscribed_newsletter},${s.subscribed_cuteness},${s.created_at}`
  )
  const csv  = [header, ...rows].join('\n')
  const blob = new Blob([csv], { type: 'text/csv' })
  const url  = URL.createObjectURL(blob)
  const a    = document.createElement('a'); a.href = url; a.download = 'subscribers.csv'; a.click()
  URL.revokeObjectURL(url)
}

// ── Templates ──────────────────────────────────────────────────────────────
async function saveTemplate(id: string) {
  savingTpl.value = id
  await supabase.from('email_templates').upsert({ id, ...tplForms[id as TplId], updated_at: new Date().toISOString() })
  savingTpl.value = null
  $q.notify({ message: 'Template saved', color: 'teal', position: 'top', icon: 'save' })
}

// ── Data loaders ───────────────────────────────────────────────────────────
async function loadNewsletters() {
  const { data, error } = await supabase
    .from('newsletters').select('*').order('created_at', { ascending: false })
  if (error) { setupNeeded.value = true; return }
  newsletters.value = (data as NLetter[]) ?? []
}

async function loadSubscribers() {
  const { data } = await supabase
    .from('newsletter_subscribers').select('*').order('created_at', { ascending: false })
  subscribers.value = (data as Subscriber[]) ?? []
}

async function loadCutenessQueue() {
  const { data } = await supabase
    .from('cuteness_queue').select('*').order('scheduled_date')
  cutenessQueue.value = (data as CutenessEntry[]) ?? []
}

async function loadTemplates() {
  const { data } = await supabase.from('email_templates').select('*')
  if (data) {
    for (const tpl of data as EmailTemplate[]) {
      const form = tplForms[tpl.id as TplId]
      if (form) Object.assign(form, { subject: tpl.subject, html_body: tpl.html_body })
    }
  }
}

async function ensureGalleryLoaded() {
  if (galleryLoaded.value) return
  const { data } = await supabase
    .from('gallery_photos').select('id,category,url,caption,display_order,published')
    .eq('published', true).order('category').order('display_order')
  galleryPhotos.value = (data as GalleryPhoto[]) ?? []
  galleryLoaded.value = true
}

// ── Helpers ────────────────────────────────────────────────────────────────
function nlStatusColor(s: string) {
  return s === 'sent' ? 'positive' : s === 'sending' ? 'orange' : 'grey-7'
}

function fmtDate(d: string | null) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

// ── Lazy load tabs ─────────────────────────────────────────────────────────
const tabsLoaded = reactive<Record<string, boolean>>({})
watch(activeTab, async (tab) => {
  if (tabsLoaded[tab]) return
  tabsLoaded[tab] = true
  if (tab === 'subscribers') await loadSubscribers()
  if (tab === 'templates')   await loadTemplates()
  if (tab === 'cuteness')    await loadCutenessQueue()
}, { immediate: false })

// ── Setup SQL ──────────────────────────────────────────────────────────────
const SETUP_SQL = `-- Newsletter v2 migration — run once in Supabase SQL Editor

ALTER TABLE newsletter_subscribers
  ADD COLUMN IF NOT EXISTS name text,
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS unsubscribe_token text UNIQUE DEFAULT gen_random_uuid()::text,
  ADD COLUMN IF NOT EXISTS subscribed_newsletter boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS subscribed_cuteness boolean NOT NULL DEFAULT false;

DROP POLICY IF EXISTS "Anon can insert subscribers" ON newsletter_subscribers;
CREATE POLICY "Anon manages subscribers"
  ON newsletter_subscribers FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE newsletters
  ADD COLUMN IF NOT EXISTS blocks jsonb NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'draft',
  ADD COLUMN IF NOT EXISTS recipient_count int;

CREATE TABLE IF NOT EXISTS email_templates (
  id         text PRIMARY KEY,
  subject    text NOT NULL DEFAULT '',
  html_body  text NOT NULL DEFAULT '',
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anon manages templates" ON email_templates FOR ALL USING (true) WITH CHECK (true);

INSERT INTO email_templates (id, subject, html_body) VALUES
('welcome', '🎵 Welcome to Nikki''s Great Music Festivals!',
 '<!DOCTYPE html><html><body style="font-family:Arial,sans-serif;background:#f5f0ff;margin:0;padding:20px"><div style="max-width:560px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden"><div style="background:linear-gradient(135deg,#1a0042,#0d1a3a);padding:36px 28px;text-align:center"><h1 style="color:#ffd700;font-size:24px;margin:0">🎵 Nikki''s Great Music Festivals</h1><p style="color:rgba(255,255,255,.7);margin:8px 0 0;font-size:14px">Welcome to the community</p></div><div style="padding:32px 28px"><h2 style="color:#1a0042">Hey {{name}},</h2><p style="color:#444;line-height:1.7">Thanks for joining! You''re now part of our community of festival fans, campfire pickers, and music adventurers.</p><p style="font-size:11px;color:#aaa;margin-top:28px">You subscribed as {{email}}. <a href="{{unsubscribe_url}}" style="color:#aaa">Unsubscribe</a></p></div></div></body></html>')
ON CONFLICT (id) DO NOTHING;

INSERT INTO email_templates (id, subject, html_body) VALUES
('weekly', '🎵 This Week at Nikki''s',
 '<!DOCTYPE html><html><body style="font-family:Arial,sans-serif;background:#f5f0ff;margin:0;padding:20px"><div style="max-width:560px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden"><div style="background:linear-gradient(135deg,#1a0042,#0d1a3a);padding:36px 28px;text-align:center"><h1 style="color:#ffd700;font-size:24px;margin:0">🎵 Nikki''s Great Music Festivals</h1><p style="color:rgba(255,255,255,.7);margin:8px 0 0;font-size:14px">{{subject}}</p></div><div style="padding:32px 28px"><p style="color:#555">Hi {{name}},</p>{{blocks_html}}<hr style="border:none;border-top:1px solid #eee;margin:28px 0 16px"><p style="font-size:11px;color:#aaa;text-align:center"><a href="{{unsubscribe_url}}" style="color:#aaa">Unsubscribe</a></p></div></div></body></html>')
ON CONFLICT (id) DO NOTHING;

INSERT INTO email_templates (id, subject, html_body) VALUES
('cuteness', '🐾 Your Daily Cuteness from Nikki''s!',
 '<!DOCTYPE html><html><body style="font-family:Arial,sans-serif;background:#fff0f5;margin:0;padding:20px"><div style="max-width:560px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden"><div style="background:linear-gradient(135deg,#880e4f,#ad1457);padding:28px 28px;text-align:center"><h1 style="color:#fff;font-size:22px;margin:0">🐾 Daily Cuteness</h1><p style="color:rgba(255,255,255,.8);margin:6px 0 0;font-size:13px">{{date}}</p></div><div style="padding:32px 28px"><p style="color:#555;line-height:1.7">{{body_text}}</p><img src="{{photo_url}}" alt="{{caption}}" style="max-width:100%;border-radius:8px;display:block;margin:16px 0"/><p v-if="{{caption}}" style="color:#888;font-size:12px;text-align:center;font-style:italic">{{caption}}</p><hr style="border:none;border-top:1px solid #eee;margin:24px 0 12px"><p style="font-size:11px;color:#aaa;text-align:center"><a href="{{unsubscribe_url}}" style="color:#aaa">Unsubscribe</a></p></div></div></body></html>')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS cuteness_queue (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scheduled_date date UNIQUE NOT NULL,
  photo_url      text NOT NULL,
  caption        text,
  body_text      text,
  subject        text NOT NULL DEFAULT '🐾 Your Daily Cuteness from Nikki''s!',
  status         text NOT NULL DEFAULT 'staged',
  sent_at        timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE cuteness_queue ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anon manages cuteness queue"
  ON cuteness_queue FOR ALL USING (true) WITH CHECK (true);`

async function copySetupSql() {
  await navigator.clipboard.writeText(SETUP_SQL)
  $q.notify({ message: 'SQL copied to clipboard', color: 'teal', position: 'top', icon: 'check' })
}

// ── Mount ──────────────────────────────────────────────────────────────────
onMounted(async () => {
  await loadNewsletters()
  loading.value = false
})
</script>

<style lang="scss" scoped>
.nl-panel {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.2);
  border-radius: 12px;
}

.nl-card {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.18);
  border-radius: 12px;
  cursor: pointer;
  transition: border-color 0.2s, transform 0.15s;
  &:hover { border-color: rgba(77,182,172,0.5); transform: translateY(-2px); }
}

.nl-block-card {
  background: #161628;
  border: 1px solid rgba(77,182,172,0.15);
  border-radius: 10px;
}

.nl-add-btn { border: 1px solid rgba(255,255,255,0.08); border-radius: 6px; }

.nl-tabs { border-bottom: 1px solid rgba(77,182,172,0.15); }

.stat-card {
  background: #1a1a2e;
  border: 1px solid rgba(77,182,172,0.15);
  border-radius: 12px;
}

.ls-1  { letter-spacing: 1px; }
.ls-2  { letter-spacing: 2px; }

.setup-banner { background: rgba(255,179,0,0.08); border: 1px solid rgba(255,179,0,0.3); color: #e0f2f1; }

/* ── Calendar ── */
.cal-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 3px;
}

.cal-header {
  text-align: center; font-size: 10px; font-weight: 700;
  color: rgba(255,255,255,0.35); padding: 6px 0; letter-spacing: 1px;
}

.cal-cell {
  min-height: 54px; border-radius: 8px;
  background: #161628;
  border: 1px solid rgba(255,255,255,0.06);
  cursor: pointer; position: relative;
  display: flex; flex-direction: column;
  align-items: flex-start; padding: 6px 8px;
  transition: border-color 0.15s, background 0.15s;

  &:hover:not(&--empty) { border-color: rgba(236,64,122,0.45); background: rgba(236,64,122,0.06); }
  &--empty { cursor: default; background: transparent; border-color: transparent; }
  &--today { border-color: #ffd700 !important; background: rgba(255,215,0,0.07) !important; }
  &--staged { border-color: rgba(236,64,122,0.6); background: rgba(236,64,122,0.1); }
  &--sent   { border-color: rgba(76,175,80,0.4);  background: rgba(76,175,80,0.07); }
}

.cal-day-num {
  font-size: 12px; font-weight: 600;
  color: rgba(255,255,255,0.6);
  .cal-cell--today & { color: #ffd700; }
  .cal-cell--staged & { color: #f48fb1; }
  .cal-cell--sent   & { color: #a5d6a7; }
}

.cal-icon {
  position: absolute; bottom: 5px; right: 5px;
  .cal-cell--staged & { color: #f48fb1; }
  .cal-cell--sent   & { color: #a5d6a7; }
}

.cal-legend {
  display: inline-block; width: 10px; height: 10px; border-radius: 2px;
  &--staged { background: rgba(236,64,122,0.6); }
  &--sent   { background: rgba(76,175,80,0.5); }
  &--today  { background: rgba(255,215,0,0.8); }
}

/* ── Cuteness gallery picker ── */
.cuteness-gallery-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 4px;
  max-height: 160px;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: rgba(236,64,122,0.3) transparent;
}

.cuteness-thumb {
  position: relative; aspect-ratio: 1;
  border-radius: 4px; overflow: hidden;
  cursor: pointer;
  border: 2px solid transparent;
  transition: border-color 0.12s;

  img { width: 100%; height: 100%; object-fit: cover; display: block; }
  &:hover { border-color: rgba(236,64,122,0.5); }
  &--sel  { border-color: #e91e63; }
}

.thumb-check {
  position: absolute; top: 2px; right: 2px;
  color: #e91e63; font-size: 15px;
  filter: drop-shadow(0 0 2px #000);
}
</style>

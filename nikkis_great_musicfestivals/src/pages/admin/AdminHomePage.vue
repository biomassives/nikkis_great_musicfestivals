<template>
  <q-page class="q-pa-lg">

    <div class="row items-center q-mb-lg">
      <div>
        <div class="text-h5 text-teal-3">Homepage Manager</div>
        <div class="text-caption text-grey-5">Click a section to expand · each saves independently</div>
      </div>
      <q-space />
      <q-btn color="teal" unelevated icon="save" label="Save All" :loading="savingAll" @click="saveAll" />
    </div>

    <q-banner v-if="savedAll" rounded class="save-banner q-mb-lg">
      <template #avatar><q-icon name="check_circle" color="teal-4" /></template>
      All sections saved successfully.
    </q-banner>

    <!-- ── ACCORDION ──────────────────────────────────────────── -->
    <q-list bordered class="home-accordion rounded-borders">

      <!-- ① PAGE CONTENT -->
      <q-expansion-item default-opened class="home-section">
        <template #header>
          <q-item-section avatar><q-icon name="edit_note" color="teal-4" /></q-item-section>
          <q-item-section>
            <q-item-label class="section-label-text">Page Content</q-item-label>
            <q-item-label caption class="text-grey-6">Hero, CTAs, artists header, newsletter text</q-item-label>
          </q-item-section>
          <q-item-section side>
            <div class="row items-center q-gutter-sm no-wrap" @click.stop>
              <q-icon v-if="saved.content" name="check_circle" color="positive" size="16px" />
              <q-btn size="xs" color="teal" unelevated label="Save" :loading="saving.content" @click="saveContent" />
            </div>
          </q-item-section>
        </template>
        <q-card class="section-card">
          <q-card-section class="q-gutter-md">
            <div class="text-caption text-teal-5 text-uppercase ls-1">Hero</div>
            <q-input v-model="content.hero_title" label="Hero Title"
              dark outlined dense label-color="teal-3" color="teal-3" />
            <q-input v-model="content.mission_statement" label="Mission Statement"
              type="textarea" autogrow dark outlined dense label-color="teal-3" color="teal-3"
              hint="Shown as the blockquote under the title" />
            <div class="row q-col-gutter-md">
              <div class="col-6">
                <q-input v-model="content.cta_story_label" label="CTA — Story button"
                  dark outlined dense label-color="teal-3" color="teal-3" />
              </div>
              <div class="col-6">
                <q-input v-model="content.cta_tour_label" label="CTA — Tour button"
                  dark outlined dense label-color="teal-3" color="teal-3" />
              </div>
            </div>

            <q-separator dark class="q-my-sm" />
            <div class="text-caption text-teal-5 text-uppercase ls-1">Artists Section Header</div>
            <div class="row q-col-gutter-md">
              <div class="col-6">
                <q-input v-model="content.artists_label" label="Section eyebrow"
                  dark outlined dense label-color="teal-3" color="teal-3" />
              </div>
              <div class="col-6">
                <q-input v-model="content.artists_title" label="Section heading"
                  dark outlined dense label-color="teal-3" color="teal-3" />
              </div>
            </div>

            <q-separator dark class="q-my-sm" />
            <div class="text-caption text-teal-5 text-uppercase ls-1">Newsletter Section</div>
            <q-input v-model="content.subscribe_title" label="Subscribe heading"
              dark outlined dense label-color="teal-3" color="teal-3" />
            <q-input v-model="content.subscribe_body" label="Subscribe description"
              type="textarea" autogrow dark outlined dense label-color="teal-3" color="teal-3" />
          </q-card-section>
          <q-card-actions align="right" class="q-pr-md q-pb-md">
            <q-icon v-if="saved.content" name="check_circle" color="positive" size="18px" class="q-mr-sm" />
            <q-btn unelevated color="teal" label="Save Content" :loading="saving.content" @click="saveContent" />
          </q-card-actions>
        </q-card>
      </q-expansion-item>

      <q-separator dark />

      <!-- ② WELCOME SPLASH -->
      <q-expansion-item class="home-section">
        <template #header>
          <q-item-section avatar><q-icon name="celebration" color="amber-4" /></q-item-section>
          <q-item-section>
            <q-item-label class="section-label-text">Welcome Splash</q-item-label>
            <q-item-label caption class="text-grey-6">Full-screen overlay shown once per session</q-item-label>
          </q-item-section>
          <q-item-section side>
            <div class="row items-center q-gutter-sm no-wrap" @click.stop>
              <q-icon v-if="saved.welcome" name="check_circle" color="positive" size="16px" />
              <q-btn size="xs" color="teal" unelevated label="Save" :loading="saving.welcome" @click="saveWelcome" />
            </div>
          </q-item-section>
        </template>
        <q-card class="section-card">
          <q-card-section class="q-gutter-md">
            <div class="text-caption text-teal-5 text-uppercase ls-1">Background Image</div>
            <div class="row q-col-gutter-md items-center">
              <div class="col">
                <q-input v-model="welcome.image_url" label="Image URL"
                  dark outlined dense label-color="teal-3" color="teal-3" clearable />
              </div>
              <div class="col-auto">
                <q-btn color="teal-8" icon="upload" label="Upload" unelevated
                  :loading="uploadingWelcome" @click="triggerWelcomeUpload" />
                <input ref="welcomeFileInput" type="file" accept="image/*" class="hidden" @change="handleWelcomeUpload" />
              </div>
            </div>
            <div v-if="welcome.image_url" class="q-mt-xs">
              <img :src="welcome.image_url" class="bg-preview" />
            </div>

            <q-separator dark class="q-my-sm" />
            <div class="text-caption text-teal-5 text-uppercase ls-1">Text</div>
            <q-input v-model="welcome.eyebrow" label="Eyebrow (small text above title)"
              dark outlined dense label-color="teal-3" color="teal-3" />
            <q-input v-model="welcome.title" label="Title (Enter for line breaks)"
              type="textarea" :rows="2" autogrow dark outlined label-color="teal-3" color="teal-3" />
            <q-input v-model="welcome.tagline" label="Tagline (italic quote)"
              type="textarea" :rows="2" autogrow dark outlined label-color="teal-3" color="teal-3" />

            <q-separator dark class="q-my-sm" />
            <div class="text-caption text-teal-5 text-uppercase ls-1">Button</div>
            <div class="row q-col-gutter-md items-center">
              <div class="col">
                <q-input v-model="welcome.button_label" label="Button label"
                  dark outlined dense label-color="teal-3" color="teal-3" />
              </div>
              <div class="col-auto column items-center" style="gap:4px">
                <div class="text-caption text-grey-5">Color</div>
                <input type="color" v-model="welcome.button_color" class="color-picker" title="Button border & text color" />
              </div>
            </div>
            <div class="welcome-preview">
              <div class="wp-eyebrow">{{ welcome.eyebrow }}</div>
              <div class="wp-title" style="white-space:pre-line">{{ welcome.title }}</div>
              <div class="wp-tagline">{{ welcome.tagline }}</div>
              <button class="wp-btn" :style="`border-color:${welcome.button_color}; color:${welcome.button_color}`">
                {{ welcome.button_label }} →
              </button>
            </div>
          </q-card-section>
          <q-card-actions align="right" class="q-pr-md q-pb-md">
            <q-icon v-if="saved.welcome" name="check_circle" color="positive" size="18px" class="q-mr-sm" />
            <q-btn unelevated color="teal" label="Save Welcome Splash" :loading="saving.welcome" @click="saveWelcome" />
          </q-card-actions>
        </q-card>
      </q-expansion-item>

      <q-separator dark />

      <!-- ③ ARTIST PROFILES -->
      <q-expansion-item class="home-section">
        <template #header>
          <q-item-section avatar><q-icon name="queue_music" color="purple-3" /></q-item-section>
          <q-item-section>
            <q-item-label class="section-label-text">Artist Profiles</q-item-label>
            <q-item-label caption class="text-grey-6">{{ artists.length }} artist{{ artists.length !== 1 ? 's' : '' }} · each becomes an accordion panel on the homepage</q-item-label>
          </q-item-section>
          <q-item-section side>
            <div class="row items-center q-gutter-sm no-wrap" @click.stop>
              <q-icon v-if="saved.artists" name="check_circle" color="positive" size="16px" />
              <q-btn size="xs" color="teal" unelevated label="Save" :loading="saving.artists" @click="saveArtists" />
              <q-btn size="xs" icon="add" color="teal-7" outline @click.stop="openAddArtist" title="Add artist" />
            </div>
          </q-item-section>
        </template>
        <q-card class="section-card">
          <q-card-section>
            <q-list separator dark style="background:transparent">
              <q-item v-for="(artist, i) in artists" :key="artist.id" dense class="q-py-sm">
                <q-item-section avatar>
                  <q-icon :name="artist.icon || 'music_note'" :color="artist.icon_color" size="22px" />
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-grey-2 text-weight-medium">{{ artist.name }}</q-item-label>
                  <q-item-label caption class="text-grey-6">{{ artist.subtitle }}</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <div class="row q-gutter-xs">
                    <q-btn flat dense round icon="arrow_upward"   color="grey-5" size="sm" :disable="i === 0"                   @click="moveArtist(i, -1)" />
                    <q-btn flat dense round icon="arrow_downward" color="grey-5" size="sm" :disable="i === artists.length - 1" @click="moveArtist(i,  1)" />
                    <q-btn flat dense round icon="edit"   color="teal-4" size="sm" @click="openEditArtist(i)" />
                    <q-btn flat dense round icon="delete" color="red-4"  size="sm" @click="removeArtist(i)" :disable="artists.length <= 1" />
                  </div>
                </q-item-section>
              </q-item>
              <q-item v-if="artists.length === 0">
                <q-item-section class="text-grey-6 text-center q-py-md">No artists yet</q-item-section>
              </q-item>
            </q-list>
          </q-card-section>
          <q-card-actions align="right" class="q-pr-md q-pb-md">
            <q-icon v-if="saved.artists" name="check_circle" color="positive" size="18px" class="q-mr-sm" />
            <q-btn unelevated color="teal" label="Save Artists" :loading="saving.artists" @click="saveArtists" />
          </q-card-actions>
        </q-card>
      </q-expansion-item>

      <q-separator dark />

      <!-- ④ BACKGROUND & THEME -->
      <q-expansion-item class="home-section">
        <template #header>
          <q-item-section avatar><q-icon name="palette" color="deep-orange-3" /></q-item-section>
          <q-item-section>
            <q-item-label class="section-label-text">Background & Theme</q-item-label>
            <q-item-label caption class="text-grey-6">Hero background image, SVG pattern, footer scene</q-item-label>
          </q-item-section>
          <q-item-section side>
            <div class="row items-center q-gutter-sm no-wrap" @click.stop>
              <q-icon v-if="saved.appearance" name="check_circle" color="positive" size="16px" />
              <q-btn size="xs" color="teal" unelevated label="Save" :loading="saving.appearance" @click="saveAppearance" />
            </div>
          </q-item-section>
        </template>
        <q-card class="section-card">
          <q-card-section class="q-gutter-md">
            <div class="text-caption text-teal-5 text-uppercase ls-1">Background Image</div>
            <div class="text-caption text-grey-6">Paste a URL or upload. Overlays on top of the SVG pattern.</div>
            <div class="row q-col-gutter-md items-center">
              <div class="col">
                <q-input v-model="appearance.bg_image_url" label="Image URL (leave blank for SVG pattern only)"
                  dark outlined dense label-color="teal-3" color="teal-3" clearable />
              </div>
              <div class="col-auto">
                <q-btn color="teal-8" icon="upload" label="Upload" unelevated
                  :loading="uploadingBg" @click="triggerBgUpload" />
                <input ref="bgFileInput" type="file" accept="image/*" class="hidden" @change="handleBgUpload" />
              </div>
            </div>
            <div v-if="appearance.bg_image_url" class="q-mt-xs">
              <img :src="appearance.bg_image_url" class="bg-preview" />
              <div class="text-caption text-grey-5 q-mt-xs">Preview</div>
            </div>

            <q-separator dark class="q-my-sm" />
            <div class="text-caption text-teal-5 text-uppercase ls-1">SVG Pattern</div>
            <q-select v-model="appearance.bg_variant" :options="bgVariantOptions" emit-value map-options
              label="Background pattern" dark outlined dense label-color="teal-3" color="teal-3" />
            <q-item dark dense class="q-pa-none">
              <q-item-section>
                <q-item-label class="text-grey-3">Pattern opacity</q-item-label>
                <q-item-label caption class="text-grey-6">{{ Math.round((appearance.bg_opacity ?? 0.09) * 100) }}%</q-item-label>
              </q-item-section>
              <q-item-section>
                <q-slider v-model="appearance.bg_opacity" :min="0.02" :max="0.3" :step="0.01" color="teal-3" dark />
              </q-item-section>
            </q-item>

            <q-separator dark class="q-my-sm" />
            <div class="text-caption text-teal-5 text-uppercase ls-1">SVG Art Colors</div>
            <div class="text-caption text-grey-6 q-mb-sm">Tune the spirograph stroke colors and sky atmosphere — changes preview live below.</div>

            <!-- Sky tint + clouds -->
            <div class="row q-col-gutter-md items-center q-mb-sm">
              <div class="col-auto column items-center" style="gap:4px">
                <div class="text-caption text-grey-5" style="font-size:10px">Sky Tint</div>
                <input type="color" :value="appearance.sky_tint"
                  @input="appearance.sky_tint = ($event.target as HTMLInputElement).value"
                  class="color-picker" title="Sky atmosphere hue" />
              </div>
              <div class="col">
                <q-item dark dense class="q-pa-none">
                  <q-item-section>
                    <q-item-label class="text-grey-3">Cloud softness</q-item-label>
                    <q-item-label caption class="text-grey-6">{{ Math.round(appearance.clouds_opacity * 100) }}%</q-item-label>
                  </q-item-section>
                  <q-item-section>
                    <q-slider v-model="appearance.clouds_opacity" :min="0" :max="1" :step="0.05" color="teal-3" dark />
                  </q-item-section>
                </q-item>
              </div>
            </div>

            <!-- 4 spirograph stroke color pickers -->
            <div class="row q-gutter-md items-end q-mb-md">
              <div v-for="(label, idx) in ['Stroke 1 (Sun)', 'Stroke 2 (Sky)', 'Stroke 3 (Haze)', 'Stroke 4 (Dusk)']" :key="idx"
                class="column items-center" style="gap:4px">
                <div class="text-caption text-grey-5" style="font-size:10px">{{ label }}</div>
                <input type="color" :value="appearance.spiro_colors[idx]"
                  @input="appearance.spiro_colors.splice(idx, 1, ($event.target as HTMLInputElement).value)"
                  class="color-picker" :title="label" />
              </div>
            </div>

            <!-- Live preview -->
            <div class="text-caption text-grey-5 q-mb-xs">Live Preview</div>
            <div class="spiro-preview-wrap">
              <PageBackground
                variant="home"
                :opacity="appearance.bg_opacity"
                :spiroColors="appearance.spiro_colors"
                :skyTint="appearance.sky_tint"
                :cloudsOpacity="appearance.clouds_opacity"
              />
            </div>

            <q-separator dark class="q-my-sm" />
            <div class="text-caption text-teal-5 text-uppercase ls-1">Footer Scene</div>
            <q-toggle v-model="appearance.footer_default_night" label="Default to night scene on load" color="teal-3" dark />
            <div class="text-caption text-grey-6">Day/night still follows the dark-mode toggle; this controls the initial state for visitors whose preference is unknown.</div>
          </q-card-section>
          <q-card-actions align="right" class="q-pr-md q-pb-md">
            <q-icon v-if="saved.appearance" name="check_circle" color="positive" size="18px" class="q-mr-sm" />
            <q-btn unelevated color="teal" label="Save Appearance" :loading="saving.appearance" @click="saveAppearance" />
          </q-card-actions>
        </q-card>
      </q-expansion-item>

      <q-separator dark />

      <!-- ⑤ FOOTER SKY TEXT -->
      <q-expansion-item class="home-section">
        <template #header>
          <q-item-section avatar><q-icon name="title" color="yellow-5" /></q-item-section>
          <q-item-section>
            <q-item-label class="section-label-text">Footer Sky Text</q-item-label>
            <q-item-label caption class="text-grey-6">Dashed digital message displayed in the footer SVG sky — can link anywhere</q-item-label>
          </q-item-section>
          <q-item-section side>
            <div class="row items-center q-gutter-sm no-wrap" @click.stop>
              <q-icon v-if="saved.skyText" name="check_circle" color="positive" size="16px" />
              <q-btn size="xs" color="teal" unelevated label="Save" :loading="saving.skyText" @click="saveSkyText" />
            </div>
          </q-item-section>
        </template>
        <q-card class="section-card">
          <q-card-section class="q-gutter-md">
            <q-input v-model="skyText.text" label="Sky message (keep short — 30–50 chars)"
              dark outlined dense label-color="teal-3" color="teal-3" clearable
              hint="Rendered in dashed monospace across the footer sky. Leave blank to hide." />
            <q-input v-model="skyText.url" label="Link URL (optional)"
              dark outlined dense label-color="teal-3" color="teal-3" clearable
              hint="e.g. https://archive.org/details/billystrings2026-02-06" />
            <div class="row items-center q-gutter-md">
              <q-input v-model="skyText.color" label="Text color" readonly
                dark outlined dense label-color="teal-3" color="teal-3" style="max-width:180px" />
              <div class="column items-center" style="gap:4px">
                <div class="text-caption text-grey-5">Color</div>
                <input type="color" v-model="skyText.color" class="color-picker" title="Sky text color" />
              </div>
            </div>
            <!-- Preview strip -->
            <div v-if="skyText.text" class="sky-preview">
              <span :style="`
                font-family: 'Courier New', monospace;
                font-weight: 700;
                letter-spacing: 5px;
                font-size: 13px;
                color: transparent;
                -webkit-text-stroke: 0.7px ${skyText.color};
                text-decoration: ${skyText.url ? 'underline' : 'none'};
                opacity: 0.82;
              `">{{ skyText.text }}</span>
            </div>
          </q-card-section>
          <q-card-actions align="right" class="q-pr-md q-pb-md">
            <q-icon v-if="saved.skyText" name="check_circle" color="positive" size="18px" class="q-mr-sm" />
            <q-btn unelevated color="teal" label="Save Sky Text" :loading="saving.skyText" @click="saveSkyText" />
          </q-card-actions>
        </q-card>
      </q-expansion-item>

      <q-separator dark />

      <!-- ⑥ SEO & SOCIAL -->
      <q-expansion-item class="home-section">
        <template #header>
          <q-item-section avatar><q-icon name="search" color="light-blue-3" /></q-item-section>
          <q-item-section>
            <q-item-label class="section-label-text">SEO & Social</q-item-label>
            <q-item-label caption class="text-grey-6">Meta tags, Open Graph, Twitter card</q-item-label>
          </q-item-section>
          <q-item-section side>
            <div class="row items-center q-gutter-sm no-wrap" @click.stop>
              <q-icon v-if="saved.seo" name="check_circle" color="positive" size="16px" />
              <q-btn size="xs" color="teal" unelevated label="Save" :loading="saving.seo" @click="saveSeo" />
            </div>
          </q-item-section>
        </template>
        <q-card class="section-card">
          <q-card-section>
            <q-list bordered class="seo-inner rounded-borders">

              <q-expansion-item icon="travel_explore" label="Search engine basics" header-class="seo-header" default-opened>
                <q-card class="seo-card">
                  <q-card-section class="q-gutter-md">
                    <q-input v-model="seo.site_name" label="Site name" dark outlined dense label-color="teal-3" color="teal-3" />
                    <q-input v-model="seo.meta_description" label="Meta description"
                      type="textarea" autogrow dark outlined dense label-color="teal-3" color="teal-3"
                      :hint="`${seo.meta_description?.length ?? 0} chars — aim for 150–160`"
                      counter maxlength="160" />
                    <q-input v-model="seo.meta_keywords" label="Meta keywords (comma-separated)"
                      dark outlined dense label-color="teal-3" color="teal-3" />
                    <q-input v-model="seo.og_url" label="Canonical URL"
                      dark outlined dense label-color="teal-3" color="teal-3"
                      hint="e.g. https://nikkisgreatmusicfestivals.vercel.app" />
                  </q-card-section>
                </q-card>
              </q-expansion-item>

              <q-separator dark />

              <q-expansion-item icon="share" label="Open Graph (Facebook, LinkedIn, Slack…)" header-class="seo-header">
                <q-card class="seo-card">
                  <q-card-section class="q-gutter-md">
                    <q-input v-model="seo.og_title" label="og:title"
                      dark outlined dense label-color="teal-3" color="teal-3"
                      :hint="`${seo.og_title?.length ?? 0} chars`" />
                    <q-input v-model="seo.og_description" label="og:description"
                      type="textarea" autogrow dark outlined dense label-color="teal-3" color="teal-3"
                      :hint="`${seo.og_description?.length ?? 0} chars — aim for 100–200`" />
                    <div class="text-caption text-grey-5 q-mb-xs">og:image — recommended 1200×630 px</div>
                    <div class="row q-col-gutter-md items-center">
                      <div class="col">
                        <q-input v-model="seo.og_image" label="og:image URL"
                          dark outlined dense label-color="teal-3" color="teal-3" clearable />
                      </div>
                      <div class="col-auto">
                        <q-btn color="teal-8" icon="upload" label="Upload" unelevated
                          :loading="uploadingOg" @click="triggerOgUpload" />
                        <input ref="ogFileInput" type="file" accept="image/*" class="hidden" @change="handleOgUpload" />
                      </div>
                    </div>
                    <div v-if="seo.og_image" class="q-mt-xs og-preview-wrap">
                      <img :src="seo.og_image" class="og-preview" />
                      <div class="text-caption text-grey-5 q-mt-xs">Preview (1200×630 target)</div>
                    </div>
                  </q-card-section>
                </q-card>
              </q-expansion-item>

              <q-separator dark />

              <q-expansion-item icon="tag" label="Twitter / X Card" header-class="seo-header">
                <q-card class="seo-card">
                  <q-card-section class="q-gutter-md">
                    <q-select v-model="seo.twitter_card" :options="twitterCardOptions" emit-value map-options
                      label="Card type" dark outlined dense label-color="teal-3" color="teal-3"
                      hint="summary_large_image shows a big banner — recommended" />
                    <q-input v-model="seo.twitter_site" label="twitter:site (your @handle, optional)"
                      dark outlined dense label-color="teal-3" color="teal-3" />
                    <q-input v-model="seo.twitter_creator" label="twitter:creator (@author handle, optional)"
                      dark outlined dense label-color="teal-3" color="teal-3" />
                  </q-card-section>
                </q-card>
              </q-expansion-item>

            </q-list>
          </q-card-section>
          <q-card-actions align="right" class="q-pr-md q-pb-md">
            <q-icon v-if="saved.seo" name="check_circle" color="positive" size="18px" class="q-mr-sm" />
            <q-btn unelevated color="teal" label="Save SEO" :loading="saving.seo" @click="saveSeo" />
          </q-card-actions>
        </q-card>
      </q-expansion-item>

    </q-list>

    <div class="row justify-end q-mt-lg">
      <q-btn color="teal" unelevated icon="save" label="Save All" :loading="savingAll" @click="saveAll" />
    </div>

    <!-- ── Artist Add / Edit Dialog ───────────────────────── -->
    <q-dialog v-model="artistDialog.open" persistent>
      <q-card style="min-width:460px; max-width:580px; background:#1a1a2e; border:1px solid rgba(77,182,172,0.3)">
        <q-card-section>
          <div class="text-h6 text-teal-3">{{ artistDialog.isNew ? 'Add Artist' : 'Edit Artist' }}</div>
        </q-card-section>
        <q-card-section class="q-gutter-md" style="max-height:72vh; overflow-y:auto">

          <div class="row q-col-gutter-md">
            <div class="col-8">
              <q-input v-model="artistForm.name" label="Artist name *"
                dark outlined dense label-color="teal-3" color="teal-3"
                @update:model-value="autoArtistId" />
            </div>
            <div class="col-4">
              <q-input v-model="artistForm.id" label="Slug *"
                dark outlined dense label-color="teal-3" color="teal-3"
                :readonly="!artistDialog.isNew" hint="Auto-generated" />
            </div>
          </div>

          <q-input v-model="artistForm.subtitle" label="Genre / subtitle"
            dark outlined dense label-color="teal-3" color="teal-3" />

          <div class="row q-col-gutter-md">
            <div class="col-7">
              <q-input v-model="artistForm.icon" label="Icon (Material icon name)"
                dark outlined dense label-color="teal-3" color="teal-3"
                hint="e.g. music_note, queue_music, mic, star">
                <template #prepend>
                  <q-icon :name="artistForm.icon || 'music_note'" :color="artistForm.icon_color" />
                </template>
              </q-input>
            </div>
            <div class="col-5">
              <q-select v-model="artistForm.icon_color" :options="accentColorOptions" emit-value map-options
                label="Accent color" dark outlined dense label-color="teal-3" color="teal-3">
                <template #prepend><q-icon name="circle" :color="artistForm.icon_color" /></template>
              </q-select>
            </div>
          </div>

          <div class="row q-col-gutter-md">
            <div class="col-7">
              <q-input v-model="artistForm.badge_text" label="Badge label (e.g. Headline, Legacy Act)"
                dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
            <div class="col-5">
              <q-select v-model="artistForm.badge_color" :options="accentColorOptions" emit-value map-options
                label="Badge color" dark outlined dense label-color="teal-3" color="teal-3" />
            </div>
          </div>

          <q-input v-model="artistForm.bio_main" label="Main bio paragraph"
            type="textarea" :rows="4" dark outlined label-color="teal-3" color="teal-3" />
          <q-input v-model="artistForm.bio_sub" label="Secondary paragraph (festival experience, tips, etc.)"
            type="textarea" :rows="3" dark outlined label-color="teal-3" color="teal-3" />
          <q-input v-model="artistForm.songsStr" label="Highlight songs (comma-separated)"
            dark outlined dense label-color="teal-3" color="teal-3"
            hint="e.g. Home, Dust in a Baggie, Meet Me at the Creek" />

        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" color="grey-5" v-close-popup />
          <q-btn unelevated label="Save Artist" color="teal"
            :disable="!artistForm.name || !artistForm.id"
            @click="saveArtistDialog" />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-page>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { supabase } from 'src/lib/supabase'
import type { HomepageArtist } from 'src/lib/supabase'
import PageBackground from 'src/components/PageBackground.vue'

// ── Upload refs ──────────────────────────────────────────────────────────────
const uploadingBg      = ref(false)
const uploadingOg      = ref(false)
const uploadingWelcome = ref(false)
const bgFileInput      = ref<HTMLInputElement | null>(null)
const ogFileInput      = ref<HTMLInputElement | null>(null)
const welcomeFileInput = ref<HTMLInputElement | null>(null)

// ── Per-section save state ───────────────────────────────────────────────────
const saving = reactive({ content: false, welcome: false, artists: false, appearance: false, seo: false, skyText: false })
const saved  = reactive({ content: false, welcome: false, artists: false, appearance: false, seo: false, skyText: false })
const savingAll = ref(false)
const savedAll  = ref(false)

function flash(key: keyof typeof saved) {
  saved[key] = true
  setTimeout(() => { saved[key] = false }, 3000)
}

// ── Options ──────────────────────────────────────────────────────────────────
const bgVariantOptions = [
  { label: 'Home — Mardi-Gras spiral',    value: 'home'        },
  { label: 'Support — Soundwave rings',   value: 'support'     },
  { label: 'News — Diagonal ink grid',    value: 'news'        },
  { label: 'Photography — Lens aperture', value: 'photography' },
  { label: 'Maps — Topographic contours', value: 'maps'        },
  { label: 'Merch — Diamond lattice',     value: 'merch'       },
]
const twitterCardOptions = [
  { label: 'summary_large_image (big banner — recommended)', value: 'summary_large_image' },
  { label: 'summary (small square thumbnail)',               value: 'summary'             },
]
const accentColorOptions = [
  { label: 'Amber',       value: 'amber'       },
  { label: 'Deep Orange', value: 'deep-orange' },
  { label: 'Purple',      value: 'purple'      },
  { label: 'Teal',        value: 'teal'        },
  { label: 'Indigo',      value: 'indigo'      },
  { label: 'Green',       value: 'green'       },
  { label: 'Pink',        value: 'pink'        },
  { label: 'Blue',        value: 'blue'        },
  { label: 'Red',         value: 'red'         },
]

// ── Default artist data ──────────────────────────────────────────────────────
const DEFAULT_ARTISTS: HomepageArtist[] = [
  {
    id: 'billy-strings', name: 'Billy Strings',
    subtitle: 'Progressive Bluegrass · Newgrass · Psychedelic',
    icon: 'music_note', icon_color: 'amber',
    badge_text: 'Headline', badge_color: 'amber',
    bio_main: "William Apostol — known to the world as Billy Strings — is a Grammy-winning flatpicker who bends time with a guitar. Raised on the old-time music of Michigan and west of the Blue Ridge, he has become one of the most electrifying live performers in any genre, threading jaw-dropping technique through dark folk imagery and untethered improvisation.",
    bio_sub: "At Nikki's festivals, Billy's sets tend to stretch deep into the night — the jam-grass crowd locks in, and the field turns into something that feels less like a concert and more like a ritual. Bring layers. Bring patience. Let the third set happen to you.",
    songs: ['Home', 'Dust in a Baggie', 'Meet Me at the Creek'],
  },
  {
    id: 'leftover-salmon', name: 'Leftover Salmon',
    subtitle: 'Polyethnic Cajun Slamgrass · Roots · Mountain Folk',
    icon: 'water', icon_color: 'deep-orange',
    badge_text: 'Legacy Act', badge_color: 'deep-orange',
    bio_main: 'Colorado\'s Leftover Salmon invented "Polyethnic Cajun Slamgrass" — a label that sounds like a joke until you hear it, and then it makes perfect sense. Vince Herman and Mark Vann started cooking something strange and wonderful in the early \'90s, and the band has been a cornerstone of the jam scene ever since.',
    bio_sub: "Festival crowds who've seen Leftover Salmon dozens of times will tell you: no two shows are the same. The energy is communal, the musicianship is staggering, and the party starts before the first note lands. Pack a cowboy hat. Hydrate. Dance until your knees forget they have feelings.",
    songs: ['Zombie Jamboree', 'Salmon Run', 'Euphoria'],
  },
  {
    id: 'stringdusters', name: 'The Infamous Stringdusters',
    subtitle: 'Grammy Bluegrass · Acoustic Jam · Americana',
    icon: 'star', icon_color: 'purple',
    badge_text: 'Grammy Winners', badge_color: 'purple',
    bio_main: "The Infamous Stringdusters have spent two decades proving that bluegrass is not a museum piece. Grammy-winning and perpetually evolving, the band writes originals that sound traditional until they don't, and then they improvise in ways that should not work but absolutely do.",
    bio_sub: 'Their sets at outdoor festivals have a particular magic: acoustic instruments carrying over acres of open field, five-part harmonies landing like a surprise. The Dusters reward attentive listening and reward dancing in equal measure.',
    songs: ['Fork in the Road', 'Silver Sky', 'Things You Left Behind'],
  },
]

// ── Reactive data ────────────────────────────────────────────────────────────
const welcome = reactive({
  image_url:    'https://picsum.photos/seed/bluegrass-evening/1920/1080',
  eyebrow:      'Welcome to',
  title:        "Nikki's Great\nMusic Festivals",
  tagline:      '"Helping to improve lives by improving access to great music, community, and the outdoors."',
  button_label: 'Enter the Festival',
  button_color: '#ffffff',
})

const content = reactive({
  hero_title:        "Nikki's Great Music Festivals",
  mission_statement: 'Helping to improve lives by improving access to great music, community, and the outdoors.',
  cta_story_label:   'Our Full Story',
  cta_tour_label:    'Explore the Tour',
  artists_label:     'Artist Interviews',
  artists_title:     'Featured Artists',
  subscribe_title:   'Join the Newsletter Adventure',
  subscribe_body:    'Show dates, artist interviews, trail reports, and community stories — straight to your inbox.',
})

const artists = ref<HomepageArtist[]>([...DEFAULT_ARTISTS])

const appearance = reactive({
  bg_image_url:         null as string | null,
  bg_variant:           'home',
  bg_opacity:           0.09,
  footer_default_night: false,
  // SVG art tuner
  spiro_colors:   ['#f5a623', '#b39ddb', '#5ba3c9', '#e8956c'] as string[],
  sky_tint:        '#c8dff0',
  clouds_opacity:  0.55,
})

const skyText = reactive({
  text:  'Music Festivals & Nature Camping & Community Building',
  url:   '',
  color: '#ffd700',
})

const seo = reactive({
  site_name:       "Nikki's Great Music Festivals",
  og_title:        "Nikki's Great Music Festivals — Tour Maps, Live Music & Community",
  og_description:  'Follow the festival trail — tour maps, artist interviews, photography, and community across the US.',
  og_image:        null as string | null,
  og_url:          'https://nikkisgreatmusicfestivals.vercel.app',
  meta_description:"Festival tour maps, artist interviews, trail photography and community — Nikki's Great Music Festivals.",
  meta_keywords:   'music festivals, bluegrass, outdoor concerts, Billy Strings, Leftover Salmon, Stringdusters',
  twitter_card:    'summary_large_image',
  twitter_site:    null as string | null,
  twitter_creator: null as string | null,
})

// ── Artist dialog ────────────────────────────────────────────────────────────
const artistDialog = ref({ open: false, isNew: true, editIndex: -1 })
const artistForm   = reactive({
  id: '', name: '', subtitle: '',
  icon: 'music_note', icon_color: 'amber',
  badge_text: '', badge_color: 'amber',
  bio_main: '', bio_sub: '', songsStr: '',
})

function autoArtistId(val: string | number | null) {
  if (artistDialog.value.isNew) {
    artistForm.id = String(val).toLowerCase()
      .replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')
  }
}
function openAddArtist() {
  artistDialog.value = { open: true, isNew: true, editIndex: -1 }
  Object.assign(artistForm, { id: '', name: '', subtitle: '', icon: 'music_note', icon_color: 'amber', badge_text: '', badge_color: 'amber', bio_main: '', bio_sub: '', songsStr: '' })
}
function openEditArtist(i: number) {
  artistDialog.value = { open: true, isNew: false, editIndex: i }
  const a = artists.value[i]!
  Object.assign(artistForm, { id: a.id, name: a.name, subtitle: a.subtitle, icon: a.icon, icon_color: a.icon_color, badge_text: a.badge_text, badge_color: a.badge_color, bio_main: a.bio_main, bio_sub: a.bio_sub, songsStr: a.songs.join(', ') })
}
function saveArtistDialog() {
  const songs = artistForm.songsStr.split(',').map(s => s.trim()).filter(Boolean)
  const entry: HomepageArtist = {
    id: artistForm.id, name: artistForm.name, subtitle: artistForm.subtitle,
    icon: artistForm.icon, icon_color: artistForm.icon_color,
    badge_text: artistForm.badge_text, badge_color: artistForm.badge_color,
    bio_main: artistForm.bio_main, bio_sub: artistForm.bio_sub, songs,
  }
  if (artistDialog.value.isNew) artists.value.push(entry)
  else artists.value.splice(artistDialog.value.editIndex, 1, entry)
  artistDialog.value.open = false
}
function removeArtist(i: number) { artists.value.splice(i, 1) }
function moveArtist(i: number, dir: -1 | 1) {
  const arr = [...artists.value]
  const tmp = arr[i]!; arr[i] = arr[i + dir]!; arr[i + dir] = tmp
  artists.value = arr
}

// ── Per-section save functions ───────────────────────────────────────────────
async function saveContent() {
  saving.content = true
  await supabase.from('site_settings').upsert({ key: 'homepage_content', value: { ...content }, updated_at: new Date().toISOString() })
  saving.content = false; flash('content')
}
async function saveWelcome() {
  saving.welcome = true
  await supabase.from('site_settings').upsert({ key: 'welcome_overlay', value: { ...welcome }, updated_at: new Date().toISOString() })
  saving.welcome = false; flash('welcome')
}
async function saveArtists() {
  saving.artists = true
  await supabase.from('site_settings').upsert({ key: 'homepage_artists', value: artists.value, updated_at: new Date().toISOString() })
  saving.artists = false; flash('artists')
}
async function saveAppearance() {
  saving.appearance = true
  await supabase.from('site_settings').upsert({ key: 'homepage_appearance', value: { ...appearance }, updated_at: new Date().toISOString() })
  saving.appearance = false; flash('appearance')
}
async function saveSeo() {
  saving.seo = true
  await supabase.from('site_settings').upsert({ key: 'homepage_seo', value: { ...seo }, updated_at: new Date().toISOString() })
  saving.seo = false; flash('seo')
}
async function saveSkyText() {
  saving.skyText = true
  await supabase.from('site_settings').upsert({ key: 'footer_sky_text', value: { ...skyText }, updated_at: new Date().toISOString() })
  saving.skyText = false; flash('skyText')
}
async function saveAll() {
  savingAll.value = true; savedAll.value = false
  await Promise.all([saveContent(), saveWelcome(), saveArtists(), saveAppearance(), saveSeo(), saveSkyText()])
  savingAll.value = false; savedAll.value = true
  setTimeout(() => { savedAll.value = false }, 3000)
}

// ── Load ─────────────────────────────────────────────────────────────────────
async function loadSettings() {
  const { data } = await supabase.from('site_settings').select('key, value')
  for (const row of (data ?? []) as { key: string; value: unknown }[]) {
    if (row.key === 'homepage_content')    Object.assign(content,    row.value as object)
    if (row.key === 'homepage_appearance') Object.assign(appearance, row.value as object)
    if (row.key === 'homepage_seo')        Object.assign(seo,        row.value as object)
    if (row.key === 'welcome_overlay')     Object.assign(welcome,    row.value as object)
    if (row.key === 'homepage_artists' && Array.isArray(row.value) && row.value.length)
      artists.value = row.value as HomepageArtist[]
    if (row.key === 'footer_sky_text') Object.assign(skyText, row.value as object)
  }
}

// ── Upload handlers (auto-save + reset input) ────────────────────────────────
function triggerBgUpload()      { bgFileInput.value?.click()      }
function triggerOgUpload()      { ogFileInput.value?.click()      }
function triggerWelcomeUpload() { welcomeFileInput.value?.click() }

async function handleWelcomeUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingWelcome.value = true
  const path = `homepage/welcome-${Date.now()}.${file.name.split('.').pop() ?? 'jpg'}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    welcome.image_url = data.publicUrl
    await saveWelcome()          // ← auto-save immediately
  }
  if (welcomeFileInput.value) welcomeFileInput.value.value = ''   // reset so same file re-triggers
  uploadingWelcome.value = false
}

async function handleBgUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingBg.value = true
  const path = `homepage/bg-${Date.now()}.${file.name.split('.').pop() ?? 'jpg'}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    appearance.bg_image_url = data.publicUrl
    await saveAppearance()       // ← auto-save immediately
  }
  if (bgFileInput.value) bgFileInput.value.value = ''
  uploadingBg.value = false
}

async function handleOgUpload(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploadingOg.value = true
  const path = `homepage/og-${Date.now()}.${file.name.split('.').pop() ?? 'jpg'}`
  const { error } = await supabase.storage.from('festival-media').upload(path, file)
  if (!error) {
    const { data } = supabase.storage.from('festival-media').getPublicUrl(path)
    seo.og_image = data.publicUrl
    await saveSeo()              // ← auto-save immediately
  }
  if (ogFileInput.value) ogFileInput.value.value = ''
  uploadingOg.value = false
}

onMounted(loadSettings)
</script>

<style lang="scss" scoped>
.home-accordion {
  background: #1a1a2e;
  border-color: rgba(77,182,172,0.2) !important;
  border-radius: 12px;
}
.home-section { background: #1a1a2e; }
.section-label-text {
  font-size: 12px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; color: #80cbc4;
}
:deep(.home-section > .q-expansion-item__container > .q-item) {
  min-height: 56px;
  &:hover { background: rgba(77,182,172,0.05); }
}
.section-card {
  background: #14142a;
  border-top: 1px solid rgba(77,182,172,0.12);
}
.seo-inner {
  background: #1a1a2e;
  border-color: rgba(77,182,172,0.15) !important;
  border-radius: 8px;
}
.seo-header { background: #1a1a2e; color: #b2dfdb; }
.seo-card   { background: #0f0f22; border-top: 1px solid rgba(77,182,172,0.1); }
.save-banner { background: rgba(77,182,172,0.1); border: 1px solid rgba(77,182,172,0.3); color: #e0f2f1; }
.ls-1 { letter-spacing: 1.5px; }
.hidden { display: none; }
.bg-preview { max-height: 120px; max-width: 100%; border-radius: 8px; object-fit: cover; }
.spiro-preview-wrap {
  position: relative;
  height: 180px;
  border-radius: 10px;
  overflow: hidden;
  background: linear-gradient(180deg, #d0eaff 0%, #f5f0ff 100%);
  border: 1px solid rgba(255,255,255,0.18);
}
.og-preview-wrap { max-width: 480px; }
.og-preview { width: 100%; border-radius: 8px; aspect-ratio: 1200/630; object-fit: cover; }
.color-picker {
  width: 40px; height: 40px; border: none; padding: 0;
  border-radius: 8px; cursor: pointer; background: none;
}
.welcome-preview {
  margin-top: 8px;
  background: linear-gradient(to top, rgba(0,0,0,0.82) 0%, rgba(0,0,0,0.5) 100%);
  border-radius: 10px; padding: 24px 32px;
  display: flex; flex-direction: column; align-items: center;
  text-align: center; gap: 10px;
}
.wp-eyebrow { font-size: 11px; font-weight: 700; letter-spacing: 4px; text-transform: uppercase; color: rgba(255,215,0,0.85); }
.wp-title   { font-size: 28px; font-weight: 900; line-height: 1.1; color: #fff; letter-spacing: -0.5px; }
.wp-tagline { font-size: 13px; font-weight: 300; color: rgba(255,255,255,0.7); font-style: italic; max-width: 380px; }
.wp-btn {
  background: rgba(255,255,255,0.1); border: 2px solid currentColor;
  font-size: 12px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; padding: 10px 24px; border-radius: 999px; cursor: default;
}
.sky-preview {
  margin-top: 4px;
  background: linear-gradient(to bottom, #0d1a2e, #0a1828);
  border-radius: 8px; padding: 20px 28px;
  text-align: center;
}
.ls-2 { letter-spacing: 2px; }
</style>

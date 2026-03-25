<template>
  <q-page class="news-page relative overflow-hidden">
    <PageBackground variant="blog" />

    <div class="page-content q-pa-lg">

      <div class="text-center q-py-xl">
        <div class="section-label q-mb-xs">What's Happening</div>
        <div class="text-h3 text-bold q-mb-sm">Blog &amp; Tour Updates</div>
        <div class="text-body1 text-grey-6">Recent adventures and what's coming up on the road</div>
      </div>

      <div class="row q-col-gutter-xl q-pb-xl" style="max-width:1100px; margin:0 auto;">

        <!-- RECENT EVENTS -->
        <div class="col-12 col-md-7">
          <div class="section-label q-mb-md">Recent Events</div>

          <div v-if="loading" class="flex flex-center q-py-xl">
            <q-spinner-orbit color="indigo" size="40px" />
          </div>
          <div v-else-if="articles.length === 0" class="text-grey-5 q-py-xl text-center">
            No articles yet — check back soon.
          </div>
          <q-timeline v-else color="secondary">
            <q-timeline-entry
              v-for="article in articles"
              :key="article.id"
              :title="article.title"
              :subtitle="article.date ?? ''"
              :icon="article.icon"
              :color="article.color"
            >
              <div class="news-card q-pa-md rounded-borders">
                <div v-if="article.image_url" class="q-mb-md">
                  <q-img :src="article.image_url" :ratio="16/9" class="rounded-borders" />
                </div>
                <p class="text-body2 text-grey-8 q-mb-sm">{{ article.body }}</p>
                <div class="row q-gutter-xs">
                  <q-chip
                    v-for="tag in article.tags"
                    :key="tag"
                    dense size="sm"
                    color="indigo-1" text-color="indigo-9"
                  >{{ tag }}</q-chip>
                </div>
              </div>
            </q-timeline-entry>
          </q-timeline>
        </div>

        <!-- UPCOMING TOUR STOPS -->
        <div class="col-12 col-md-5">
          <div class="section-label q-mb-md">Upcoming Cities</div>
          <q-list class="upcoming-list rounded-borders overflow-hidden" bordered>
            <q-item v-for="stop in upcomingStops" :key="stop.id" class="upcoming-item q-py-md">
              <q-item-section avatar>
                <div class="date-badge">
                  <div class="date-month">{{ stop.month }}</div>
                  <div class="date-day">{{ stop.day }}</div>
                </div>
              </q-item-section>
              <q-item-section>
                <q-item-label class="text-weight-bold">{{ stop.venue }}</q-item-label>
                <q-item-label caption class="text-grey-6">{{ stop.city }}</q-item-label>
                <q-item-label caption>
                  <q-chip dense size="sm" :color="stop.chipColor" text-color="white">{{ stop.artist }}</q-chip>
                </q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-btn flat round dense icon="map" color="teal" :to="'/maps'" size="sm" />
              </q-item-section>
            </q-item>
          </q-list>

          <!-- Newsletter CTA -->
          <div class="news-subscribe-cta q-mt-xl q-pa-lg rounded-borders">
            <NewsletterSignup
              title="Get Tour Updates"
              subtitle="Be the first to know about new dates"
              :dark="false"
            />
          </div>
        </div>

      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import PageBackground    from 'src/components/PageBackground.vue'
import NewsletterSignup  from 'src/components/NewsletterSignup.vue'
import { supabase } from 'src/lib/supabase'
import type { NewsArticle } from 'src/lib/supabase'

const loading  = ref(true)
const articles = ref<NewsArticle[]>([])

onMounted(async () => {
  const { data } = await supabase
    .from('news_articles')
    .select('*')
    .eq('published', true)
    .order('created_at', { ascending: false })
  articles.value = (data as NewsArticle[]) ?? []
  loading.value = false
})

const upcomingStops = [
  { id: 1, month: 'MAY', day: '10', venue: 'Rialto Theatre',              city: 'Tucson, AZ',       artist: 'Billy Strings',   chipColor: 'amber-7'       },
  { id: 2, month: 'JUN', day: '14', venue: 'Bonnaroo Farm',               city: 'Manchester, TN',   artist: 'Stringdusters',   chipColor: 'purple-7'      },
  { id: 3, month: 'JUN', day: '20', venue: 'Rabbit Rabbit',               city: 'Asheville, NC',    artist: 'Stringdusters',   chipColor: 'purple-7'      },
  { id: 4, month: 'JUL', day: '12', venue: 'Red Rocks Amphitheatre',      city: 'Morrison, CO',     artist: 'Billy Strings',   chipColor: 'amber-7'       },
  { id: 5, month: 'JUL', day: '18', venue: 'Planet Bluegrass',            city: 'Lyons, CO',        artist: 'Leftover Salmon', chipColor: 'deep-orange-7' },
  { id: 6, month: 'JUL', day: '25', venue: 'Interlochen Arts Center',     city: 'Interlochen, MI',  artist: 'Billy Strings',   chipColor: 'amber-7'       },
  { id: 7, month: 'AUG', day: '01', venue: 'Pickathon Grounds',           city: 'Happy Valley, OR', artist: 'Leftover Salmon', chipColor: 'deep-orange-7' },
  { id: 8, month: 'AUG', day: '10', venue: 'Catskill Crest Amphitheatre', city: 'Catskills, NY',    artist: 'Stringdusters',   chipColor: 'purple-7'      },
]
</script>

<style lang="scss" scoped>
.news-page    { min-height: 100vh; }
.page-content { position: relative; z-index: 1; }

.section-label {
  font-size: 11px; font-weight: 700; letter-spacing: 3px;
  text-transform: uppercase; color: #3949ab; display: block;
}

.news-card {
  background: rgba(255,255,255,0.85);
  border: 1px solid rgba(57,73,171,0.12);
  backdrop-filter: blur(4px);
}

.upcoming-list  { background: rgba(255,255,255,0.9); }
.upcoming-item  { border-bottom: 1px solid rgba(0,0,0,0.05); &:last-child { border-bottom: none; } }

.date-badge {
  width: 44px; text-align: center;
  background: #3949ab; border-radius: 8px; padding: 4px 0;
  .date-month { font-size: 9px; font-weight: 700; letter-spacing: 1px; color: #90caf9; }
  .date-day   { font-size: 20px; font-weight: 900; color: white; line-height: 1.1; }
}

.news-subscribe-cta {
  background: linear-gradient(135deg, rgba(0,188,212,0.08), rgba(57,73,171,0.1));
  border: 1px solid rgba(0,188,212,0.2);
}
</style>

<style lang="scss">
body.body--dark {
  .news-page { background: #060d1a !important; }

  .news-page .section-label { color: #7986cb !important; }
  .news-page .text-h3, .news-page .text-body1 { color: rgba(255,255,255,0.9) !important; }
  .news-page .text-grey-6 { color: rgba(255,255,255,0.5) !important; }

  .news-page .news-card {
    background: rgba(255,255,255,0.05) !important;
    border-color: rgba(255,255,255,0.1) !important;
    backdrop-filter: none !important;
  }
  .news-page .text-grey-8 { color: rgba(255,255,255,0.7) !important; }

  .news-page .upcoming-list {
    background: rgba(255,255,255,0.04) !important;
    border-color: rgba(255,255,255,0.1) !important;
  }
  .news-page .upcoming-item { border-bottom-color: rgba(255,255,255,0.06) !important; }
  .news-page .text-weight-bold { color: rgba(255,255,255,0.9) !important; }

  .news-page .news-subscribe-cta {
    background: linear-gradient(135deg, rgba(0,188,212,0.12), rgba(57,73,171,0.15)) !important;
    border-color: rgba(0,188,212,0.3) !important;
  }
}
</style>

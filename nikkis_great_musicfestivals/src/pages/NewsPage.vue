<template>
  <q-page class="news-page relative overflow-hidden">
    <PageBackground variant="news" />

    <div class="page-content q-pa-lg">

      <div class="text-center q-py-xl">
        <div class="section-label q-mb-xs">What's Happening</div>
        <div class="text-h3 text-bold q-mb-sm">News & Tour Updates</div>
        <div class="text-body1 text-grey-6">Recent adventures and what's coming up on the road</div>
      </div>

      <div class="row q-col-gutter-xl q-pb-xl" style="max-width:1100px; margin:0 auto;">

        <!-- RECENT EVENTS -->
        <div class="col-12 col-md-7">
          <div class="section-label q-mb-md">Recent Events</div>
          <q-timeline color="secondary">
            <q-timeline-entry
              v-for="event in recentEvents"
              :key="event.id"
              :title="event.title"
              :subtitle="event.date"
              :icon="event.icon"
              :color="event.color"
            >
              <div class="news-card q-pa-md rounded-borders">
                <div v-if="event.image" class="q-mb-md">
                  <q-img :src="event.image" :ratio="16/9" class="rounded-borders" />
                </div>
                <p class="text-body2 text-grey-8 q-mb-sm">{{ event.body }}</p>
                <div class="row q-gutter-xs">
                  <q-chip v-for="tag in event.tags" :key="tag" dense size="sm" color="indigo-1" text-color="indigo-9">{{ tag }}</q-chip>
                </div>
              </div>
            </q-timeline-entry>
          </q-timeline>
        </div>

        <!-- UPCOMING TOUR STOPS -->
        <div class="col-12 col-md-5">
          <div class="section-label q-mb-md">Upcoming Cities</div>
          <q-list class="upcoming-list rounded-borders overflow-hidden" bordered>
            <q-item
              v-for="stop in upcomingStops"
              :key="stop.id"
              class="upcoming-item q-py-md"
            >
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

          <!-- NEWSLETTER CTA in sidebar -->
          <div class="news-subscribe-cta q-mt-xl q-pa-lg rounded-borders text-center">
            <q-icon name="mark_email_unread" size="36px" color="teal-4" />
            <div class="text-subtitle1 text-bold q-mt-sm q-mb-xs">Get Tour Updates</div>
            <div class="text-caption text-grey-6 q-mb-md">Be the first to know about new dates</div>
            <q-btn label="Subscribe to Newsletter" color="teal" outline :to="'/#subscribe-bottom'" />
          </div>
        </div>

      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import PageBackground from 'src/components/PageBackground.vue'

const recentEvents = [
  {
    id: 1,
    title: 'Red Rocks — Billy Strings Night 1',
    date: 'July 12, 2026',
    icon: 'star',
    color: 'amber',
    body: 'An absolutely transcendent night at Red Rocks. Billy opened with a 25-minute "Meet Me at the Creek" that had the whole amphitheater on their feet by the second verse. The canyon walls bounced the sound into something otherworldly.',
    tags: ['Billy Strings', 'Red Rocks', 'Mountain West'],
    image: null,
  },
  {
    id: 2,
    title: 'Planet Bluegrass — Rocky Mtn Folks Festival',
    date: 'July 18, 2026',
    icon: 'music_note',
    color: 'deep-orange',
    body: 'Leftover Salmon headlined the Saturday night on the main stage and played a nearly three-hour set. Vince Herman told stories between every song. The kind of show you tell your grandkids about.',
    tags: ['Leftover Salmon', 'Planet Bluegrass', 'Colorado'],
    image: null,
  },
  {
    id: 3,
    title: 'Bonnaroo — The Farm, Tennessee',
    date: 'June 14, 2026',
    icon: 'festival',
    color: 'purple',
    body: 'The Infamous Stringdusters closed out the Which Stage on Friday night. Silver Sky into Fork in the Road — the field went absolutely still, then erupted. Festival season officially opened.',
    tags: ['Stringdusters', 'Bonnaroo', 'Southeast'],
    image: null,
  },
]

const upcomingStops = [
  { id: 1, month: 'MAY', day: '10', venue: 'Rialto Theatre',             city: 'Tucson, AZ',       artist: 'Billy Strings',   chipColor: 'amber-7'      },
  { id: 2, month: 'JUN', day: '14', venue: 'Bonnaroo Farm',              city: 'Manchester, TN',   artist: 'Stringdusters',   chipColor: 'purple-7'     },
  { id: 3, month: 'JUN', day: '20', venue: 'Rabbit Rabbit',              city: 'Asheville, NC',    artist: 'Stringdusters',   chipColor: 'purple-7'     },
  { id: 4, month: 'JUL', day: '12', venue: 'Red Rocks Amphitheatre',     city: 'Morrison, CO',     artist: 'Billy Strings',   chipColor: 'amber-7'      },
  { id: 5, month: 'JUL', day: '18', venue: 'Planet Bluegrass',           city: 'Lyons, CO',        artist: 'Leftover Salmon', chipColor: 'deep-orange-7'},
  { id: 6, month: 'JUL', day: '25', venue: 'Interlochen Arts Center',    city: 'Interlochen, MI',  artist: 'Billy Strings',   chipColor: 'amber-7'      },
  { id: 7, month: 'AUG', day: '01', venue: 'Pickathon Grounds',          city: 'Happy Valley, OR', artist: 'Leftover Salmon', chipColor: 'deep-orange-7'},
  { id: 8, month: 'AUG', day: '10', venue: 'Catskill Crest Amphitheatre',city: 'Catskills, NY',    artist: 'Stringdusters',   chipColor: 'purple-7'     },
]
</script>

<style lang="scss" scoped>
.news-page    { min-height: 100vh; background: #f0f4fa; }
.page-content { position: relative; z-index: 1; }

.section-label {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 3px;
  text-transform: uppercase;
  color: #3949ab;
  display: block;
}

.news-card {
  background: rgba(255,255,255,0.85);
  border: 1px solid rgba(57,73,171,0.12);
  backdrop-filter: blur(4px);
}

.upcoming-list { background: rgba(255,255,255,0.9); }
.upcoming-item {
  border-bottom: 1px solid rgba(0,0,0,0.05);
  &:last-child { border-bottom: none; }
}

.date-badge {
  width: 44px;
  text-align: center;
  background: #3949ab;
  border-radius: 8px;
  padding: 4px 0;
  .date-month { font-size: 9px; font-weight: 700; letter-spacing: 1px; color: #90caf9; }
  .date-day   { font-size: 20px; font-weight: 900; color: white; line-height: 1.1; }
}

.news-subscribe-cta {
  background: linear-gradient(135deg, rgba(0,188,212,0.08), rgba(57,73,171,0.1));
  border: 1px solid rgba(0,188,212,0.2);
}
</style>

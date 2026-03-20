import os

dreamer_layout = """
<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated :class="$q.dark.isActive ? 'dream-header-dark' : 'dream-header-light'">
      <q-toolbar class="q-py-sm">
        <q-btn flat round icon="menu" @click="toggleLeftDrawer" class="hover-pop" />
        
        <q-toolbar-title class="text-weight-thin text-italic letter-spacing-2">
          NIKKI'S <span class="text-weight-bolder">FESTIVALS</span>
        </q-toolbar-title>

        <q-btn 
          flat round 
          :icon="$q.dark.isActive ? 'brightness_5' : 'brightness_3'" 
          @click="toggleDarkMode" 
          class="rotate-hover"
        />
      </q-toolbar>
    </q-header>

    <q-drawer v-model="leftDrawerOpen" show-if-above bordered :class="drawerClass">
      <div class="full-height column">
        <div class="flex flex-center q-py-xl">
           <svg width="120" height="120" viewBox="0 0 100 100" class="dream-frog">
            <path d="M50 15 A35 35 0 0 1 85 50 A35 35 0 0 1 50 85 A35 35 0 0 1 15 50 A35 35 0 0 1 50 15 Z" 
              fill="none" :stroke="accentColor" stroke-width="2" stroke-dasharray="4 2"/>
            <path d="M30 50 Q 50 20 70 50 Q 50 80 30 50" fill="none" :stroke="accentColor" stroke-width="3" />
            <circle cx="42" cy="45" r="2" :fill="accentColor" />
            <circle cx="58" cy="45" r="2" :fill="accentColor" />
          </svg>
        </div>

        <q-list class="col">
          <q-item v-for="link in navLinks" :key="link.title" clickable :to="link.link" exact class="dream-link">
            <q-item-section avatar>
              <q-icon :name="link.icon" :class="$q.dark.isActive ? link.darkColor : link.lightColor" />
            </q-item-section>
            <q-item-section class="text-uppercase ls-1">{{ link.title }}</q-item-section>
          </q-item>
        </q-list>

        <div class="q-pa-lg">
          <div class="text-caption q-mb-sm ls-2" :class="$q.dark.isActive ? 'text-teal-3' : 'text-indigo-9'">NEWSLETTER</div>
          <q-input v-model="navEmail" dense borderless class="dream-input q-px-md" placeholder="Enter email...">
            <template v-slot:after>
              <q-btn flat round icon="arrow_forward" :color="$q.dark.isActive ? 'teal-3' : 'indigo-9'" />
            </template>
          </q-input>
        </div>
      </div>
    </q-drawer>

    <q-page-container :class="pageClass">
      <div class="dream-bg-container absolute-full no-pointer-events overflow-hidden">
        <svg class="absolute-full opacity-20 layer-1" width="100%" height="100%">
          <pattern id="pattern1" patternUnits="userSpaceOnUse" width="600" height="600">
            <circle cx="300" cy="300" r="250" fill="none" :stroke="svgStroke" stroke-width="0.5" stroke-dasharray="20 10" />
          </pattern>
          <rect width="100%" height="100%" fill="url(#pattern1)" />
        </svg>
        <svg class="absolute-full opacity-10 layer-2" width="100%" height="100%">
          <pattern id="pattern2" patternUnits="userSpaceOnUse" width="413" height="413" patternTransform="rotate(15)">
            <path d="M0 206 Q 206 0 413 206 T 0 206" fill="none" :stroke="svgStroke" stroke-width="1" />
          </pattern>
          <rect width="100%" height="100%" fill="url(#pattern2)" />
        </svg>
      </div>

      <router-view class="relative-position z-top" />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const leftDrawerOpen = ref(false)
const navEmail = ref('')

const toggleLeftDrawer = () => { leftDrawerOpen.value = !leftDrawerOpen.value }
const toggleDarkMode = () => { $q.dark.toggle() }

const accentColor = computed(() => $q.dark.isActive ? '#4db6ac' : '#3949ab')
const svgStroke = computed(() => $q.dark.isActive ? '#00bcd4' : '#ffb74d')
const pageClass = computed(() => $q.dark.isActive ? 'bg-dream-dark' : 'bg-dream-light')
const drawerClass = computed(() => $q.dark.isActive ? 'bg-dream-drawer-dark' : 'bg-dream-drawer-light')

const navLinks = [
  { title: 'Home', icon: 'auto_awesome', link: '/', lightColor: 'text-indigo-9', darkColor: 'text-teal-3' },
  { title: 'Photography', icon: 'camera', link: '/photography', lightColor: 'text-orange-9', darkColor: 'text-amber-3' },
  { title: 'Maps', icon: 'explore', link: '/maps', lightColor: 'text-green-9', darkColor: 'text-light-green-3' },
  { title: 'Support', icon: 'stadium', link: '/support', lightColor: 'text-red-9', darkColor: 'text-pink-3' },
  { title: 'Merch', icon: 'style', link: '/merch', lightColor: 'text-blue-9', darkColor: 'text-cyan-3' },
  { title: 'News', icon: 'forum', link: '/news', lightColor: 'text-teal-9', darkColor: 'text-teal-3' }
]
</script>

<style lang="scss">
/* DREAMER THEME COLORS */
.bg-dream-light { background: #fdf6e3; color: #073642; }
.bg-dream-dark { background: #001f3f; color: #e0f2f1; }
.bg-dream-drawer-light { background: #eee8d5 !important; }
.bg-dream-drawer-dark { background: #001a35 !important; }

.dream-header-light { background: linear-gradient(to right, #3949ab, #4db6ac) !important; }
.dream-header-dark { background: #001220 !important; border-bottom: 1px solid #00bcd4; }

.ls-1 { letter-spacing: 1px; }
.ls-2 { letter-spacing: 2px; }

.dream-link {
  margin: 8px 16px;
  border-radius: 50px;
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  &:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: scale(1.05);
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  }
}

.dream-input {
  background: rgba(0,0,0,0.05);
  border-radius: 12px;
  border: 1px solid rgba(0,0,0,0.1);
}

.dream-frog {
  filter: drop-shadow(0 0 10px rgba(0, 188, 212, 0.3));
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

/* NON-REPEATING LAYERED ANIMATION */
.layer-1 { animation: drift 120s linear infinite; }
.layer-2 { animation: drift 85s linear infinite reverse; }

@keyframes drift {
  from { transform: rotate(0deg) scale(1); }
  to { transform: rotate(360deg) scale(1.1); }
}

.no-pointer-events { pointer-events: none; }
</style>
"""

def update_layout():
    path = os.path.join('src', 'layouts', 'MainLayout.vue')
    with open(path, 'w') as f:
        f.write(dreamer_layout.strip())
    print(f"🌌 Dreamer Layout Deployed: Layered SVGs and Toggle Restored.")

if __name__ == "__main__":
    update_layout()

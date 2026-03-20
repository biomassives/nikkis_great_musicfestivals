import os

final_layout_content = """
<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated :class="$q.dark.isActive ? 'bg-black' : 'mardi-header-light'">
      <q-toolbar class="relative-position overflow-hidden" style="min-height: 64px;">
        
        <div class="absolute-full opacity-20">
          <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">
            <pattern id="headerSpiral" patternUnits="userSpaceOnUse" width="80" height="80">
              <path d="M40,40 a20,20 0 1,0 20,20 a10,10 0 1,0 -10,-10" fill="none" 
                :stroke="$q.dark.isActive ? '#ffd700' : '#ffffff'" stroke-width="1" />
            </pattern>
            <rect width="100%" height="100%" fill="url(#headerSpiral)" />
          </svg>
        </div>

        <q-btn flat dense round icon="menu" @click="toggleLeftDrawer" class="hover-pop z-top" />
        <q-toolbar-title class="text-bold text-italic z-top" :class="$q.dark.isActive ? 'text-gold' : 'text-white'">
          Nikki's Music Festivals
        </q-toolbar-title>

        <div class="q-gutter-sm z-top">
          <q-btn 
            flat 
            round 
            :icon="$q.dark.isActive ? 'light_mode' : 'dark_mode'" 
            @click="toggleDarkMode" 
            class="hover-pop"
          />
          <q-btn flat round icon="account_circle" class="hover-pop" />
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer v-model="leftDrawerOpen" show-if-above bordered :class="$q.dark.isActive ? 'bg-black' : 'bg-orange-1'">
      <q-list padding>
        <div class="flex flex-center q-py-lg">
          <svg width="60" height="60" viewBox="0 0 100 100">
            <path d="M50 10 A40 40 0 0 1 90 50 A40 40 0 0 1 50 90 A40 40 0 0 1 10 50 A40 40 0 0 1 50 10 Z M50 20 A30 30 0 0 1 80 50 A30 30 0 0 1 50 80 A30 30 0 0 1 20 50 A30 30 0 0 1 50 20 Z" 
              fill="none" :stroke="$q.dark.isActive ? '#ffd700' : '#4b0082'" stroke-width="4"/>
            <circle cx="35" cy="45" r="3" :fill="$q.dark.isActive ? '#ffd700' : '#4b0082'" />
            <circle cx="65" cy="45" r="3" :fill="$q.dark.isActive ? '#ffd700' : '#4b0082'" />
          </svg>
        </div>

        <q-item v-for="link in navLinks" :key="link.title" clickable :to="link.link" exact class="mardi-link q-ma-sm rounded-borders">
          <q-item-section avatar>
            <q-icon :name="link.icon" :class="link.colorClass" />
          </q-item-section>
          <q-item-section>
            <q-item-label class="text-weight-bold">{{ link.title }}</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>

      <div class="absolute-bottom q-pa-md border-top-gold" :class="$q.dark.isActive ? 'bg-dark' : 'bg-orange-2'">
        <div class="text-caption text-bold q-mb-xs" :class="$q.dark.isActive ? 'text-gold' : 'text-purple-10'">JOIN THE NEWS</div>
        <q-input v-model="navEmail" dense filled :dark="$q.dark.isActive" placeholder="Email...">
          <template v-slot:after>
            <q-btn round dense flat icon="send" :color="$q.dark.isActive ? 'gold' : 'purple-10'" />
          </template>
        </q-input>
      </div>
    </q-drawer>

    <q-page-container :class="$q.dark.isActive ? 'bg-grey-10' : 'bg-warm-glow'">
       <div class="absolute-full overflow-hidden opacity-10" style="pointer-events: none;">
          <svg width="100%" height="100%">
            <pattern id="pageSpiral" patternUnits="userSpaceOnUse" width="150" height="150">
               <circle cx="75" cy="75" r="40" fill="none" 
                 :stroke="$q.dark.isActive ? '#4b0082' : '#ffb74d'" stroke-width="2" stroke-dasharray="5,5" />
            </pattern>
            <rect width="100%" height="100%" fill="url(#pageSpiral)" />
          </svg>
       </div>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const leftDrawerOpen = ref(false)
const navEmail = ref('')

const toggleLeftDrawer = () => { leftDrawerOpen.value = !leftDrawerOpen.value }
const toggleDarkMode = () => { $q.dark.toggle() }

const navLinks = [
  { title: 'Home', icon: 'home', link: '/', colorClass: 'text-purple' },
  { title: 'Photography', icon: 'photo_camera', link: '/photography', colorClass: 'text-green' },
  { title: 'Maps', icon: 'map', link: '/maps', colorClass: 'text-orange' },
  { title: 'Support', icon: 'favorite', link: '/support', colorClass: 'text-red' },
  { title: 'Merch', icon: 'shopping_bag', link: '/merch', colorClass: 'text-blue' },
  { title: 'News', icon: 'newspaper', link: '/news', colorClass: 'text-teal' }
]
</script>

<style lang="scss">
.text-gold { color: #ffd700; }
.bg-warm-glow { background: #fffcf2; } // Creamy off-white for less contrast
.bg-orange-1 { background: #fff8e1 !important; }
.bg-orange-2 { background: #ffecb3 !important; }

.mardi-header-light {
  background: linear-gradient(45deg, #4b0082, #6a0dad) !important;
  border-bottom: 3px solid #ffd700;
}

.mardi-link:hover {
  background: rgba(255, 215, 0, 0.2);
  transform: translateX(5px);
  transition: all 0.3s ease;
}

.z-top { z-index: 10; }
.hover-pop:hover { transform: scale(1.15); transition: 0.2s ease-out; }
</style>
"""

def run_update():
    path = os.path.join('src', 'layouts', 'MainLayout.vue')
    with open(path, 'w') as f:
        f.write(final_layout_content.strip())
    print(f"✅ Layout updated: Day/Night toggle restored & Warm Light theme enabled.")

if __name__ == "__main__":
    run_update()

import os

layout_with_frog = """
<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="mardi-gras-header relative overflow-hidden">
      <div class="mardi-spiral-bg absolute-full opacity-15">
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">
          <defs>
            <radialGradient id="mardiGrad1" cx="50%" cy="50%" r="50%">
              <stop offset="0%" style="stop-color:#4b0082" />
              <stop offset="50%" style="stop-color:#ffd700" />
              <stop offset="100%" style="stop-color:#008f39" />
            </radialGradient>
            <pattern id="spiralPattern" patternUnits="userSpaceOnUse" width="100" height="100">
              <path d="M50,50 a25,25 0 1,0 25,25 a12.5,12.5 0 1,0 -12.5,-12.5 a6.25,6.25 0 1,0 6.25,6.25" fill="none" stroke="url(#mardiGrad1)" stroke-width="2" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#spiralPattern)" />
        </svg>
      </div>

      <q-toolbar class="relative z-top">
        <q-btn flat dense round icon="menu" aria-label="Menu" @click="toggleLeftDrawer" class="hover-pop" />
        <q-toolbar-title class="text-bold text-italic text-gold">
          Nikki's Music Festivals
        </q-toolbar-title>
        <div class="q-gutter-sm">
          <q-btn flat round :icon="$q.dark.isActive ? 'light_mode' : 'dark_mode'" @click="toggleDarkMode" class="hover-pop" />
          <q-btn flat round icon="account_circle" class="hover-pop" />
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer v-model="leftDrawerOpen" show-if-above bordered :class="$q.dark.isActive ? 'bg-black' : 'bg-grey-1'">
      <q-list padding>
        <q-item-label header class="flex flex-center q-pt-lg q-pb-none">
          <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" viewBox="0 0 100 100" class="mardi-frog">
            <path d="M50 10 A40 40 0 0 1 90 50 A40 40 0 0 1 50 90 A40 40 0 0 1 10 50 A40 40 0 0 1 50 10 Z 
                     M50 20 A30 30 0 0 1 80 50 A30 30 0 0 1 50 80 A30 30 0 0 1 20 50 A30 30 0 0 1 50 20 Z 
                     M35 45 A5 5 0 1 0 35 55 A5 5 0 1 0 35 45 Z 
                     M65 45 A5 5 0 1 0 65 55 A5 5 0 1 0 65 45 Z" 
                  fill="none" stroke="#ffd700" stroke-width="4"/>
          </svg>
        </q-item-label>
        
        <q-item-label header class="text-gold text-bold q-mt-md text-center">THE LINEUP</q-item-label>
        
        <q-item v-for="link in navLinks" :key="link.title" clickable :to="link.link" exact class="mardi-link q-ma-sm rounded-borders" active-class="mardi-active">
          <q-item-section avatar> <q-icon :name="link.icon" :class="link.colorClass" /> </q-item-section>
          <q-item-section>
            <q-item-label class="text-weight-bold">{{ link.title }}</q-item-label>
            <q-item-label caption :class="$q.dark.isActive ? 'text-grey-5' : 'text-grey-7'"> {{ link.caption }} </q-item-label>
          </q-item-section>
        </q-item>
      </q-list>

      <div class="absolute-bottom q-pa-md border-top-gold" :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'">
        <div class="text-caption text-gold q-mb-xs">JOIN THE FESTIVAL NEWS</div>
        <q-input v-model="navEmail" :dark="$q.dark.isActive" dense filled placeholder="Email address" class="mardi-input">
          <template v-slot:after> <q-btn round dense flat icon="send" color="gold" @click="handleSubscribe" /> </template>
        </q-input>
      </div>
    </q-drawer>

    <q-page-container> <router-view /> </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const leftDrawerOpen = ref(false)
const navEmail = ref('')

const navLinks = [
  { title: 'Home', caption: 'The Mission', icon: 'home', link: '/', colorClass: 'text-purple-accent-2' },
  { title: 'Photography', caption: 'Adventures & Cuteness', icon: 'photo_camera', link: '/photography', colorClass: 'text-green-accent-3' },
  { title: 'Maps', caption: 'Shows & Senior Stops', icon: 'map', link: '/maps', colorClass: 'text-orange-5' },
  { title: 'Support', caption: 'Join the Tiers', icon: 'favorite', link: '/purple' },
  { title: 'Merch', caption: 'Art & Stuff', icon: 'shopping_bag', link: '/green' },
  { title: 'News', caption: 'Latest Updates', icon: 'newspaper', link: '/orange' },
]

function toggleLeftDrawer() { leftDrawerOpen.value = !leftDrawerOpen.value }
function toggleDarkMode() { $q.dark.toggle() }
function handleSubscribe() { if (navEmail.value) { $q.notify({ message: 'Welcome to the party!', color: 'positive' }); navEmail.value = '' } }
</script>

<style lang="scss">
$mardi-purple: #4b0082;
$mardi-gold: #ffd700;
$mardi-green: #008f39;

.mardi-gras-header {
  background: $mardi-purple !important;
  color: white;
  border-bottom: 3px solid $mardi-gold;
}

.text-gold { color: $mardi-gold; }
.border-top-gold { border-top: 1px solid $mardi-gold; }

.mardi-frog {
  transition: transform 0.4s ease;
  &:hover { transform: scale(1.1) rotate(10deg); }
}

.mardi-link { transition: all 0.3s ease; border: 1px solid transparent; &:hover { background: rgba(255, 215, 0, 0.1); transform: translateX(8px); border-left: 4px solid $mardi-green; } }
.mardi-active { background: rgba(255, 215, 0, 0.15) !important; border: 1px solid $mardi-gold !important; .q-item__label { color: $mardi-gold !important; } }
.rounded-borders { border-radius: 8px; }
.hover-pop { transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275); &:hover { transform: scale(1.2); color: $mardi-gold !important; } }
</style>
"""

def update_layout():
    path = os.path.join('src', 'layouts', 'MainLayout.vue')
    with open(path, 'w') as f:
        f.write(layout_with_frog.strip())
    print(f"🐸 Mardi Gras Layout updated with SVG Frog and Spirals at {path}")

if __name__ == "__main__":
    update_layout()

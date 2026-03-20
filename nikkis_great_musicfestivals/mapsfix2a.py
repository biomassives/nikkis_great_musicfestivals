import os

nav_content = """
<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="mardi-gras-gradient">
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="menu"
          aria-label="Menu"
          @click="toggleLeftDrawer"
          class="hover-pop"
        />

        <q-toolbar-title class="text-bold text-italic">
          Nikki's Music Festivals
        </q-toolbar-title>

        <div class="q-gutter-sm">
          <q-btn flat round icon="notifications" class="hover-pop" />
          <q-btn flat round icon="account_circle" class="hover-pop" />
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      class="bg-dark text-white"
    >
      <q-list padding>
        <q-item-label header class="text-gold text-bold q-mt-md">THE LINEUP</q-item-label>

        <q-item
          v-for="link in navLinks"
          :key="link.title"
          clickable
          :to="link.link"
          exact
          class="mardi-link q-ma-sm rounded-borders"
          active-class="mardi-active"
        >
          <q-item-section avatar>
            <q-icon :name="link.icon" :class="link.colorClass" />
          </q-item-section>

          <q-item-section>
            <q-item-label class="text-weight-bold">{{ link.title }}</q-item-label>
            <q-item-label caption class="text-grey-5">{{ link.caption }}</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const leftDrawerOpen = ref(false)

const navLinks = [
  { title: 'Home', caption: 'The Mission', icon: 'home', link: '/', colorClass: 'text-purple-accent-2' },
  { title: 'Photography', caption: 'Adventures & Cuteness', icon: 'photo_camera', link: '/photography', colorClass: 'text-green-accent-3' },
  { title: 'Maps', caption: 'Shows & Senior Stops', icon: 'map', link: '/maps', colorClass: 'text-orange-5' },
  { title: 'Support', caption: 'Join the Tiers', icon: 'favorite', link: '/support', colorClass: 'text-purple-accent-2' },
  { title: 'Merch', caption: 'Art & Stuff', icon: 'shopping_bag', link: '/merch', colorClass: 'text-green-accent-3' },
  { title: 'News', caption: 'Latest Updates', icon: 'newspaper', link: '/news', colorClass: 'text-orange-5' },
]

function toggleLeftDrawer() {
  leftDrawerOpen.value = !leftDrawerOpen.value
}
</script>

<style lang="scss">
/* Mardi Gras Palette Variables */
$mardi-purple: #4b0082;
$mardi-gold: #ffd700;
$mardi-green: #008f39;

.mardi-gras-gradient {
  background: linear-gradient(45deg, $mardi-purple, #6a0dad) !important;
  border-bottom: 3px solid $mardi-gold;
}

.text-gold {
  color: $mardi-gold;
}

/* Hover & Pop Effects */
.hover-pop {
  transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  &:hover {
    transform: scale(1.2);
    color: $mardi-gold !important;
  }
}

.mardi-link {
  transition: all 0.3s ease;
  border: 1px solid transparent;

  &:hover {
    background: rgba(255, 215, 0, 0.1);
    transform: translateX(10px);
    border-left: 5px solid $mardi-green;
  }
}

/* Active State Effect */
.mardi-active {
  background: rgba(255, 215, 0, 0.2) !important;
  border: 1px solid $mardi-gold !important;
  box-shadow: 0 0 15px rgba(255, 215, 0, 0.3);
  
  .q-item__label {
    color: $mardi-gold !important;
  }
}

.rounded-borders {
  border-radius: 12px;
}
</style>
"""

def update_nav():
    path = os.path.join('src', 'layouts', 'MainLayout.vue')
    with open(path, 'w') as f:
        f.write(nav_content.strip())
    print(f"🎭 Mardi Gras Navigation System installed at {path}")

if __name__ == "__main__":
    update_nav()

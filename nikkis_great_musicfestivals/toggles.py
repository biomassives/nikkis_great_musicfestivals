import os

theme_layout_content = """
<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated :class="headerClass">
      <q-toolbar>
        <q-btn flat dense round icon="menu" aria-label="Menu" @click="toggleLeftDrawer" class="hover-pop" />

        <q-toolbar-title class="text-bold text-italic">
          Nikki's Music Festivals
        </q-toolbar-title>

        <div class="q-gutter-sm">
          <q-btn 
            flat 
            round 
            :icon="$q.dark.isActive ? 'light_mode' : 'dark_mode'" 
            @click="toggleDarkMode" 
            class="hover-pop"
            :title="$q.dark.isActive ? 'Switch to Light Mode' : 'Switch to Dark Mode'"
          />
          <q-btn flat round icon="account_circle" class="hover-pop" />
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      :class="$q.dark.isActive ? 'bg-black' : 'bg-grey-1'"
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
            <q-item-label caption :class="$q.dark.isActive ? 'text-grey-5' : 'text-grey-7'">
              {{ link.caption }}
            </q-item-label>
          </q-item-section>
        </q-item>
      </q-list>

      <div class="absolute-bottom q-pa-md border-top-gold" :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'">
        <div class="text-caption text-gold q-mb-xs">JOIN THE FESTIVAL NEWS</div>
        <q-input 
          v-model="navEmail" 
          :dark="$q.dark.isActive" 
          dense 
          filled 
          placeholder="Email address"
          class="mardi-input"
        >
          <template v-slot:after>
            <q-btn round dense flat icon="send" color="gold" @click="handleSubscribe" />
          </template>
        </q-input>
      </div>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const leftDrawerOpen = ref(false)
const navEmail = ref('')

const headerClass = computed(() => {
  return $q.dark.isActive ? 'mardi-gras-dark' : 'mardi-gras-light'
})

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

function toggleDarkMode() {
  $q.dark.toggle()
}

function handleSubscribe() {
  if (navEmail.value) {
    $q.notify({ message: 'Welcome to the party!', color: 'positive' })
    navEmail.value = ''
  }
}
</script>

<style lang="scss">
$mardi-purple: #4b0082;
$mardi-gold: #ffd700;
$mardi-green: #008f39;

.mardi-gras-light {
  background: linear-gradient(45deg, $mardi-purple, #6a0dad) !important;
  color: white;
  border-bottom: 3px solid $mardi-gold;
}

.mardi-gras-dark {
  background: #121212 !important;
  color: $mardi-gold;
  border-bottom: 3px solid $mardi-purple;
}

.text-gold { color: $mardi-gold; }
.border-top-gold { border-top: 1px solid $mardi-gold; }

.hover-pop {
  transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  &:hover {
    transform: scale(1.2);
    color: $mardi-gold !important;
  }
}

.mardi-link {
  transition: all 0.3s ease;
  &:hover {
    background: rgba(255, 215, 0, 0.1);
    transform: translateX(8px);
    border-left: 4px solid $mardi-green;
  }
}

.mardi-active {
  background: rgba(255, 215, 0, 0.15) !important;
  border: 1px solid $mardi-gold !important;
  .q-item__label { color: $mardi-gold !important; }
}

.rounded-borders { border-radius: 8px; }
</style>
"""

def update_layout():
    path = os.path.join('src', 'layouts', 'MainLayout.vue')
    with open(path, 'w') as f:
        f.write(theme_layout_content.strip())
    print(f"✨ Theme Toggle & Mardi Gras Layout updated at {path}")

if __name__ == "__main__":
    update_layout()

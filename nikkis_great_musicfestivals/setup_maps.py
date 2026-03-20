import os

map_content = """
<template>
  <q-page class="column">
    <div class="q-pa-md row justify-center q-gutter-sm bg-white shadow-1 z-top">
      <q-chip clickable v-model:selected="filters.shows" color="primary" text-color="white" icon="event">Festivals</q-chip>
      <q-chip clickable v-model:selected="filters.seniors" color="secondary" text-color="white" icon="elderly">Senior Facilities</q-chip>
      <q-chip clickable v-model:selected="filters.nature" color="accent" text-color="white" icon="landscape">Must Sees</q-chip>
    </div>

    <div id="map" class="col" style="min-height: 400px;"></div>
  </q-page>
</template>

<script setup lang="ts">
import { onMounted, ref, watch, reactive } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

// 1. Data Layers (Mock Coordinates for Nederland/Boulder Area)
const locations = {
  shows: [
    { name: "Red Rocks Amphitheatre", lat: 39.6654, lng: -105.2057, desc: "Iconic Outdoor Venue" },
    { name: "Planet Bluegrass", lat: 40.2241, lng: -105.2714, desc: "Rocky Mountain Folks Festival" }
  ],
  seniors: [
    { name: "The Pearl at Boulder Creek", lat: 40.0150, lng: -105.2705, desc: "Assisted Living Support" },
    { name: "Sunrise at FlatIrons", lat: 39.9328, lng: -105.1166, desc: "Senior Care on-the-way" }
  ],
  nature: [
    { name: "Lost Gulch Overlook", lat: 40.0025, lng: -105.3400, desc: "Must-see photography spot" },
    { name: "Lookout Mountain", lat: 39.7329, lng: -105.2393, desc: "Panoramic views" }
  ]
}

const filters = reactive({
  shows: true,
  seniors: true,
  nature: true
})

let map: L.Map
const markerGroups: Record<string, L.LayerGroup> = {}

onMounted(() => {
  // Initialize Map
  map = L.map('map').setView([39.95, -105.20], 10)

  // Add OpenStreetMap Tiles
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors'
  }).addTo(map)

  // Create Groups
  Object.keys(locations).forEach(key => {
    markerGroups[key] = L.layerGroup().addTo(map)
    locations[key as keyof typeof locations].forEach(loc => {
      L.marker([loc.lat, loc.lng])
        .bindPopup(`<b>${loc.name}</b><br>${loc.desc}`)
        .addTo(markerGroups[key])
    })
  })
})

// Watch for filter changes to show/hide layers
watch(filters, (newVal) => {
  if (newVal.shows) map.addLayer(markerGroups.shows); else map.removeLayer(markerGroups.shows)
  if (newVal.seniors) map.addLayer(markerGroups.seniors); else map.removeLayer(markerGroups.seniors)
  if (newVal.nature) map.addLayer(markerGroups.nature); else map.removeLayer(markerGroups.nature)
})
</script>

<style scoped>
.z-top { z-index: 1000; }
</style>
"""

def update_map():
    path = os.path.join('src', 'pages', 'MapsPage.vue')
    with open(path, 'w') as f:
        f.write(map_content.strip())
    print(f"🗺️ Maps page updated at {path}")

if __name__ == "__main__":
    update_map()

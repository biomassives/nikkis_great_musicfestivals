<template>
  <q-page class="q-pa-md">
    <div class="text-h3 text-center q-mb-xl">Photography</div>

    <div class="q-mb-xl">
      <div class="text-h5 q-mb-md text-primary"><q-icon name="forest" /> Documenting Outdoor Adventures</div>
      <div class="row q-col-gutter-md">
        <div v-for="n in 4" :key="n" class="col-12 col-sm-6 col-md-3">
          <q-img src="https://picsum.photos/500/300?random=1" ratio="1" class="rounded-borders shadow-1" />
        </div>
      </div>
    </div>

    <div class="q-mb-xl">
      <div class="text-h5 q-mb-md text-secondary"><q-icon name="confirmation_number" /> Music Concerts</div>
      <div class="row q-col-gutter-md">
        <div v-for="n in 4" :key="n" class="col-12 col-sm-6 col-md-3">
          <q-img src="https://picsum.photos/500/300?random=2" ratio="1" class="rounded-borders shadow-1" />
        </div>
      </div>
    </div>

    <div class="q-mb-xl">
      <div class="text-h5 q-mb-md text-accent"><q-icon name="pets" /> Daily Cuteness</div>
      <div class="row q-col-gutter-md">
        <div v-for="n in 4" :key="n" class="col-12 col-sm-6 col-md-3">
          <q-img src="https://picsum.photos/500/300?random=3" ratio="1" class="rounded-borders shadow-1" />
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts">
// Logic for gallery filtering could go here later
</script>
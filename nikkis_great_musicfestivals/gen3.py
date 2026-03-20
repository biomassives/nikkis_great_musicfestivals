import os

home_content = """
<template>
  <q-page class="home-page flex flex-center">
    <div class="geometric-bg"></div>
    <div class="content-container q-pa-lg text-center">
      <header class="q-mb-xl">
        <div class="text-h2 text-bold text-primary q-mb-md">Nikki's Great Music Festivals</div>
        <q-img src="https://cdn.quasar.dev/logo-v2/svg/logo.svg" style="width: 120px; height: 120px" class="q-mb-lg" />
        <div class="mission-statement text-h5 text-grey-9 q-mx-auto" style="max-width: 700px">
          "Documenting the rhythm of the outdoors and the soul of the stage."
        </div>
      </header>

      <section class="q-mb-xl">
        <div class="text-h4 q-mb-md">Intentions & Interviews</div>
        <div class="row q-col-gutter-md justify-center">
          <div v-for="n in 3" :key="n" class="col-12 col-sm-4">
            <q-card flat bordered class="interview-card">
              <q-card-section>
                <div class="text-subtitle1 text-bold text-secondary">Festival Interview #{{ n }}</div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </section>

      <footer class="subscribe-section q-mt-xl q-pa-xl bg-white rounded-borders shadow-2">
        <div class="text-h6 q-mb-sm">Join the Journey</div>
        <div class="row justify-center items-center q-gutter-sm">
          <q-input filled v-model="email" label="Email Address" dense style="min-width: 250px" />
          <q-btn unelevated color="primary" label="Subscribe" />
        </div>
      </footer>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const email = ref('')
</script>

<style lang="scss" scoped>
.home-page { position: relative; overflow: hidden; min-height: 100vh; }
.geometric-bg {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; opacity: 0.1;
  background-image: radial-gradient(#4b0082 1px, transparent 1px), radial-gradient(#4b0082 1px, #ffffff 1px);
  background-size: 40px 40px; background-position: 0 0, 20px 20px;
  animation: shift 20s linear infinite;
}
@keyframes shift { from { background-position: 0 0, 20px 20px; } to { background-position: 100px 100px, 120px 120px; } }
.content-container { position: relative; z-index: 1; }
</style>
"""

def update_home():
    path = os.path.join('src', 'pages', 'IndexPage.vue')
    with open(path, 'w') as f:
        f.write(home_content.strip())
    print(f"✅ Fixed IndexPage.vue with lang='ts'")

if __name__ == "__main__":
    update_home()

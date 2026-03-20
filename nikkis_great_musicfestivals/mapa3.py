import os

home_with_frog = """
<template>
  <q-page class="home-page relative overflow-hidden flex flex-center">
    <div class="mardi-spiral-bg absolute-full opacity-10 z-back">
      <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">
        <defs>
          <radialGradient id="mardiGradHome" cx="50%" cy="50%" r="50%">
            <stop offset="0%" style="stop-color:#4b0082" />
            <stop offset="50%" style="stop-color:#ffd700" />
            <stop offset="100%" style="stop-color:#008f39" />
          </radialGradient>
          <pattern id="spiralPatternHome" patternUnits="userSpaceOnUse" width="150" height="150">
            <path d="M75,75 a37.5,37.5 0 1,0 37.5,37.5 a18.75,18.75 0 1,0 -18.75,-18.75 a9.375,9.375 0 1,0 9.375,9.375" fill="none" stroke="url(#mardiGradHome)" stroke-width="3" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#spiralPatternHome)" />
      </svg>
    </div>

    <div class="content-container q-pa-lg text-center relative z-front">
      <header class="q-mb-xl row items-center justify-center q-gutter-xl">
        <div class="col-12 col-md-4 flex flex-center">
          <svg xmlns="http://www.w3.org/2000/svg" width="160" height="160" viewBox="0 0 100 100" class="mardi-frog-hero">
            <path d="M50 10 A40 40 0 0 1 90 50 A40 40 0 0 1 50 90 A40 40 0 0 1 10 50 A40 40 0 0 1 50 10 Z 
                     M50 20 A30 30 0 0 1 80 50 A30 30 0 0 1 50 80 A30 30 0 0 1 20 50 A30 30 0 0 1 50 20 Z 
                     M35 45 A5 5 0 1 0 35 55 A5 5 0 1 0 35 45 Z 
                     M65 45 A5 5 0 1 0 65 55 A5 5 0 1 0 65 45 Z" 
                  fill="none" stroke="#ffd700" stroke-width="5"/>
          </svg>
        </div>
        
        <div class="col-12 col-md-7 text-left">
          <div class="text-h2 text-bold text-primary q-mb-md">Nikki's Great Music Festivals</div>
          <div class="mission-statement text-h5 text-grey-9 q-mb-lg" style="max-width: 800px">
            "Helping to improve lives by improving access to great music, community, and the outdoors."
          </div>
          <q-btn label="Our Full Story" color="secondary" outline class="hover-pop" />
        </div>
      </header>

      <section class="q-mb-xl">
        <div class="text-h4 text-bold q-mb-lg text-purple-10">The Artist Interviews</div>
        <div class="row q-col-gutter-xl justify-center">
          </div>
      </section>

      <div id="subscribe-bottom" class="q-mt-xl text-grey-6 text-italic">
        Scroll down to join the newsletter adventure.
      </div>
    </div>
  </q-page>
</template>

<script setup lang="ts"></script>

<style lang="scss" scoped>
.home-page { min-height: 100vh; background: #fafafa; }
.z-back { z-index: 0; }
.z-front { z-index: 10; }
.content-container { position: relative; z-index: 1; }

.mardi-frog-hero {
  transition: transform 0.4s ease;
  &:hover { transform: scale(1.05) rotate(-5deg); filter: drop-shadow(0 0 10px rgba(255, 215, 0, 0.4)); }
}

.mission-statement {
  line-height: 1.4;
  font-weight: 300;
  color: #2c3e50;
  border-left: 4px solid #ffd700;
  padding-left: 20px;
}
</style>
"""

def update_home():
    path = os.path.join('src', 'pages', 'IndexPage.vue')
    with open(path, 'w') as f:
        f.write(home_with_frog.strip())
    print(f"🎸 Homepage updated with {path} - Colorful SVG Spirals and Frog Hero added!")

if __name__ == "__main__":
    update_home()

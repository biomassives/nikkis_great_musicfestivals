import os

# Define the pages based on your handwritten notes
pages = [
    "IndexPage",
    "SupportPage",
    "PhotographyPage",
    "MapsPage",
    "MerchPage",
    "NewsPage"
]

def provision_quasar():
    print("🚀 Starting Quasar page provisioning...")

    # 1. Generate the Vue files using Quasar CLI
    for page in pages:
        print(f"Generating {page}...")
        os.system(f"quasar new page {page}")

    # 2. Define the new routes.js content
    routes_content = """
const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/IndexPage.vue'), name: 'home' },
      { path: 'support', component: () => import('pages/SupportPage.vue'), name: 'support' },
      { path: 'photography', component: () => import('pages/PhotographyPage.vue'), name: 'photography' },
      { path: 'maps', component: () => import('pages/MapsPage.vue'), name: 'maps' },
      { path: 'merch', component: () => import('pages/MerchPage.vue'), name: 'merch' },
      { path: 'news', component: () => import('pages/NewsPage.vue'), name: 'news' }
    ]
  },

  // Always leave this as last one, but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue')
  }
]

export default routes
"""

    # 3. Overwrite the routes file
    routes_path = os.path.join('src', 'router', 'routes.js')
    
    try:
        with open(routes_path, 'w') as f:
            f.write(routes_content.strip())
        print(f"✅ Successfully updated {routes_path}")
    except FileNotFoundError:
        print("❌ Error: src/router/routes.js not found. Are you in the root of a Quasar project?")

if __name__ == "__main__":
    provision_quasar()

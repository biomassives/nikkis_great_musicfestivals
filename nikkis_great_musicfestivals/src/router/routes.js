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
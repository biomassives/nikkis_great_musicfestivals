import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '',              component: () => import('pages/IndexPage.vue') },
      { path: 'photography',   component: () => import('pages/PhotographyPage.vue') },
      { path: 'maps',          component: () => import('pages/MapsPage.vue') },
      { path: 'maps/:regionId',component: () => import('pages/MapDetailPage.vue') },
      { path: 'support',       component: () => import('pages/SupportPage.vue') },
      { path: 'merch',         component: () => import('pages/MerchPage.vue') },
      { path: 'news',          component: () => import('pages/NewsPage.vue') },
      { path: ':customSlug',   component: () => import('pages/CustomPage.vue') },
    ],
  },

  {
    path: '/admin',
    component: () => import('layouts/AdminLayout.vue'),
    children: [
      { path: 'login',          component: () => import('pages/admin/AdminLoginPage.vue') },
      { path: '',               component: () => import('pages/admin/AdminDashboardPage.vue') },
      { path: 'maps',           component: () => import('pages/admin/AdminMapsPage.vue') },
      { path: 'maps/:regionId', component: () => import('pages/admin/AdminMapEditorPage.vue') },
      { path: 'gallery',        component: () => import('pages/admin/AdminGalleryPage.vue') },
      { path: 'newsletter',     component: () => import('pages/admin/AdminNewsletterPage.vue') },
      { path: 'news',           component: () => import('pages/admin/AdminNewsPage.vue') },
      { path: 'merch',          component: () => import('pages/admin/AdminMerchPage.vue') },
      { path: 'home',           component: () => import('pages/admin/AdminHomePage.vue') },
      { path: 'story',          component: () => import('pages/admin/AdminStoryPage.vue') },
      { path: 'support',        component: () => import('pages/admin/AdminSupportPage.vue') },
      { path: 'nav',            component: () => import('pages/admin/AdminNavPage.vue') },
      { path: 'pages',          component: () => import('pages/admin/AdminPagesPage.vue') },
      { path: 'reset-password', component: () => import('pages/admin/AdminResetPasswordPage.vue') },
    ],
  },

  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue'),
  },
];

export default routes;

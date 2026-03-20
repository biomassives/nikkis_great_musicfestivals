import type { RouteRecordRaw } from 'vue-router';
import { supabase } from 'src/lib/supabase';

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
    ],
  },

  {
    path: '/admin',
    component: () => import('layouts/AdminLayout.vue'),
    children: [
      { path: 'login',           component: () => import('pages/admin/AdminLoginPage.vue') },
      { path: '',                component: () => import('pages/admin/AdminDashboardPage.vue'), meta: { requiresAuth: true } },
      { path: 'maps',            component: () => import('pages/admin/AdminMapsPage.vue'),       meta: { requiresAuth: true } },
      { path: 'maps/:regionId',  component: () => import('pages/admin/AdminMapEditorPage.vue'),  meta: { requiresAuth: true } },
      { path: 'gallery',         component: () => import('pages/admin/AdminGalleryPage.vue'),     meta: { requiresAuth: true } },
      { path: 'newsletter',      component: () => import('pages/admin/AdminNewsletterPage.vue'),  meta: { requiresAuth: true } },
      { path: 'news',            component: () => import('pages/admin/AdminNewsPage.vue'),        meta: { requiresAuth: true } },
      { path: 'merch',           component: () => import('pages/admin/AdminMerchPage.vue'),       meta: { requiresAuth: true } },
    ],
    beforeEnter: async (_to, _from, next) => {
      const meta = _to.meta as { requiresAuth?: boolean };
      if (!meta.requiresAuth) return next();
      const { data } = await supabase.auth.getSession();
      if (data.session) return next();
      next('/admin/login');
    },
  },

  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue'),
  },
];

export default routes;

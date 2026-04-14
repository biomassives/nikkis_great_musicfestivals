import { defineRouter } from '#q-app/wrappers';
import {
  createMemoryHistory,
  createRouter,
  createWebHashHistory,
  createWebHistory,
} from 'vue-router';
import routes from './routes';
import { supabase } from 'src/lib/supabase';

/*
 * If not building with SSR mode, you can
 * directly export the Router instantiation;
 *
 * The function below can be async too; either use
 * async/await or return a Promise which resolves
 * with the Router instance.
 */

export default defineRouter(function (/* { store, ssrContext } */) {
  const createHistory = process.env.SERVER
    ? createMemoryHistory
    : process.env.VUE_ROUTER_MODE === 'history'
      ? createWebHistory
      : createWebHashHistory;

  const Router = createRouter({
    scrollBehavior: () => ({ left: 0, top: 0 }),
    routes,

    // Leave this as is and make changes in quasar.conf.js instead!
    // quasar.conf.js -> build -> vueRouterMode
    // quasar.conf.js -> build -> publicPath
    history: createHistory(process.env.VUE_ROUTER_BASE),
  });

  const ADMIN_PUBLIC  = ['/admin/login', '/admin/reset-password'];
  const COMING_SOON   = import.meta.env.VITE_COMING_SOON === 'true';

  Router.beforeEach(async (to) => {
    // Coming soon mode — gate all public routes, let admin through
    if (COMING_SOON && !to.path.startsWith('/admin') && to.path !== '/coming-soon') {
      return '/coming-soon';
    }

    // Admin auth guard
    if (!to.path.startsWith('/admin')) return;
    if (ADMIN_PUBLIC.includes(to.path)) return;
    const { data } = await supabase.auth.getSession();
    if (!data.session) return '/admin/login';
  });

  return Router;
});

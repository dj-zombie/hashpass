import Vue from 'vue'
import Router from 'vue-router'
import LoginPage from '../pages/LoginPage.vue'
import MainPage from '../pages/MainPage.vue'
import ErrorPage from '../pages/ErrorPage.vue'
import QueuePage from '../pages/QueuePage.vue'
import HashesPage from '../pages/HashesPage.vue'
import SettingsPage from '../pages/SettingsPage.vue'

Vue.use(Router);

export const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'login',
      component: LoginPage
    },
    {
      path: '/attack',
      name: 'attack',
      component: MainPage
    },
    {
      path: '/hashes',
      name: 'hashes',
      component: HashesPage
    },
    {
      path: '/queue',
      name: 'queue',
      component: QueuePage
    },
    {
      path: '/settings',
      name: 'settings',
      component: SettingsPage
    },
    {
      path: '*',
      name: 'error',
      component: ErrorPage
    },
  ],
  scrollBehavior(to, from, savedPosition) {
    return {x: 0, y: 0}
  }
});

router.beforeEach((to, from, next) => {
  const publicPages = ['/'];
  const loggedIn = localStorage.getItem('user');
  if (!publicPages.includes(to.path) && !loggedIn) {
    return next('/');
  }
  else {
  }

  next();
})
import Vue from 'vue'
import Router from 'vue-router'
import MainPage from '../pages/MainPage.vue'
import ErrorPage from '../pages/ErrorPage.vue'
import QueuePage from '../pages/QueuePage.vue'
import HashesPage from '../pages/HashesPage.vue'

Vue.use(Router);

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'main_page',
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
      path: '*',
      name: 'error',
      component: ErrorPage
    },
  ],
  scrollBehavior(to, from, savedPosition) {
    return {x: 0, y: 0}
  }
});


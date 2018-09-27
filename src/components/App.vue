<template>
  <div id='app' class="flex1 skull-bg">
    <div class="navbar">      
      <ul>        
        <router-link to="attack">
          <span class="oi" data-glyph="dashboard" title="dashboard" aria-hidden="true"></span>
        </router-link>
        <router-link to="queue">
          <span class="oi" data-glyph="layers" title="queue" aria-hidden="true"></span>
        </router-link>
        <router-link to="hashes">
          <span class="oi" data-glyph="spreadsheet" title="hashes" aria-hidden="true"></span>
        </router-link>
        <router-link to="cracked">
          <span class="oi" data-glyph="lock-unlocked" title="cracked" aria-hidden="true"></span>
        </router-link>
        <router-link to="agents">
          <span class="oi" data-glyph="cloud-download" title="agents" aria-hidden="true"></span>
        </router-link>
        <router-link to="settings">
          <span class="oi" data-glyph="cog" title="settings" aria-hidden="true"></span>
        </router-link>
        <a href="/">
          <span @click="logout()" class="oi" data-glyph="account-logout" title="logout" aria-hidden="true"></span>
        </a>
      </ul>
      <div class="flex1" style="text-align:right">
        <vue-typer
          :text='title'
          :pre-type-delay='140'
          :pre-erase-delay='10000'
          :erase-delay='50'
          :shuffle='true'
          :type-delay='222'
          style="font-size:16px;margin-left:-8px;">
        </vue-typer>
      </div> 
    </div>
    <div class="view-main">
      <transition name="page" mode="out-in">
        <router-view></router-view>
      </transition>
    </div>
  </div>
</template>

<script>
  import store from '../store/store'

  export default {
    data() {
      return {
        activeIndex: '1',
        intervalId: 0,
      };
    },
    mounted() {
      console.log('route', this.$route.path)      
    },
    computed: {
      title: function() {
        return this.$route.path
      }
    },
    methods: {
      start: function() {
        if (store.getters.getPending) {
          store.dispatch('promote_next')
          store.dispatch('start')
        }
        else {
          store.dispatch('start')
        }
      },
      stop: function() {
        store.dispatch('stop')
      },
      logout: function() {
        store.dispatch('logout')
        store.dispatch('clear_token')
        this.$router.push('/')
      }
    },
    name: 'app'
  }
</script>

<style>
.page-enter-active,
.page-leave-active {
  transition-duration: 0.1s;
  transition-property: opacity;
  transition-timing-function: ease-in-out;
}

.page-enter,
.page-leave-active {
  opacity: 0
}
</style>
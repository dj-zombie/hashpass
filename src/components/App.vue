<template>
  <div id='app' class="flex1">
    <div class="navbar">
      <h1><span class="oi mr2" data-glyph="lock-unlocked" title="icon name" aria-hidden="true"></span>Hashpass</h1>
      <ul>        
        <router-link to="/">
          <span class="oi" data-glyph="target" title="dashboard" aria-hidden="true"></span>
        </router-link>
        <router-link to="hashes">
          <span class="oi" data-glyph="key" title="hashes" aria-hidden="true"></span>
        </router-link>
        <router-link to="queue">
          <span class="oi" data-glyph="list" title="queue" aria-hidden="true"></span>
        </router-link>
        <router-link to="/settings">
          <span class="oi" data-glyph="cog" aria-hidden="true"></span>
        </router-link>
        <a href="/">
          <span class="oi" data-glyph="account-logout" title="logout" aria-hidden="true"></span>
        </a>        
      </ul>
    </div>
    <div class="view-main">
      <router-view></router-view>
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
    },
    name: 'app'
  }
</script>

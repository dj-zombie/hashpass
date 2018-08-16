<template>
  <div class="view-cracked">
    <h2>Cracked</h2>
    <button class="btn btn--small" @click="clear">
      <span class="oi" data-glyph="ban" title="icon name" aria-hidden="true"></span>
      Clear
    </button>
    <div class="card" v-for="cracked in getCracked">
      <div class="card__header">{{cracked.hash}}</div>
      <div class="card__body">
        <p>Password: <span>{{cracked.password}}</span></p>
      </div>
    </div>
  </div>
</template>

<script>
  import store from '../store/store'

  export default {
    computed: { 
      getCracked: function() { return store.getters.getCracked; },
      getQueue: function() { return store.getters.getPending; }
    },
    mounted(){
      store.dispatch('get_cracked')
    },
    methods: {
      clear: function() {
        store.dispatch('clear_cracked')
      }
    }
  }
</script>

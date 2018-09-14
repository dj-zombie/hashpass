<template>
  <div class="text-center">
    <h2>Cracked</h2>
    <button class="btn btn--small" @click="clear">
      <span class="oi" data-glyph="ban" title="clear" aria-hidden="true"></span>
      Clear
    </button>
    <div class="view-cracked">    
      <div class="card" v-for="cracked in getCracked">
        <div class="card__header"><span class="oi" data-glyph="wifi" title="clear" aria-hidden="true"></span> {{ getName(cracked.hash) }}</div>
        <div class="card__body text-highlight">
          {{ cracked.password }}</span></p>
        </div>
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
      getName: function(h) {
        console.log('hash:', h)
        let data = h.toString().split('*')
        if (data.length > 2) {
          let name = '';
          let hex = data[data.length-1]
          for (var i = 0; (i < hex.length && hex.substr(i, 2) !== '00'); i += 2) {
            name += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
          }
          return name
        }
        else {
          return h
        }
      },
      clear: function() {
        store.dispatch('clear_cracked')
      }
    }
  }
</script>

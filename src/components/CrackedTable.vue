<template>
  <div class="text-center" style="max-width:800px;margin:0 auto">
    <h2>Cracked</h2>
    <button class="btn btn--small" @click="clear">
      <span data-glyph="ban" title="Delete All!" aria-hidden="true" class="oi text-red"></span>
    </button>
    <button class="btn btn--small" @click="showGrid = !showGrid">
      <span v-show="showGrid" class="oi" data-glyph="list" title="List View" aria-hidden="true"></span>
      <span v-show="!showGrid" class="oi" data-glyph="grid-three-up" title="Gride View" aria-hidden="true"></span>
    </button>

    <span v-if="getCracked.length <= 0" class="w100 dblock mt3 text-center">Aww you haven't cracked anything yet 😂</span>

    <div v-if="getCracked.length" class="view-cracked flex-col">
      <v-client-table v-show="!showGrid" class="skull-bg" :data="getCracked" :columns="crackedColumns" :options="crackedOptions">
        <div slot="hash" slot-scope="props">
          {{ getName(props.row.hash) }}
        </div>
      </v-client-table>
    </div>    
    <div v-show="showGrid" class="view-cracked">
      <transition-group name="cracked" tag="cracked">
        <div class="card" v-for="cracked in getCracked" :key="showGrid">
          <div class="card__header">
            <span class="oi" data-glyph="wifi" title="wifi" aria-hidden="true"></span>
            {{ getName(cracked.hash) }}
          </div>
          <div class="card__body text-highlight">
            {{ cracked.password }}
          </div>
        </div>
      </transition-group>
    </div>
  </div>
</template>

<script>
  import store from '../store/store'
  import {ServerTable, ClientTable, Event} from 'vue-tables-2';

  export default {
    data() {
      return {
        crackedColumns: ['hash', 'password'],
        crackedOptions: {
          perPage: 999,
          filterable: false,          
        },
        showGrid: false
      }
    },
    computed: { 
      getCracked: function() { return store.getters.getCracked; },
      getQueue: function() { return store.getters.getPending; }      
    },
    mounted(){
      store.dispatch('get_cracked')
    },
    methods: {
      getName: function(h) {
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

<style>

.view-cracked cracked {
  display: flex;
  flex-flow: wrap;
}
.cracked-enter-active,
.cracked-leave-active,
.cracked-move {
  transition: 1000ms cubic-bezier(0.59, 0.12, 0.34, 0.95);
  transition-property: opacity, transform;
}

.cracked-enter {
  opacity: 0;
  transform: translateY(50px) scaleX(0.5);
}

.cracked-enter-to {
  opacity: 1;
  transform: translateY(0) scaleX(1);
}

.cracked-leave-active {
  position: absolute;
}

.cracked-leave-to {
  opacity: 0;
  transform: scaleY(0);
  transform-origin: center top;
}
</style>
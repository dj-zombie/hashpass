<template>
  <div>
    <div class="view-queue">
      <h2>Attack Queue</h2>
      <div class="dflex">        
        <button v-if="getPending[0]" class="btn btn--small" @click="clear">
          <span class="oi" data-glyph="ban" title="icon name" aria-hidden="true"></span>
          Clear
        </button>
        <div v-if="getRunning[0]">
          <button v-if="progress.restore_point.split('/')[0] > 0" class="btn btn--secondary" @click="stop">
            <span class="oi" data-glyph="play" title="icon name" aria-hidden="true"></span>
            <span>Pause</span>
          </button>
          <button v-else class="btn btn--red" @click="stop">
            <span>Stop</span>
          </button>
        </div>
        <div v-else>
          <button v-if="getPending[0]" class="btn btn--primary" v-bind:class="{ 'loading' : isLoading }" @click="start">
            <span>Crack!</span>
          </button>
          <router-link v-else to="/hashes" class="btn btn--secondary" tag="button">Queue Hash</router-link>
        </div>
        <button v-if="getPending[0]" class="btn btn--small" @click="promote_next">
          <span class="oi" data-glyph="arrow-circle-top" title="icon name" aria-hidden="true"></span>
          Next
        </button>
      </div>
      <div class='dflex' v-bind:class="{ 'grow': getPending[0] }" style='overflow:hidden;flex-direction:column'>
        <transition name='fade' class='view-queue'>
          <div class="card" v-for="queue in getPending" v-bind:key="queue">
            <div class="card__header">
              <span class="oi mr2 fr" data-glyph="wifi" title="icon name" aria-hidden="true"></span>
              🎯 {{queue.name}}
            </div>
            <div class="card__body">
              <p v-if="queue.name">Hash: <span>{{ queue.hash }} {{ queue.hashstring }}</span></p>
              <p v-if="queue.hashmode">Type: <span>{{queue.hashmode}}</span></p>
              <p v-if="queue.dictionary">Dictionary: <span>{{queue.dictionary}}</span></p>
              <p v-if="queue.dictionary2">Dictionary 2: <span>{{queue.dictionary2}}</span></p>
              <p v-if="queue.rules">Rules: <span>{{queue.rules}}</span></p>
              <p v-if="queue.mask">Mask: <span>{{queue.mask}}</span></p>
            </div>
          </div>
        </transition>
      </div>
    </div>    
  </div>
</template>

<script>
  import store from '../store/store'

  export default {
    components: {},

    data: function() {
      return {
        isLoading: false,
      }
    },
    computed: {
      getPending: function() { return store.getters.getPending; },
      getRunning: function() { return store.getters.getRunning; },
      progress: function() { return store.getters.getProgress },
    },
    methods: {
      clear: function() { store.dispatch('clear_running')  },
      promote_next: function() {
        store.dispatch('promote_next')
          .then(function() {
            store.dispatch('get_pending');
            store.dispatch('get_running');
          })
          .catch((error)=>{ console.error('promote_next', error)
        })
      },
      start: function() {
        if (store.getters.getPending) {
          store.dispatch('promote_next')
          store.dispatch('start')
          store.dispatch('get_pending');
          store.dispatch('get_running');
        }
        else {
          store.dispatch('start')
        }
        this.isLoading = true;
        let _this = this
        setTimeout(function() {
          _this.isLoading = false;
        }, 3000);
      },
      stop: function() { 
        store.dispatch('stop') 
        store.dispatch('get_pending');
        store.dispatch('get_running');
        this.isLoading = false;
      },
      pause: function() { 
        store.dispatch('pause') 
        store.dispatch('get_pending');
        store.dispatch('get_running');
      },
    }
  }
</script>

<style>
  .fade-enter-active,
  .fade-leave-active { 
    transition: opacity 2.5s ease-out;
    .view-queue & {
      flex: 1;
    }
  }
  .fade-enter,
  .fade-leave-to { opacity: 0; }
  .view-queue {
    overflow: hidden;
    transition: flex .66s ease-out;
    flex-direction: column;
    flex: 0;
    height: auto;
  }
  .grow {
    flex: 1;
  }
</style>

<template>
  <div>
    <div class="view-queue">
      <h2>Attack Queue</h2>
      <div class="dflex" style="flex:1; align-items: center">        
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
          <router-link v-else to="/hashes" class="btn btn--secondary" tag="button">
            <span class="oi" data-glyph="list" title="clear" aria-hidden="true"></span>
            Queue Hash
          </router-link>
        </div>
        <button v-if="getPending[0]" class="btn btn--small" @click="promote_next">
          <span class="oi" data-glyph="arrow-circle-top" title="icon name" aria-hidden="true"></span>
          Next
        </button>
      </div>
      <div class='dflex' v-bind:class="{ 'grow': getPending[0] }" style='overflow:hidden;flex-direction:column'>
        <transition-group name="queue" tag="queue">
          <div class="card" v-for="queue in getPending" :key="showQueue">
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
        </transition-group>
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
        showQueue: false
      }
    },
    computed: {
      getPending: function() { return store.getters.getPending; },
      getRunning: function() { return store.getters.getRunning; },
      progress: function() { return store.getters.getProgress },
    },
    mounted() {
      store.dispatch('get_pending')
      this.showQueue = !this.showQueue
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
  .faded-enter-active,
  .faded-leave-active { 
    /*transition: opacity 2.5s ease-out;*/
    .view-queue & {
      /*flex: 1;*/
    }
  }
  .faded-enter,
  .faded-leave-to { }

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


  .view-queue queue {
    max-width: 800px;
    display: flex;
    flex-flow: wrap;
  }
  .queue-enter-active,
  .queue-leave-active,
  .queue-move {
    transition: 1000ms cubic-bezier(0.59, 0.12, 0.34, 0.95);
    transition-property: opacity, transform;
  }

  .queue-enter {
    opacity: 0;
    transform: translateY(50px) scaleX(0.5);
  }

  .queue-enter-to {
    opacity: 1;
    transform: translateY(0) scaleX(1);
  }

  .queue-leave-active {
    position: absolute;
  }

  .queue-leave-to {
    opacity: 0;
    transform: scaleY(0);
    transform-origin: center top;
  }
</style>

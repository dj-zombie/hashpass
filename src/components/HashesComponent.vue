<template>
  <div>
    <div class="view-hashes">
      <div class="hashtable">           
        <v-client-table :data="getHashes" :columns="columns" :options="options" >
          <div v-if="props.row.added" slot="added" slot-scope="props">{{ props.row.added | moment("dddd, MMMM Do YYYY HH:mm") }}</div>
          <div slot="child_row" slot-scope="props" style='padding:1rem'>
            <div>
              <button class="btn btn--mini" @click="deleteHash(props.row.id)">Delete</button>
              <button class="btn btn--mini" @click="">Edit</button>
              <button class="btn btn--mini" @click="">Queue</button>
              <button class="btn btn--mini" @click="">Cut in line</button>
              <button class="btn btn--mini" @click="rowclick(props.row.id)">History</button>
            </div>            
            <div class='mt3'>
              <div>
                <div>
                  <div v-show='props.row.longitude'>
                    Longitude:
                    <span class='text-secondary'>{{ props.row.longitude }}</span>
                  </div>
                  <div v-show='props.row.latitude'>
                    Latitude: 
                    <span class='text-secondary'>{{ props.row.latitude }}</span>
                  </div>
                  <div v-show='props.row.string'>
                    Hash String: 
                    <span class='text-secondary'>{{ props.row.string }}</span>
                  </div>
                  <div v-show='props.row.file'>
                    File: 
                    <span class='text-secondary'>{{ props.row.file }}</span>
                  </div>
                  <div v-show='props.row.mode'>
                    Mode: 
                    <span class='text-secondary'>{{ props.row.mode }}</span>
                  </div>
                  <div v-show='props.row.loot'>
                    Loot 💰: 
                    <span class='text-secondary'>{{ props.row.loot }}</span>
                  </div>
                  <div v-show='props.row.added'>
                    Added on: 
                    <span class='text-secondary'>{{ props.row.added }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <input type="checkbox" name="checkboxes" slot="select" slot-scope="props" v-model="hashSelection" :value="props.row">                
        </v-client-table>
        <div style='align-items: center'>
          <label for="select" class="label">Select All:</label>
          <input id="select" type="checkbox" v-model="selectall">
          <button class="btn btn--primary btn--small" @click="toggleModal(hash)">Queue</button>
          <!-- <button class="btn btn--primary btn--small">Cut in line</button> -->
          <!-- <button class="btn btn--primary btn--small">Edit</button>  -->
          <button class="btn btn--primary btn--small" @click="showModal">Add</button>
        </div>
      </div>

      <div class="map">
        <l-map :zoom="zoom" :center="center" :min-zoom="1" :max-zoom="18">
          <l-control-layers :position="position"/>
          <l-tile-layer :url="url" :attribution="attribution"></l-tile-layer>
          <l-control-zoom :position="position" />  
          <l-control-attribution :position="position" :prefix="Vue2Leaflet" />
          <l-control-scale :imperial="false" />       
          <marker-popup v-for="hash in hashSelection" :key="hash.id" :position="latlong(parseFloat(hash.latitude), parseFloat(hash.longitude))" :text="hash.name"></marker-popup>
        </l-map>
      </div>      
    </div>
    <div class="p2">
      <h2 class="text-center">History</h2>
      <v-client-table :data="showHistory" :columns="historyCols" :options="historyOps" >

        <div v-if="props.row.restore" slot="restore" slot-scope="props">
          <button @click="resume(props.row)" class="btn btn--secondary btn--small">&#9654;</button> 
        </div>

        <div v-if="props.row.started_on" slot="started_on" slot-scope="props">
          {{ props.row.started_on | moment("dddd, MMMM Do YYYY HH:mm") }}
        </div>
      </v-client-table>      
    </div>


    <modal v-if="modalVisible" @close="toggleModal">
      <h3 slot="header">
        Queue Hash
        <button class="btn btn--small modal-default-button mt0" @click="toggleModal">
          Close
        </button>
      </h3>
      <queue-form :hashes="hashSelection" slot="body"></queue-form>
      <!-- <v-client-table slot="footer" :data="showHistory" :columns="historyCols" :options="historyOps" >
        <div v-if="props.row.started_on" slot="started_on" slot-scope="props">
          {{ props.row.started_on | moment("dddd, MMMM Do YYYY HH:mm") }}
        </div>
      </v-client-table> -->
    </modal>

    <modal v-if="modalHashVisible" @close="hideModal">
      <h3 slot="header">
        Crack new hash
        <button class="btn btn--small modal-default-button mt0" @click="hideModal">
          Close
        </button>
      </h3>
      <upload-hash-form slot="body"></upload-hash-form>
    </modal>
  </div>
</template>


<script>
  import store from '../store/store'
  import L from 'leaflet'
  import { LMap, LTileLayer, LMarker, LIconDefault } from 'vue2-leaflet';
  import QueueForm from '../components/QueueForm.vue'
  import Modal from '../components/ModalComponent.vue'
  import MarkerPopup from '../components/MarkerPopup.vue';
  import {ServerTable, ClientTable, Event} from 'vue-tables-2';
  import Vue2LeafletMarkerCluster from 'vue2-leaflet-markercluster'
  import UploadHashForm from '../components/UploadHashForm.vue'
  
  export default {
    components: {UploadHashForm: UploadHashForm, Modal: Modal, QueueForm: QueueForm, LMap: LMap, LTileLayer: LTileLayer, LMarker: LMarker, MarkerPopup: MarkerPopup, LIconDefault: LIconDefault},

    data: function() {
      return {
        modalVisible: false,
        errors: [],
        hashSelection: [],
        columns: ['select', 'name', 'mode', 'loot', 'added'],      
        options: {
          headings: {
            select: '',
            loot: 'Loot 💰',
            added: 'Added'
          },
          columnsDisplay: {
            added: 'desktop',
            mode: 'desktop',
          },
          columnsClasses: { loot: 'text-primary', name: 'flex1 text-secondary', 
            select: 'cboxes', added: 'added', mode: 'mode'
          },
          perPage: 10,
          sortable: ['added', 'name', 'mode', 'loot'],
          filterable: ['name', 'mode'],
        },
        historyCols: ['restore', 'dictionary', 'dictionary2', 'rules', 'mask', 'started_on'],      
        historyOps: {
          headings: {
            restore: 'Resume',
            dictionary: 'Dictionary', 
            dictionary2: 'Dic2',
            rules: 'Rules',
            mask: 'Mask',
            started_on: 'Started'
          },
          columnsDisplay: {
            started_on: 'desktop'
          },
          columnsClasses: { restore: 'restore' },
          perPage: 10,
          sortable: ['dictionary', 'dictionary2', 'rules', 'mask', 'completed'],
          filterable: [],
        },
        marker: L.latLng(32.83165, -117.1123964),
        marker2: L.latLng(32.835615, -117.125568),
        text: 'my marker popup text',
        title: 'My marker popup title',
        position: 'topright',
        zoom: 10,
        bounds: L.latLngBounds([[33.2323423, -223.32343], [32.835615, -117.125568]]),
        maxBounds: L.latLngBounds([[33.2323423, -223.32343], [32.835615, -117.125568]]),
        url: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
        attribution:'&#x2620;',

      }
    },
    mounted() {
      setTimeout(function() { window.dispatchEvent(new Event('resize')) }, 250);
      store.dispatch('get_history')
    },
    watch: {
      hashSelection: function(val) {
        let id = val[val.length-1].id
        store.dispatch('get_history', id)
      }
    },
    computed: { 
      getHashes: function() { return store.getters.getHashes; },
      selectall: {
        get: function () {
          return this.getHashes ? this.hashSelection.length == this.getHashes.length : false;
        },
        set: function (value) {
          var selected = [];
          if (value) {
            this.getHashes.forEach(function (hash) {
              selected.push(hash);
            });
          }
          this.hashSelection = selected;
        }
      },
      center: function() {
        if (this.hashSelection[0]) {
          let lat = parseFloat(this.hashSelection[this.hashSelection.length-1].latitude);
          let long = parseFloat(this.hashSelection[this.hashSelection.length-1].longitude);  
          return L.latLng(lat, long)
        }
        else {
          return L.latLng(32.835615, -117.125568)
        }
      },
      showHistory: function() {
        return store.getters.getHistory
      },
      modalHashVisible: function() { return store.getters.getShowModal; }      
    },
    methods: {
      toggleModal: function() { 
        this.modalVisible = !this.modalVisible
      },
      latlong: function(lat, long) { 
        return L.latLng(lat || 0, long || 0) 
      },
      deleteHash: function(id) { 
        store.dispatch('delete_hash', id)
        store.dispatch('get_hashes')
      },
      rowclick: function(id) {
        store.dispatch('get_history', id)
      },
      resume: function(row) {
        console.log('resume', row)
        let _this = this;
        store.dispatch('create_pending', {name: 'Resume', dictionary: row.dictionary, dictionary2: row.dictionary2, rules: row.rules, mask: row.mask, hash: row.started_on, hashmode: '', hashstring: '', hashid: row.hashid})
            .then(function(){
              store.dispatch('get_pending');
              store.dispatch('get_running');
              _this.$router.push('/')
            })
            .catch((error)=>{ console.error(error) })  
      },
      showModal: function() { store.dispatch('show_modal') },
      hideModal: function() { store.dispatch('hide_modal') },
    },
    mounted(){
      store.dispatch('get_hashes')
    }
  }
</script>

<style>
.VueTables__child-row-toggler {
  width: 16px;
  height: 16px;
  line-height: 16px;
  display: block;
  margin: auto;
  text-align: center;
}

.VueTables__child-row-toggler--closed::before {
  content: "+";
}

.VueTables__child-row-toggler--open::before {
  content: "-";
}
.cboxes {
  width: 20px;
}
.added {
  width: 220px;
  text-align: center;
}
.mode {
  width: 60px;
  text-align: center;
}
.restore {
  width: 48px;
}
</style>
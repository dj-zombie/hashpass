<template>
  <div>
    <div class="view-hashes">
      <div class="hashtable">           
        <v-client-table :data="getHashes" :columns="columns" :options="options" >
           <div v-if="props.row.added" slot="added" slot-scope="props">
            {{ props.row.added | moment("ddd, MMM Do h:mma") }}
            <!-- {{ props.row.added }} -->
          </div>
          <div slot="child_row" slot-scope="props" style='padding:1rem'>
            <div>
              <button class="btn btn--mini btn--secondary" @click="deleteHash(props.row.id)">Delete</button>
              <button class="btn btn--mini btn--secondary" @click="rowclick(props.row.id)">History</button>
              <button class="btn btn--mini btn--secondary" @click="fetchAgentLogs(props.row.name)">Get Agent Logs</button>
              <div class="dflex mt3" style="flex-wrap: wrap">
                <button v-for="file in getAgentLogs" class="btn btn--mini" @click="fetchAgentLog(props.row.name, file)">{{ file }}</button>
              </div>
            </div>
            <div class="dflex mt3" style="flex-wrap:wrap">
              <div class="flex1">
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
                    Lo💰t: 
                    <span class='text-secondary'>{{ props.row.loot }}</span>
                  </div>
                  <div v-show='props.row.added'>
                    Added on: 
                    <span class='text-secondary'>{{ props.row.added }}</span>
                  </div>
                  <textarea v-show="getAgentLog" autocomplete="off" autocorrect="off" autocapitalize="off" wrap="off" spellcheck="false">{{ getAgentLog }}</textarea>
                </div>
              </div>
            </div>
          </div>
          <input type="checkbox" name="checkboxes" slot="select" slot-scope="props" v-model="hashSelection" :value="props.row">                
        </v-client-table>
        <div style='align-items: center; text-align: center'>
          <label for="select" class="label" style="float:left;margin-top:1rem">
            Select All:
          </label>
          <input id="select" type="checkbox" style="float:left;margin-left:0.8rem;margin-top:1rem" v-model="selectall">
          <button v-show="hashSelection.length" class="btn btn--secondary btn--small" @click="toggleModal(hash)">
            👌 Queue
          </button>
          <button class="btn btn--primary btn--small" @click="showModal">
            Import
          </button>
          <button class="btn btn--small fright"  @click="toggleMap">
            Toggle Map
          </button>
        </div>
      </div>

      <div v-show="showMap" :class="{ 'showmap' : showMap }" class="map">
        <l-map :zoom="zoom" :center="center" :min-zoom="1" :max-zoom="18">
          <l-control-layers :position="position"/>
          <l-tile-layer :url="url" :attribution="attribution"></l-tile-layer>
          <l-control-zoom :position="position" />  
          <l-control-attribution :position="position" :prefix="Vue2Leaflet" />
          <l-control-scale :imperial="false" />       
          <marker-popup v-for="hash in hashSelection" :key="hash.id" :position="latlong(parseFloat(hash.latitude), parseFloat(hash.longitude))" :title="hash.loot" :text="getMarkerContent(hash.name, hash.loot)"></marker-popup>
        </l-map>
      </div>      
    </div>
    <div v-if="hashSelection.length" class="p2">
      <h2 class="text-center no-transform">
        {{ hashSelection[hashSelection.length-1].name }} History
      </h2>
      <v-client-table :data="showHistory" :columns="historyCols" :options="historyOps" >

        <div v-if="props.row.restore" slot="restore" slot-scope="props">
          <button @click="resume(props.row)" class="btn btn--secondary btn--small">&#9654;</button> 
        </div>

        <div v-if="props.row.started_on" slot="started_on" slot-scope="props">
          <!-- {{ props.row.started_on | moment("dddd, MMMM Do YYYY HH:mm") }} -->
          {{ props.row.started_on }}
        </div>
      </v-client-table>      
    </div>


    <modal v-if="modalVisible" @close="toggleModal">
      <h3 slot="header">
        Queue Hash
        <button class="btn btn--small modal-default-button mt0" @click="toggleModal" style="position:absolute;top:1rem;right:5px">
          Close
        </button>
      </h3>
      <queue-form :hashes="hashSelection" slot="body"></queue-form>
    </modal>

    <modal v-if="modalHashVisible" @close="hideModal">
      <h3 slot="header">
        Import hash to database
        <button class="btn btn--small modal-default-button mt0" @click="hideModal" style="position:absolute;top:1rem;right:5px">
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
        showMap: true,
        errors: [],
        hashSelection: [],
        columns: ['select', 'name', 'mode', 'loot', 'hosts', 'added'],      
        options: {
          headings: {
            select: '🎯',
            loot: 'Lo💰t',
            added: 'Added'
          },
          // sortingAlgorithm: function(data, column) {
          //   alert('haaay! ' + column + data)
          // },
          columnsDisplay: {
            added: 'desktop',
            mode: 'desktop',
            hashes: 'desktop',
            loot: 'desktop',
            hosts: 'desktop'
          },
          columnsClasses: { loot: 'text-primary text-center', name: 'flex1 text-secondary', 
            select: 'cboxes text-center', added: 'added', mode: 'mode', hosts: 'text-center'
          },
          perPage: 10,
          sortable: ['added', 'name', 'mode', 'hosts', 'loot'],
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
            dictionary2: 'desktop',
            rules: 'desktop',
            mask: 'desktop',            
            started_on: 'desktop'
          },
          columnsClasses: { restore: 'restore' },
          perPage: 10,
          sortable: ['dictionary', 'dictionary2', 'rules', 'mask', 'completed'],
          filterable: [],
        },
        marker: L.latLng(32.83165, -117.1123964),
        marker2: L.latLng(32.835615, -117.125568),
        text: 'hash',
        title: 'name',
        position: 'topright',
        zoom: 11,
        bounds: L.latLngBounds([[33.2323423, -223.32343], [32.835615, -117.125568]]),
        maxBounds: L.latLngBounds([[33.2323423, -223.32343], [32.835615, -117.125568]]),
        url: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
        attribution:'&#x2620;',

      }
    },
    mounted() {
      store.dispatch('get_history')
    },
    watch: {
      hashSelection: function(val) {
        if (!val.length) { return }
        let id = val[val.length-1].id
        store.dispatch('get_history', id)
      }
    },
    computed: { 
      getAgentLog: function() { return store.getters.getAgentLog; },
      getAgentLogs: function() { return store.getters.getAgentLogs; },
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
      toggleMap: function() {
        this.showMap = !this.showMap
      },
      getMarkerContent: function(name, loot) {
        if (loot) {
          return name + ' - ' + loot
        }
        else {
          return name
        }
      },
      fetchAgentLog: function(ssid, file) {
        store.dispatch('get_agent_log', { ssid: ssid, file: file })
      },
      fetchAgentLogs: function(ssid) {
        store.dispatch('get_agent_logs', ssid)
      },
      resume: function(row) {
        console.log('resume', row)
        let _this = this;
        store.dispatch('create_pending', { name: 'Resume', dictionary: row.dictionary, dictionary2: row.dictionary2, rules: row.rules, mask: row.mask, hash: row.started_on, hashmode: '', hashstring: '', hashid: row.hashid })
            .then(function(){
              store.dispatch('get_pending');
              store.dispatch('get_running');
              _this.$router.push('/attack')
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
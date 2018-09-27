<template>
  <form class="dflex flex-col" action=''>
    <p v-if="errors.length">
      <b>
        Please correct the following error(s):
      </b>
      <ul class="error">
        <li v-for="error in errors">
          {{ error }}
        </li>
      </ul>
    </p>
    </div>    
    <div class="field-group">
      <label for="name" class="label">
        Name
      </label>
      <div class="field">
        <input name="name" type="text" v-model="getItem.name">
       </div>
    </div>
    <div class="field-group">
      <label for="upload" class="label">
        Upload Hash:
      </label>
      <div class="field upload">
        <button class='btn'>
          Browse
        </button>
        <input name="files[]" class='' ref="files" type="file" @change="onFileChange" autoComplete="off" multiple>
        <small class="ml2">{{files.length}} files selected</small>
      </div>
    </div>
    <p class="text-right">
      If you need a hash generator try: <a href="https://www.onlinehashcrack.com/hash-generator.php" target="_blank">Online Hash Crack</a>
    </p>
    <div class="field-group">
      <label for="hashstring" class="label">
        Hash String
      </label>      
      <div class="field">
        <input name="hashstring" id="hashstring" type="text" v-model="getItem.hashstring">
       </div>
    </div>
    <div class="field-group">
      <div class="label">
        Mode:
      </div>
      <div class="field">
        <select id="mode" name="mode" v-model="getItem.hashmode">
          <option value="" selected disabled hidden>Select Hash Mode</option>
          <option value="2500">WPA2</option>
          <option value="0">MD5</option>
          <option value="3000">LM</option>
          <option value="1000">NTLM</option>
          <option value="300">MySQL</option>
          <option value="100">SHA-1</option>
          <option value="1400">SHA-256</option>
          <option value="1700">SHA-512</option>
          <option value="2611">vBulletin &lt; 3.8.5</option>
          <option value="2711">vBulletin &gt;= 3.8.5</option>
          <option value="400">phpBB3 (MD5)</option>
          <option value="2811">IPB2+</option>
          <option value="2811">MyBB 1.2+</option>
          <option value="7900">Drupal 7</option>
          <option value="400">Wordpress (MD5)</option>
          <option value="3200">bcrypt</option>
          <option value="9999">Other</option>
        </select>
      </div>
    </div>
    <div class="field-group">
      <label for="latitude" class="label">
        Location
      </label>
      <div class="field">
        <input name="latitude" type="text" placeholder="latitude" v-model="getItem.latitude">
      </div>
      <div class="field">
        <input name="longitude" type="text" placeholder="longitude" v-model="getItem.longitude">
      </div>
    </div>
    <button name="submit" type="button" v-on:click="add_item" @keyup.enter="add_item" class="btn btn--primary">Submit</button>
  </form>
</template>

<script>
  import store from '../store/store'
  import axios from 'axios'

  export default {
    data: function(){
      return {
        files: '',
        errors: []        
      };
    },
    computed: {
      getItem: function(){
        return store.getters.getItem
      }
    },
    methods: {
      checkform() {
        this.errors = []
        if (!store.getters.getItem.hashmode) {
          this.errors.push('Hash mode requird.')
        }
        if (!this.files &&
            !store.getters.getItem.hashstring) {
            this.errors.push('Select either Upload Hash or Hash String.')
        }
        if (store.getters.getItem.hashstring &&
          this.files) {
          this.errors.push('You cannot select both hash file and hash string.')
        }
        if (!this.errors.length) {
          return true
        }
      },
      submitFiles() {
        let formData = new FormData();
        for(var i = 0; i < this.files.length; i++) {
          let file = this.files[i];
          formData.append('files[' + i + ']', file);
        }
        axios.post( '/api/upload',
          formData,{headers: {'Content-Type': 'multipart/form-data'}}
        ).then(function(){
        })
        .catch(function(){
          console.error('Unable to upload files');
        });
      },
      onFileChange() {
        this.files = this.$refs.files.files;
      },
      add_item: function() {
        if (!this.checkform()) return false
        store.dispatch('hide_modal')
        this.submitFiles()
        const files = this.files;
        if (files.length > 1) {
          for (var i=0; i < files.length; i++) {
            store.dispatch('insert_hash', {name: this.getItem.name, hash: this.files[i].name, hashmode: this.getItem.hashmode, hashstring: this.getItem.hashstring, latitude: this.getItem.latitude, longitude: this.getItem.longitude})
              .then(function(){
                store.dispatch('get_hashes')
              })
              .catch((error)=>{ console.error(error) })
          }
          this.files = [];
        }
        else if (files.length == 1) {
          store.dispatch('insert_hash', {name: this.getItem.name, hash: this.files[0].name, hashmode: this.getItem.hashmode, hashstring: this.getItem.hashstring, latitude: this.getItem.latitude, longitude: this.getItem.longitude})
            .then(function(){
              store.dispatch('get_hashes')
            })
            .catch((error)=>{ console.error(error) })
          this.files = [];
        } else {
          let _this = this;
          store.dispatch('insert_hash', {name: this.getItem.name, hash: '', hashmode: this.getItem.hashmode, hashstring: this.getItem.hashstring, latitude: this.getItem.latitude, longitude: this.getItem.longitude})
            .then(function(){
              store.dispatch('get_hashes')
              _this.$parent.dialogVisible = false;
            })
            .catch((error)=>{ console.error(error) })
          this.fileList = [];
        }
      }
    }
  }
</script>

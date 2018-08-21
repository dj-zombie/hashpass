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
        Dictionary:
      </div>
      <div class="field">
        <select id="dictionary" name="dictionary" v-model="getItem.dictionary">
          <option value="" selected disabled hidden>Select Dictionary</option>
          <option value="rockyou.txt">RockYou 140MB</option>
          <option value="Rocktastic12a.txt">Rocktastic12a</option>
          <option value="Custom-WPA.txt">Custom WPA</option>
          <option value="Top1pt8Billion-WPA-probable-v2.txt">Top1pt8Billion WPA-probable v2</option>
          <option value="Top1pt2Million-WPA-probable-v2.txt">Top1pt2Million-WPA-probable-v2</option>
          <option value="MainEnglishDictionary_ProbWL.txt">MainEnglishDictionary_ProbWL</option>
          <option value="HashesOrg.txt">HashesOrg</option>
          <option value="crackstation.txt">crackstation</option>
          <option value="WoNDeR.txt">WoNDeR 98MB</option>
          <option value="weakpass_2.txt">Weakpass 30GB</option>
          <option value="weakpass_2_wifi.txt">Weakpass WIFI 28GB</option>
          <option value="google-10000-english-no-swears.txt">Google top 10k no swears</option>
          <option value="google-10000-english-usa.txt">Google top 10k usa</option>
        </select>
      </div>
    </div>
    <div class="field-group">
      <div class="label">
        Dictionary 2:
      </div>
      <div class="field">
        <select id="dictionary2" name="dictionary2" v-model="getItem.dictionary2">
          <option value="" selected disabled hidden>Select Dictionary</option>
          <option value="rockyou.txt">RockYou 140MB</option>
          <option value="Rocktastic12a.txt">Rocktastic12a</option>
          <option value="Custom-WPA.txt">Custom WPA</option>
          <option value="Top1pt8Billion-WPA-probable-v2.txt">Top1pt8Billion WPA-probable v2</option>
          <option value="Top1pt2Million-WPA-probable-v2.txt">Top1pt2Million-WPA-probable-v2</option>
          <option value="MainEnglishDictionary_ProbWL.txt">MainEnglishDictionary_ProbWL</option>
          <option value="HashesOrg.txt">HashesOrg</option>
          <option value="crackstation.txt">crackstation</option>
          <option value="WoNDeR.txt">WoNDeR 98MB</option>
          <option value="weakpass_2.txt">Weakpass 30GB</option>
          <option value="weakpass_2_wifi.txt">Weakpass WIFI 28GB</option>
          <option value="google-10000-english-no-swears.txt">Google top 10k no swears</option>
          <option value="google-10000-english-usa.txt">Google top 10k usa</option>
        </select>
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
      <label for="rules" class="label">
        Rules:
      </label>
      <div class="field">
        <select id="rules" name="rules" v-model="getItem.rules">
          <option value="" selected disabled hidden>Select Rules</option>
          <option value="hybrid/append_d">Append Number</option>
          <option value="hybrid/append_ds">Append Number + Symbol</option>
          <option value="hybrid/append_s">Append Symbol</option>
          <option value="hybrid/prepend_s">Prepend Symbol</option>
          <option value="hybrid/prepend_n">Prepend Number</option>
          <option value="best">Best</option>
          <option value="best64">Best 64</option>
          <option value="d3ad0ne">d3ad0ne</option>
          <option value="d3adhob0">d3adhob0</option>
          <option value="zombie">zombie</option>
          <option value="leetspeek">leetspeek</option>
          <option value="rockyou-30000">rockyou-30000</option>
          <option value="T0XlC">T0XlC</option>
          <option value="OneRuleToRuleThemAll">OneRuleToRuleThemAll</option>
        </select>
      </div>
    </div>
    <div class="field-group">
      <label for="mask" class="label">Mask:</label>
      <div class="field">
        <input name="mask" id="mask" type="text" spellcheck="false" v-model="getItem.mask" pattern="[?ludhHsab]">
      </div>
      <div class="field">
        <textarea>
          Cheat sheet
          ============
          l: a-z
          u: A-Z
          d: 0-9
          h: 0-9a-f
          H: 0-9A-F
          s: !"#$..
          a: ?l?u?d?s
          b: 0x00-0xff
        </textarea>
      </div>
    </div>
    <div name="submit" type="submit" v-on:click="add_item" @keyup.enter="add_item" class="btn btn--primary">Submit</div>
  </form>
</template>

<script>
  import store from '../store/store'
  import axios from 'axios'

  export default {
    data: function(){
      return {
        files: '',
        errors: [],
        options: [{
            value: 'rockyou.txt',
            label: 'Rockyou'
          }, {
            value: 'john.txt',
            label: 'John the ripper'
          }, {
            value: 'phpbb.txt',
            label: 'PHPbb'
          }, {
            value: 'WoNDeR.txt',
            label: 'wunderlist'
          }],
        hashModes: [{
            value: '2500',
            label: 'WPA2'
          }, {
            value: '0',
            label: 'MD5'
          }, {
            value: '1700',
            label: 'SHA-512'
          }, {
            value: '1000',
            label: 'NTLM'
          }, {
            value: '300',
            label: 'MySQL'
          }],
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
        if (!store.getters.getItem.dictionary &&
            !store.getters.getItem.dictionary2 &&
            !store.getters.getItem.mask) {
          this.errors.push('Select at least one dictionary or mask')
        }
        if (store.getters.getItem.rules &&
            store.getters.getItem.mask) {
          this.errors.push('You cannot select both mask and rules.')
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
            store.dispatch('create_pending', {name: this.getItem.name, dictionary: this.getItem.dictionary, dictionary2: this.getItem.dictionary2, rules: this.getItem.rules, mask: this.getItem.mask, hash: this.files[i].name, hashmode: this.getItem.hashmode, hashstring: this.getItem.hashstring})
              .then(function(){
                store.dispatch('get_pending');
                store.dispatch('get_running');
              })
              .catch((error)=>{ console.error(error) })
          }
          this.files = [];
        }
        else if (files.length == 1) {
          store.dispatch('create_pending', {name: this.getItem.name, dictionary: this.getItem.dictionary, dictionary2: this.getItem.dictionary2, rules: this.getItem.rules, mask: this.getItem.mask, hash: this.files[0].name, hashmode: this.getItem.hashmode, hashstring: this.getItem.hashstring})
            .then(function(){
              store.dispatch('get_pending');
              store.dispatch('get_running');
            })
            .catch((error)=>{ console.error(error) })
          this.files = [];
        } else {
          let _this = this;
          store.dispatch('create_pending', {name: this.getItem.name, dictionary: this.getItem.dictionary, dictionary2: this.getItem.dictionary2, rules: this.getItem.rules, mask: this.getItem.mask, hash: '', hashmode: this.getItem.hashmode, hashstring: this.getItem.hashstring})
            .then(function(){
              store.dispatch('get_pending');
              store.dispatch('get_running');
              _this.$parent.dialogVisible = false;
            })
            .catch((error)=>{ console.error(error) })
          this.fileList = [];
        }
      }
    }
  }
</script>

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
      <div class="label">
        Attacking: ⛧ 
      </div>
      <ul class="field">
        <li v-for="(hash, i) in hashes">
          <span class="text-red">{{ hash.name }}</span> ⛧
        </li>
      </ul>
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
          <option value="18_in_1.lst">1.8 Billion Leak</option>
          <option value="Top1pt8Billion-WPA-probable-v2.txt">Top1pt8Billion WPA-probable v2</option>
          <option value="Top1pt2Million-WPA-probable-v2.txt">Top1pt2Million-WPA-probable-v2</option>
          <option value="MainEnglishDictionary_ProbWL.txt">MainEnglishDictionary_ProbWL</option>
          <option value="HashesOrg.txt">HashesOrg</option>
          <option value="crackstation.txt">crackstation</option>
          <option value="WoNDeR.txt">WoNDeR 98MB</option>
          <option value="weakpass_2a.txt">Weakpass 30GB</option>
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
          <option value="18_in_1.lst">1.8 Billion Leak</option>
          <option value="Top1pt8Billion-WPA-probable-v2.txt">Top1pt8Billion WPA-probable v2</option>
          <option value="Top1pt2Million-WPA-probable-v2.txt">Top1pt2Million-WPA-probable-v2</option>
          <option value="MainEnglishDictionary_ProbWL.txt">MainEnglishDictionary_ProbWL</option>
          <option value="HashesOrg.txt">HashesOrg</option>
          <option value="crackstation.txt">crackstation</option>
          <option value="WoNDeR.txt">WoNDeR 98MB</option>
          <option value="weakpass_2a.txt">Weakpass 30GB</option>
          <option value="weakpass_2_wifi.txt">Weakpass WIFI 28GB</option>
          <option value="google-10000-english-no-swears.txt">Google top 10k no swears</option>
          <option value="google-10000-english-usa.txt">Google top 10k usa</option>
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
    </div>
    <div class="">
      <div class="label">
        Notifications:
      </div>
      <div class="field p1">        
        <input id="sms" type="checkbox" v-model="getItem.sms" />
        <label class="label" for="sms">SMS</label>
      </div>
      <div class="field p1">
        <input id="email" type="checkbox" v-model="getItem.email" />
        <label class="label" for="email">Email</label>        
      </div>
    </div>

    <div class="field-group" style="width:145px;padding-left:5px" style="display:none">
      <input type="reset" value="Reset the form" accesskey="r">
    </div>
    <div name="submit" type="submit" v-on:click="queue_item" @keyup.enter="queue_item" class="btn btn--primary align-center">Submit</div>
  </form>
</template>

<script>
  import store from '../store/store'
  import axios from 'axios'

  export default {
    props: ['hashes'],
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
      queue_item: function() {
        if (!this.checkform()) return false;
        this.modalVisible = false;
        let _this = this;
        this.hashes.forEach(function(hash) {
          console.log('sending hash', hash.string);
          store.dispatch('create_pending', {name: hash.name, dictionary: _this.getItem.dictionary, dictionary2: _this.getItem.dictionary2, rules: _this.getItem.rules, mask: _this.getItem.mask, hash: hash.file, hashmode: hash.mode, hashstring: hash.string, hashid: hash.id})
            .then(function(){
              store.dispatch('get_pending');
              store.dispatch('get_running');
              _this.$router.push('/')
            })
            .catch((error)=>{ console.error(error) })  
        })        
      }
    }
  }
</script>

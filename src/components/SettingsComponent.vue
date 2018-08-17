<template>
  <div class="dflex flex-col p2" action=''>
    <h2>Dictionaries</h2>
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
    <ul class="info">
      <li v-for="messages in messages">
        {{ messages }}
      </li>
    </ul>
    <div class="bl p1 mb2" v-for="dic in getDics">
      <div class="text-secondary">
        {{dic.name}}
        <button class="btn btn--small" ><span @click="delDictionary(dic.id)" class="oi" data-glyph="delete" title="delete dictionary" aria-hidden="true"></span></button>
      </div>
    </div>    

    <div class="field-group">
      <label for="name" class="label">
        Dictionary Name:
      </label>
      <div class="field">
        <input name="name" id="name" type="text" spellcheck="false" v-model="name">
      </div>
    </div>

    <div class="field-group">
      <label for="location" class="label">
        Path Location: <small>hint: drag/drop</small>
      </label>
      <div class="field">
        <input name="location" id="location" type="text" spellcheck="false" v-model="location">
      </div>
    </div>

    <div name="submit" type="submit" v-on:click="addDictionary" @keyup.enter="addDictionary" class="btn btn--primary align-center">
      <span class="oi" data-glyph="plus" title="add" aria-hidden="true"></span>
      Add Dictionary
    </div>

    <h2>Masks</h2>
    <div class="field-group">
      <label for="maskName" class="label">
        Mask Name:
      </label>
      <div class="field">
        <input maskName="maskName" id="maskName" type="text" spellcheck="false" v-model="maskName">
      </div>
    </div>

    <div class="field-group">
      <label for="maskLocation" class="label">
        Mask Location: <small>hint: drag/drop</small>
      </label>
      <div class="field">
        <input name="maskLocation" id="maskLocation" type="text" spellcheck="false" @keyup.enter="addMask" v-model="maskLocation">
      </div>
    </div>

    <div name="submit" type="submit" v-on:click="addMask" class="btn btn--primary align-center">
      <span class="oi" data-glyph="plus" title="add" aria-hidden="true"></span>
      Add Mask
    </div>
  </div>
</template>

<script>
  import store from '../store/store'

  export default {
    data: function() {
      return {
        name: null,
        location: null,
        maskName: null,
        maskLocation: null,
        errors: [],
        messages: []
      }
    },
    computed: {
      getDics: function() { return store.getters.getDics }
    },
    mounted(){
      store.dispatch('get_dics')
    },
    methods: {
      checkform() {
        this.errors = []
        if (!this.name) {
          this.errors.push('Name required.')
        }
        if (!this.location) {
          this.errors.push('Wordlist location required.')
        }

        if (!this.errors.length) {
          return true
        }
      },
      delDictionary(id) {
        let _this = this;
        store.dispatch('delete_dic', id)
          .then(function() {
            _this.messages.push('Sucessfully deleted')
            store.dispatch('get_dics')
          })
          .catch((error)=>{ console.error(error) })
      },
      addMask() {
      },
      addDictionary() {
        if (!this.checkform()) return false;
        let _this = this;
        store.dispatch('insert_dic', {name: this.name, location: this.location})
          .then(function() {
            _this.messages.push('Sucessfully added ' + _this.location)
            _this.name = null
            _this.location = null
            store.dispatch('get_dics')
          })
          .catch((error)=>{ console.error(error) })
      }
    }
  }
</script>

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


    <h2>Rules</h2>
    <div class="bl p1 mb2" v-for="rule in getRules">
      <div class="text-primary">
        {{rule.name}}
        <button class="btn btn--small" ><span @click="delRule(rule.id)" class="oi" data-glyph="delete" title="delete rule" aria-hidden="true"></span></button>
      </div>
    </div>  
    <div class="field-group">
      <label for="ruleName" class="label">
        Rule Name:
      </label>
      <div class="field">
        <input name="ruleName" id="ruleName" type="text" spellcheck="false" v-model="ruleName">
      </div>
    </div>

    <div class="field-group">
      <label for="ruleLocation" class="label">
        Rule Location: <small>hint: drag/drop</small>
      </label>
      <div class="field">
        <input name="ruleLocation" id="ruleLocation" type="text" spellcheck="false" @keyup.enter="addRule" v-model="ruleLocation">
      </div>
    </div>

    <div name="submit" type="submit" v-on:click="addRule" class="btn btn--primary align-center">
      <span class="oi" data-glyph="plus" title="add" aria-hidden="true"></span>
      Add Rule
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
        ruleName: null,
        ruleLocation: null,
        errors: [],
        messages: []
      }
    },
    computed: {
      getDics: function() { return store.getters.getDics },
      getRules: function() { return store.getters.getRules }
    },
    mounted(){
      store.dispatch('get_dics')
      store.dispatch('get_rules')
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
      checkRules() {
        this.errors = []
        if (!this.ruleName) {
          this.errors.push('Name required.')
        }
        if (!this.ruleLocation) {
          this.errors.push('Rule location required.')
        }

        if (!this.errors.length) {
          return true
        }
      },
      delDictionary(id) {
        let _this = this;
        store.dispatch('delete_dic', id)
          .then(function() {
            _this.messages.push('Sucessfully deleted dictionary.')
            store.dispatch('get_dics')
          })
          .catch((error)=>{ console.error(error) })
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
      },
      delRule(id) {
        let _this = this;
        store.dispatch('delete_rule', id)
          .then(function() {
            _this.messages.push('Sucessfully deleted rule.')
            store.dispatch('get_rules')
          })
          .catch((error)=>{ console.error(error) })
      },
      addRule() {
        if (!this.checkRules()) return false;
        let _this = this;
        store.dispatch('insert_rule', {name: this.ruleName, location: this.ruleLocation})
          .then(function() {
            _this.messages.push('Sucessfully added ' + _this.location)
            _this.ruleName = null
            _this.ruleLocation = null
            store.dispatch('get_rules')
          })
          .catch((error)=>{ console.error(error) })
      }
    }
  }
</script>

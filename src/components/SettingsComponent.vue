<template>
  <div class="dflex flex-col skull-bg">
    <ul class="info" style="margin:0">
      <li v-for="messages in messages">
        {{ messages }}
      </li>
    </ul>    
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
    <div class="dflex flex-row p2 align-center settings-page" action="" style="flex-wrap:wrap;">
      <div class="flex1 dflex flex-col" style="padding: 0 2rem;">
        <h2>
          Dics
        </h2>
        <v-client-table v-if="getDics.length != 0" :data="getDics" :options="dicOps" :columns="dicCols">
          <div class="p2" slot="child_row" slot-scope="props">
            <div>
              <button class="btn btn--mini" @click="delDictionary(props.row.id)">Delete</button>
            </div>
          </div>
        </v-client-table>
        <div class="info mb2" v-else>
          <span class="error">Dictionary list empty.</span>
          To add a dictionary, first give it a name then specify the file path of the dictionary/wordlist 
          in the location field. This location must be a path accessable by the server. <i>Tips: drag and drop
          a file into the location field to save yourself from typing the path. Don't have any wordlists?
          Try downloading some from <a href="https://github.com/danielmiessler/SecLists" target="_blank">SecLists</a></i>
        </div>
        <div class="field-group">
          <label for="name" class="label">
            Dictionary Name:
          </label>
          <div class="field">
            <input name="name" id="name" type="text" placeholder="Rockyou" spellcheck="false" v-model="name">
          </div>
        </div>
        <div class="field-group">
          <label for="location" class="label">
            Path Location:
          </label>
          <div class="field">
            <input name="location" id="location" type="text" placeholder="ex: /usr/share/wordlists/rockyou.txt" spellcheck="false" v-model="location">
          </div>
        </div>
        <button name="submit" type="submit" v-on:click="addDictionary" @keyup.enter="addDictionary" class="btn btn--primary align-center">
          <span class="oi" data-glyph="book" title="add" aria-hidden="true"></span>
          Add Dictionary
        </button>
      </div>

      <div class="flex1 dflex flex-col" style="padding: 0 2rem;">
        <h2>
          Rules
        </h2>
        <v-client-table v-if="getRules.length != 0" :data="getRules" :options="ruleOpts" :columns="ruleCols">
          <div class="p2" slot="child_row" slot-scope="props">
            <div>
              <button class="btn btn--mini" @click="delRule(props.row.id)">Delete</button>
            </div>
          </div>
        </v-client-table>
        <div class="info mb2" v-else>
          <span class="error">Rule list empty.</span>
          To add a rules, first give it a name then specify the file path of the rule 
          in the location field. This location must be a path accessable by the server. <i>Tip: drag and drop
          a file into the location field to save yourself from typing the path.</i>
        </div>
        <div class="field-group">
          <label for="ruleName" class="label">
            Rule Name:
          </label>
          <div class="field">
            <input name="ruleName" id="ruleName" type="text" placeholder="Best 64" spellcheck="false" v-model="ruleName">
          </div>
        </div>
        <div class="field-group">
          <label for="ruleLocation" class="label">
            Rule Location:
          </label>
          <div class="field">
            <input name="ruleLocation" id="ruleLocation" type="text" placeholder="ex: /usr/share/hashcat/rules/best64.rule" spellcheck="false" @keyup.enter="addRule" v-model="ruleLocation">
          </div>
        </div>

        <button name="submit" type="submit" v-on:click="addRule" class="btn btn--primary align-center">
          <span class="oi" data-glyph="plus" title="add" aria-hidden="true"></span>
          Add Rule
        </button>
      </div>

      <div class="flex1" style="padding: 0 2rem;min-width:300px;margin:0 auto">
        <h2>Users</h2>
        <v-client-table v-if="getUsers.length != 0" :data="getUsers" :columns="userCols" >
          <div class="p2" slot="child_row" slot-scope="props">
            <div>
              <button class="btn btn--mini" @click="delUser(props.row.id)">Delete</button>
            </div>
          </div>
        </v-client-table>
        <div class="info mb2" v-else>
          <span class="error">User list empty.</span>      
        </div>
        <div class="field-group">
          <label for="userName" class="label">
            User Name:
          </label>
          <div class="field">
            <input name="userName" id="userName" type="text" placeholder="l33tHax04" spellcheck="false" v-model="userName">
          </div>
        </div>
        <div class="field-group">
          <label for="userPassword" class="label">
            Password:
          </label>
          <div class="field">
            <input name="userPassword" id="userPassword" type="password" placeholder="god" spellcheck="false" @keyup.enter="addUser" v-model="userPassword">
          </div>
        </div>
        <div class="field-group">
          <div class="label">
            Role:
          </div>
          <div class="field">
            <select id="role" name="dictionary" v-model="role">
              <option value="n00b">User</option>
              <option value="pi">Rotten Pi Agent</option>
              <option value="agent">Hive Agent</option>
              <option value="admin">Administrator</option>
            </select>
          </div>
        </div>       

        <button name="submit" type="submit" v-on:click="addUser" class="btn btn--secondary align-center">
          <span class="oi" data-glyph="person" title="add" aria-hidden="true"></span>
          Add User
        </button>
      </div>
    </div>
  </div>
</template>

<script>
  import store from '../store/store'
  import {ServerTable, ClientTable, Event} from 'vue-tables-2';

  export default {
    data: function() {
      return {
        name: null,
        location: null,
        ruleName: null,
        ruleLocation: null,
        userPassword: null,
        userName: null,
        role: 'n00b',
        errors: [],
        messages: [],
        dicCols: ['name', 'location', 'size'],
        ruleCols: ['name', 'location', 'size'],
        userCols: ['email', 'role'],
        dicOps: {
          columnsDisplay: {
            location: 'desktop',
            size: 'desktop'
          }
        },
        ruleOpts: {
          columnsDisplay: {
            location: 'desktop',
            size: 'desktop'
          }
        }
      }
    },
    computed: {
      getDics: function() { return store.getters.getDics },
      getRules: function() { return store.getters.getRules },
      getUsers: function() { return store.getters.getUsers }
    },
    mounted(){
      store.dispatch('get_dics')
      store.dispatch('get_rules')
      store.dispatch('get_users')
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
      checkRule() {
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
      checkUser() {
        this.errors = []
        if (!this.userName) {
          this.errors.push('Name required.')
        }
        if (!this.userPassword) {
          this.errors.push('Password required.')
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
        if (!this.checkRule()) return false;
        let _this = this;
        store.dispatch('insert_rule', {name: this.ruleName, location: this.ruleLocation})
          .then(function() {
            _this.messages.push('Sucessfully added ' + _this.location)
            _this.ruleName = null
            _this.ruleLocation = null
            store.dispatch('get_rules')
          })
          .catch((error)=>{ console.error(error) })
      },
      delUser(id) {
        let _this = this;
        store.dispatch('delete_user', id)
          .then(function() {
            _this.messages.push('Sucessfully deleted user.')
            store.dispatch('get_users')
          })
          .catch((error)=>{ console.error(error) })
      },
      addUser() {
        if (!this.checkUser()) return false;
        let _this = this;
        store.dispatch('insert_user', {name: this.userName, password: this.userPassword, role: this.role})
          .then(function() {
            _this.messages.push('Sucessfully added ' + _this.userName)
            _this.userName = null
            _this.userPassword = null
            _this.admin = null
            store.dispatch('get_users')
          })
          .catch((error)=>{ console.error(error) })
      }
    }
  }
</script>

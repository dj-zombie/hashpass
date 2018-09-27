
<template>
  <div class="dflex flex-col skull-bg" style="padding: 2rem"> 
    <h3 class="mt0">
      Rotten-Pi Command Assignment:
    </h3>
    <div class="dflex mt3" style="padding-bottom: 1rem;flex-wrap:wrap">
      <div class="dflex flex-col align-start flex1 mobile mr3">
        <div class="dflex flex-col align-center">
          <button class="btn btn--primary btn--mini" @click="ssh()">Launch Auto-SSH Terminal</button>      
        </div>
        <div>
          <div class="field p1 w100 mt3">
            <label class="text-primary mr3">
              RottenPi Agent:
            </label>
            <div v-for="user in getUsers" class="dflex align-center">
              <label class="label mr2" :for="user.email">{{ user.email }}</label>
              <input class="mr3" :id="user.email" :value="user.email" type="radio" v-model="agent" checked>
            </div>
          </div>
          <div class="field w100">
            <select id="mode" name="mode" v-model="func">
              <option value="command" selected>Shell Command</option>              
              <option value="connect">Connect</option>
              <option value="shutdown">Shutdown</option>
              <option value="restart">Restart</option>
              <option value="recon">Recon</option>
              <option value="phishing">Phishing</option>
              <option value="dns">DNS Poison</option>
              <option value="pmkid" selected>PMKID via hcxtools</option>
            </select>
          </div>
          <div v-show="func" class="field-group w100">
            <label for="args" class="label">
              Arguments:
            </label>
            <pre v-show="func == 'shutdown'" class="text-highlight" wrap="off">              
              Examples:
                halt in 30 minitues: -h 30
                reboot: -r now
                cancel: -c
            </pre>
            <pre v-show="func == 'command'" class="text-highlight" wrap="off">
              Examples:
                ping -c 7 hashcat.net
                ifconfig wlan0
            </pre>
            <div class="field">
              <input @keyup.enter="insert_command()"" name="args" type="text" v-model="args">
             </div>
          </div>
          <button name="submit" type="submit" v-on:click="insert_command()" class="btn">
            <span class="oi" data-glyph="share" title="agents" aria-hidden="true"></span>
            Run
          </button>
        </div>
      </div>

      <div class="flex1">        
        <v-client-table v-show="getCommands.length" class="skull-bg" :data="getCommands" :columns="commandsColumns" :options="commandsOptions" style="height:100%">
          <div v-if="props.row.user" slot="user" slot-scope="props">
            <span @click="delete_command(props.row.id)" data-glyph="ban" title="Delete!" aria-hidden="true" class="oi text-red"></span>
            {{ props.row.user }}
          </div>

          <div slot="afterTable">
            <div class="text-center">
              <button class="btn btn--mini" @click="delete_commands()">
                <span data-glyph="ban" title="Delete All!" aria-hidden="true" class="oi text-red"></span>
                All
              </button>
              <button class="btn btn--mini" @click="refresh_cmds()">
                <span data-glyph="reload" title="Refresh" aria-hidden="true" class="oi text-primary"></span>
                Refresh
              </button>
            </div>
          </div>

          <div v-if="props.row.timestamp" slot="timestamp" slot-scope="props">
            <!-- {{ props.row.timestamp | moment("HH:mm")  }} -->
            {{ props.row.timestamp  }}
          </div>
        </v-client-table>
      </div>
    </div>

    <h3>
      Live Rotten-Pi C2C Communication:
    </h3>
    
    <!-- <span class="text-highlight text-center">
      {{ datenow }}
    </span>     -->
      <v-client-table class="skull-bg" :data="getRotten" :columns="tableColumns" :options="tableOptions">
        <div slot="child_row" slot-scope="props" style='padding:1rem'>
          <div>
            <h4 class="m2">
              Result
            </h4>
            <textarea class="m0" autocomplete="off" autocorrect="off" autocapitalize="off" wrap="off" spellcheck="false" >{{ props.row.result }}</textarea>
          </div>
        </div>
        <div v-if="props.row.timestamp" slot="timestamp" slot-scope="props">
          {{ props.row.timestamp }}
        </div>
        <div slot="afterTable">
          <div class="text-center">
            <button class="btn btn--mini" @click="delete_rotten_logs()">
              <span data-glyph="ban" title="Delete All!" aria-hidden="true" class="oi text-red"></span>
              All
            </button>          
          </div>
        </div>
      </v-client-table>
    </transition>
  </div>
</template>

<script>
  import client from './../client/client.js'
  import store from '../store/store'
  import {ServerTable, ClientTable, Event} from 'vue-tables-2';

  export default {
    data: function() {
      return {
        cmd: null,
        func: 'command',
        args: '',
        agent: '',
        datenow: '',
        refreshing: true,
        enableHeartbeat: false,
        tableColumns: ['user', 'function', 'arguments', 'event', 'result', 'timestamp'],
        tableOptions: {
          headings: {
            user: '👿 User',
            timestamp: 'Timestamp 🕐'
          },
          columnsDisplay: {
            function: 'desktop',
            arguments: 'desktop',
            result: 'desktop',
            timestamp: 'desktop',
          },
          rowClassCallback: function(row) {
            if (row.event == 'CHECKIN') {
              return 'green-bg'  
            }
            else if (row.event == 'CHECKOUT') {
              return 'red-bg'
            }
            else if (row.event == 'COMMAND') {
              return 'green-dashed'
            }
            else if (row.event == 'HEARTBEAT' && true) {
              // return 'dnone'
              return ''
            }
            else {
              return ''
            }            
          },
          perPage: 100,
          columnsClasses: { user: 'text-left', timestamp: 'text-right', event: 'text-center', function: 'text-center', arguments: 'text-center', result: 'text-center' },
          sortable: ['added', 'name', 'mode', 'hosts', 'loot'],
        },

        commandsColumns: ['user', 'function', 'arguments'],
        commandsOptions: {
          perPage: 6,
          filterable: false
        },
      }
    },
    computed: {
      getRotten: function() { return store.getters.getRotten },
      getCommands: function() { return store.getters.getCommands },
      getUsers: function() { 
        let users = store.getters.getUsers
        
        let pi = []
        for (var u in users) {
          if (users[u].role == 'pi')
            pi.push(users[u])
        }
        let vm = this
        setTimeout(function() {
          vm.agent = pi[0].email
        },5)
        return pi
      }
    },
    mounted(){
      store.dispatch('get_rotten')
      store.dispatch('get_agent_commands')
      store.dispatch('get_users')
      this.updateTime()
      this.refresh()
    },
    methods: {
      ssh: function() {
        client.agent_ssh()
          .then(function(response){
            console('ssh', response.data)
          })
          .catch(function(error) {
            console.error('Error running ssh:', error)
          })
      },
      refresh_cmds: function() {
        store.dispatch('get_agent_commands')
      },
      insert_command: function() {
        store.dispatch('insert_command', {user: this.agent, function: this.func, arguments: this.args})
          .then(function(){
            store.dispatch('get_agent_commands')
          })
          .catch((error)=>{ console.error(error) })
      },
      delete_command: function(id) {
        store.dispatch('delete_command', id)
          .then(function(){
            store.dispatch('get_agent_commands')
          })
          .catch((error)=>{ console.error(error) })
      },
      delete_commands: function() {
        store.dispatch('delete_commands')
          .then(function(){
            console.log('done deleted!')
            store.dispatch('get_agent_commands')
          })
          .catch((error)=>{ console.error(error) })
      },
      delete_rotten_logs: function() {
        store.dispatch('delete_rotten_logs')
          .then(function(){
            store.dispatch('get_rotten')
          })
          .catch((error)=>{ console.error(error) })
      },
      updateTime: function() {
        let vm = this
        this.datenow = this.$moment().format('h:mm:ss')
        // setInterval(vm.updateTime, 1000)
      },
      refresh: function() {
        let vm = this
        setInterval(function(){
          if (vm.refreshing) {
            store.dispatch('get_rotten')
            store.dispatch('get_agent_commands')
          }
        }, 2500);
      }
    }
  }
</script>

<template>
  <div class="dflex flex-col" style="align-self:center; margin:0 auto">
    <vue-typer
      class='text-secondary'
      :class="{ 'error' : getMessages[0] }"
      :text="getMsg"
      :pre-erase-delay='8000'
      :erase-delay='50'
      style='margin-bottom:3rem; text-align:center;'>
    </vue-typer>
    <div class="dflex flex-col" style="align-items:center">
      <div class="field-group">
        <label for="handle" class="label" style="margin-right:2rem">h@ndL3</label>
        <div class="field">
          <input name="handle" id="handle" placeholder="zerocool" v-model="handle" type="text">
        </div>
      </div>
      <div class="field-group">
        <label for="password" class="label" style="margin-right:2rem">p@s$w0rD</label>
        <div class="field">
          <input name="password" id="password" placeholder="god" v-model="password" @keyup.enter="login()" type="password">
          <input type="hidden" name="authenticity_token" value="DJz0mb13">
        </div>
      </div>
      <button name="submit" @click="login()" class="btn btn--primary" @keyup.enter="login()" v-bind:class="{ 'loading' : loggingIn }">Enter</button>
    </div>
  </div>
</template>

<script>
  import store from '../store/store'
  export default {
    data() {
      return {
        knock: 'Knock knock, Neo.',
        handle: null,
        password: null,
        loggingIn: false
      };
    },
    computed: {
      getMessages: function() { return store.getters.getMessages; },
      getMsg: function() { 
        let msg = store.getters.getMessages
        if (msg.length) {
          return msg[msg.length-1]
        }
        else {
          return 'Knock knock, Neo.'
        }
      }
    },
    mounted() {
    },
    methods: {
      login() {
        this.loggingIn = true;
        let _this = this;
        store.dispatch('login', {handle: this.handle, password: this.password})
          .then(function() {
            setTimeout(function() {
              const loggedIn = localStorage.getItem('user');
              if (loggedIn) {
                store.dispatch('clear_messages')
                _this.$router.push('/attack')
              }
              else {
                _this.loggingIn = false;
                _this.$router.push('/')
              }  
            }, 1337);
            
          })
          .catch((error)=>{ 
            console.error('login component', error)
          })  
      }      
    }
  }
</script>

<style>
.error.vue-typer .custom.char {
  color: red;
  background-color: #000;
}
.error.vue-typer .custom.char.selected {
  background-color: #264F78;
}

.error.vue-typer .custom.caret {
  width: 0.75rem;
  background-color: #666;
}
</style>
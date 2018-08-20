<template>
  <div class="dflex flex-col" style="align-self:center; margin:0 auto">
    <vue-typer
      class='text-secondary'
      :text="knock"
      :pre-erase-delay='8000'
      :erase-delay='50'
      style='margin-bottom:3rem; text-align:center'>
    </vue-typer>
    <div class="dflex flex-col" style="align-items:center">
      <div class="field-group">
        <label for="handle" class="label" style="margin-right:2rem">h@ndL3</label>
        <div class="field">
          <input name="handle" id="handle" v-model="handle" type="text">
        </div>
      </div>
      <div class="field-group">
        <label for="password" class="label" style="margin-right:2rem">p@s$w0rD</label>
        <div class="field">
          <input name="password" id="password" v-model="password" type="password">
        </div>
      </div>
      <button name="submit" @click="login()" class="btn btn--primary" v-bind:class="{ 'loading' : loggingIn }" style="margin:0">Enter</button>
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
      getToken: function() { return store.getters.getToken; }
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
                _this.$router.push('/attack')
              }
              else {
                _this.loggingIn = false;
                _this.$router.push('/')
              }  
            }, 1337);
            
          })
          .catch((error)=>{ console.error(error) })  
      }      
    }
  }
</script>

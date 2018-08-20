<template>
  <div class="login-page">
    <login-component></login-component>
  </div>
</template>

<script>
  import LoginComponent from '../components/LoginComponent.vue'
  export default {
    components: {LoginComponent: LoginComponent}
  }
</script>

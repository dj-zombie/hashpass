<template>
  <div class="dflex flex-col" style="align-self:center; margin:0 auto">
    <vue-typer
      class='text-secondary'
      :text="knock"
      :pre-erase-delay='8000'
      :erase-delay='50'
      style='margin-bottom:3rem; text-align:center'>
    </vue-typer>
    <form class="dflex flex-col" action='/' method='post'>
      <div class="field-group">
        <label for="handle" class="label" style="margin-right:2rem">h@ndL3</label>
        <div class="field">
          <input name="handle" id="handle" type="text">
        </div>
      </div>
      <div class="field-group">
        <label for="password" class="label" style="margin-right:2rem">p@s$w0rD</label>
        <div class="field">
          <input name="password" id="password" type="password">
        </div>
      </div>
      <button name="submit" type="submit" class="btn btn--primary" style="margin:0">Enter</button>
    </form>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        knock: 'Knock knock, Neo.'
      };
    },
    name: 'login'
  }
</script>

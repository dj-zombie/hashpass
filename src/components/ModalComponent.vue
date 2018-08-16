<template>
  <transition name="modal">
    <div class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <div class="modal-header">
            <slot name="header"></slot>
          </div>
          <div class="modal-body">
            <slot name="body"></slot>
          </div>
          <div class="modal-footer">
            <slot name="footer"></slot>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
  export default {
    data: function() {
      return { showModal: false }
    }
  }
</script>

<style>
  .modal-mask {
    position: fixed;
    z-index: 9998;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, .75);
    transition: opacity .3s ease;
    display: flex;
  }
  .modal-wrapper {
    display: flex;
    margin: 2rem auto;
    max-width: 700px;
    width: 90%;
    height: 90%;
  }
  .modal-container {
    margin: 0px auto;
    background-color: #222;
    border-radius: 0;
    border: 1px solid #4a4a4a;
    box-shadow: 0 2px 8px rgba(0, 0, 0, .33);
    transition: all .3s ease;
    display: flex;
    flex: 1;
    flex-direction: column;
  }
  .modal-header h3 {
    margin: 0;
    color: #3ddb16;
    text-align: left;
    font-size: 18px;
  }
  .modal-body {
    padding: 2rem 3rem;
    margin: 20px 0;
    flex: 1;
    overflow: auto;
  }
  .modal-header {
    padding: 1rem;
    background: #2a2a2a;
    max-height: 2rem;
  }
  .modal-footer {
    padding: 1rem;
    background: #2a2a2a;
    max-height: 25%;
    overflow-y: scroll;
  }

  .modal-default-button { float: right; }
  .modal-enter { opacity: 0; }
  .modal-leave-active { opacity: 0; }
  .modal-enter .modal-container,
  .modal-leave-active .modal-container {
    -webkit-transform: scale(1.1);
    transform: scale(1.1);
  }
</style>


<template>
  <div>
    <active></active>
    <queue></queue>
    <cracked-table></cracked-table>
  </div>
</template>

<script>
  import store from '../store/store'
  import JobForm from '../components/JobForm.vue'
  import Active from '../components/ActiveComponent.vue'
  import Queue from '../components/QueueComponent.vue'
  import CrackedTable from '../components/CrackedTable.vue'
  import Modal from '../components/ModalComponent.vue'

  export default {
    components: {JobForm: JobForm, Active: Active, Queue: Queue, CrackedTable: CrackedTable, Modal: Modal},
    data: function() {
      return {
        showModal: false,
        dialogVisible: false,
        intervalId: 0,
        isRefreshing: false
      }
    }
  }
</script>

<template>
  <div class="dflex flex-col" style="padding: 2rem">
    <transition name='fade'>
      <div v-show="getRunning[0]" class='skull-right'></div>
    </transition>
    <transition name='fade'>
      <div v-show="getRunning[0]" class='skull-left'></div>
    </transition>
    <div class="progress-header c-secondary">
      <vue-typer
        :text="hash"
        :pre-erase-delay='3000'
        :erase-delay='50'>
      </vue-typer>
      <p v-if="getRunning[0]">{{getRunning[0].rules}}</p>
      <p v-if="getRunning[0]">{{getRunning[0].mask}}</p>
      <p v-if="getRunning[0]">{{getRunning[0].dictionary}}</p>
    </div>
    <div class="chart">
      <div class="chart__left text-right">
        <p class="flex1"><span>Type:</span>
          <vue-typer v-if="getRunning[0]"
            :text="progress.type.toString()"
            :pre-erase-delay='3000'
            :erase-delay='50'>
          </vue-typer>
        </p>
        <p class="flex1 dnone"><span>Speed Dev #1:</span>
          <vue-typer v-if="getRunning[0]"
            :text="progress.speed_dev_1.toString()"
            :pre-erase-delay='3000'
            :erase-delay='50'>
          </vue-typer>
       </p>
        <p class="flex1"><span>Time Started:</span>
          <span v-if="getRunning[0]">
            {{ progress.time_started.toString() }}            
          </span>
        </p>
        <p class="flex1"><span>Time Estimeated:</span>
          <span v-if="getRunning[0]">
            {{ progress.time_estimated.toString() }}
          </span>
        </p>
        <p class="flex1"><span>Candidates #1:</span>
          <vue-typer v-if="getRunning[0]"
            :text="progress.candidates_1.toString()"
            :pre-erase-delay='3000'
            :erase-delay='50'>
          </vue-typer>
        </p>
        <p class="flex1 dnone"><span>HW Monitor #1:</span>
          <vue-typer v-if="getRunning[0]"
            :text="progress.hw_monitor_1.toString()"
            :pre-erase-delay='3000'
            :erase-delay='50'>
          </vue-typer>
        </p>
      </div>
      <div class="chart__center">
        <highcharts :options="options" ref="highcharts"></highcharts>
      </div>
      <div class="chart__right text-left">
        <p class="flex1"><span>Recovered:</span>
          <vue-typer v-if="getRunning[0]"
            :text="progress.recovered.toString()"
            :pre-erase-delay='3000'
            :erase-delay='50'>
          </vue-typer>
        </p>
        <p class="flex1"><span>Rejected:</span>
          <span v-if="getRunning[0]">
            {{ progress.rejected.toString() }}
          </span>
        </p>
        <p class="flex1"><span>Restore Point:</span>
          <span v-if="getRunning[0]">
            {{ progress.restore_point.toString() }}
          </span>
        </p>
        <p class="flex1"><span>Candidates #2:</span>
          <vue-typer v-if="getRunning[0]"
            :text="progress.candidates_2.toString()"
            :pre-erase-delay='3000'
            :erase-delay='50'>
          </vue-typer>
        </p>
        <p class="flex1 dnone"><span>HW Monitor #2:</span>
          <vue-typer v-if="getRunning[0]"
            :text="progress.hw_monitor_2.toString()"
            :pre-erase-delay='3000'
            :erase-delay='50'>
          </vue-typer>
        </p>
      </div>
    </div>
    <div v-if="getRunning[0]" class='dflex flex-col'>
      <textarea name="stdout" autocomplete="off" autocorrect="off" autocapitalize="off" wrap="off" spellcheck="false" disabled="true">{{progress.stdout}}</textarea>
    </div>
  </div>
</template>

<script>
  import store from '../store/store'

  export default {
    data: function() {
      return {
        options: {
          chart: {
            type: 'pie',
            renderTo: 'container',
            backgroundColor:'rgba(255, 255, 255, 0.0)',
            height: 320,
            width: 320,
            borderRadius: 0
          },
          title: {
            verticalAlign: 'middle',
            floating: true,
            text: '0.000%',
            y: 5,
            style: {
              "color": '#3ddb16',
              "fontSize": "3rem"
            }
          },
          subtitle: {
            text: 'Waiting for status...',
            verticalAlign: 'middle',
            floating: true,
            y: 35,
            style: {
              "color": '#3ddb16',
              "fontSize": "1rem"
            }
          },
          credits: {
            enabled: false
          },
          plotOptions: {
            pie: {
              innerSize: '80%',
              size: '100%',
              borderWidth: 0,
              shadow: false,
              startAngle: 0,
              dataLabels: false,
              borderColor: '#40bbd5',
              stickyTracking: false,
              states: {
                hover: {
                  enabled: false
                }
              },
              point: {
                events: {
                  mouseOver: function(){
                      this.series.chart.innerText.attr({text: this.y});
                  },
                  mouseOut: function(){
                      this.series.chart.innerText.attr({text: 112});
                  }
                }
              }
            }
          },
          tooltip: false,
          series: [{
            data: [
              [1],
              [100]
            ]
          }]
        }
      }
    },
    mounted() {
      let vm = this;
      store.dispatch('get_running')
      store.dispatch('get_progress')
      store.dispatch('get_cracked')
      store.dispatch('get_pending')
      setInterval(function(){
        store.dispatch('get_progress')
        store.dispatch('get_running')
        store.dispatch('get_cracked')
        store.dispatch('get_pending')
        if (vm.$refs.highcharts) {
          let running = store.getters.getRunning.length;
          let status = store.getters.getProgress.status;
          let cur = store.getters.getProgress.progress_cur||0,
              end = store.getters.getProgress.progress_end||0;
          let percentage = (cur/end)*100||0;        
          let { chart } = vm.$refs.highcharts;
          var newData = [[percentage],[100-percentage]];
          chart.series[0].setData(newData);
          let text = percentage.toFixed(3) + '%';
          chart.setTitle({text: text});
          if (status) {
            chart.setTitle(null,{text: status});
          }
          else {
            chart.setTitle(null,{text: 'Waiting for status...'});
          }
        }
      }, 5000);
    },
    computed: {
      isRunning: function() { return store.getters.getIsRunning; },
      getRunning: function() { return store.getters.getRunning; },
      percentage: function() {
        let cur = store.getters.getProgress.progress_cur||0,
            end = store.getters.getProgress.progress_end||0;
        let percentage = (cur/end)*100||0;
        return parseFloat(percentage.toFixed(2));
      },
      pidActive: function() {
        return store.getters.getPidActive
      },
      progress: function() {
        return store.getters.getProgress
      },
      pid: function() {
        return store.getters.getPid
      },
      cmd: function() {
        return store.getters.getCmd
      },
      hash: function() {
        let running = store.getters.getRunning[0];
        if (running) {
          return running.hash
        }
        else {
          return 'feed me some hashes to pwn...'
        }
      },
      running: function() {
        return store.getters.getIsRunning
      },
      status: function() {
        let status = store.getters.getProgress.status;
      }
    }
  }
</script>

<style>
  .fade-enter-active,
  .fade-leave-active { transition: opacity 5s ease-out;}
  .fade-enter,
  .fade-leave-to { opacity: 0; }
</style>

#==============================================================================
# Library: monitor.sh
# Description: Process and resource monitoring system
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly MONITOR_INTERVAL=5
declare -A PROCESS_STATS

start_monitoring() {
  init_process_stats
  start_monitor_loop &
  MONITOR_PID=$!
}

stop_monitoring() {
  [[ -n "$MONITOR_PID" ]] && kill "$MONITOR_PID"
  generate_monitoring_report
}

init_process_stats() {
  PROCESS_STATS=(
    [start_time]=$(date +%s)
    [cpu_total]=0
    [mem_total]=0
    [io_total]=0
    [samples]=0
  )
}

start_monitor_loop() {
  while true; do
    collect_process_stats
    sleep "$MONITOR_INTERVAL"
  done
}

collect_process_stats() {
  local pid=$$
  local cpu_usage=$(ps -p $pid -o %cpu= | tr -d ' ')
  local mem_usage=$(ps -p $pid -o %mem= | tr -d ' ')
  local io_usage=$(iostat -p $pid | awk 'NR==4{print $4}')

  ((PROCESS_STATS[cpu_total] += cpu_usage))
  ((PROCESS_STATS[mem_total] += mem_usage))
  ((PROCESS_STATS[io_total] += io_usage))
  ((PROCESS_STATS[samples]++))
}

generate_monitoring_report() {
  local duration=$(($(date +%s) - PROCESS_STATS[start_time]))
  local avg_cpu=$((PROCESS_STATS[cpu_total] / PROCESS_STATS[samples]))
  local avg_mem=$((PROCESS_STATS[mem_total] / PROCESS_STATS[samples]))
  local avg_io=$((PROCESS_STATS[io_total] / PROCESS_STATS[samples]))

  log_info "Process Monitoring Report:"
  log_info "Duration: ${duration}s"
  log_info "Average CPU: ${avg_cpu}%"
  log_info "Average Memory: ${avg_mem}%"
  log_info "Average I/O: ${avg_io} KB/s"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

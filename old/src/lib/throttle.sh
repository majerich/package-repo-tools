#==============================================================================
# Library: throttle.sh
# Description: Resource throttling and load management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

init_throttling() {
  export THROTTLE_CHECK_INTERVAL=5
  trap check_resource_throttle SIGALRM
}

start_throttle_monitor() {
  while true; do
    sleep "$THROTTLE_CHECK_INTERVAL"
    check_resource_throttle
  done &
  THROTTLE_MONITOR_PID=$!
}

stop_throttle_monitor() {
  [[ -n "$THROTTLE_MONITOR_PID" ]] && kill "$THROTTLE_MONITOR_PID"
}

check_resource_throttle() {
  local cpu_usage=$(get_cpu_usage)
  local mem_usage=$(get_memory_usage)

  if ((cpu_usage > MAX_CPU_USAGE)) || ((mem_usage > MAX_MEMORY_USAGE)); then
    throttle_operations
  else
    unthrottle_operations
  fi
}

throttle_operations() {
  if [[ -z "$THROTTLED" ]]; then
    log_warn "Resource usage high, throttling operations"
    THROTTLED=true
    PARALLEL_JOBS=$((PARALLEL_JOBS / 2))
    [[ $PARALLEL_JOBS -lt 1 ]] && PARALLEL_JOBS=1
  fi
}

unthrottle_operations() {
  if [[ -n "$THROTTLED" ]]; then
    log_info "Resource usage normalized, resuming normal operations"
    THROTTLED=
    PARALLEL_JOBS=$(get_optimal_job_count)
  fi
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

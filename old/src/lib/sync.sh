#==============================================================================
# Library: sync.sh
# Description: Process synchronization and coordination
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly SYNC_DIR="/var/lib/package-repo-tools/sync"
readonly SYNC_INTERVAL=60

init_sync() {
  mkdir -p "$SYNC_DIR"
  touch "$SYNC_DIR/sync.lock"
  start_sync_monitor
}

start_sync_monitor() {
  while true; do
    sleep "$SYNC_INTERVAL"
    synchronize_processes
  done &
  SYNC_MONITOR_PID=$!
}

synchronize_processes() {
  local lock_file="$SYNC_DIR/sync.lock"

  (
    flock -x 200
    collect_process_states
    distribute_work_load
    update_sync_status
  ) 200>"$lock_file"
}

collect_process_states() {
  local state_file="$SYNC_DIR/states.json"

  {
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"processes\": ["
    ps -ef | grep "$NAMESPACE_PREFIX" | while read -r line; do
      generate_process_state "$line"
    done
    echo "  ]"
    echo "}"
  } >"$state_file"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

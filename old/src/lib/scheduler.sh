#!/usr/bin/env bash

#==============================================================================
# Library: scheduler.sh
# Description: Process scheduling and task management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly SCHEDULE_DIR="/var/lib/package-repo-tools/schedule"
readonly SCHEDULE_INTERVAL=300

init_scheduler() {
  mkdir -p "$SCHEDULE_DIR"
  load_schedule
  start_scheduler
}

start_scheduler() {
  while true; do
    sleep "$SCHEDULE_INTERVAL"
    process_scheduled_tasks
  done &
  SCHEDULER_PID=$!
}

load_schedule() {
  local schedule_file="$SCHEDULE_DIR/tasks.json"
  [[ -f "$schedule_file" ]] && SCHEDULED_TASKS=$(jq -r '.tasks[]' "$schedule_file")
}

process_scheduled_tasks() {
  for task in "${SCHEDULED_TASKS[@]}"; do
    if should_run_task "$task"; then
      execute_scheduled_task "$task"
    fi
  done
}

should_run_task() {
  local task="$1"
  local next_run=$(get_task_next_run "$task")
  local current_time=$(date +%s)

  ((current_time >= next_run))
}

execute_scheduled_task() {
  local task="$1"
  log_info "Executing scheduled task: $task"

  manage_child_priorities "$task"
  update_task_schedule "$task"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

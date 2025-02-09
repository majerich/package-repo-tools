#==============================================================================
# Library: colors.sh
# Description: Color definitions and styled output functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Process Management Library Usage
#==============================================================================
#
# Check Process Status:
#   check_process_status "pacman"
#   Output: Checking process [####··] 66%
#
# Kill Process:
#   kill_process "pacman"
#   Output: [ᗧ···ᗣ] Terminating process...
#
# Monitor Process:
#   monitor_process 1234
#   Output: Monitoring PID 1234 [####··] 66%
#
# Wait For Process:
#   wait_for_process 1234 30
#   Output: Waiting for process [####··] 66%
#==============================================================================

source "./progress.sh"

check_process_status() {
  local process_name="$1"
  local total_steps=3
  local current=0

  # Step 1: Check process existence
  ((current++))
  show_progress "$current" "$total_steps" "Checking process"
  local pid=$(pgrep -x "$process_name")

  # Step 2: Check process state
  ((current++))
  show_progress "$current" "$total_steps" "Checking state"
  if [[ -n "$pid" ]]; then
    local state=$(ps -p "$pid" -o state= 2>/dev/null)
    if [[ -z "$state" ]]; then
      log_error "Process state unavailable"
      return 1
    fi
  fi

  # Step 3: Check resource usage
  ((current++))
  show_progress "$current" "$total_steps" "Checking resources"
  if [[ -n "$pid" ]]; then
    local cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null)
    local mem=$(ps -p "$pid" -o %mem= 2>/dev/null)
    log_info "Process $process_name (PID: $pid) - CPU: $cpu%, MEM: $mem%"
  else
    log_warn "Process $process_name not running"
  fi

  return 0
}

kill_process() {
  local process_name="$1"
  local force="${2:-false}"

  start_spinner "Terminating process $process_name"

  local pid=$(pgrep -x "$process_name")
  if [[ -n "$pid" ]]; then
    if [[ "$force" = true ]]; then
      kill -9 "$pid" 2>/dev/null
    else
      kill "$pid" 2>/dev/null
    fi

    if [[ $? -eq 0 ]]; then
      stop_spinner
      log_success "Process $process_name terminated"
      return 0
    fi
  fi

  stop_spinner
  log_error "Failed to terminate process $process_name"
  return 1
}

monitor_process() {
  local pid="$1"
  local interval="${2:-5}"
  local total_checks=0

  while kill -0 "$pid" 2>/dev/null; do
    ((total_checks++))
    show_progress "$total_checks" 100 "Monitoring PID $pid"

    local cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null)
    local mem=$(ps -p "$pid" -o %mem= 2>/dev/null)
    log_debug "PID $pid - CPU: $cpu%, MEM: $mem%"

    sleep "$interval"
  done

  log_info "Process $pid terminated"
  return 0
}

wait_for_process() {
  local pid="$1"
  local timeout="${2:-30}"
  local waited=0

  while ((waited < timeout)); do
    show_progress "$waited" "$timeout" "Waiting for process $pid"

    if ! kill -0 "$pid" 2>/dev/null; then
      log_success "Process $pid terminated"
      return 0
    fi

    sleep 1
    ((waited++))
  done

  log_error "Timeout waiting for process $pid"
  return 1
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

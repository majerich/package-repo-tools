#==============================================================================
# Library: signals.sh
# Description: Signal handling and process management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Signal Handling Library Usage
#==============================================================================
#
# Setup Signal Handlers:
#   setup_signal_handlers
#   Output: Signal handlers configured
#
# Handle Interrupt:
#   handle_interrupt
#   Output: [ᗧ···ᗣ] Handling interrupt...
#
# Handle Termination:
#   handle_termination
#   Output: Cleaning up [####··] 66%
#
# Reset Signal Handlers:
#   reset_signal_handlers
#   Output: Signal handlers reset
#==============================================================================

source "./progress.sh"

setup_signal_handlers() {
  trap 'handle_interrupt' INT
  trap 'handle_termination' TERM
  trap 'handle_exit' EXIT
  trap 'handle_error' ERR

  log_debug "Signal handlers configured"
}

handle_interrupt() {
  start_spinner "Handling interrupt"

  # Release locks
  for lock in "$LOCK_DIR"/*.lock; do
    [[ -d "$lock" ]] && release_lock "${lock%.lock}"
  done

  # Clean temporary files
  rm -rf "/tmp/package-repo-tools-$$"*

  stop_spinner
  log_warn "Operation interrupted by user"
  exit 130
}

handle_termination() {
  local total_steps=3
  local current=0

  # Step 1: Stop ongoing operations
  ((current++))
  show_progress "$current" "$total_steps" "Stopping operations"
  killall -q pacman 2>/dev/null

  # Step 2: Release resources
  ((current++))
  show_progress "$current" "$total_steps" "Releasing resources"
  for pid in $(jobs -p); do
    kill "$pid" 2>/dev/null
  done

  # Step 3: Clean up
  ((current++))
  show_progress "$current" "$total_steps" "Cleaning up"
  cleanup_on_termination

  log_warn "Process terminated"
  exit 143
}

handle_exit() {
  local exit_code=$?

  start_spinner "Performing exit cleanup"

  # Release locks
  for lock in "$LOCK_DIR"/*.lock; do
    [[ -d "$lock" ]] && release_lock "${lock%.lock}"
  done

  # Remove temporary files
  rm -rf "/tmp/package-repo-tools-$$"*

  stop_spinner

  if [[ $exit_code -eq 0 ]]; then
    log_success "Process completed successfully"
  else
    log_error "Process exited with code $exit_code"
  fi
}

handle_error() {
  local error_line=$1
  local error_cmd=$2

  start_spinner "Handling error"

  log_error "Error occurred in command '$error_cmd' at line $error_line"

  # Cleanup resources
  cleanup_on_error

  stop_spinner
  exit 1
}

reset_signal_handlers() {
  trap - INT TERM EXIT ERR
  log_debug "Signal handlers reset"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

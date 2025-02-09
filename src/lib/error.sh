#==============================================================================
# Library: colors.sh
# Description: Color definitions and styled output functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Error Handling Library Usage
#==============================================================================
#
# Handle Command Error:
#   handle_error "Failed to install package" $?
#   Output: [ERROR] Failed to install package (exit code: 1)
#
# Try Command with Retry:
#   try_command "pacman -Sy nginx" 3
#   Output: Attempting command [####··] 66%
#
# Set Error Handler:
#   set_error_handler my_error_handler
#   some_command || handle_error "Command failed"
#
# Cleanup on Error:
#   trap_errors
#   Output: [ᗧ···ᗣ] Cleaning up after error...
#==============================================================================

source "./progress.sh"

readonly ERROR_MESSAGES=(
  [1]="Operation not permitted"
  [2]="No such file or directory"
  [13]="Permission denied"
  [28]="Operation timed out"
)

handle_error() {
  local message="$1"
  local exit_code="${2:-1}"
  local error_desc="${ERROR_MESSAGES[$exit_code]:-Unknown error}"

  log_error "$message (exit code: $exit_code - $error_desc)"
  cleanup_on_error

  return "$exit_code"
}

try_command() {
  local command="$1"
  local max_attempts="${2:-3}"
  local attempt=1
  local result=0

  while [[ $attempt -le $max_attempts ]]; do
    show_progress "$attempt" "$max_attempts" "Attempting command"

    eval "$command"
    result=$?

    if [[ $result -eq 0 ]]; then
      log_success "Command succeeded on attempt $attempt"
      return 0
    fi

    log_warn "Command failed (attempt $attempt/$max_attempts)"
    ((attempt++))
    sleep 2
  done

  handle_error "Command failed after $max_attempts attempts" "$result"
  return "$result"
}

set_error_handler() {
  local handler="$1"

  if [[ -n "$handler" ]]; then
    trap "$handler" ERR
    log_debug "Error handler set to: $handler"
  fi
}

cleanup_on_error() {
  start_spinner "Cleaning up after error"

  # Release any held locks
  for lock in "$LOCK_DIR"/*.lock; do
    [[ -d "$lock" ]] && release_lock "${lock%.lock}"
  done

  # Remove temporary files
  rm -rf "/tmp/package-repo-tools-$$"*

  stop_spinner
  log_info "Cleanup completed"
}

trap_errors() {
  trap 'handle_error "Unexpected error occurred" $?' ERR
  trap 'handle_error "Script interrupted" 130' INT TERM
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

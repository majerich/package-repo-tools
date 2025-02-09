#==============================================================================
# Library: recovery.sh
# Description: Process recovery and fault tolerance
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly RECOVERY_DIR="/var/lib/package-repo-tools/recovery"
readonly MAX_RETRIES=3

init_recovery() {
  mkdir -p "$RECOVERY_DIR"
  declare -A RETRY_COUNT
}

handle_failure() {
  local process_id="$1"
  local error_code="$2"

  log_error "Process $process_id failed with code $error_code"

  if can_retry "$process_id"; then
    retry_process "$process_id"
  else
    fail_process "$process_id"
  fi
}

can_retry() {
  local process_id="$1"

  [[ ${RETRY_COUNT[$process_id]:-0} -lt $MAX_RETRIES ]]
}

retry_process() {
  local process_id="$1"

  ((RETRY_COUNT[$process_id]++))
  log_info "Retrying process $process_id (attempt ${RETRY_COUNT[$process_id]})"

  restore_process_state "$process_id"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

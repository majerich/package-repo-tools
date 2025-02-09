#==============================================================================
# Library: locks.sh
# Description: Lock file management for concurrent operations
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Lock Management Library Usage
#==============================================================================
#
# Acquire Process Lock:
#   acquire_lock "backup-process"
#   Output: [ᗧ···ᗣ] Acquiring lock...
#
# Release Process Lock:
#   release_lock "backup-process"
#   Output: Lock released successfully
#
# Check Lock Status:
#   check_lock_status "backup-process"
#   if [[ $? -eq 0 ]]; then
#     echo "Lock is available"
#   else
#     echo "Lock is held by PID: $(get_lock_holder 'backup-process')"
#   fi
#
# Wait for Lock:
#   wait_for_lock "backup-process" 60
#   Output: Waiting for lock [####··] 66%
#==============================================================================

source "./progress.sh"

readonly LOCK_DIR="/var/run/package-repo-tools"

init_locks() {
  mkdir -p "$LOCK_DIR"
  chmod 755 "$LOCK_DIR"
}

acquire_lock() {
  local lock_name="$1"
  local lock_file="$LOCK_DIR/$lock_name.lock"

  start_spinner "Acquiring lock: $lock_name"

  if ! mkdir "$lock_file" 2>/dev/null; then
    if ! kill -0 "$(cat "$lock_file/pid" 2>/dev/null)" 2>/dev/null; then
      rm -rf "$lock_file"
      mkdir "$lock_file"
    else
      stop_spinner
      log_error "Lock acquisition failed: $lock_name is locked"
      return 1
    fi
  fi

  echo $$ >"$lock_file/pid"
  stop_spinner
  log_success "Lock acquired: $lock_name"
  return 0
}

release_lock() {
  local lock_name="$1"
  local lock_file="$LOCK_DIR/$lock_name.lock"

  if [[ -d "$lock_file" ]]; then
    if [[ "$(cat "$lock_file/pid" 2>/dev/null)" == "$$" ]]; then
      rm -rf "$lock_file"
      log_success "Lock released: $lock_name"
      return 0
    fi
  fi

  log_error "Cannot release lock: $lock_name (not owner)"
  return 1
}

check_lock_status() {
  local lock_name="$1"
  local lock_file="$LOCK_DIR/$lock_name.lock"

  if [[ ! -d "$lock_file" ]]; then
    return 0
  fi

  if ! kill -0 "$(cat "$lock_file/pid" 2>/dev/null)" 2>/dev/null; then
    rm -rf "$lock_file"
    return 0
  fi

  return 1
}

get_lock_holder() {
  local lock_name="$1"
  local lock_file="$LOCK_DIR/$lock_name.lock"

  if [[ -f "$lock_file/pid" ]]; then
    cat "$lock_file/pid"
  fi
}

wait_for_lock() {
  local lock_name="$1"
  local timeout=${2:-60}
  local waited=0

  while [[ $waited -lt $timeout ]]; do
    show_progress "$waited" "$timeout" "Waiting for lock: $lock_name"

    if check_lock_status "$lock_name"; then
      log_success "Lock became available: $lock_name"
      return 0
    fi

    sleep 1
    ((waited++))
  done

  log_error "Timeout waiting for lock: $lock_name"
  return 1
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

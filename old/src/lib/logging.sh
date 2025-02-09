#==============================================================================
# Library: logging.sh
# Description: Logging and output management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Logging Library Usage
#==============================================================================
#
# Basic Logging:
#   log_info "Starting backup process"
#   Output: [2024-01-20 14:30:45] [INFO] Starting backup process
#
# Error Logging with Exit:
#   log_error "Backup failed" 1
#   Output: [2024-01-20 14:30:45] [ERROR] Backup failed
#   (exits with code 1)
#
# Debug Logging (only when LOG_LEVEL=DEBUG):
#   log_debug "Checking package dependencies"
#   Output: [2024-01-20 14:30:45] [DEBUG] Checking package dependencies
#
# Success Logging:
#   log_success "Backup completed successfully"
#   Output: [2024-01-20 14:30:45] [SUCCESS] Backup completed successfully
#==============================================================================

readonly LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
readonly LOG_COLORS=([DEBUG]="\033[36m" [INFO]="\033[32m" [WARN]="\033[33m" [ERROR]="\033[31m" [SUCCESS]="\033[32m")
readonly RESET_COLOR="\033[0m"

init_logging() {
  mkdir -p "$LOG_DIR"
  readonly LOG_FILE="$LOG_DIR/package-repo-tools.log"
  rotate_logs
}

rotate_logs() {
  if [[ -f "$LOG_FILE" ]]; then
    local size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE")
    if ((size > LOG_MAX_SIZE * 1024 * 1024)); then
      for ((i = LOG_ROTATE; i > 0; i--)); do
        [[ -f "$LOG_FILE.$((i - 1))" ]] && mv "$LOG_FILE.$((i - 1))" "$LOG_FILE.$i"
      done
      mv "$LOG_FILE" "$LOG_FILE.0"
      touch "$LOG_FILE"
    fi
  fi
}

log_message() {
  local level="$1"
  local message="$2"
  local exit_code="$3"

  [[ ${LOG_LEVELS[$level]} ]] || return 1
  [[ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[$LOG_LEVEL]} ]] || return 0

  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local log_entry="[$timestamp] [$level] $message"

  # Console output with color
  if [[ -t 1 ]]; then
    echo -e "${LOG_COLORS[$level]}$log_entry${RESET_COLOR}"
  else
    echo "$log_entry"
  fi

  # File output
  echo "$log_entry" >>"$LOG_FILE"

  if [[ -n "$exit_code" ]]; then
    exit "$exit_code"
  fi
}

log_debug() { log_message "DEBUG" "$1"; }
log_info() { log_message "INFO" "$1"; }
log_warn() { log_message "WARN" "$1"; }
log_error() { log_message "ERROR" "$1" "${2:-}"; }
log_success() { log_message "SUCCESS" "$1"; }

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

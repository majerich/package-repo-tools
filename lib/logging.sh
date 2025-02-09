#!/usr/bin/env bash
#
# Logging utilities for package-repo-tools
# Author: Your Name <your.email@domain.com>
# License: MIT

#######################################
# Initialize logging for a session
# Arguments:
#   $1 - Session name
# Returns:
#   None
#######################################
init_logging() {
  local session="$1"
  mkdir -p "$LOG_DIR"
  readonly LOG_FILE="${LOG_DIR}/${session}-$(date +%Y%m%d-%H%M%S).log"
  exec 3>&1 4>&2
  exec 1> >(tee -a "$LOG_FILE")
  exec 2> >(tee -a "$LOG_FILE" >&2)
}

#######################################
# Log an info message
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1" >&3
  echo "[INFO] $1" >>"$LOG_FILE"
}

#######################################
# Log a warning message
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1" >&3
  echo "[WARN] $1" >>"$LOG_FILE"
}

#######################################
# Log an error message
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&4
  echo "[ERROR] $1" >>"$LOG_FILE"
}

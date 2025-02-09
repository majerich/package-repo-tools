#==============================================================================
# Library: errors.sh
# Description: Error handling and exception management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

# Error codes
readonly E_SUCCESS=0
readonly E_GENERAL=1
readonly E_INVALID_ARG=2
readonly E_PERMISSION=3
readonly E_NETWORK=4
readonly E_RESOURCE=5
readonly E_DEPENDENCY=6
readonly E_CONFIG=7

trap_errors() {
  trap 'handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR
}

handle_error() {
  local err=$1
  local line=$2
  local linecallfunc=$3
  local command="$4"
  local funcstack="$5"

  log_error "Error in ${funcstack} line $line: '$command' exited with status $err"

  case $err in
  $E_INVALID_ARG)
    print_error "Invalid argument provided"
    ;;
  $E_PERMISSION)
    print_error "Permission denied - try running with sudo"
    ;;
  $E_NETWORK)
    print_error "Network error - check your connection"
    ;;
  $E_RESOURCE)
    print_error "Insufficient system resources"
    ;;
  $E_DEPENDENCY)
    print_error "Missing required dependency"
    ;;
  $E_CONFIG)
    print_error "Configuration error"
    ;;
  *)
    print_error "Unknown error occurred"
    ;;
  esac

  exit "$err"
}

assert_root() {
  if [[ $EUID -ne 0 ]]; then
    throw $E_PERMISSION "Root privileges required"
  fi
}

throw() {
  local code=$1
  local message=${2:-}
  [[ -n "$message" ]] && log_error "$message"
  exit "$code"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

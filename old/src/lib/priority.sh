#==============================================================================
# Library: priority.sh
# Description: Process priority and nice level management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly DEFAULT_NICE_LEVEL=10
readonly IO_NICE_LEVEL=7

adjust_process_priority() {
  local pid=${1:-$$}
  local nice_level=${2:-$DEFAULT_NICE_LEVEL}

  # Adjust CPU priority
  renice -n "$nice_level" -p "$pid"

  # Adjust I/O priority
  ionice -c 2 -n "$IO_NICE_LEVEL" -p "$pid"

  log_debug "Adjusted process $pid priority: nice=$nice_level, io=$IO_NICE_LEVEL"
}

set_background_priority() {
  adjust_process_priority $$ 19
  ionice -c 3 -p $$
}

set_foreground_priority() {
  adjust_process_priority $$ 0
  ionice -c 2 -n 0 -p $$
}

manage_child_priorities() {
  local command="$1"
  shift

  nice -n "$DEFAULT_NICE_LEVEL" ionice -c 2 -n "$IO_NICE_LEVEL" "$command" "$@"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

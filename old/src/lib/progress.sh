#==============================================================================
# Library: progress.sh
# Description: Consolidated progress display functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Progress Display Library Usage
#==============================================================================
#
# Standard Progress Bar:
#   show_progress 5 10 "Installing packages"
#   Output: Installing packages [#####·····] 50%
#
# Pacman Animation:
#   PACMAN_ANIMATION=true
#   show_progress 2 4 "Downloading"
#   Output: Downloading [·ᗧ··ᗣ] 2/4
#
# Spinner for Unknown Duration:
#   start_spinner "Processing"
#   long_running_command
#   stop_spinner
#   Output: Processing ⠋ (animates through frames)
#
# Progress Updates with Logging:
#   for i in {1..5}; do
#     update_progress "Processing files" $i 5
#     process_file $i
#   done
#
# Terminal vs Non-Terminal Output:
#   update_progress automatically switches between
#   visual progress bars for terminals and log
#   messages for non-terminal output.
#==============================================================================

readonly SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
readonly PACMAN_FRAMES=('ᗧ···ᗣ' '·ᗧ··ᗣ' '··ᗧ·ᗣ' '···ᗧᗣ')
readonly PROGRESS_WIDTH=50

show_progress() {
  local current=$1
  local total=$2
  local message=${3:-"Processing"}

  if [[ "$PACMAN_ANIMATION" = true ]]; then
    show_pacman_progress "$current" "$total" "$message"
  else
    show_standard_progress "$current" "$total" "$message"
  fi
}

show_pacman_progress() {
  local current=$1
  local total=$2
  local message=$3
  local frame=$((current % ${#PACMAN_FRAMES[@]}))

  printf "\r%s [%s] %d/%d" \
    "$message" \
    "${PACMAN_FRAMES[frame]}" \
    "$current" \
    "$total"
}

show_standard_progress() {
  local current=$1
  local total=$2
  local message=$3

  local percentage=$((current * 100 / total))
  local filled=$((percentage * PROGRESS_WIDTH / 100))
  local empty=$((PROGRESS_WIDTH - filled))

  printf "\r%s [%s%s] %d%%" \
    "$message" \
    "$(printf '#%.0s' $(seq 1 $filled))" \
    "$(printf '·%.0s' $(seq 1 $empty))" \
    "$percentage"

  [[ $current -eq $total ]] && echo
}

start_spinner() {
  local message=${1:-"Processing"}
  a
  (
    while true; do
      for frame in "${SPINNER_FRAMES[@]}"; do
        printf "\r%s %s" "$message" "$frame"
        sleep 0.1
      done
    done
  ) &
  SPINNER_PID=$!
}

stop_spinner() {
  [[ -n "$SPINNER_PID" ]] && kill "$SPINNER_PID"
  SPINNER_PID=""
  echo
}

update_progress() {
  local message=$1
  local current=$2
  local total=$3

  if [[ -t 1 ]]; then
    show_progress "$current" "$total" "$message"
  else
    log_info "$message ($current/$total)"
  fi
}

# Usage example in package operations:
# start_progress_animation "Installing packages"
# [... package installation ...]
# stop_progress_animation

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

#!/usr/bin/env bash
#
# Progress display utilities for package-repo-tools
# Author: Your Name <your.email@domain.com>
# License: MIT

#######################################
# Display a progress bar
# Arguments:
#   $1 - Message to display
#   $2 - Percentage complete (0-100)
# Returns:
#   None
#######################################
show_progress_bar() {
  local message="$1"
  local percent="$2"
  local width=50
  local completed=$((width * percent / 100))
  local remaining=$((width - completed))

  printf "\r%s [%s%s] %d%%" \
    "$message" \
    "$(printf "%${completed}s" | tr ' ' '#')" \
    "$(printf "%${remaining}s" | tr ' ' '-')" \
    "$percent"
}

#######################################
# Display animated pacman
# Arguments:
#   $1 - Message to display
# Returns:
#   None
#######################################
show_pacman() {
  local message="$1"
  local -a frames=(
    "ᗧ···ᗣ"
    "ᗧ··ᗣ·"
    "ᗧ·ᗣ··"
    "ᗧᗣ···"
  )

  printf "\r%s %s" "$message" "${frames[RANDOM % ${#frames[@]}]}"
}

#######################################
# Display spinning dots
# Arguments:
#   $1 - Message to display
# Returns:
#   None
#######################################
show_spinner() {
  local message="$1"
  local -a spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

  printf "\r%s %s" "$message" "${spinner[RANDOM % ${#spinner[@]}]}"
}

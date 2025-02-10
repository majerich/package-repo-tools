# heredoc.shlib
# A library for managing and displaying heredoc blocks in shell scripts.
#
# This script provides functions to extract and display heredoc content
# defined within a calling script. It supports multiple blocks and
# includes error handling for unmatched start/stop markers.
#
# Compatibility:
#   This library is compatible with Bash and Zsh only.
#
# Requirements:
#   - Bash or Zsh shell
#   - `sed` command for trimming whitespace
#
# Usage:
#   source ./heredoc_lib.sh
#   display_heredoc [blockname...]
#
# Parameters:
#   blockname: One or more names of the heredoc blocks to display.
#
# Example:
#   display_heredoc "HELP" "USAGE"
#
# Author: Richard Majewski
# Version: 1.0.0
# License: MIT
# Date: 2025-02-08

# Enable strict mode
set -euo pipefail # Exit on error, unset variable, and pipeline failure

# Function to trim leading '#' and trailing whitespace
__trim() {
  sed 's/^#//; s/[[:space:]]*$//'
}

# Read heredoc blocks from the script
__read_heredoc_blocks() {
  local script_file="$1"
  local -n blocks_ref="$2"
  local in_block=0
  local heredoc=""
  local blockname=""

  while IFS= read -r line; do
    case "${line}" in
    "# START_"*)
      blockname="${line#*# START_}" # Extract block name
      blockname="${blockname%% *}"  # Remove any trailing text
      in_block=1
      heredoc="" # Reset heredoc when starting a new block
      ;;
    "# STOP_"*)
      if ((in_block)); then
        blocks_ref["${blockname}"]=$(printf "%s" "${heredoc}" | __trim) # Store trimmed block content
        in_block=0
      else
        echo "Warning: Block '# START_${blockname}' started but not closed." >&2
      fi
      ;;
    *)
      if ((in_block)); then
        heredoc+="${line}"$'\n' # Accumulate lines in the block
      fi
      ;;
    esac
  done <"${script_file}" # Read from the calling script
}

# Display requested heredoc blocks
__display_heredoc_blocks() {
  local -n blocks_ref="$1"
  shift # Shift to get block names
  local blocknames=("$@")

  for blockname in "${blocknames[@]}"; do
    if [[ -n "${blocks_ref[${blockname}]}" ]]; then
      printf "%s\n" "${blocks_ref[${blockname}]}"
    else
      echo "Error: Block '# START_${blockname}' not found." >&2
      return 2 # Specific exit code for block not found
    fi
  done
}

# Main function to display heredocs based on block name(s)
lib_display_heredoc() {
  local blocknames=("$@") # Accept multiple block names
  declare -A blocks       # Associative array to store block contents

  # Determine the script being sourced
  local script_file="${BASH_SOURCE[1]:-$0}" # Use BASH_SOURCE in Bash, $0 in Zsh

  # Read heredoc blocks from the script
  __read_heredoc_blocks "${script_file}" blocks

  # Display requested blocks or a default block if none specified
  if ((${#blocknames[@]} == 0)); then
    blocknames=("HELP") # Default block to display
  fi

  __display_heredoc_blocks blocks "${blocknames[@]}"
}

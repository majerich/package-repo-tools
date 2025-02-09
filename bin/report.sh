#!/usr/bin/env bash
#
# Generate YAML report of installed packages
# Author: Your Name <your.email@domain.com>
# License: MIT

set -euo pipefail

# Source required libraries
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/logging.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/progress.sh"

# Default values
output_file=""
verbose=0
include_versions=0

#######################################
# Parse command line arguments
#######################################
parser_definition() {
  setup REST help:usage -- "Usage: report [options] [output-file]"
  msg -- "Generate YAML report of installed packages."
  msg -- ""
  msg -- "Options:"
  flag VERSION -v --version -- "Show version"
  flag VERBOSE -V --verbose -- "Verbose output"
  flag VERSIONS -p --versions -- "Include package versions"
  disp :usage -h --help -- "Show this help"
}

eval "$(getoptions parser_definition) exit 1"

# ... (previous content remains the same)

#######################################
# Generate YAML report of installed packages
# Arguments:
#   $1 - Output file path
# Returns:
#   0 on success, 1 on failure
#######################################
generate_report() {
  local output="$1"
  local timestamp
  timestamp=$(date -Iseconds)

  {
    echo "---"
    echo "timestamp: ${timestamp}"
    echo "hostname: $(hostname)"
    echo "repositories:"

    # Official repos
    for repo in core extra community multilib; do
      echo "  ${repo}:"
      if [[ $include_versions -eq 1 ]]; then
        pacman -Qnq | pacman -Si - 2>/dev/null | awk -v repo="$repo" '$1 == "Repository" && $3 == repo { getline; printf "    - {name: %s, version: %s}\n", $2, $4 }'
      else
        pacman -Slq "$repo" | grep -Fx "$(pacman -Qnq)" | sed 's/^/    - /'
      fi
    done

    # AUR packages
    echo "  aur:"
    if [[ $include_versions -eq 1 ]]; then
      pacman -Qmq | while read -r pkg; do
        version=$(pacman -Qi "$pkg" | grep '^Version' | cut -d: -f2 | tr -d ' ')
        echo "    - {name: ${pkg}, version: ${version}}"
      done
    else
      pacman -Qmq | sed 's/^/    - /'
    fi
  } >"$output"
}

main() {
  load_config

  # Process arguments
  output_file="${1:-packages.yaml}"

  # Initialize logging
  init_logging "report"

  log_info "Generating package report..."
  show_progress_bar "Analyzing packages..." 100

  generate_report "$output_file"

  log_info "Report generated successfully: ${output_file}"
  show_pacman "Complete!"
}

main "$@"

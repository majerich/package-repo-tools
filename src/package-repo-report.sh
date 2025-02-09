#!/usr/bin/env sh

#==============================================================================
# Script: package-repo-report.sh
# Description: Generate YAML report of installed packages grouped by repository
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="/usr/lib/package-repo-tools"
CONFIG_FILE="/etc/package-repo-tools.conf"
DEFAULT_OUTPUT="packages-$(date +%Y%m%d).yaml"

# Source library files
for lib in "$LIB_DIR"/*.sh; do
  source "$lib"
done

# Load configuration
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Initialize logging
LOG_FILE="${LOG_DIR}/report-$(date +%Y%m%d-%H%M%S).log"
init_logging

generate_report() {
  local output_file="${1:-$DEFAULT_OUTPUT}"
  log_info "Generating package report: $output_file"

  # Check system resources
  check_system_resources

  # Generate YAML header
  cat >"$output_file" <<EOF
---
# Package Repository Report
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# System: $(uname -a)

repositories:
EOF

  # Process each repository
  local repos=($(pacman -Sl | cut -d' ' -f1 | sort -u))
  for repo in "${repos[@]}"; do
    log_debug "Processing repository: $repo"

    echo "  $repo:" >>"$output_file"
    pacman -Sl "$repo" | awk '$4=="[installed]" {print "    - "$2}' >>"$output_file"
  done

  # Add AUR packages if any
  if command -v yay >/dev/null 2>&1; then
    echo "  aur:" >>"$output_file"
    yay -Qm | awk '{print "    - "$1}' >>"$output_file"
  fi

  log_success "Report generated successfully: $output_file"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    show_help
    exit 0
    ;;
  -v | --verbose)
    VERBOSE=true
    shift
    ;;
  *)
    OUTPUT_FILE="$1"
    shift
    ;;
  esac
done

# Generate report
generate_report "${OUTPUT_FILE:-}"

# In package-repo-report.sh, add after report generation:

if [[ "$VERBOSE" = true ]]; then
    collect_stats
    print_stats
fi

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

#!/usr/bin/env bash

#==============================================================================
# Script: package-repo-restore.sh
# Description: Install packages from YAML repository report
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="/usr/lib/package-repo-tools"
CONFIG_FILE="/etc/package-repo-tools.conf"
DRY_RUN=false
VERBOSE=false
PARALLEL=false

# Source library files
for lib in "$LIB_DIR"/*.sh; do
  source "$lib"
done

# Load configuration
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Initialize logging
LOG_FILE="${LOG_DIR}/restore-$(date +%Y%m%d-%H%M%S).log"
init_logging

restore_packages() {
  local input_file="$1"
  log_info "Restoring packages from: $input_file"

  # Check system resources
  check_system_resources

  # Check network connectivity
  check_network_connection

  # Parse YAML and build package lists
  declare -A repo_packages
  while IFS=: read -r repo packages; do
    [[ "$repo" =~ ^[[:space:]]*# ]] && continue
    repo=$(echo "$repo" | tr -d ' ')
    [[ -z "$repo" ]] && continue

    repo_packages[$repo]="$packages"
  done < <(grep -A1 "^  [a-z]" "$input_file")

  # Validate repositories and packages
  check_custom_repos
  validate_packages

  # Install packages
  if [[ "$DRY_RUN" = true ]]; then
    log_info "Dry run - would install:"
    for repo in "${!repo_packages[@]}"; do
      echo "From $repo:"
      echo "${repo_packages[$repo]}"
    done
  else
    for repo in "${!repo_packages[@]}"; do
      if [[ "$repo" != "aur" ]]; then
        if [[ "$PARALLEL" = true ]]; then
          echo "${repo_packages[$repo]}" | parallel -j"$PARALLEL_JOBS" sudo pacman -S --needed --noconfirm {}
        else
          sudo pacman -S --needed --noconfirm ${repo_packages[$repo]}
        fi
      else
        if command -v yay >/dev/null 2>&1; then
          yay -S --needed --noconfirm ${repo_packages[$repo]}
        else
          log_warn "yay not found, skipping AUR packages"
        fi
      fi
    done
  fi

  log_success "Package restoration complete"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    show_help
    exit 0
    ;;
  -d | --dry-run)
    DRY_RUN=true
    shift
    ;;
  -v | --verbose)
    VERBOSE=true
    shift
    ;;
  -p | --parallel)
    PARALLEL=true
    shift
    ;;
  *)
    INPUT_FILE="$1"
    shift
    ;;
  esac
done

# Check input file
if [[ -z "${INPUT_FILE:-}" ]]; then
  log_error "Input file required"
  show_help
  exit 1
fi

# Restore packages
restore_packages "$INPUT_FILE"

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

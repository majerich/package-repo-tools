#!/usr/bin/env bash
#
# Restore packages from YAML report
# Author: Your Name <your.email@domain.com>
# License: MIT

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/logging.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/progress.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/package_utils.sh"

# Default values
input_file=""
verbose=0
match_versions=0

parser_definition() {
  setup REST help:usage -- "Usage: restore [options] [input-file]"
  msg -- "Restore packages from YAML report."
  msg -- ""
  msg -- "Options:"
  flag VERSION -v --version -- "Show version"
  flag VERBOSE -V --verbose -- "Verbose output"
  flag VERSIONS -m --match-versions -- "Match package versions"
  disp :usage -h --help -- "Show this help"
}

eval "$(getoptions parser_definition) exit 1"

#######################################
# Install packages from YAML report
# Arguments:
#   $1 - Input file path
# Returns:
#   0 on success, 1 on failure
#######################################
restore_packages() {
  local input="$1"
  local total_packages=0
  local current=0

  __ensure_yay

  # Parse YAML and create package lists
  declare -A repo_packages
  while IFS=': ' read -r key value; do
    case "$key" in
    "  core" | "  extra" | "  community" | "  multilib")
      repo="${key## }"
      while IFS= read -r pkg && [[ $pkg == *"-"* ]]; do
        if [[ $match_versions -eq 1 && $pkg =~ \{name:\ (.+),\ version:\ (.+)\} ]]; then
          repo_packages[$repo]+="${BASH_REMATCH[1]}=${BASH_REMATCH[2]} "
        else
          repo_packages[$repo]+="${pkg##*- } "
        fi
        ((total_packages++))
      done
      ;;
    esac
  done <"$input"

  # Install packages from official repos
  for repo in "${!repo_packages[@]}"; do
    log_info "Installing packages from ${repo}..."
    read -ra pkgs <<<"${repo_packages[$repo]}"

    for pkg in "${pkgs[@]}"; do
      if ! is_package_installed "$pkg"; then
        show_progress_bar "Installing ${pkg}..." "$((current * 100 / total_packages))"
        if [[ $verbose -eq 1 ]]; then
          sudo pacman -S --noconfirm "$pkg"
        else
          sudo pacman -S --noconfirm "$pkg" >/dev/null 2>&1
        fi
      fi
      ((current++))
      show_pacman "Installing packages..."
    done
  done

  # Install AUR packages
  while IFS=': ' read -r key value; do
    if [[ $key == "  aur" ]]; then
      log_info "Installing AUR packages..."
      while IFS= read -r pkg && [[ $pkg == *"-"* ]]; do
        pkg="${pkg##*- }"
        if ! is_package_installed "$pkg"; then
          show_progress_bar "Installing ${pkg}..." "$((current * 100 / total_packages))"
          if [[ $verbose -eq 1 ]]; then
            yay -S --noconfirm "$pkg"
          else
            yay -S --noconfirm "$pkg" >/dev/null 2>&1
          fi
        fi
        ((current++))
        show_pacman "Installing packages..."
      done
    fi
  done <"$input"
}

main() {
  load_config

  # Process arguments
  input_file="${1:-packages.yaml}"

  # Initialize logging
  init_logging "restore"

  [[ -f "$input_file" ]] || die "Input file not found: ${input_file}"

  log_info "Starting package restoration..."
  restore_packages "$input_file"

  log_info "Package restoration completed successfully"
  show_pacman "Complete!"
}

main "$@"

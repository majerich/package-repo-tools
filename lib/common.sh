#!/usr/bin/env bash
#
# Common functions and utilities for package-repo-tools
# Author: Richard Majewski <uglyegg at entropy dot quest>
# License: MIT

# Source getoptions parser
source "$(dirname "${BASH_SOURCE[0]}")/../vendor/getoptions.sh"

# Terminal colors if supported
if [[ -t 1 ]]; then
  readonly RED='\033[0;31m'
  readonly GREEN='\033[0;32m'
  readonly YELLOW='\033[1;33m'
  readonly BLUE='\033[0;34m'
  readonly NC='\033[0m'
else
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly BLUE=''
  readonly NC=''
fi

# Common variables
readonly CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/package-repo-tools/config"
readonly LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/package-repo-tools/logs"

#######################################
# Ensures yay AUR helper is installed
# Arguments:
#   None
# Returns:
#   0 if successful, 1 on error
#######################################
__ensure_yay() {
  if ! command -v yay >/dev/null 2>&1; then
    log_info "Installing yay AUR helper..."
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir"
    (cd "$tmpdir" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
  fi
}

#######################################
# Loads configuration from file
# Arguments:
#   None
# Returns:
#   None
#######################################
load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
  fi
}

#######################################
# Displays an error message and exits
# Arguments:
#   $1 - Error message
# Returns:
#   None
#######################################
die() {
  echo -e "${RED}Error: $1${NC}" >&2
  exit 1
}

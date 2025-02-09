#==============================================================================
# Library: colors.sh
# Description: Color definitions and styled output functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

# Color definitions
readonly C_RESET='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_DIM='\033[2m'
readonly C_RED='\033[31m'
readonly C_GREEN='\033[32m'
readonly C_YELLOW='\033[33m'
readonly C_BLUE='\033[34m'
readonly C_MAGENTA='\033[35m'
readonly C_CYAN='\033[36m'

# Styled output functions
print_header() {
  printf "${C_BOLD}${C_BLUE}%s${C_RESET}\n" "$1"
}

print_success() {
  printf "${C_GREEN}✓ %s${C_RESET}\n" "$1"
}

print_warning() {
  printf "${C_YELLOW}! %s${C_RESET}\n" "$1"
}

print_error() {
  printf "${C_RED}✗ %s${C_RESET}\n" "$1" >&2
}

print_info() {
  printf "${C_CYAN}ℹ %s${C_RESET}\n" "$1"
}

print_progress() {
  printf "${C_DIM}➤ %s${C_RESET}\n" "$1"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

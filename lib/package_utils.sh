#!/usr/bin/env bash
#
# Package management utilities for package-repo-tools
# Author: Your Name <your.email@domain.com>
# License: MIT

#######################################
# Check if a package is installed
# Arguments:
#   $1 - Package name
# Returns:
#   0 if installed, 1 if not
#######################################
is_package_installed() {
  pacman -Qi "$1" >/dev/null 2>&1
}

#######################################
# Get package version
# Arguments:
#   $1 - Package name
# Returns:
#   Package version string
#######################################
__get_package_version() {
  pacman -Qi "$1" 2>/dev/null | grep '^Version' | cut -d: -f2 | tr -d ' '
}

#######################################
# Compare package versions
# Arguments:
#   $1 - Version A
#   $2 - Version B
# Returns:
#   0 if equal, 1 if A > B, 2 if A < B
#######################################
__compare_versions() {
  local ver1="$1"
  local ver2="$2"

  if [[ "$ver1" == "$ver2" ]]; then
    return 0
  fi

  local IFS=.
  local i ver1=($ver1) ver2=($ver2)

  for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i = ${#ver2[@]}; i < ${#ver1[@]}; i++)); do
    ver2[i]=0
  done

  for ((i = 0; i < ${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done

  return 0
}

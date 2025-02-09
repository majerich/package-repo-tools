#!/usr/bin/env bash

#==============================================================================
# Script: update-version.sh
# Description: Script to update version numbers across all files
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <new_version>"
  exit 1
fi

NEW_VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Update PKGBUILD
sed -i "s/pkgver=.*/pkgver=$NEW_VERSION/" "$PROJECT_ROOT/PKGBUILD"

# Update .SRCINFO
cd "$PROJECT_ROOT"
makepkg --printsrcinfo >.SRCINFO

# Update version in main scripts and libraries
find "$PROJECT_ROOT/src" -type f -name "*.sh" -exec sed -i "s/Version: .*/Version: $NEW_VERSION/" {} \;

# Update Makefile
sed -i "s/VERSION = .*/VERSION = $NEW_VERSION/" "$PROJECT_ROOT/Makefile"

echo "Version updated to $NEW_VERSION"

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

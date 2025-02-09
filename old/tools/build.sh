#!/usr/bin/env bash

#==============================================================================
# Script: build.sh
# Description: Build script for creating distribution package
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION=$(grep 'pkgver=' "$PROJECT_ROOT/PKGBUILD" | cut -d'=' -f2)

cd "$PROJECT_ROOT"

# Create source distribution
mkdir -p "package-repo-tools-$VERSION"
cp -r src config README.md LICENSE Makefile PKGBUILD .SRCINFO "package-repo-tools-$VERSION/"
tar czf "package-repo-tools-$VERSION.tar.gz" "package-repo-tools-$VERSION"
rm -rf "package-repo-tools-$VERSION"

# Update checksums in PKGBUILD
sha256sum=$(sha256sum "package-repo-tools-$VERSION.tar.gz" | cut -d' ' -f1)
sed -i "s/sha256sums=('SKIP')/sha256sums=('$sha256sum')/" PKGBUILD

echo "Build complete: package-repo-tools-$VERSION.tar.gz"

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

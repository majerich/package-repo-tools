#!/usr/bin/env bash

#==============================================================================
# Script: install.sh
# Description: Installation script for development/testing
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Create necessary directories
sudo mkdir -p /usr/lib/package-repo-tools
sudo mkdir -p /var/log/package-repo-tools

# Install main scripts
sudo install -Dm755 "$PROJECT_ROOT/src/package-repo-report.sh" /usr/bin/package-repo-report
sudo install -Dm755 "$PROJECT_ROOT/src/package-repo-restore.sh" /usr/bin/package-repo-restore

# Install library files
for lib in "$PROJECT_ROOT"/src/lib/*.sh; do
  sudo install -Dm644 "$lib" "/usr/lib/package-repo-tools/$(basename "$lib")"
done

# Install configuration
sudo install -Dm644 "$PROJECT_ROOT/config/package-repo-tools.conf" /etc/package-repo-tools.conf

# Set permissions
sudo chown -R root:root /usr/lib/package-repo-tools
sudo chmod 755 /usr/lib/package-repo-tools
sudo chmod 644 /etc/package-repo-tools.conf

echo "Installation complete"

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

#!/usr/bin/env bash

#==============================================================================
# Library: help.sh
# Description: Help and usage information functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

show_help() {
  cat <<EOF
Package Repository Tools - Version 2.0.0

Usage:
    package-repo-report [options] [output_file]

Options:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output

Usage:
    package-repo-restore [options] [input_file]

Options:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -d, --dry-run       Show what would be installed (restore only)
    -p, --parallel      Enable parallel installation (restore only)
    -l, --log FILE      Specify custom log file

Examples:
    package-repo-report packages.yaml
    package-repo-restore -v packages.yaml
    package-repo-restore --dry-run packages.yaml

For more information, see:
    https://github.com/richardmajewski/package-repo-tools
EOF
}

show_version() {
  echo "Package Repository Tools - Version 2.0.0"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

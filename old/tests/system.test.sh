#!/usr/bin/env bash

#==============================================================================
# Test: system.test.sh
# Description: Unit tests for system resource management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

source "../src/lib/system.sh"
source "../src/lib/logging.sh"

test_check_system_resources() {
  # Test disk space check
  local available_space=$(df -m / | awk 'NR==2 {print $4}')
  assertTrue "Available space should be numeric" "echo $available_space | grep -E '^[0-9]+$' >/dev/null"

  # Test memory check
  local available_memory=$(free -m | awk '/Mem:/ {print $7}')
  assertTrue "Available memory should be numeric" "echo $available_memory | grep -E '^[0-9]+$' >/dev/null"

  # Test full resource check
  check_system_resources
  assertEquals 0 $?
}

test_create_system_backup() {
  # Test backup creation
  create_system_backup
  assertEquals 0 $?

  # Verify backup files exist
  assertTrue "Backup files should exist" "[ -f '/var/backup/pacman/pacman.conf' ]"
}

test_check_root_privileges() {
  if [[ $EUID -eq 0 ]]; then
    check_root_privileges
    assertEquals 0 $?
  else
    check_root_privileges
    assertEquals 1 $?
  fi
}

# Load shUnit2
. shunit2

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

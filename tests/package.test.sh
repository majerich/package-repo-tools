#!/usr/bin/env bash

#==============================================================================
# Test: package.test.sh
# Description: Unit tests for package management functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

source "../src/lib/package.sh"
source "../src/lib/logging.sh"

test_validate_packages() {
  # Test valid package
  local result=$(validate_packages "base")
  assertEquals 0 $?

  # Test invalid package
  result=$(validate_packages "nonexistent-package-123")
  assertEquals 1 $?

  # Test multiple packages
  result=$(validate_packages "base" "linux")
  assertEquals 0 $?
}

test_resolve_dependencies() {
  # Test basic dependency resolution
  local deps=$(resolve_dependencies "git")
  assertTrue "Should find dependencies" "[ ! -z '$deps' ]"

  # Test package with no extra dependencies
  deps=$(resolve_dependencies "base")
  assertEquals 0 $?
}

test_verify_gpg_keys() {
  # Test key verification
  verify_gpg_keys
  assertEquals 0 $?
}

# Load shUnit2
. shunit2

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

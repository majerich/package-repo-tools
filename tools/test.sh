#!/usr/bin/env bash

#==============================================================================
# Script: test.sh
# Description: Test suite for package repository tools
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$PROJECT_ROOT/tests"
TEMP_DIR=$(mktemp -d)

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Load test dependencies
source "$PROJECT_ROOT/src/lib/colors.sh"
source "$PROJECT_ROOT/src/lib/logging.sh"

run_tests() {
  local test_files=("$TEST_DIR"/*.test.sh)
  local passed=0
  local failed=0

  for test in "${test_files[@]}"; do
    print_header "Running test: $(basename "$test")"
    if bash "$test"; then
      ((passed++))
      print_success "Test passed: $(basename "$test")"
    else
      ((failed++))
      print_error "Test failed: $(basename "$test")"
    fi
  done

  print_header "Test Summary"
  echo "Passed: $passed"
  echo "Failed: $failed"
  echo "Total: $((passed + failed))"

  return $failed
}

run_tests

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

#!/usr/bin/env bash

#==============================================================================
# Test: network.test.sh
# Description: Unit tests for network connectivity functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

source "../src/lib/network.sh"
source "../src/lib/logging.sh"

test_check_network_connection() {
  # Test basic connectivity
  check_network_connection
  assertEquals 0 $?

  # Test with specific URLs
  local test_urls=(
    "https://archlinux.org"
    "https://aur.archlinux.org"
  )

  for url in "${test_urls[@]}"; do
    curl --connect-timeout "$TIMEOUT" -Is "$url" >/dev/null
    assertEquals "Connection to $url should succeed" 0 $?
  done
}

test_check_download_speed() {
  # Test download speed check
  check_download_speed
  assertTrue "Download speed should meet minimum requirements" $?

  # Test with specific threshold
  local speed=$(curl -s "https://archlinux.org/robots.txt" -w "%{speed_download}" -o /dev/null)
  assertTrue "Speed $speed should be numeric" "echo $speed | grep -E '^[0-9]+([.][0-9]+)?$' >/dev/null"
}

# Load shUnit2
. shunit2

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

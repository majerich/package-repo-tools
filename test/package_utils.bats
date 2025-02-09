#!/usr/bin/env bats

load test_helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/package_utils.sh"
}

@test "is_package_installed detects installed packages" {
  function pacman() { return 0; }
  run is_package_installed "base"
  [ "$status" -eq 0 ]
}

@test "compare_versions correctly compares versions" {
  run __compare_versions "1.0.0" "1.0.0"
  [ "$status" -eq 0 ]
  run __compare_versions "2.0.0" "1.0.0"
  [ "$status" -eq 1 ]
  run __compare_versions "1.0.0" "2.0.0"
  [ "$status" -eq 2 ]
}

@test "get_package_version returns version string" {
  function pacman() { echo "Version : 1.0.0"; }
  run __get_package_version "test-package"
  [ "$output" = "1.0.0" ]
}

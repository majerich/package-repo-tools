#!/usr/bin/env bats

load test_helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/common.sh"
}

@test "load_config loads existing configuration" {
  echo "VERBOSE=1" >"${CONFIG_FILE}"
  run load_config
  [ "$status" -eq 0 ]
  [ "$VERBOSE" -eq 1 ]
}

@test "ensure_yay installs yay if missing" {
  function command() { return 1; }
  run __ensure_yay
  [ "$status" -eq 0 ]
}

@test "die function exits with error message" {
  run die "test error"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "test error" ]]
}

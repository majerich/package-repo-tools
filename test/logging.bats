#!/usr/bin/env bats

load test_helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/logging.sh"
  LOG_DIR="$(mktemp -d)"
}

@test "init_logging creates log file" {
  run init_logging "test"
  [ "$status" -eq 0 ]
  [ -f "${LOG_DIR}/test-"* ]
}

@test "log_info writes to log file" {
  init_logging "test"
  run log_info "test message"
  [ "$status" -eq 0 ]
  grep -q "test message" "${LOG_DIR}/test-"*
}

@test "log_error writes to log file" {
  init_logging "test"
  run log_error "error message"
  [ "$status" -eq 0 ]
  grep -q "error message" "${LOG_DIR}/test-"*
}

#!/usr/bin/env bats

load test_helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/common.sh"
  source "${BATS_TEST_DIRNAME}/../lib/logging.sh"
  source "${BATS_TEST_DIRNAME}/../bin/restore"
}

@test "restore validates input file existence" {
  run restore_packages "nonexistent.yaml"
  [ "$status" -eq 1 ]
}

@test "restore processes valid YAML input" {
  cat >"test_input.yaml" <<EOF
---
repositories:
  core:
    - base
  aur:
    - yay
EOF
  run restore_packages "test_input.yaml"
  [ "$status" -eq 0 ]
}

@test "restore with version matching respects versions" {
  match_versions=1
  cat >"test_versions.yaml" <<EOF
---
repositories:
  core:
    - {name: base, version: 1.0.0}
EOF
  run restore_packages "test_versions.yaml"
  [ "$status" -eq 0 ]
}

#!/usr/bin/env bats

load test_helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/common.sh"
  source "${BATS_TEST_DIRNAME}/../lib/logging.sh"
  source "${BATS_TEST_DIRNAME}/../bin/report"
}

@test "report generates valid YAML" {
  run generate_report "test_packages.yaml"
  [ "$status" -eq 0 ]
  [ -f "test_packages.yaml" ]
  run yq eval 'type' "test_packages.yaml"
  [ "$output" = "map" ]
}

@test "report includes all repositories" {
  generate_report "test_packages.yaml"
  run yq eval '.repositories | keys' "test_packages.yaml"
  [[ "$output" =~ "core" ]]
  [[ "$output" =~ "extra" ]]
  [[ "$output" =~ "community" ]]
  [[ "$output" =~ "multilib" ]]
  [[ "$output" =~ "aur" ]]
}

@test "report with versions flag includes version information" {
  include_versions=1
  generate_report "test_versions.yaml"
  run yq eval '.repositories.core[0]' "test_versions.yaml"
  [[ "$output" =~ "version:" ]]
}

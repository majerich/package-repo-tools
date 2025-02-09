#!/usr/bin/env bash

#==============================================================================
# Test: integration.test.sh
# Description: Integration tests for package repository tools
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

source "../src/lib/logging.sh"
source "../src/lib/package.sh"
source "../src/lib/network.sh"
source "../src/lib/system.sh"

test_full_backup_restore_cycle() {
  # Generate report
  ../src/package-repo-report.sh test-packages.yaml
  assertEquals "Report generation should succeed" 0 $?
  assertTrue "Report file should exist" "[ -f 'test-packages.yaml' ]"

  # Modify package list
  local test_pkg="htop"
  sudo pacman -R --noconfirm "$test_pkg"

  # Restore from report
  ../src/package-repo-restore.sh test-packages.yaml
  assertEquals "Package restoration should succeed" 0 $?

  # Verify restoration
  pacman -Qi "$test_pkg" >/dev/null
  assertEquals "Test package should be restored" 0 $?
}

test_custom_repository_handling() {
  # Add custom repository
  local repo_name="test-repo"
  local repo_url="https://test.repo.com"

  add_custom_repo "$repo_name" "$repo_url"
  assertEquals "Repository addition should succeed" 0 $?

  # Verify repository configuration
  grep -q "^\[$repo_name\]" /etc/pacman.conf
  assertEquals "Repository should be in pacman.conf" 0 $?
}

test_parallel_installation() {
  local test_packages=("git" "vim" "wget")

  # Install packages in parallel
  ../src/package-repo-restore.sh --parallel test-packages.yaml
  assertEquals "Parallel installation should succeed" 0 $?

  # Verify all packages installed
  for pkg in "${test_packages[@]}"; do
    pacman -Qi "$pkg" >/dev/null
    assertEquals "Package $pkg should be installed" 0 $?
  done
}

# Load shUnit2
. shunit2

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

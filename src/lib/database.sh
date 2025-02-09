#==============================================================================
# Library: colors.sh
# Description: Color definitions and styled output functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Database Operations Library Usage
#==============================================================================
#
# Update Package Database:
#   update_package_db
#   Output: Updating database [####··] 66%
#
# Verify Database Integrity:
#   verify_db_integrity
#   Output: [ᗧ···ᗣ] Verifying database...
#
# Clean Database:
#   clean_package_db
#   Output: Cleaning database [####··] 66%
#
# Sync Database:
#   sync_package_db
#   Output: [ᗧ···ᗣ] Syncing database...
#==============================================================================

source "./progress.sh"

update_package_db() {
  local total_steps=3
  local current=0

  # Step 1: Backup current database
  ((current++))
  show_progress "$current" "$total_steps" "Backing up database"
  cp -r /var/lib/pacman/local{,.bak}

  # Step 2: Update database
  ((current++))
  show_progress "$current" "$total_steps" "Updating database"
  if ! sudo pacman -Sy; then
    log_error "Database update failed"
    return 1
  fi

  # Step 3: Verify update
  ((current++))
  show_progress "$current" "$total_steps" "Verifying update"
  if ! verify_db_integrity; then
    log_error "Database verification failed"
    return 1
  fi

  log_success "Package database updated successfully"
  return 0
}

verify_db_integrity() {
  start_spinner "Verifying database integrity"

  if ! sudo pacman -Dk >/dev/null 2>&1; then
    stop_spinner
    log_error "Database integrity check failed"
    return 1
  fi

  stop_spinner
  log_success "Database integrity verified"
  return 0
}

clean_package_db() {
  local total_steps=2
  local current=0

  # Step 1: Remove old sync databases
  ((current++))
  show_progress "$current" "$total_steps" "Removing old databases"
  sudo rm -f /var/lib/pacman/sync/*.db.old

  # Step 2: Clean package cache
  ((current++))
  show_progress "$current" "$total_steps" "Cleaning package cache"
  sudo paccache -r

  log_success "Package database cleaned"
  return 0
}

sync_package_db() {
  start_spinner "Syncing package database"

  local mirrors=($(pacman-mirrors -l))
  local sync_failed=0

  for mirror in "${mirrors[@]}"; do
    if ! sudo pacman -Sy --dbonly; then
      ((sync_failed++))
      log_warn "Sync failed for mirror: $mirror"
    fi
  done

  stop_spinner

  if ((sync_failed == ${#mirrors[@]})); then
    log_error "Database sync failed for all mirrors"
    return 1
  fi

  log_success "Package database synced successfully"
  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

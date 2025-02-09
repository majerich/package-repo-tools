#==============================================================================
# Library: restore.sh
# Description: Restore packages
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# System Restore Library Usage
#==============================================================================
#
# Restore Full System:
#   restore_system "/path/to/backup.tar.gz"
#   Output: Restoring system [####··] 66%
#
# Restore Package List:
#   restore_packages "/path/to/pkglist.txt"
#   Output: [ᗧ···ᗣ] Installing packages...
#
# Verify System State:
#   verify_system_state
#   if [[ $? -eq 0 ]]; then
#     echo "System state verified"
#   fi
#
# Restore Configuration:
#   restore_configuration "/path/to/backup/pacman.conf"
#   Output: Restoring configuration [####··] 66%
#==============================================================================

source "./progress.sh"

restore_system() {
  local backup_file="$1"
  local temp_dir="/tmp/system-restore-$$"
  local total_steps=4
  local current_step=0

  mkdir -p "$temp_dir"

  # Step 1: Extract backup
  ((current_step++))
  show_progress "$current_step" "$total_steps" "Extracting backup"
  tar xzf "$backup_file" -C "$temp_dir"

  # Step 2: Restore pacman database
  ((current_step++))
  show_progress "$current_step" "$total_steps" "Restoring pacman database"
  sudo cp -r "$temp_dir/pacman-db"/* /var/lib/pacman/local/

  # Step 3: Restore configuration
  ((current_step++))
  show_progress "$current_step" "$total_steps" "Restoring configuration"
  sudo cp "$temp_dir/pacman.conf" /etc/
  sudo cp -r "$temp_dir/pacman.d"/* /etc/pacman.d/

  # Step 4: Restore packages
  ((current_step++))
  show_progress "$current_step" "$total_steps" "Restoring packages"
  restore_packages "$temp_dir/pkglist.txt"

  rm -rf "$temp_dir"
  verify_system_state
}

restore_packages() {
  local package_list="$1"
  local total_packages=$(wc -l <"$package_list")
  local current=0

  while read -r package; do
    ((current++))
    if [[ "$PACMAN_ANIMATION" = true ]]; then
      show_pacman_progress "$current" "$total_packages" "Installing $package"
    else
      show_progress "$current" "$total_packages" "Installing packages"
    fi

    sudo pacman -S --needed --noconfirm "$package"
  done <"$package_list"
}

verify_system_state() {
  local total_checks=3
  local current=0

  # Check 1: Pacman database
  ((current++))
  show_progress "$current" "$total_checks" "Verifying pacman database"
  sudo pacman -Dk >/dev/null 2>&1

  # Check 2: Package integrity
  ((current++))
  show_progress "$current" "$total_checks" "Verifying package integrity"
  sudo pacman -Qk >/dev/null 2>&1

  # Check 3: Configuration files
  ((current++))
  show_progress "$current" "$total_checks" "Verifying configuration"
  [[ -f "/etc/pacman.conf" && -d "/etc/pacman.d" ]]

  local result=$?
  [[ $result -eq 0 ]] && log_success "System state verified" || log_error "System state verification failed"
  return $result
}

restore_configuration() {
  local config_file="$1"
  local total_steps=2
  local current=0

  # Step 1: Backup current configuration
  ((current++))
  show_progress "$current" "$total_steps" "Backing up current configuration"
  sudo cp /etc/pacman.conf /etc/pacman.conf.bak

  # Step 2: Restore new configuration
  ((current++))
  show_progress "$current" "$total_steps" "Restoring configuration"
  sudo cp "$config_file" /etc/pacman.conf

  log_success "Configuration restored successfully"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

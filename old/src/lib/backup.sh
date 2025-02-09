#==============================================================================
# Library: backup.sh
# Description: Enhanced backup functionality with new config options
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Backup Operations Library Usage
#==============================================================================
#
# Create System Backup:
#   create_backup "/path/to/backup"
#   Output: Creating backup [####··] 66%
#
# Backup Package List:
#   backup_package_list "/path/to/packages.list"
#   Output: [ᗧ···ᗣ] Saving package list...
#
# Verify Backup Integrity:
#   verify_backup "/path/to/backup.tar.gz"
#   if [[ $? -eq 0 ]]; then
#     echo "Backup verified successfully"
#   fi
#
# Clean Old Backups:
#   clean_old_backups "/path/to/backup/dir" 5
#   Output: Cleaning old backups [####··] 66%
#==============================================================================

source "./progress.sh"

create_backup() {
  local backup_dir="$1"
  local timestamp=$(date +%Y%m%d-%H%M%S)
  local backup_file="$backup_dir/system-$timestamp.tar.gz"

  mkdir -p "$backup_dir"

  local total_steps=4
  local current_step=0

  # Step 1: Backup package list
  ((current_step++))
  show_progress "$current_step" "$total_steps" "Backing up package list"
  pacman -Qqe >"$backup_dir/pkglist.txt"

  # Step 2: Backup pacman database
  ((current_step++))
  show_progress "$current_step" "$total_steps" "Backing up pacman database"
  cp -r /var/lib/pacman/local "$backup_dir/pacman-db"

  # Step 3: Backup configuration
  ((current_step++))
  show_progress "$current_step" "$total_steps" "Backing up configuration"
  cp /etc/pacman.conf "$backup_dir/"
  cp -r /etc/pacman.d "$backup_dir/"

  # Step 4: Create archive
  ((current_step++))
  show_progress "$current_step" "$total_steps" "Creating backup archive"
  tar czf "$backup_file" -C "$backup_dir" .

  verify_backup "$backup_file"
}

backup_package_list() {
  local output_file="$1"
  local total_steps=3

  start_spinner "Generating package list"

  # Official packages
  pacman -Qqen >"${output_file}.official"
  show_progress 1 "$total_steps" "Saving package lists"

  # AUR packages
  pacman -Qqem >"${output_file}.foreign"
  show_progress 2 "$total_steps" "Saving package lists"

  # Combined list with versions
  pacman -Qe >"${output_file}"
  show_progress 3 "$total_steps" "Saving package lists"

  stop_spinner
}

verify_backup() {
  local backup_file="$1"

  start_spinner "Verifying backup integrity"

  if ! tar tzf "$backup_file" >/dev/null 2>&1; then
    stop_spinner
    log_error "Backup verification failed: $backup_file"
    return 1
  fi

  stop_spinner
  log_success "Backup verified successfully"
  return 0
}

clean_old_backups() {
  local backup_dir="$1"
  local keep_count="${2:-5}"

  local backup_files=($(ls -t "$backup_dir"/system-*.tar.gz 2>/dev/null))
  local total_files=${#backup_files[@]}
  local remove_count=$((total_files - keep_count))

  if [[ $remove_count -le 0 ]]; then
    log_info "No old backups to clean"
    return 0
  fi

  for ((i = 0; i < remove_count; i++)); do
    show_progress "$((i + 1))" "$remove_count" "Cleaning old backups"
    rm -f "${backup_files[$((i + keep_count))]}"
  done

  log_success "Removed $remove_count old backup(s)"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

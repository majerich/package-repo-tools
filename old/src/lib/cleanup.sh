#==============================================================================
# Library: cleanup.sh
# Description: Cleanup and temporary file management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Cleanup Library Usage
#==============================================================================
#
# Clean Package Cache:
#   clean_package_cache 5
#   Output: Cleaning package cache [####··] 66%
#
# Remove Old Logs:
#   cleanup_logs 30
#   Output: [ᗧ···ᗣ] Removing old logs...
#
# Clean Temporary Files:
#   cleanup_temp_files
#   Output: Cleaning temporary files [####··] 66%
#
# Perform Full Cleanup:
#   perform_full_cleanup
#   Output: [ᗧ···ᗣ] Performing full cleanup...
#==============================================================================

source "./progress.sh"

clean_package_cache() {
  local keep_versions="${1:-3}"
  local cache_dir="/var/cache/pacman/pkg"
  local total_steps=3
  local current=0

  # Step 1: Count packages
  ((current++))
  show_progress "$current" "$total_steps" "Analyzing package cache"
  local packages=($(find "$cache_dir" -name "*.pkg.tar.*"))

  # Step 2: Group by package name
  ((current++))
  show_progress "$current" "$total_steps" "Grouping packages"
  declare -A package_groups
  for pkg in "${packages[@]}"; do
    local base_name=$(basename "$pkg" | sed -E 's/-[0-9].*//')
    package_groups["$base_name"]+=" $pkg"
  done

  # Step 3: Remove old versions
  ((current++))
  show_progress "$current" "$total_steps" "Removing old versions"
  for group in "${!package_groups[@]}"; do
    local versions=(${package_groups["$group"]})
    if [[ ${#versions[@]} -gt $keep_versions ]]; then
      for ((i = 0; i < ${#versions[@]} - keep_versions; i++)); do
        rm -f "${versions[i]}"
      done
    fi
  done

  log_success "Package cache cleaned"
}

cleanup_logs() {
  local days="${1:-30}"
  local log_dir="$LOG_DIR"

  start_spinner "Cleaning old logs"

  find "$log_dir" -type f -name "*.log*" -mtime +"$days" -exec rm -f {} \;

  stop_spinner
  log_success "Old logs removed"
}

cleanup_temp_files() {
  local temp_dir="/tmp/package-repo-tools-*"
  local total_steps=2
  local current=0

  # Step 1: Find temp files
  ((current++))
  show_progress "$current" "$total_steps" "Finding temporary files"
  local temp_files=($(find /tmp -maxdepth 1 -name "package-repo-tools-*"))

  # Step 2: Remove temp files
  ((current++))
  show_progress "$current" "$total_steps" "Removing temporary files"
  for file in "${temp_files[@]}"; do
    rm -rf "$file"
  done

  log_success "Temporary files cleaned"
}

perform_full_cleanup() {
  start_spinner "Starting full cleanup"

  clean_package_cache
  cleanup_logs
  cleanup_temp_files

  stop_spinner
  log_success "Full cleanup completed"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

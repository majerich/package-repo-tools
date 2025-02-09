#==============================================================================
# Library: cache.sh
# Description: Package cache management with new config options
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Cache Management Library Usage
#==============================================================================
#
# Clean Package Cache:
#   clean_cache 5
#   Output: Cleaning cache [####··] 66%
#
# Verify Cache Integrity:
#   verify_cache_integrity
#   Output: [ᗧ···ᗣ] Verifying cache...
#
# Get Cache Statistics:
#   get_cache_stats
#   Output: Cache size: 2.5GB, Files: 150
#
# Optimize Cache:
#   optimize_cache
#   Output: Optimizing cache [####··] 66%
#==============================================================================

source "./progress.sh"

clean_cache() {
  local keep_versions="${1:-3}"
  local total_steps=3
  local current=0

  # Step 1: Analyze cache
  ((current++))
  show_progress "$current" "$total_steps" "Analyzing cache"
  local cache_size=$(du -sh /var/cache/pacman/pkg | cut -f1)

  # Step 2: Remove old packages
  ((current++))
  show_progress "$current" "$total_steps" "Removing old packages"
  sudo paccache -r -k "$keep_versions"

  # Step 3: Clean uninstalled packages
  ((current++))
  show_progress "$current" "$total_steps" "Cleaning uninstalled packages"
  sudo paccache -ruk0

  local new_size=$(du -sh /var/cache/pacman/pkg | cut -f1)
  log_success "Cache cleaned. Size reduced from $cache_size to $new_size"
  return 0
}

verify_cache_integrity() {
  start_spinner "Verifying cache integrity"

  local corrupted=0
  local packages=($(find /var/cache/pacman/pkg -name "*.pkg.tar.*"))

  for pkg in "${packages[@]}"; do
    if ! bsdtar -tf "$pkg" >/dev/null 2>&1; then
      ((corrupted++))
      log_warn "Corrupted package found: $(basename "$pkg")"
      rm -f "$pkg"
    fi
  done

  stop_spinner

  if ((corrupted > 0)); then
    log_warn "Removed $corrupted corrupted package(s)"
  else
    log_success "Cache integrity verified"
  fi

  return 0
}

get_cache_stats() {
  local cache_dir="/var/cache/pacman/pkg"
  local total_size=$(du -sh "$cache_dir" | cut -f1)
  local file_count=$(find "$cache_dir" -type f | wc -l)
  local pkg_groups=$(find "$cache_dir" -name "*.pkg.tar.*" | sed 's/-[0-9].*//' | sort -u | wc -l)

  echo "Cache Statistics:"
  echo "Total Size: $total_size"
  echo "Total Files: $file_count"
  echo "Package Groups: $pkg_groups"
}

optimize_cache() {
  local total_steps=4
  local current=0

  # Step 1: Remove duplicates
  ((current++))
  show_progress "$current" "$total_steps" "Removing duplicates"
  sudo paccache -rk1

  # Step 2: Remove uninstalled
  ((current++))
  show_progress "$current" "$total_steps" "Cleaning uninstalled packages"
  sudo paccache -ruk0

  # Step 3: Clean partial downloads
  ((current++))
  show_progress "$current" "$total_steps" "Removing partial downloads"
  find /var/cache/pacman/pkg -name "*.part" -delete

  # Step 4: Verify integrity
  ((current++))
  show_progress "$current" "$total_steps" "Verifying cache"
  verify_cache_integrity

  log_success "Cache optimized successfully"
  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

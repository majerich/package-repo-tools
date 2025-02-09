#==============================================================================
# Library: conflicts.sh
# Description: Package conflict detection and resolution
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Package Conflicts Management Library Usage
#==============================================================================
#
# Check Package Conflicts:
#   check_conflicts "nginx-mainline" "nginx"
#   Output: Checking conflicts [####··] 66%
#
# Resolve Package Conflicts:
#   resolve_conflicts "nginx-mainline" "nginx"
#   Output: [ᗧ···ᗣ] Resolving conflicts...
#
# List Package Conflicts:
#   list_conflicts "nginx-mainline"
#   Output: Conflicts for nginx-mainline:
#          - nginx
#
# Check File Conflicts:
#   check_file_conflicts "package.pkg.tar.zst"
#   Output: Checking file conflicts [####··] 66%
#==============================================================================

source "./progress.sh"

check_conflicts() {
  local package1="$1"
  local package2="$2"
  local total_steps=3
  local current=0

  # Step 1: Check direct conflicts
  ((current++))
  show_progress "$current" "$total_steps" "Checking direct conflicts"
  local conflicts=($(pacman -Si "$package1" | grep "Conflicts With" | cut -d: -f2-))

  # Step 2: Check provides conflicts
  ((current++))
  show_progress "$current" "$total_steps" "Checking provides conflicts"
  local provides=($(pacman -Si "$package1" | grep "Provides" | cut -d: -f2-))

  # Step 3: Check file conflicts
  ((current++))
  show_progress "$current" "$total_steps" "Checking file conflicts"
  if pacman -Ql "$package1" "$package2" 2>/dev/null | sort | uniq -d; then
    log_error "File conflicts detected between $package1 and $package2"
    return 1
  fi

  if [[ " ${conflicts[*]} " =~ " ${package2} " ]]; then
    log_error "Package conflict detected: $package1 conflicts with $package2"
    return 1
  fi

  log_success "No conflicts detected"
  return 0
}

resolve_conflicts() {
  local package1="$1"
  local package2="$2"

  start_spinner "Analyzing conflicts"

  local conflicts=($(pacman -Si "$package1" | grep "Conflicts With" | cut -d: -f2-))

  stop_spinner

  if [[ " ${conflicts[*]} " =~ " ${package2} " ]]; then
    show_progress 1 2 "Removing conflicting package"
    sudo pacman -R --noconfirm "$package2"
    show_progress 2 2 "Installing new package"
    sudo pacman -S --noconfirm "$package1"
  fi

  log_success "Conflicts resolved successfully"
  return 0
}

list_conflicts() {
  local package="$1"

  echo "Conflicts for $package:"

  # Direct conflicts
  echo "Direct conflicts:"
  pacman -Si "$package" | grep "Conflicts With" | cut -d: -f2- | tr ' ' '\n' | grep -v '^$' | sed 's/^/  - /'

  # Provides conflicts
  echo "Provides conflicts:"
  pacman -Si "$package" | grep "Provides" | cut -d: -f2- | tr ' ' '\n' | grep -v '^$' | sed 's/^/  - /'
}

check_file_conflicts() {
  local package_file="$1"
  local total_steps=3
  local current=0

  # Step 1: Extract package info
  ((current++))
  show_progress "$current" "$total_steps" "Extracting package info"
  local pkg_files=($(bsdtar -tf "$package_file"))

  # Step 2: Check system files
  ((current++))
  show_progress "$current" "$total_steps" "Checking system files"
  local conflicts=()

  for file in "${pkg_files[@]}"; do
    if [[ -f "/$file" ]]; then
      local owner=$(pacman -Qo "/$file" 2>/dev/null)
      if [[ -n "$owner" ]]; then
        conflicts+=("$file")
      fi
    fi
  done

  # Step 3: Report conflicts
  ((current++))
  show_progress "$current" "$total_steps" "Analyzing conflicts"

  if [[ ${#conflicts[@]} -gt 0 ]]; then
    log_error "File conflicts detected:"
    printf '%s\n' "${conflicts[@]}" | sed 's/^/  - /'
    return 1
  fi

  log_success "No file conflicts detected"
  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

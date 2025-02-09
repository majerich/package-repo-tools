#==============================================================================
# Library: package.sh
# Description: Package management and installation functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Package Management Library Usage
#==============================================================================
#
# Install Single Package:
#   install_package "nginx"
#   Output: [ᗧ···ᗣ] Installing nginx...
#
# Install Multiple Packages:
#   install_package_group "nginx" "php" "mariadb"
#   Output: Installing packages [####··] 66%
#
# Validate Package Names with Progress:
#   start_spinner "Validating packages"
#   validate_packages "nginx" "php"
#   stop_spinner
#
# Check Package Status:
#   check_package_status "nginx"
#   case $? in
#     0) echo "Package installed" ;;
#     1) echo "Package not installed" ;;
#     2) echo "Package not found" ;;
#   esac
#==============================================================================

source "./progress.sh"

install_package() {
  local package="$1"

  if [[ "$PACMAN_ANIMATION" = true ]]; then
    show_pacman_progress 0 1 "Installing $package"
    sudo pacman -S --needed --noconfirm "$package"
    show_pacman_progress 1 1 "Installing $package"
  else
    start_spinner "Installing $package"
    sudo pacman -S --needed --noconfirm "$package"
    stop_spinner
  fi
}

install_package_group() {
  local packages=("$@")
  local total=${#packages[@]}

  for i in "${!packages[@]}"; do
    show_progress "$((i + 1))" "$total" "Installing packages"
    install_package "${packages[i]}"
  done
}

validate_packages() {
  local packages=("$@")
  local invalid_packages=()
  local total=${#packages[@]}

  for i in "${!packages[@]}"; do
    update_progress "Validating packages" "$((i + 1))" "$total"
    if ! pacman -Si "${packages[i]}" >/dev/null 2>&1; then
      invalid_packages+=("${packages[i]}")
      log_error "Package not found: ${packages[i]}"
    fi
  done

  if [[ ${#invalid_packages[@]} -gt 0 ]]; then
    log_error "Invalid packages found: ${invalid_packages[*]}"
    return 1
  fi

  log_success "All packages validated successfully"
  return 0
}

check_package_status() {
  local package="$1"

  start_spinner "Checking status of $package"

  if pacman -Qi "$package" >/dev/null 2>&1; then
    stop_spinner
    return 0 # Installed
  elif pacman -Si "$package" >/dev/null 2>&1; then
    stop_spinner
    return 1 # Not installed but available
  else
    stop_spinner
    return 2 # Not found
  fi
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

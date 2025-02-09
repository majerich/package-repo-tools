#==============================================================================
# Library: security.sh
# Description: Package security and verification management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

verify_package_security() {
  local package="$1"

  if [[ "$VERIFY_SIGNATURES" = true ]]; then
    log_debug "Verifying signature for $package"
    pacman-key --verify "$package.sig" "$package"
  fi
}

check_package_downgrade() {
  local package="$1"
  local new_version="$2"

  if [[ "$ALLOW_DOWNGRADE" = false ]]; then
    local current_version=$(pacman -Q "$package" | cut -d' ' -f2)
    if [[ $(vercmp "$new_version" "$current_version") -lt 0 ]]; then
      log_error "Package downgrade not allowed: $package ($current_version -> $new_version)"
      return 1
    fi
  fi
  return 0
}

handle_package_replacement() {
  local package="$1"
  local replaces=$(pacman -Si "$package" | grep "Replaces" | cut -d: -f2)

  if [[ -n "$replaces" && "$ALLOW_REPLACEMENTS" = false ]]; then
    log_error "Package replacement not allowed: $package would replace $replaces"
    return 1
  fi
  return 0
}

verify_package_integrity() {
  local package="$1"

  if [[ "$VERIFY_SIGNATURES" = true ]]; then
    pacman -Qk "$package"
    if [[ $? -ne 0 ]]; then
      log_error "Package integrity check failed: $package"
      return 1
    fi
  fi
  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

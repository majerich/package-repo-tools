#==============================================================================
# Library: repos.sh
# Description: Repository management and configuration
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

check_custom_repos() {
  log_info "Checking custom repositories..."

  for repo in "${!repo_packages[@]}"; do
    for known_repo in "${CUSTOM_REPOS[@]}"; do
      IFS='|' read -r repo_name repo_url key_id key_server <<<"$known_repo"

      if [[ "$repo" == "$repo_name" ]]; then
        add_custom_repo "$repo_name" "$repo_url" "$key_id" "$key_server"
      fi
    done
  done
}

add_custom_repo() {
  local repo_name="$1"
  local repo_url="$2"
  local key_id="$3"
  local key_server="$4"

  if ! grep -q "^\[$repo_name\]" /etc/pacman.conf; then
    log_info "Adding $repo_name repository..."

    if [[ "$DRY_RUN" = false ]]; then
      # Add repository configuration
      sudo tee -a /etc/pacman.conf >/dev/null <<EOF

[$repo_name]
Server = $repo_url
EOF

      # Import and sign GPG key
      sudo pacman-key --recv-key "$key_id" --keyserver "$key_server"
      sudo pacman-key --lsign-key "$key_id"

      # Update package database
      sudo pacman -Sy
    fi
  fi
}

verify_repo_access() {
  local repo_name="$1"
  local repo_url="$2"

  if ! curl --connect-timeout "$TIMEOUT" -Is "$repo_url" >/dev/null 2>&1; then
    log_warn "Repository $repo_name is not accessible"
    return 1
  fi
  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

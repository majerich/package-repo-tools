#==============================================================================
# Library: descriptions.sh
# Description: Package description management and caching
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly DESC_CACHE_FILE="$CACHE_DIR/descriptions.cache"

cache_package_descriptions() {
  [[ "$INCLUDE_PACKAGE_DESCRIPTIONS" = true ]] || return 0

  log_debug "Caching package descriptions"
  mkdir -p "$(dirname "$DESC_CACHE_FILE")"

  pacman -Q | while read -r pkg _; do
    local desc=$(pacman -Qi "$pkg" | grep "^Description" | cut -d: -f2 | xargs)
    echo "$pkg:$desc"
  done >"$DESC_CACHE_FILE"
}

get_package_description() {
  local package="$1"

  if [[ "$INCLUDE_PACKAGE_DESCRIPTIONS" = true ]]; then
    if [[ -f "$DESC_CACHE_FILE" ]]; then
      grep "^$package:" "$DESC_CACHE_FILE" | cut -d: -f2
    else
      pacman -Qi "$package" | grep "^Description" | cut -d: -f2 | xargs
    fi
  fi
}

update_description_cache() {
  [[ "$INCLUDE_PACKAGE_DESCRIPTIONS" = true ]] || return 0

  if [[ -f "$DESC_CACHE_FILE" ]]; then
    local cache_age=$(($(date +%s) - $(stat -c %Y "$DESC_CACHE_FILE")))
    if ((cache_age > CACHE_DAYS * 86400)); then
      cache_package_descriptions
    fi
  else
    cache_package_descriptions
  fi
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

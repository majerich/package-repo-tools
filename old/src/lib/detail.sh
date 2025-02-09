#==============================================================================
# Library: detail.sh
# Description: Package detail level management and formatting
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

format_package_details() {
  local package="$1"

  case "$REPORT_DETAIL_LEVEL" in
  "basic")
    format_basic_details "$package"
    ;;
  "full")
    format_full_details "$package"
    ;;
  "detailed")
    format_detailed_details "$package"
    ;;
  esac
}

format_basic_details() {
  local package="$1"
  pacman -Q "$package"
}

format_full_details() {
  local package="$1"
  {
    pacman -Qi "$package" | grep -E "^(Name|Version|Description|Architecture|URL|Licenses|Groups|Provides|Depends On|Optional Deps|Required By|Conflicts With|Replaces)"
    echo "Install Date: $(stat -c %y /var/lib/pacman/local/*-"$package")"
    echo "Install Size: $(pacman -Qi "$package" | grep "Installed Size" | cut -d: -f2)"
  } | sed 's/^/  /'
}

format_detailed_details() {
  local package="$1"
  {
    format_full_details "$package"
    echo "Package Files:"
    pacman -Ql "$package" | sed 's/^/    /'
    echo "Backup Files:"
    pacman -Qii "$package" | grep "^BACKUP" | sed 's/^BACKUP/    /'
    echo "Package Changes:"
    pacman -Qc "$package" | sed 's/^/    /'
    if [[ -f "/var/log/pacman.log" ]]; then
      echo "Install History:"
      grep "$package" /var/log/pacman.log | sed 's/^/    /'
    fi
  }
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

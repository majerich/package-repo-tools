#==============================================================================
# Library: versions.sh
# Description: Version comparison and management functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Version Management Library Usage
#==============================================================================
#
# Compare Versions:
#   compare_versions "1.2.3" "1.2.4"
#   Output: Comparing versions [####··] 66%
#
# Get Latest Version:
#   get_latest_version "nginx"
#   Output: [ᗧ···ᗣ] Checking latest version...
#
# Check Version Compatibility:
#   check_version_compatibility "2.0.0" ">=1.0.0"
#   Output: Checking compatibility [####··] 66%
#
# Parse Version String:
#   parse_version_string "1.2.3-1"
#   Output: Major: 1, Minor: 2, Patch: 3, Release: 1
#==============================================================================

source "./progress.sh"

compare_versions() {
  local version1="$1"
  local version2="$2"
  local total_steps=3
  local current=0

  # Step 1: Parse versions
  ((current++))
  show_progress "$current" "$total_steps" "Parsing versions"
  local v1=(${version1//./ })
  local v2=(${version2//./ })

  # Step 2: Compare major.minor
  ((current++))
  show_progress "$current" "$total_steps" "Comparing versions"
  for i in {0..2}; do
    if ((${v1[$i]:-0} > ${v2[$i]:-0})); then
      return 1
    elif ((${v1[$i]:-0} < ${v2[$i]:-0})); then
      return 2
    fi
  done

  # Step 3: Compare release
  ((current++))
  show_progress "$current" "$total_steps" "Comparing release numbers"
  local r1=$(echo "$version1" | grep -oP '(?<=-)\d+$' || echo "0")
  local r2=$(echo "$version2" | grep -oP '(?<=-)\d+$' || echo "0")

  if ((r1 > r2)); then
    return 1
  elif ((r1 < r2)); then
    return 2
  fi

  return 0
}

get_latest_version() {
  local package="$1"

  start_spinner "Checking latest version"

  local version=$(pacman -Si "$package" 2>/dev/null | grep Version | awk '{print $3}')

  if [[ -n "$version" ]]; then
    stop_spinner
    echo "$version"
    return 0
  fi

  stop_spinner
  log_error "Could not determine latest version for $package"
  return 1
}

check_version_compatibility() {
  local version="$1"
  local requirement="$2"
  local op=${requirement:0:2}
  local req_version=${requirement:2}

  start_spinner "Checking version compatibility"

  compare_versions "$version" "$req_version"
  local comparison=$?

  stop_spinner

  case "$op" in
  ">=") return $((comparison != 2)) ;;
  "<=") return $((comparison != 1)) ;;
  "==") return $((comparison == 0)) ;;
  "!=") return $((comparison != 0)) ;;
  ">") return $((comparison == 1)) ;;
  "<") return $((comparison == 2)) ;;
  *)
    log_error "Invalid operator: $op"
    return 1
    ;;
  esac
}

parse_version_string() {
  local version="$1"
  local pattern="^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9]+))?$"

  if [[ ! "$version" =~ $pattern ]]; then
    log_error "Invalid version format: $version"
    return 1
  fi

  echo "Major: ${BASH_REMATCH[1]}"
  echo "Minor: ${BASH_REMATCH[2]}"
  echo "Patch: ${BASH_REMATCH[3]}"
  echo "Release: ${BASH_REMATCH[5]:-0}"
  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

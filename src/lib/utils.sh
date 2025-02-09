#==============================================================================
# Library: colors.sh
# Description: Color definitions and styled output functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Utilities Library Usage
#==============================================================================
#
# Parse Command Arguments:
#   parse_args "$@"
#   Output: Parsing arguments [####··] 66%
#
# Format File Size:
#   format_size 1048576
#   Output: 1.0 GB
#
# Get Timestamp:
#   get_timestamp "filename"
#   Output: 2024-01-20-143045
#
# Parse Version String:
#   parse_version "1.2.3-1"
#   Output: [ᗧ···ᗣ] Parsing version...
#==============================================================================

source "./progress.sh"

parse_args() {
  local args=("$@")
  local total_args=${#args[@]}
  local current=0

  while [[ $current -lt $total_args ]]; do
    show_progress "$((current + 1))" "$total_args" "Parsing arguments"

    case "${args[current]}" in
    --help | -h)
      show_help
      exit 0
      ;;
    --version | -v)
      show_version
      exit 0
      ;;
    --config | -c)
      ((current++))
      CONFIG_FILE="${args[current]}"
      ;;
    --verbose)
      VERBOSE=true
      ;;
    --debug)
      DEBUG=true
      LOG_LEVEL="DEBUG"
      ;;
    *)
      POSITIONAL_ARGS+=("${args[current]}")
      ;;
    esac
    ((current++))
  done
}

format_size() {
  local size="$1"
  local units=("B" "KB" "MB" "GB" "TB")
  local unit=0

  while ((size > 1024 && unit < ${#units[@]} - 1)); do
    size=$(echo "scale=1; $size / 1024" | bc)
    ((unit++))
  done

  printf "%.1f %s" "$size" "${units[$unit]}"
}

get_timestamp() {
  local prefix="${1:-}"
  local timestamp

  if [[ -n "$prefix" ]]; then
    timestamp="${prefix}-$(date +%Y%m%d-%H%M%S)"
  else
    timestamp="$(date +%Y%m%d-%H%M%S)"
  fi

  echo "$timestamp"
}

parse_version() {
  local version="$1"
  local pattern="^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9]+))?$"

  start_spinner "Parsing version string"

  if [[ ! "$version" =~ $pattern ]]; then
    stop_spinner
    log_error "Invalid version format: $version"
    return 1
  fi

  local major="${BASH_REMATCH[1]}"
  local minor="${BASH_REMATCH[2]}"
  local patch="${BASH_REMATCH[3]}"
  local revision="${BASH_REMATCH[5]:-0}"

  stop_spinner

  declare -gA VERSION=(
    [major]="$major"
    [minor]="$minor"
    [patch]="$patch"
    [revision]="$revision"
  )

  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

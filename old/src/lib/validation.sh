#==============================================================================
# Library: validation.sh
# Description: Input validation and error checking functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Validation Library Usage
#==============================================================================
#
# Validate File Path:
#   validate_path "/path/to/check" "write"
#   Output: Validating path [####··] 66%
#
# Check Dependencies:
#   check_dependencies "curl" "jq" "tar"
#   Output: [ᗧ···ᗣ] Checking dependencies...
#
# Validate Package Name:
#   validate_package_name "nginx-custom"
#   if [[ $? -eq 0 ]]; then
#     echo "Package name is valid"
#   fi
#
# Verify Checksum:
#   verify_checksum "package.tar.gz" "package.sha256"
#   Output: Verifying checksum [####··] 66%
#==============================================================================

source "./progress.sh"

validate_path() {
  local path="$1"
  local access_type="${2:-read}"
  local total_checks=3
  local current=0

  # Check 1: Path exists
  ((current++))
  show_progress "$current" "$total_checks" "Validating path"
  if [[ ! -e "$path" ]]; then
    log_error "Path does not exist: $path"
    return 1
  fi

  # Check 2: Access permissions
  ((current++))
  show_progress "$current" "$total_checks" "Checking permissions"
  case "$access_type" in
  "read")
    if [[ ! -r "$path" ]]; then
      log_error "Path not readable: $path"
      return 1
    fi
    ;;
  "write")
    if [[ ! -w "$path" ]]; then
      log_error "Path not writable: $path"
      return 1
    fi
    ;;
  "execute")
    if [[ ! -x "$path" ]]; then
      log_error "Path not executable: $path"
      return 1
    fi
    ;;
  esac

  # Check 3: Path type validation
  ((current++))
  show_progress "$current" "$total_checks" "Validating path type"
  if [[ -d "$path" ]] || [[ -f "$path" ]]; then
    log_success "Path validated successfully: $path"
    return 0
  fi

  log_error "Invalid path type: $path"
  return 1
}

check_dependencies() {
  local deps=("$@")
  local missing_deps=()
  local total=${#deps[@]}
  local current=0

  for dep in "${deps[@]}"; do
    ((current++))
    show_progress "$current" "$total" "Checking dependencies"

    if ! command -v "$dep" &>/dev/null; then
      missing_deps+=("$dep")
    fi
  done

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "Missing dependencies: ${missing_deps[*]}"
    return 1
  fi

  log_success "All dependencies satisfied"
  return 0
}

validate_package_name() {
  local package="$1"
  local pattern="^[a-zA-Z0-9][a-zA-Z0-9@._+-]*$"

  start_spinner "Validating package name"

  if [[ ! "$package" =~ $pattern ]]; then
    stop_spinner
    log_error "Invalid package name format: $package"
    return 1
  fi

  if [[ ${#package} -gt 64 ]]; then
    stop_spinner
    log_error "Package name too long: $package"
    return 1
  fi

  stop_spinner
  log_success "Package name validated: $package"
  return 0
}

verify_checksum() {
  local file="$1"
  local checksum_file="$2"
  local total_steps=2
  local current=0

  # Step 1: Generate checksum
  ((current++))
  show_progress "$current" "$total_steps" "Calculating checksum"
  local calculated_sum=$(sha256sum "$file" | cut -d' ' -f1)

  # Step 2: Compare checksums
  ((current++))
  show_progress "$current" "$total_steps" "Verifying checksum"
  local expected_sum=$(cat "$checksum_file")

  if [[ "$calculated_sum" == "$expected_sum" ]]; then
    log_success "Checksum verified successfully"
    return 0
  fi

  log_error "Checksum verification failed"
  return 1
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

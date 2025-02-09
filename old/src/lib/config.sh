#==============================================================================
# Library: config.sh
# Description: configuration file management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Configuration Library Usage
#==============================================================================
#
# Load Configuration:
#   load_configuration "/etc/package-repo-tools/config"
#   Output: Loading configuration [####··] 66%
#
# Validate Configuration:
#   validate_config
#   if [[ $? -eq 0 ]]; then
#     echo "Configuration is valid"
#   fi
#
# Get Configuration Value:
#   get_config_value "BACKUP_DIR"
#   Output: /var/backup/package-repo-tools
#
# Update Configuration:
#   update_config "BACKUP_DIR" "/new/backup/path"
#   Output: [ᗧ···ᗣ] Updating configuration...
#==============================================================================

source "./progress.sh"

readonly CONFIG_REQUIRED=(
  "BACKUP_DIR"
  "LOG_DIR"
  "LOG_LEVEL"
  "TIMEOUT"
  "RETRY_COUNT"
)

load_configuration() {
  local config_file="$1"
  local total_steps=3
  local current=0

  # Step 1: Check file existence
  ((current++))
  show_progress "$current" "$total_steps" "Loading configuration"
  if [[ ! -f "$config_file" ]]; then
    log_error "Configuration file not found: $config_file"
    return 1
  fi

  # Step 2: Source configuration
  ((current++))
  show_progress "$current" "$total_steps" "Reading configuration"
  source "$config_file"

  # Step 3: Validate configuration
  ((current++))
  show_progress "$current" "$total_steps" "Validating configuration"
  validate_config
}

validate_config() {
  local missing_vars=()

  start_spinner "Validating configuration"

  for var in "${CONFIG_REQUIRED[@]}"; do
    if [[ -z "${!var}" ]]; then
      missing_vars+=("$var")
    fi
  done

  stop_spinner

  if [[ ${#missing_vars[@]} -gt 0 ]]; then
    log_error "Missing required configuration: ${missing_vars[*]}"
    return 1
  fi

  log_success "Configuration validated successfully"
  return 0
}

get_config_value() {
  local key="$1"
  local default="$2"

  if [[ -n "${!key}" ]]; then
    echo "${!key}"
  else
    echo "$default"
  fi
}

update_config() {
  local key="$1"
  local value="$2"
  local config_file="${3:-/etc/package-repo-tools/config}"

  start_spinner "Updating configuration"

  if grep -q "^${key}=" "$config_file"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$config_file"
  else
    echo "${key}=${value}" >>"$config_file"
  fi

  stop_spinner
  log_success "Configuration updated: $key = $value"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

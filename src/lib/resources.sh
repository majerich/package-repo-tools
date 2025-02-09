#==============================================================================
# Library: resources.sh
# Description: System resource monitoring and management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Resource Management Library Usage
#==============================================================================
#
# Check System Resources:
#   check_system_resources
#   Output: Checking resources [####··] 66%
#
# Monitor Disk Space:
#   monitor_disk_space "/var/cache/pacman" 90
#   Output: [ᗧ···ᗣ] Monitoring disk space...
#
# Get Resource Usage:
#   get_resource_usage "memory"
#   Output: Current memory usage: 45%
#
# Check Available Space:
#   check_space_requirement "/backup" 1024
#   Output: Checking space requirement [####··] 66%
#==============================================================================

source "./progress.sh"

check_system_resources() {
  local total_checks=3
  local current=0

  # Check 1: Memory
  ((current++))
  show_progress "$current" "$total_checks" "Checking memory"
  local mem_usage=$(get_memory_usage)
  if ((mem_usage > MAX_MEMORY_USAGE)); then
    log_error "Insufficient memory available (${mem_usage}%)"
    return 1
  fi

  # Check 2: CPU
  ((current++))
  show_progress "$current" "$total_checks" "Checking CPU"
  local cpu_usage=$(get_cpu_usage)
  if ((cpu_usage > MAX_CPU_USAGE)); then
    log_error "CPU usage too high (${cpu_usage}%)"
    return 1
  fi

  # Check 3: Disk
  ((current++))
  show_progress "$current" "$total_checks" "Checking disk space"
  local disk_usage=$(get_disk_usage)
  if ((disk_usage > MAX_DISK_USAGE)); then
    log_error "Insufficient disk space (${disk_usage}%)"
    return 1
  fi

  log_success "System resources verified"
  return 0
}

monitor_disk_space() {
  local path="$1"
  local threshold="${2:-90}"

  start_spinner "Monitoring disk space"

  while true; do
    local usage=$(df -h "$path" | awk 'NR==2 {print $5}' | tr -d '%')
    if ((usage >= threshold)); then
      stop_spinner
      log_error "Disk usage exceeded threshold: ${usage}%"
      return 1
    fi
    sleep 5
  done
}

get_resource_usage() {
  local resource="$1"

  case "$resource" in
  "memory")
    get_memory_usage
    ;;
  "cpu")
    get_cpu_usage
    ;;
  "disk")
    get_disk_usage
    ;;
  *)
    log_error "Unknown resource type: $resource"
    return 1
    ;;
  esac
}

check_space_requirement() {
  local path="$1"
  local required_mb="$2"
  local total_steps=2
  local current=0

  # Step 1: Get available space
  ((current++))
  show_progress "$current" "$total_steps" "Checking available space"
  local available=$(df -m "$path" | awk 'NR==2 {print $4}')

  # Step 2: Compare with requirement
  ((current++))
  show_progress "$current" "$total_steps" "Verifying space requirement"
  if ((available < required_mb)); then
    log_error "Insufficient space: ${available}MB available, ${required_mb}MB required"
    return 1
  fi

  log_success "Space requirement satisfied"
  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

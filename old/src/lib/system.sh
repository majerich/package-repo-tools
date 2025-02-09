#==============================================================================
# Library: system.sh
# Description: System resource and configuration management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# System Operations Library Usage
#==============================================================================
#
# Check System Status:
#   check_system_status
#   Output: Checking system [####··] 66%
#
# Verify System Requirements:
#   verify_system_requirements
#   Output: [ᗧ···ᗣ] Verifying requirements...
#
# Get System Information:
#   get_system_info "cpu"
#   Output: CPU: 8 cores @ 3.6GHz
#
# Check System Load:
#   check_system_load 4.0
#   Output: Checking system load [####··] 66%
#==============================================================================

source "./progress.sh"

check_system_status() {
  local total_checks=4
  local current=0

  # Check 1: System load
  ((current++))
  show_progress "$current" "$total_checks" "Checking system load"
  local load=$(cut -d ' ' -f1 /proc/loadavg)
  if (($(echo "$load > $MAX_LOAD" | bc -l))); then
    log_error "System load too high: $load"
    return 1
  fi

  # Check 2: Available memory
  ((current++))
  show_progress "$current" "$total_checks" "Checking memory"
  local mem_free=$(free | awk '/Mem:/ {print $4}')
  if ((mem_free < MIN_MEMORY)); then
    log_error "Insufficient memory: ${mem_free}KB"
    return 1
  fi

  # Check 3: Disk space
  ((current++))
  show_progress "$current" "$total_checks" "Checking disk space"
  local space_free=$(df -k / | awk 'NR==2 {print $4}')
  if ((space_free < MIN_DISK_SPACE)); then
    log_error "Insufficient disk space: ${space_free}KB"
    return 1
  fi

  # Check 4: System services
  ((current++))
  show_progress "$current" "$total_checks" "Checking services"
  if ! systemctl is-system-running &>/dev/null; then
    log_error "System services not running normally"
    return 1
  fi

  log_success "System status verified"
  return 0
}

verify_system_requirements() {
  start_spinner "Verifying system requirements"

  local requirements=(
    "CPU cores >= 2"
    "Memory >= 2GB"
    "Disk space >= 10GB"
    "Systemd running"
  )

  for req in "${requirements[@]}"; do
    if ! check_requirement "$req"; then
      stop_spinner
      log_error "System requirement not met: $req"
      return 1
    fi
  done

  stop_spinner
  log_success "All system requirements met"
  return 0
}

get_system_info() {
  local component="$1"

  case "$component" in
  "cpu")
    echo "CPU: $(nproc) cores @ $(grep "MHz" /proc/cpuinfo | head -1 | awk '{print $4}')MHz"
    ;;
  "memory")
    echo "Memory: $(free -h | awk '/Mem:/ {print $2}') total"
    ;;
  "disk")
    echo "Disk: $(df -h / | awk 'NR==2 {print $2}') total"
    ;;
  *)
    log_error "Unknown component: $component"
    return 1
    ;;
  esac
}

check_system_load() {
  local threshold="${1:-4.0}"
  local total_checks=3
  local current=0

  for i in {1..3}; do
    ((current++))
    show_progress "$current" "$total_checks" "Checking system load"

    local load=$(cut -d ' ' -f$i /proc/loadavg)
    if (($(echo "$load > $threshold" | bc -l))); then
      log_error "Load average too high: $load (${i}min)"
      return 1
    fi
  done

  log_success "System load within acceptable range"
  return 0
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

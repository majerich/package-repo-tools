#==============================================================================
# Library: network.sh
# Description: Network connectivity and download management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Network Operations Library Usage
#==============================================================================
#
# Check Network Connection:
#   check_network_connection
#   if [[ $? -eq 0 ]]; then
#     echo "Network is available"
#   fi
#
# Download Package with Progress:
#   download_package "https://arch.org/packages/nginx.pkg.tar.zst"
#   Output: Downloading nginx [####··] 66%
#
# Check Download Speed:
#   check_download_speed
#   if [[ $? -eq 0 ]]; then
#     echo "Download speed meets requirements"
#   fi
#
# Download with Retry:
#   download_with_retry "https://example.com/file.tar.gz" "output.tar.gz"
#   Output: Downloading [ᗧ···ᗣ] Attempt 1/3
#==============================================================================

source "./progress.sh"

check_network_connection() {
  local urls=(
    "https://archlinux.org"
    "https://aur.archlinux.org"
  )

  start_spinner "Checking network connectivity"

  for url in "${urls[@]}"; do
    if ! curl --connect-timeout "$TIMEOUT" -Is "$url" >/dev/null; then
      stop_spinner
      log_error "Failed to connect to $url"
      return 1
    fi
  done

  stop_spinner
  log_success "Network connectivity verified"
  return 0
}

download_package() {
  local url="$1"
  local output="${2:-$(basename "$url")}"
  local total_size

  # Get file size
  total_size=$(curl -sI "$url" | grep -i content-length | awk '{print $2}' | tr -d '\r')

  # Download with progress
  curl -L --progress-bar "$url" -o "$output" 2>&1 |
    while read -r data; do
      if [[ $data =~ [0-9]+$ ]]; then
        show_progress "${data%.*}" "$total_size" "Downloading $(basename "$output")"
      fi
    done
}

check_download_speed() {
  local test_url="https://archlinux.org/robots.txt"
  local min_speed=$((MIN_DOWNLOAD_SPEED * 1024)) # Convert to bytes/sec

  start_spinner "Testing download speed"

  local speed=$(curl -w "%{speed_download}" -s "$test_url" -o /dev/null)

  stop_spinner

  if (($(echo "$speed < $min_speed" | bc -l))); then
    log_error "Download speed (${speed%.*} B/s) below minimum requirement ($min_speed B/s)"
    return 1
  fi

  log_success "Download speed: ${speed%.*} B/s"
  return 0
}

download_with_retry() {
  local url="$1"
  local output="$2"
  local attempt=1

  while [[ $attempt -le $RETRY_COUNT ]]; do
    show_progress "$attempt" "$RETRY_COUNT" "Downloading $(basename "$output")"

    if curl -L --connect-timeout "$TIMEOUT" -o "$output" "$url"; then
      log_success "Download completed successfully"
      return 0
    fi

    log_warn "Download attempt $attempt failed"
    ((attempt++))
    sleep 2
  done

  log_error "Download failed after $RETRY_COUNT attempts"
  return 1
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

#==============================================================================
# Library: state.sh
# Description: Process state management and persistence
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly STATE_DIR="/var/lib/package-repo-tools/state"
readonly STATE_FILE="$STATE_DIR/current_state.json"

init_state_management() {
  mkdir -p "$STATE_DIR"
  load_state
  register_state_handlers
}

save_state() {
  local timestamp=$(date -Iseconds)

  cat >"$STATE_FILE" <<EOF
{
    "timestamp": "$timestamp",
    "pid": "$$",
    "packages": {
        "processed": ${#PROCESSED_PACKAGES[@]},
        "failed": ${#FAILED_PACKAGES[@]},
        "pending": ${#PENDING_PACKAGES[@]}
    },
    "resources": {
        "cpu_usage": "$(get_cpu_usage)",
        "mem_usage": "$(get_memory_usage)",
        "disk_usage": "$(get_disk_usage)"
    }
}
EOF
}

load_state() {
  if [[ -f "$STATE_FILE" ]]; then
    local state_data=$(cat "$STATE_FILE")
    PROCESSED_PACKAGES=($(echo "$state_data" | jq -r '.packages.processed[]'))
    FAILED_PACKAGES=($(echo "$state_data" | jq -r '.packages.failed[]'))
    PENDING_PACKAGES=($(echo "$state_data" | jq -r '.packages.pending[]'))
  fi
}

register_state_handlers() {
  trap save_state EXIT TERM INT
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

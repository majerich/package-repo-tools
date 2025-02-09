#==============================================================================
# Library: migration.sh
# Description: Process migration and load balancing
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly MIGRATION_DIR="/var/lib/package-repo-tools/migration"
readonly MIGRATION_THRESHOLD=80

init_migration() {
  mkdir -p "$MIGRATION_DIR"
  check_migration_capabilities
}

check_load_balance() {
  local cpu_load=$(get_cpu_usage)
  local mem_load=$(get_memory_usage)

  if ((cpu_load > MIGRATION_THRESHOLD)) || ((mem_load > MIGRATION_THRESHOLD)); then
    trigger_migration
  fi
}

trigger_migration() {
  local target_host=$(select_target_host)
  if [[ -n "$target_host" ]]; then
    migrate_process "$target_host"
  fi
}

select_target_host() {
  local hosts_file="/etc/package-repo-tools/hosts.conf"
  [[ -f "$hosts_file" ]] || return 1

  while read -r host; do
    if check_host_availability "$host"; then
      echo "$host"
      return 0
    fi
  done <"$hosts_file"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

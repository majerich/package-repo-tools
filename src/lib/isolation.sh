#==============================================================================
# Library: isolation.sh
# Description: Process isolation and containerization
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

readonly CGROUP_NAME="package-repo-tools"
readonly NAMESPACE_PREFIX="pkgrepo"

setup_isolation() {
  create_cgroup
  setup_namespaces
  set_resource_limits
}

create_cgroup() {
  if [[ -d "/sys/fs/cgroup/unified" ]]; then
    cgcreate -g cpu,memory,io:/"$CGROUP_NAME"
    echo "$MAX_CPU_USAGE" >"/sys/fs/cgroup/$CGROUP_NAME/cpu.max"
    echo "$((MAX_MEMORY_USAGE * 1024 * 1024))" >"/sys/fs/cgroup/$CGROUP_NAME/memory.max"
  fi
}

setup_namespaces() {
  unshare --mount --uts --ipc --pid --mount-proc \
    --fork --name="$NAMESPACE_PREFIX" /bin/bash
}

set_resource_limits() {
  ulimit -n 4096                # File descriptors
  ulimit -u 2048                # Max user processes
  ulimit -m "$MAX_MEMORY_USAGE" # Max memory size
}

cleanup_isolation() {
  cgdelete -g cpu,memory,io:/"$CGROUP_NAME"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

# Function: update_mirrors
# Updates and manages repository mirrorlists for detected package repositories
# 
# Usage:
#   update_mirrors [-q] [-l]          # Update mirrors (quiet/logging optional)
#   update_mirrors -s                  # Show available backups
#   update_mirrors -r BACKUP_DATE      # Restore specific backup
#
# Options:
#   -q: Quiet mode, suppress stdout
#   -l: Enable logging to /var/log/rate-mirror.log
#   -s: Show available backups
#   -r: Restore backup from specified date

update_mirrors() {
  local -r BACKUP_PATH="/var/cache/rate-mirror"
  local -r LOG_FILE="/var/log/rate-mirror.log"
  local -r MIRROR_PATH="/etc/pacman.d"
  local -r MAX_BACKUPS=5
  local -r RFC_DATE="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  local -r HOSTNAME="${HOSTNAME:-$(hostname)}"
  local -a FOUND_REPOS=()

  # Combined shell detection and optimization
  local SHELL_TYPE
  case "${SHELL:A}" in
    *zsh)
      SHELL_TYPE="zsh"
      setopt LOCAL_OPTIONS PIPE_FAIL
      local -A opts
      zparseopts -D -A opts q l s r:
      local QUIET="${+opts[-q]}"
      local FILE_LOG="${+opts[-l]}"
      local SHOW_BACKUPS="${+opts[-s]}"
      local RESTORE_MODE="${+opts[-r]}"
      local RESTORE_DATE="${opts[-r]}"
      ;;
    *bash)
      SHELL_TYPE="bash"
      set -o pipefail
      local QUIET=0 FILE_LOG=0 SHOW_BACKUPS=0 RESTORE_MODE=0
      local RESTORE_DATE=""
      while getopts "qlsr:" opt; do
        case "${opt}" in
          q) QUIET=1 ;;
          l) FILE_LOG=1 ;;
          s) SHOW_BACKUPS=1 ;;
          r) RESTORE_MODE=1; RESTORE_DATE="${OPTARG}" ;;
        esac
      done
      ;;
    *)
      printf '%s\n' 'Unsupported shell environment. Use bash or zsh.' >&2
      return 1
      ;;
  esac

  __log() {
    local priority="${1}" message="${2}"
    logger -t "mirror-update" "${message}"
    (( FILE_LOG )) && printf '<'%s'>1 %s %s rate-mirror - - - %s\n' \
      "${priority}" "${RFC_DATE}" "${HOSTNAME}" "${message}" | \
      sudo tee -a "${LOG_FILE}" >/dev/null
  }

  __output() {
    local priority="${1}" message="${2}" symbol="${3}"
    (( ! QUIET )) && \
      printf '\033[%sm%s\033[0m %s\n' "${priority}" "${symbol}" "${message}"
    __log "${priority}" "${message}"
  }

  __msg() { __output "34" "${1}" "→"; }
  __err() { __output "31" "${1}" "✗" >&2; }

  __backup_mirrors() {
    local date_stamp="$(date +%Y%m%d_%H%M%S)"
    local backup_file="${BACKUP_PATH}/${date_stamp}.tar.gz"
    
    sudo mkdir -p "${BACKUP_PATH}"
    sudo tar czf "${backup_file}" -C "${MIRROR_PATH}" ./*mirrorlist
    
    # Maintain backup limit using shell-agnostic commands
    local old_backups
    old_backups=$(ls -t "${BACKUP_PATH}"/*.tar.gz 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)))
    [[ -n "${old_backups}" ]] && sudo rm -f ${old_backups}
  }

  __show_backups() {
    [[ ! -d "${BACKUP_PATH}" ]] && {
      __err "No backups found"
      return 1
    }
    printf '%s\n' "Available backups:"
    ls -t "${BACKUP_PATH}"/*.tar.gz 2>/dev/null | while read -r backup; do
      printf '  %s\n' "$(basename "${backup}" .tar.gz)"
    done
  }

  __restore_backup() {
    local backup_file="${BACKUP_PATH}/${1}.tar.gz"
    [[ ! -f "${backup_file}" ]] && {
      __err "Backup not found: ${1}"
      return 1
    }
    sudo tar xzf "${backup_file}" -C "${MIRROR_PATH}"
    __msg "Restored mirrors from backup: ${1}"
  }

  __detect_repos() {
    local find_cmd
    find_cmd="$(find "${MIRROR_PATH}" -type f -name "*mirrorlist" -exec basename {} \; | sed 's/-mirrorlist//')"
    FOUND_REPOS=( ${(f):-"${find_cmd}"} )
  }

  __generate_mirrors() {
    whence rate-mirrors >/dev/null || {
      __err "rate-mirrors not found"
      return 1
    }
    rate-mirrors --save="${1}" "${2}" &>/dev/null
  }

  __update_files() {
    [[ -w "${MIRROR_PATH}" ]] || {
      __err "Mirror path not writable"
      return 1
    }
    sudo mv "${MIRROR_PATH}/${1}"{,-backup} &>/dev/null &&
    sudo mv "${2}" "${MIRROR_PATH}/${1}" &>/dev/null
  }

  __cleanup() {
    [[ -f "${1}" ]] && rm -f "${1}" &>/dev/null
  }

  # Handle operation modes
  (( SHOW_BACKUPS )) && {
    __show_backups
    return $?
  }

  (( RESTORE_MODE )) && {
    [[ -z "${RESTORE_DATE}" ]] && {
      __err "Restore date required"
      return 1
    }
    __restore_backup "${RESTORE_DATE}"
    return $?
  }

  # Check for ghostmirror
  if systemctl --user is-active --quiet ghostmirror.timer; then
    printf '%s\n\n%s\n' \
      "Your mirrors are currently managed by 'ghostmirror'" \
      "No action taken."
    __log 3 "Update blocked: ghostmirror active"
    return 1
  }

  # Ensure sudo access
  sudo -v || {
    __err "Sudo access required"
    return 1
  }

  (( FILE_LOG )) && {
    sudo touch "${LOG_FILE}"
    sudo chmod 644 "${LOG_FILE}"
  }

  __detect_repos
  (( ${#FOUND_REPOS[@]} == 0 )) && {
    __err "No repository mirrorlists found"
    return 1
  }

  __log 6 "Starting mirror update process"
  __msg "Found repositories: ${(j:, :)FOUND_REPOS}"

  local success=true
  local tmp_files=()
  for repo in "${FOUND_REPOS[@]}"; do
    tmp_files+=("$(mktemp)")
    trap '__cleanup ${(j: :)tmp_files}' EXIT INT TERM
    if __generate_mirrors "${tmp_files[-1]}" "${repo}"; then
      if __update_files "${repo}-mirrorlist" "${tmp_files[-1]}"; then
        __msg "${repo^} mirrors updated"
      else
        success=false
        __err "Failed updating ${repo^} mirrors"
      fi
    else
      success=false
      __err "Failed generating ${repo^} mirrors"
    fi
  done

  ${success} && {
    __backup_mirrors
    __msg "Mirror update completed successfully"
    __log 6 "Mirror update process completed"
  }
}

# ---
#
# vim: fenc=utf-8:ts=2:sw=2:sta:et:sts=2:fdm=marker:ai:ft=sh:

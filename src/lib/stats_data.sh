#==============================================================================
# Library: stats.sh
# Description: Statistics collection and reporting functions
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

# Initialize statistics tracking
declare -A stats_data=(
  [total_packages]=0
  [aur_packages]=0
  [official_packages]=0
  [custom_repos]=0
  [dependencies]=0
  [start_time]=$(date +%s)
)

collect_stats() {
  stats_data[total_packages]=$(pacman -Q | wc -l)
  stats_data[aur_packages]=$(pacman -Qm | wc -l)
  stats_data[official_packages]=$((stats_data[total_packages] - stats_data[aur_packages]))
  stats_data[custom_repos]=$(grep "^\[.*\]" /etc/pacman.conf | grep -v "^\[options\]" | wc -l)
  stats_data[end_time]=$(date +%s)
  stats_data[elapsed_time]=$((stats_data[end_time] - stats_data[start_time]))
}

print_stats() {
  print_header "Operation Statistics"
  printf "Total packages: %d\n" "${stats_data[total_packages]}"
  printf "Official packages: %d\n" "${stats_data[official_packages]}"
  printf "AUR packages: %d\n" "${stats_data[aur_packages]}"
  printf "Custom repositories: %d\n" "${stats_data[custom_repos]}"
  printf "Dependencies resolved: %d\n" "${stats_data[dependencies]}"
  printf "Elapsed time: %d seconds\n" "${stats_data[elapsed_time]}"
}

export stats_data

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

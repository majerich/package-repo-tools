i#!/usr/bin/env bash

#==============================================================================
# Library: parallel.sh
# Description: Parallel operation management and throttling
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

init_parallel_processing() {
    export PARALLEL_JOBS=$(get_optimal_job_count)
    export PARALLEL_SEMAPHORE="/tmp/package-repo-tools.sem"
    
    # Initialize semaphore
    sem --init --jobs="$PARALLEL_JOBS"
}

get_optimal_job_count() {
    local cpu_count=$(nproc)
    local mem_jobs=$(($(free -g | awk '/^Mem:/ {print $7}') + 1))
    local network_jobs=$MAX_DOWNLOAD_JOBS
    
    echo $(( min(cpu_count, mem_jobs, network_jobs) ))
}

parallel_execute() {
    local -a commands=("$@")
    
    if [[ "$PARALLEL" = true ]]; then
        printf '%s\n' "${commands[@]}" | parallel --semaphore -j"$PARALLEL_JOBS" {}
    else
        for cmd in "${commands[@]}"; do
            eval "$cmd"
        done
    fi
}

parallel_download() {
    local -a urls=("$@")
    
    if [[ "$PARALLEL" = true ]]; then
        printf '%s\n' "${urls[@]}" | parallel --semaphore -j"$PARALLEL_JOBS" \
            "curl -L -O {}"
    else
        for url in "${urls[@]}"; do
            curl -L -O "$url"
        done
    fi
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

#==============================================================================
# Library: dependencies.sh
# Description: Package dependency resolution and management
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

#==============================================================================
# Dependencies Management Library Usage
#==============================================================================
#
# Check Package Dependencies:
#   check_dependencies "nginx"
#   Output: Checking dependencies [####··] 66%
#
# Resolve Missing Dependencies:
#   resolve_dependencies "nginx"
#   Output: [ᗧ···ᗣ] Resolving dependencies...
#
# List Package Dependencies:
#   list_dependencies "nginx"
#   Output: Dependencies for nginx:
#          - openssl
#          - pcre
#
# Check Circular Dependencies:
#   check_circular_deps "package"
#   Output: Checking circular deps [####··] 66%
#==============================================================================

source "./progress.sh"

check_dependencies() {
  local package="$1"
  local total_steps=3
  local current=0

  # Step 1: Check direct dependencies
  ((current++))
  show_progress "$current" "$total_steps" "Checking direct dependencies"
  local deps=($(pacman -Si "$package" | grep "Depends On" | cut -d: -f2- | tr -d '[[:space:]]' | tr '>' ' '))

  # Step 2: Verify dependencies
  ((current++))
  show_progress "$current" "$total_steps" "Verifying dependencies"
  local missing_deps=()
  for dep in "${deps[@]}"; do
    if ! pacman -Qi "$dep" >/dev/null 2>&1; then
      missing_deps+=("$dep")
    fi
  done

  # Step 3: Check optional dependencies
  ((current++))
  show_progress "$current" "$total_steps" "Checking optional dependencies"
  local opt_deps=($(pacman -Si "$package" | grep "Optional Deps" | cut -d: -f2-))

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_warn "Missing dependencies: ${missing_deps[*]}"
    return 1
  fi

  log_success "All dependencies satisfied"
  return 0
}

resolve_dependencies() {
  local package="$1"

  start_spinner "Resolving dependencies for $package"

  local deps=($(pacman -Si "$package" | grep "Depends On" | cut -d: -f2- | tr -d '[[:space:]]' | tr '>' ' '))
  local missing_deps=()

  for dep in "${deps[@]}"; do
    if ! pacman -Qi "$dep" >/dev/null 2>&1; then
      missing_deps+=("$dep")
    fi
  done

  stop_spinner

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    show_progress 1 2 "Installing missing dependencies"
    sudo pacman -S --needed --noconfirm "${missing_deps[@]}"
    show_progress 2 2 "Verifying installation"
  fi

  log_success "Dependencies resolved successfully"
  return 0
}

list_dependencies() {
  local package="$1"

  echo "Dependencies for $package:"

  # Direct dependencies
  echo "Direct dependencies:"
  pacman -Si "$package" | grep "Depends On" | cut -d: -f2- | tr ' ' '\n' | grep -v '^$' | sed 's/^/  - /'

  # Optional dependencies
  echo "Optional dependencies:"
  pacman -Si "$package" | grep "Optional Deps" | cut -d: -f2- | tr ' ' '\n' | grep -v '^$' | sed 's/^/  - /'
}

check_circular_deps() {
  local package="$1"
  local checked=()
  local total_steps=0
  local current=0

  function check_dep() {
    local pkg="$1"
    local depth="$2"
    local path="$3"

    ((current++))
    show_progress "$current" "$total_steps" "Checking dependencies"

    if [[ " ${checked[*]} " =~ " ${pkg} " ]]; then
      return 0
    fi

    checked+=("$pkg")
    local deps=($(pacman -Si "$pkg" 2>/dev/null | grep "Depends On" | cut -d: -f2- | tr -d '[[:space:]]' | tr '>' ' '))

    for dep in "${deps[@]}"; do
      if [[ "$path" =~ " $dep " ]]; then
        log_error "Circular dependency detected: $path -> $dep"
        return 1
      fi
      check_dep "$dep" "$((depth + 1))" "$path $dep"
    done
  }

  total_steps=$(pacman -Si "$package" | grep -c "Depends On")
  check_dep "$package" 0 "$package"
  return $?
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

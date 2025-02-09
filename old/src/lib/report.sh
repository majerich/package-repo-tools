#==============================================================================
# Library: report.sh
# Description: Package reporting with multiple format support
# Author: Richard Majewski
# License: MIT
# Version: 2.0.0
#==============================================================================

generate_report() {
  local output_file="$1"

  case "$REPORT_FORMAT" in
  "yaml")
    generate_yaml_report "$output_file"
    ;;
  "json")
    generate_json_report "$output_file"
    ;;
  "text")
    generate_text_report "$output_file"
    ;;
  esac
}

generate_yaml_report() {
  local output_file="$1"

  {
    echo "---"
    echo "timestamp: $(date -Iseconds)"
    echo "system:"
    echo "  hostname: $(hostname)"
    echo "  kernel: $(uname -r)"
    echo "packages:"

    if [[ "$INCLUDE_PACKAGE_DESCRIPTIONS" = true ]]; then
      pacman -Q | while read -r pkg ver; do
        echo "  $pkg:"
        echo "    version: $ver"
        echo "    description: $(pacman -Qi "$pkg" | grep "Description" | cut -d: -f2 | xargs)"
      done
    else
      pacman -Q | while read -r pkg ver; do
        echo "  $pkg: $ver"
      done
    fi
  } >"$output_file"
}

generate_json_report() {
  local output_file="$1"

  {
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"system\": {"
    echo "    \"hostname\": \"$(hostname)\","
    echo "    \"kernel\": \"$(uname -r)\""
    echo "  },"
    echo "  \"packages\": {"

    local first=true
    pacman -Q | while read -r pkg ver; do
      $first || echo ","
      first=false

      if [[ "$INCLUDE_PACKAGE_DESCRIPTIONS" = true ]]; then
        local desc=$(pacman -Qi "$pkg" | grep "Description" | cut -d: -f2 | xargs)
        echo "    \"$pkg\": {"
        echo "      \"version\": \"$ver\","
        echo "      \"description\": \"$desc\""
        echo "    }"
      else
        echo "    \"$pkg\": \"$ver\""
      fi
    done

    echo "  }"
    echo "}"
  } >"$output_file"
}

generate_text_report() {
  local output_file="$1"

  {
    echo "Package Report - $(date)"
    echo "System: $(hostname) - Kernel: $(uname -r)"
    echo "----------------------------------------"

    if [[ "$INCLUDE_PACKAGE_DESCRIPTIONS" = true ]]; then
      pacman -Qi | grep -E "^(Name|Version|Description)" | sed 's/^/  /'
    else
      pacman -Q | sed 's/^/  /'
    fi
  } >"$output_file"
}

# {{{ vim modeline
# vim: fenc=utf-8:ft=sh:ts=2:sw=2:sts=2:expandtab:fdm=marker:
# vim: et:ai:number:relativenumber:
# }}}

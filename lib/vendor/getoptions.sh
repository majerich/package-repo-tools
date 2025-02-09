#!/usr/bin/env bash
# shellcheck disable=SC1003,SC2016,SC2034,SC2145,SC2046,SC2086,SC2089,SC2090
# URL: https://github.com/ko1nksm/getoptions
# License: Creative Commons Zero v1.0 Universal
# Author: Koichi Nakashima

getoptions() {
  _error='' _on=1 _no='' _export='' _plus='' _mode='' _alt='' _rest='' _def=''
  _flags='' _nflags='' _opts='' _help='' _abbr='' _cmds='' _init=@empty IFS=' '
  [ $# -gt 0 ] && getoptions_parse "$@"
}

getoptions_parse() {
  eval '
    parser_definition() {
      setup   REST help:usage abbr:true -- "Usage: $2 [options...] [arguments...]"
      msg -- "" "Options:"
      flag    FLAG    -f                  -- "flag option"
      param   PARAM   -p                  -- "parameter option"
      option  OPTION  -o --option         -- "option with an argument"
      disp    :usage  -h --help
      disp    VERSION    --version        -- "display version"
    }
  '
  [ $# -gt 0 ] && eval "set -- $1"
  eval "_getoptions_${1:-parser_definition}" ${2:+"$2"}
  [ $# -le 1 ] && return 0
  shift 2
  [ "$_help" ] && _getoptions_help "$@" && return 0
  eval "set -- $@"

  OPTIND=1
  while [ $# -gt 0 ]; do
    case $1 in
    --)
      shift
      break
      ;;
    --\{no-\}*)
      _value=1
      _nflags="$_nflags ${1#--\{no-\}}"
      ;;
    --no-*)
      _value=0
      _nflags="$_nflags ${1#--no-}"
      ;;
    --*=*)
      _value="${1#*=}"
      _opts="$_opts ${1%%=*}"
      ;;
    --*)
      _value=1
      _opts="$_opts $1"
      ;;
    -[!-]?*)
      _value=1
      _flags="$_flags ${1#-}"
      ;;
    -[!-])
      _value=1
      _flags="$_flags ${1#-}"
      ;;
    *) break ;;
    esac
    shift
    eval "_getoptions_${1:-parser_definition}_set \"$_value\""
  done
  [ $# -gt 0 ] && eval "set -- $@"
  return 0
}

getoptions_help() {
  _width=30 IFS=" "
  for _opts in $_help; do
    _opt=${_opts%% *}
    _desc=${_opts#* }
    printf "  %-${_width}s %s\n" "$_opt" "$_desc"
  done
}

@empty() { :; }

@flag() {
  _flags="$_flags $1"
  _help="$_help \"$1\""
  [ "$_export" ] && eval "export $1"
}

@param() {
  _opts="$_opts $1"
  _help="$_help \"$1 $2\""
  [ "$_export" ] && eval "export $1"
}

@option() {
  _opts="$_opts $1"
  _help="$_help \"$1 $2\""
  [ "$_export" ] && eval "export $1"
}

@disp() {
  eval "_getoptions_${1}_disp() { echo \"\$$1\"; }"
}

@msg() { _help="$_help \"$*\""; }

@setup() {
  [ "$_rest" ] && eval "shift; set -- \"\${$_rest[@]}\"" 2>/dev/null || set --
}

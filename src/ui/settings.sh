#!/usr/bin/env bash
cmd_settings() {
  cfg_load
  local action=${1:-show} key=${2:-} val=${3:-}
  case "$action" in
    show|list) cfg_show;;
    set)
      [ -n "$key" ] && [ -n "$val" ] || die "usage: animated.sh settings set <key> <value>"
      cfg_set "$key" "$val"
      printf 'set %s = %s\n' "$key" "$val";;
    reset) rm -f "$CFG_FILE"; printf 'config removed\n';;
    *) die "usage: animated.sh settings [show|set <key> <value>|reset]";;
  esac
}

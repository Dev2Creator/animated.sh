#!/usr/bin/env bash
# input.sh - non-blocking single key reads

KEY_TIMEOUT=${KEY_TIMEOUT:-0.02}

read_key() {
  KEY=""
  [ "$TTY" = 1 ] || return 1
  IFS= read -rsn1 -t "$KEY_TIMEOUT" KEY 2>/dev/null || true
  [ -n "$KEY" ] || return 1
  case "$KEY" in
    "$(printf '\033')") IFS= read -rsn2 -t 0.001 KEY 2>/dev/null; KEY="ESC";;
  esac
  return 0
}

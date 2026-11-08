#!/usr/bin/env bash
# renderer.sh - shared frame loop, lifecycle, key dispatch

PAUSED=0
FRAME_INDEX=0
SPEED=${SPEED:-1}
FRAME_DELAY=${FRAME_DELAY:-}

render_setup() {
  term_init
  raw_on
  [ "$TTY" = 1 ] && alt_on
  cursor_hide
  clear_screen
  [ -z "$FRAME_DELAY" ] && FRAME_DELAY=$(frame_budget)
  [ "${ANIMATED_NO_ANIM:-0}" = 1 ] && FRAME_DELAY=0
}

render_teardown() { cleanup; }

render_frame() {
  local fn=$1
  command -v "$fn" >/dev/null 2>&1 || { warn "scene function '$fn' missing"; return 1; }
  [ "$PAUSED" = 1 ] && return 0
  "$fn" "$FRAME_INDEX"
}

handle_global_key() {
  local fn_hook=$1
  case "$KEY" in
    q|Q|ESC) return 1;;
    ' ') [ "$PAUSED" = 1 ] && PAUSED=0 || PAUSED=1;;
    h|H) if command -v show_help_overlay >/dev/null 2>&1; then show_help_overlay; fi;;
    '+'|'=') SPEED=$(awk -v s="$SPEED" 'BEGIN{printf "%.2f", s+0.25}');;
    '-'|'_') SPEED=$(awk -v s="$SPEED" 'BEGIN{ v=s-0.25; if (v<0.25) v=0.25; printf "%.2f", v }');;
    *)
      if [ -n "$fn_hook" ] && command -v "$fn_hook" >/dev/null 2>&1; then "$fn_hook" "$KEY"; fi;;
  esac
  return 0
}

run_loop() {
  local frame_fn=$1 key_fn=${2:-} limit=${ANIMATED_FRAMES:-0}
  render_setup
  while :; do
    render_frame "$frame_fn" || break
    FRAME_INDEX=$((FRAME_INDEX + 1))
    if [ "$limit" -gt 0 ] && [ "$FRAME_INDEX" -ge "$limit" ]; then break; fi
    if read_key; then
      handle_global_key "$key_fn" || break
      [ "$SPEED" != "${FRAME_DELAY_BASE:-}" ] && true
    fi
    [ "$FRAME_DELAY" != "0" ] && [ "$PAUSED" = 0 ] && pause "$FRAME_DELAY"
  done
  render_teardown
}

# print a single frame, used by --plain and by the tests
render_once() {
  local fn=$1
  term_init
  COLOR_MODE=${COLOR_MODE:-none}
  "$fn" 0
  printf '\n'
}

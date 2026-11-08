#!/usr/bin/env bash
# terminal.sh - capabilities, size, cursor control, cleanup

ESC=$'\033'
shopt -s checkwinsize 2>/dev/null || true

term_init() {
  COLS=${COLUMNS:-0}; LINES_ROWS=${LINES:-0}
  term_size
  TTY=0; [ -t 1 ] && TTY=1
  case "${TERM:-dumb}" in dumb|"") TTY=0;; esac
  if [ -n "${NO_COLOR:-}" ] || [ "${ANIMATED_NO_COLOR:-0}" = 1 ]; then
    COLOR_MODE=none
  elif [ "${COLORTERM:-}" = "truecolor" ] || [ "${COLORTERM:-}" = "24bit" ]; then
    COLOR_MODE=truecolor
  elif [ -n "${TERM:-}" ] && case "$TERM" in *256color*) true;; *) false;; esac; then
    COLOR_MODE=256
  else
    COLOR_MODE=basic
  fi
  case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *UTF-8*|*utf8*|*UTF8*) UNICODE=1;;
    *) UNICODE=0;;
  esac
  [ "${ANIMATED_ASCII:-0}" = 1 ] && UNICODE=0
  ALT=1; [ "$TTY" = 1 ] || ALT=0
}

term_size() {
  local s
  s=$(stty size 2>/dev/null) || s=""
  if [ -n "$s" ]; then
    LINES_ROWS=${s%% *}; COLS=${s##* }
  fi
  [ "${COLS:-0}" -ge 20 ] || COLS=${COLUMNS:-80}
  [ "${LINES_ROWS:-0}" -ge 8 ] || LINES_ROWS=${LINES:-24}
}

cursor_hide() { [ "$TTY" = 1 ] && printf '%s' "${ESC}[?25l"; }
cursor_show() { [ "$TTY" = 1 ] && printf '%s' "${ESC}[?25h"; }
alt_on()  { [ "$ALT" = 1 ] && printf '%s' "${ESC}[?1049h"; }
alt_off() { [ "$ALT" = 1 ] && printf '%s' "${ESC}[?1049l"; }
home()    { printf '%s' "${ESC}[H"; }
clear_screen() { printf '%s' "${ESC}[2J${ESC}[H"; }
reset_sgr() { [ "$TTY" = 1 ] && printf '%s' "${ESC}[0m"; }

raw_on() {
  [ "$TTY" = 1 ] || return 0
  STTY_SAVED=$(stty -g 2>/dev/null) || STTY_SAVED=""
  stty -echo -icanon min 0 time 0 2>/dev/null || true
}

raw_off() {
  [ -n "${STTY_SAVED:-}" ] && stty "$STTY_SAVED" 2>/dev/null || stty sane 2>/dev/null || true
}

cleanup() {
  reset_sgr; cursor_show; alt_off; raw_off
}

term_guard() {
  trap cleanup EXIT INT TERM
}

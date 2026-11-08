#!/usr/bin/env bash
# animated.sh - a little world inside your terminal
VERSION="1.0.0"
SELF_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$SELF_DIR" || exit 1

. src/core/terminal.sh
. src/core/utilities.sh
. src/core/colors.sh
. src/core/config.sh
. src/core/input.sh
. src/core/renderer.sh
. src/scenes/world.sh
. src/ui/menu.sh
. src/ui/help.sh
. src/ui/settings.sh

SPEED=""; FPS=""; SEED=""; THEME=""; TEXT=""; EFFECT=""; QUOTE_CATEGORY=""
CLOCK_FORMAT=""; SHOW_DATE=0; PIPE_COUNT=""; PIPE_STYLE=""; WEATHER=""; SEASON=""
TIMEOFDAY=""; COUNTDOWN_TO=""; PLAIN=0

take_globals() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --no-color) ANIMATED_NO_COLOR=1; COLOR_MODE=none;;
      --ascii) ANIMATED_ASCII=1;;
      --no-animation) ANIMATED_NO_ANIM=1;;
      --reduced-motion) ANIMATED_NO_ANIM=1; REDUCED_MOTION=1;;
    esac
  done
}

parse_opts() {
  while [ $# -gt 0 ]; do
    local opt="" val=""
    case "$1" in
      --*=*) opt=${1%%=*}; val=${1#*=}; shift;;
      --*)   opt=$1; shift
             if [ $# -gt 0 ]; then case "$1" in --*) ;; *) val=$1; shift;; esac; fi;;
      *)     POSITIONAL="$POSITIONAL $1"; shift; continue;;
    esac
    case "$opt" in
      --speed) SPEED=$val;;
      --fps) FPS=$val; is_uint "$val" || die "--fps wants a whole number, got '$val'";;
      --seed) SEED=$val; is_uint "$val" || die "--seed wants a whole number, got '$val'";;
      --theme) THEME=$val;;
      --effect) EFFECT=$val;;
      --category) QUOTE_CATEGORY=$val;;
      --random) QUOTE_RANDOM=1;;
      --format) CLOCK_FORMAT=$val;;
      --show-date) SHOW_DATE=1;;
      --count) PIPE_COUNT=$val; is_uint "$val" || die "--count wants a whole number";;
      --style) PIPE_STYLE=$val;;
      --weather) WEATHER=$val;;
      --season) SEASON=$val;;
      --time) TIMEOFDAY=$val;;
      --to) COUNTDOWN_TO=$val;;
      --save) FOREST_SAVE=$val;;
      --load) FOREST_LOAD=$val;;
      --list-saves) FOREST_LIST=1;;
      --plain) PLAIN=1;;
      --frames) ANIMATED_FRAMES=$val; is_uint "$val" || die "--frames wants a whole number";;
      --no-color) ANIMATED_NO_COLOR=1;;
      --ascii) ANIMATED_ASCII=1;;
      --no-animation) ANIMATED_NO_ANIM=1;;
      --reduced-motion) ANIMATED_NO_ANIM=1;;
      *) die "unknown option '$opt' (see: animated.sh help)";;
    esac
  done
}

apply_config() {
  cfg_load
  : "${SPEED:=$CFG_speed}"; : "${FPS:=$CFG_fps}"; : "${THEME:=$CFG_theme}"
  : "${WEATHER:=$CFG_weather}"; : "${SEASON:=$CFG_season}"; : "${TIMEOFDAY:=$CFG_time}"
  : "${QUOTE_CATEGORY:=$CFG_quote_category}"; : "${CLOCK_FORMAT:=$CFG_clock_format}"
  [ "${CFG_reduced_motion:-0}" = 1 ] && ANIMATED_NO_ANIM=1
  theme_palette
  term_init
}

cmd_list() {
  printf '\n  worlds\n'
  printf '    forest pipes text quote clock countdown ocean cosmos garden fireplace matrix starfield\n\n'
  printf '  text effects\n'
  printf '    typewriter rainbow gradient wave bounce marquee scramble reveal fade pulse\n'
  printf '    glow rotate slide scroll matrix star fire particle spiral\n\n'
  printf '  quote categories\n    %s\n\n' "$(ls data/quotes | sed 's/\.txt$//' | tr '\n' ' ')"
}

cmd_doctor() {
  term_init
  printf '\n  animated.sh doctor\n\n'
  printf '  bash          %s\n' "${BASH_VERSION%%(*}"
  printf '  awk           %s\n' "$(command -v awk || echo missing)"
  printf '  terminal      %s\n' "${TERM:-unknown}"
  printf '  size          %sx%s\n' "$COLS" "$LINES_ROWS"
  printf '  interactive   %s\n' "$([ "$TTY" = 1 ] && echo yes || echo no)"
  printf '  colour        %s\n' "$COLOR_MODE"
  printf '  unicode       %s\n' "$([ "$UNICODE" = 1 ] && echo yes || echo no)"
  printf '  animations    %s\n' "$([ "${ANIMATED_NO_ANIM:-0}" = 1 ] && echo off || echo on)"
  printf '  config        %s\n\n' "$CFG_FILE"
}

cmd_countdown() {
  [ -n "$COUNTDOWN_TO" ] || die 'countdown needs --to "YYYY-MM-DD HH:MM"'
  local target
  target=$(date -d "$COUNTDOWN_TO" +%s 2>/dev/null) || die "cannot read that date: '$COUNTDOWN_TO' (try 2027-01-01 00:00)"
  [ "$target" -gt "$(date +%s)" ] || die "that moment is in the past: $COUNTDOWN_TO"
  while :; do
    local now left d h m s
    now=$(date +%s); left=$((target - now)); [ "$left" -le 0 ] && { printf '\n  it is time.\n'; break; }
    d=$((left/86400)); h=$(((left%86400)/3600)); m=$(((left%3600)/60)); s=$((left%60))
    printf '\r  %d days %02d:%02d:%02d ' "$d" "$h" "$m" "$s"
    [ "${ANIMATED_PLAIN:-0}" = 1 ] && { printf '\n'; break; }
    sleep 1
  done
}

dispatch() {
  local cmd=${1:-menu}; shift || true
  if [ "${FOREST_SAVE:-}" != "" ] && [ "$cmd" = forest ]; then
    SEED=$(pick_seed); save_forest "$FOREST_SAVE"; return 0
  fi
  if [ "${PLAIN:-0}" = 1 ]; then ANIMATED_PLAIN=1; ANIMATED_FRAMES=1; fi
  case "$cmd" in
    menu|"") cmd_menu;;
    forest) cmd_forest;;
    pipes) cmd_pipes;;
    text) [ -n "$TEXT" ] || TEXT="$*"; [ -n "$TEXT" ] || die 'text needs a sentence: animated.sh text "hello"'; cmd_text;;
    quote) cmd_quote;;
    clock) cmd_clock;;
    countdown) cmd_countdown;;
    ocean|cosmos|garden|fireplace|matrix|starfield) cmd_world "$cmd";;
    list) cmd_list;;
    settings) cmd_settings "$@";;
    doctor) cmd_doctor;;
    version|--version) printf 'animated.sh %s\n' "$VERSION";;
    help|--help|-h) cmd_help;;
    *) die "unknown command '$cmd' (see: animated.sh help)";;
  esac
}

main() {
  POSITIONAL=""
  take_globals "$@"
  # first non-option word is the command; the rest are options or text
  local cmd="" rest=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --*) rest+=("$1"); shift;;
      *)
        if [ -z "$cmd" ]; then cmd=$1; else rest+=("$1"); fi
        shift;;
    esac
  done
  set -- "${rest[@]}"
  parse_opts "$@"
  apply_config
  term_guard
  dispatch "$cmd" ${POSITIONAL:-}
}

main "$@"

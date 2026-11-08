#!/usr/bin/env bash
# world.sh - one bash wrapper per world, all sharing the frame loop

awkframe() {  # awkframe <awkfile> [extra -v pairs...]
  local file=$1; shift
  awk -v w="$COLS" -v h="$LINES_ROWS" -v t="$T_FRAME" -v seed="$SEED" -v uni="$UNICODE" \
      -v weather="$WEATHER" -v time="$TIMEOFDAY" -v season="$SEASON" \
      -v mode="$MODE" -v n="$PIPE_COUNT" -v style="$PIPE_STYLE" \
      -v msg="$TEXT" -v effect="$EFFECT" -v clocktext="$CLOCK_TEXT" \
      -v datetext="$DATE_TEXT" -v showdate="${SHOW_DATE:-0}" -v block="${BLOCK_CHAR:-@}" \
      -f src/forest/grid.awk -f "$file" "$@"
}

frame_forest() { T_FRAME=$((FRAME_INDEX)); term_size; awkframe src/forest/forest.awk; }
frame_pipes()  { T_FRAME=$((FRAME_INDEX)); term_size; awkframe src/scenes/pipes.awk; }
frame_particle() { T_FRAME=$((FRAME_INDEX)); term_size; awkframe src/scenes/particles.awk; }
frame_text()   { T_FRAME=$(awk -v f="$FRAME_INDEX" 'BEGIN{printf "%.2f", f*0.12}'); term_size; awkframe src/scenes/text.awk; }

forest_keys() {
  case "$1" in
    r|R) SEED=$(( (SEED*7+13) % 99991 )); clear_screen;;
    w|W) WEATHER=$(nextof "$WEATHER" sunny rain storm fog snow);;
    t|T) TIMEOFDAY=$(nextof "$TIMEOFDAY" morning afternoon evening night);;
    s|S) SEASON=$(nextof "$SEASON" spring summer autumn winter);;
    f|F) [ "$FIREFLIES" = 1 ] && FIREFLIES=0 || FIREFLIES=1;;
  esac
  [ "${ANIMATED_NO_ANIM:-0}" = 1 ] && FRAME_DELAY=0
}

nextof() { local cur=$1; shift; local list=("$@") i found=""
  for i in "${list[@]}"; do [ -n "$found" ] && { echo "$i"; return; }; [ "$i" = "$cur" ] && found=1; done
  echo "${list[0]}"
}

SAVE_DIR() { printf '%s/saves' "$CFG_DIR"; }

save_forest() {
  local name=$1; [ -n "$name" ] || die 'forest --save needs a name'
  mkdir -p "$(SAVE_DIR)" || die "cannot write $(SAVE_DIR)"
  printf 'seed=%s\nweather=%s\nseason=%s\ntime=%s\n' "$SEED" "$WEATHER" "$SEASON" "$TIMEOFDAY" > "$(SAVE_DIR)/$name.conf"
  printf 'saved forest "%s" (seed %s)\n' "$name" "$SEED"
}

load_forest() {
  local name=$1 file; file="$(SAVE_DIR)/$name.conf"
  [ -f "$file" ] || die "no saved forest called '$name' (try: animated.sh forest --list-saves)"
  while IFS='=' read -r k v; do case "$k" in seed) SEED=$v;; weather) WEATHER=$v;; season) SEASON=$v;; time) TIMEOFDAY=$v;; esac; done < "$file"
  printf 'loaded forest "%s" (seed %s)\n' "$name" "$SEED"
}

list_saves() {
  local dir; dir=$(SAVE_DIR)
  [ -d "$dir" ] || { printf 'no saved forests yet\n'; return 0; }
  printf 'saved forests:\n'; for f in "$dir"/*.conf; do [ -e "$f" ] && printf '  %s\n' "$(basename "$f" .conf)"; done
}

cmd_forest() {
  if [ "${FOREST_LIST:-0}" = 1 ]; then list_saves; return 0; fi
  [ -n "${FOREST_LOAD:-}" ] && load_forest "$FOREST_LOAD"
  SEED=$(pick_seed); WEATHER=${WEATHER:-sunny}; TIMEOFDAY=${TIMEOFDAY:-morning}; SEASON=${SEASON:-spring}
  FIREFLIES=1
  FRAME_DELAY=$(speed_delay "$SPEED")
  run_loop frame_forest forest_keys
}

cmd_world() {  # ocean cosmos garden fireplace matrix starfield
  MODE=$1; SEED=$(pick_seed); FRAME_DELAY=$(speed_delay "$SPEED")
  run_loop frame_particle ""
}

cmd_pipes() {
  SEED=$(pick_seed); PIPE_COUNT=${PIPE_COUNT:-8}; PIPE_STYLE=${PIPE_STYLE:-classic}
  FRAME_DELAY=$(speed_delay "$SPEED")
  run_loop frame_pipes ""
}

cmd_text() {
  SEED=$(pick_seed); TEXT=${TEXT:-"animated.sh"}; EFFECT=${EFFECT:-typewriter}
  FRAME_DELAY=$(speed_delay "$SPEED")
  run_loop frame_text ""
}

clock_text_now() {
  if [ "${CLOCK_FORMAT:-24h}" = "12h" ]; then date +"%I:%M %p"; else date +"%H:%M"; fi
}
frame_clock() { term_size; CLOCK_TEXT=$1; DATE_TEXT=$2; SHOW_DATE=${SHOW_DATE:-0}; awkframe src/scenes/clock.awk; }

cmd_clock() {
  local fmt=${CLOCK_FORMAT:-24h}
  local text date_line
  if [ "${ANIMATED_FRAMES:-0}" -gt 0 ] || [ "${ANIMATED_PLAIN:-0}" = 1 ]; then
    if [ "$fmt" = 12h ]; then text=$(date +"%I:%M"); else text=$(date +"%H:%M"); fi
    date_line=$(date +"%A %d %B")
    term_init; frame_clock "$text" "$date_line"; printf '\n'; return 0
  fi
  render_setup
  while :; do
    term_size
    if [ "$fmt" = 12h ]; then text=$(date +"%I:%M"); else text=$(date +"%H:%M"); fi
    frame_clock "$text" "$(date +'%A %d %B')" >/dev/null 2>&1 || true
    term_size; awkframe src/scenes/clock.awk -v clocktext="$text" -v datetext="$(date +'%A %d %B')"
    local k=""; if read_key; then case "$k$KEY" in q|Q|ESC) break;; esac; fi
    pause 0.8
  done
  render_teardown
}

cmd_quote() {
  local cat=${QUOTE_CATEGORY:-nature}
  local file="data/quotes/$cat.txt"
  [ -f "$file" ] || die "unknown quote category '$cat' (have: $(ls data/quotes | sed 's/.txt//' | tr '\n' ' '))"
  local line text author
  if [ "${QUOTE_RANDOM:-0}" = 1 ]; then file=$(ls data/quotes/*.txt | shuf -n1 2>/dev/null || ls data/quotes/*.txt | head -1); fi
  line=$(shuf -n1 "$file" 2>/dev/null || head -1 "$file")
  text=${line%%|*}; author=${line##*|}
  if [ "${ANIMATED_FRAMES:-0}" -gt 0 ] || [ "${ANIMATED_PLAIN:-0}" = 1 ]; then
    printf '  %s\n  — %s\n' "$text" "$author"; return 0
  fi
  TEXT=$text; EFFECT=${EFFECT:-typewriter}
  cmd_text
  printf '\n  — %s\n\n' "$author"
}

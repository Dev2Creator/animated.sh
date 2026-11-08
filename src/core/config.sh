#!/usr/bin/env bash
# config.sh - tiny key=value store at ~/.config/animated.sh/config

CFG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/animated.sh
CFG_FILE=$CFG_DIR/config

cfg_defaults() {
  CFG_speed=1
  CFG_fps=24
  CFG_theme=blossom
  CFG_unicode=auto
  CFG_color=auto
  CFG_weather=sunny
  CFG_season=spring
  CFG_time=morning
  CFG_default_scene=forest
  CFG_quote_category=nature
  CFG_clock_format=24h
  CFG_density=medium
  CFG_reduced_motion=0
}

cfg_load() {
  cfg_defaults
  [ -f "$CFG_FILE" ] || return 0
  while IFS='=' read -r key val; do
    case "$key" in ''|\#*) continue;; esac
    case "$key" in
      speed|fps|theme|unicode|color|weather|season|time|default_scene|quote_category|clock_format|density|reduced_motion)
        printf -v "CFG_$key" '%s' "$val";;
    esac
  done < "$CFG_FILE"
}

cfg_save() {
  mkdir -p "$CFG_DIR" || die "cannot create $CFG_DIR"
  {
    echo "# animated.sh configuration"
    echo "speed=$CFG_speed"
    echo "fps=$CFG_fps"
    echo "theme=$CFG_theme"
    echo "unicode=$CFG_unicode"
    echo "color=$CFG_color"
    echo "weather=$CFG_weather"
    echo "season=$CFG_season"
    echo "time=$CFG_time"
    echo "default_scene=$CFG_default_scene"
    echo "quote_category=$CFG_quote_category"
    echo "clock_format=$CFG_clock_format"
    echo "density=$CFG_density"
    echo "reduced_motion=$CFG_reduced_motion"
  } > "$CFG_FILE"
}

cfg_set() {
  local key=$1 val=$2
  case "$key" in
    speed|fps|theme|unicode|color|weather|season|time|default_scene|quote_category|clock_format|density|reduced_motion)
      printf -v "CFG_$key" '%s' "$val"; cfg_save;;
    *) die "unknown setting '$key' (try: animated.sh settings list)";;
  esac
}

cfg_show() {
  printf 'config file: %s\n\n' "$CFG_FILE"
  for k in speed fps theme unicode color weather season time default_scene quote_category clock_format density reduced_motion; do
    printf '  %-16s %s\n' "$k" "$(eval printf '%s' \"\$CFG_$k\")"
  done
}

#!/usr/bin/env bash
# utilities.sh - small helpers shared by every scene

die() { printf 'animated.sh: %s\n' "$*" >&2; exit 2; }
warn() { printf 'animated.sh: %s\n' "$*" >&2; }

is_uint() { case "${1:-}" in ''|*[!0-9]*) return 1;; *) return 0;; esac; }

need_cmd() { command -v "$1" >/dev/null 2>&1; }

clamp() {
  local v=$1 lo=$2 hi=$3
  [ "$v" -lt "$lo" ] && v=$lo
  [ "$v" -gt "$hi" ] && v=$hi
  printf '%s' "$v"
}

pick_seed() {
  if [ -n "${SEED:-}" ]; then
    is_uint "$SEED" || die "--seed wants a whole number, got '$SEED'"
    printf '%s' "$SEED"
  else
    printf '%s' "$(( $(date +%s) % 100000 ))"
  fi
}

now_epoch() { date +%s; }

# sleep that accepts fractions on GNU sleep and BSD sleep alike
pause() {
  local d=$1
  if [ "${ANIMATED_NO_ANIM:-0}" = 1 ]; then return 0; fi
  sleep "$d" 2>/dev/null || sleep 1
}

speed_delay() {
  local speed=${1:-1}
  awk -v s="$speed" 'BEGIN{ d = 0.09 / (s <= 0 ? 1 : s); if (d < 0.012) d = 0.012; printf "%.3f", d }'
}

frame_budget() {
  local fps=${FPS:-24}
  is_uint "$fps" || fps=24
  [ "$fps" -lt 4 ] && fps=4
  [ "$fps" -gt 60 ] && fps=60
  awk -v f="$fps" 'BEGIN{ printf "%.3f", 1/f }'
}

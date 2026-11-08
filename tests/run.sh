#!/usr/bin/env bash
# tests/run.sh - the whole suite, no framework required
set -u
cd "$(dirname "$0")/.." || exit 1
PASS=0; FAIL=0; FAILED=()

ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); FAILED+=("$1"); printf '  FAIL %s\n' "$1"; }
check(){ local name=$1; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else bad "$name"; fi; }

export ANIMATED_ASCII=1 ANIMATED_NO_ANIM=1 ANIMATED_FRAMES=1
export XDG_CONFIG_HOME=$(mktemp -d)

printf '\ncli\n'
check "version prints a number"      bash -c './animated.sh version | grep -q "[0-9]\.[0-9]"'
check "help mentions forest"         bash -c './animated.sh help | grep -q forest'
check "list mentions effects"        bash -c './animated.sh list | grep -q rainbow'
check "unknown command is refused"   bash -c '! ./animated.sh nonsense 2>/dev/null'
check "unknown option is refused"    bash -c '! ./animated.sh forest --bogus 2>/dev/null'
check "bad seed is refused"          bash -c '! ./animated.sh forest --seed abc 2>/dev/null'
check "bad fps is refused"           bash -c '! ./animated.sh forest --fps 1.5 2>/dev/null'

printf '\nconfig\n'
check "settings set writes a value"  bash -c './animated.sh settings set theme ocean >/dev/null && grep -q "theme=ocean" "$XDG_CONFIG_HOME/animated.sh/config"'
check "settings list shows it"       bash -c './animated.sh settings list | grep -q ocean'
check "unknown setting is refused"   bash -c '! ./animated.sh settings set nope 1 2>/dev/null'

printf '\nscenes\n'
for s in forest pipes ocean cosmos garden fireplace matrix starfield; do
  check "$s renders a frame" bash -c "./animated.sh $s --frames 1 >/tmp/an_$s.out 2>/dev/null && [ -s /tmp/an_$s.out ]"
done
check "text typewriter renders"      bash -c './animated.sh text "hello" --effect typewriter --frames 1 >/dev/null'
check "text rainbow renders"         bash -c './animated.sh text "hello" --effect rainbow --frames 1 >/dev/null'
check "clock renders"                bash -c './animated.sh clock --format 24h >/dev/null'
check "quote renders"                bash -c './animated.sh quote --category nature | grep -q "—"'
check "quote unknown category fails" bash -c '! ./animated.sh quote --category nowhere 2>/dev/null'

printf '\nforest determinism and validation\n'
bash -c './animated.sh forest --seed 2026 --frames 1 > /tmp/an_a.out'
bash -c './animated.sh forest --seed 2026 --frames 1 > /tmp/an_b.out'
if cmp -s /tmp/an_a.out /tmp/an_b.out; then ok "same seed gives the same forest"; else bad "same seed gives the same forest"; fi
bash -c './animated.sh forest --seed 999 --frames 1 > /tmp/an_c.out'
check "different seed differs" bash -c '! cmp -s /tmp/an_a.out /tmp/an_c.out'
check "countdown rejects past"     bash -c '! ./animated.sh countdown --to "2000-01-01 00:00" 2>/dev/null'
check "countdown rejects nonsense" bash -c '! ./animated.sh countdown --to "not-a-date" 2>/dev/null'
check "doctor runs"                bash -c './animated.sh doctor | grep -q colour'

printf '\nsize and independence\n'
kb=$(du -sk --exclude=.git . 2>/dev/null | cut -f1)
if [ "${kb:-9999}" -lt 5000 ]; then ok "source stays under 5 MB (${kb} KB)"; else bad "source stays under 5 MB (${kb} KB)"; fi
check "no python or node requirement" bash -c '! grep -rqE "python3? |node " --include="*.sh" src animated.sh'

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] || { printf 'failed: %s\n' "${FAILED[*]}"; exit 1; }

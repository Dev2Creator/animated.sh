#!/usr/bin/env bash
set -eu
PREFIX=${1:-$HOME/.local}
rm -f "$PREFIX/bin/animated.sh"
printf 'removed %s/bin/animated.sh\n' "$PREFIX"

#!/usr/bin/env bash
set -eu
PREFIX=${1:-$HOME/.local}
HERE=$(cd -- "$(dirname -- "$0")" && pwd)
DEST="$PREFIX/bin/animated.sh"
mkdir -p "$PREFIX/bin"
printf '#!/usr/bin/env bash\nexec "%s/animated.sh" "$@"\n' "$HERE" > "$DEST"
chmod +x "$DEST"
printf 'installed: %s -> %s/animated.sh\n' "$DEST" "$HERE"
printf 'make sure %s is on your PATH\n' "$PREFIX/bin"

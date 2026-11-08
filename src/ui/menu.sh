#!/usr/bin/env bash
# menu.sh - interactive launcher with a still fallback

menu_items() {
  cat <<'TXT'
1|forest|Forest|a procedural woodland with weather and seasons
2|pipes|Pipes|wandering pipes that turn corners forever
3|text|Text Studio|nineteen ways to set a sentence in motion
4|quote|Quote Studio|small lines, gently delivered
5|clock|Clock|time, set in blocks
6|ocean|Ocean|waves, bubbles and slow fish
7|cosmos|Cosmos|stars, planets and a little drifting dust
8|garden|Zen Garden|ripples, petals and quiet
9|fireplace|Fireplace|warm flickering shapes
0|matrix|Matrix|falling characters, calm speed
TXT
}

menu_still() {
  printf '\n' 
  printf '      ✦ animated.sh ✦\n'
  printf '   A little world inside your terminal\n\n'
  while IFS='|' read -r key id name desc; do
    printf '   [%s] %-12s %s\n' "$key" "$name" "$desc"
  done < <(menu_items)
  printf '\n   [s] settings   [d] doctor   [h] help   [q] quit\n\n'
  printf 'Select a world to explore... '
}

menu_interactive() {
  local pick
  while :; do
    clear_screen
    printf '\n'
    printf '        %s\n' "$(printf '%s' "✦ animated.sh ✦")"
    printf '     %s\n\n' "A little world inside your terminal"
    while IFS='|' read -r key id name desc; do
      printf '   [%s] %-12s %s\n' "$key" "$name" "$desc"
    done < <(menu_items)
    printf '\n   [s] settings   [h] help   [q] quit\n'
    printf '\n   Select a world to explore... '
    read -r pick || return 0
    case "$pick" in
      q|Q) return 0;;
      s|S) cmd_settings;;
      h|H) cmd_help; read -r _ || true;;
      1) cmd_forest;;
      2) cmd_pipes;;
      3) cmd_text;;
      4) cmd_quote;;
      5) cmd_clock;;
      6) cmd_world ocean;;
      7) cmd_world cosmos;;
      8) cmd_world garden;;
      9) cmd_world fireplace;;
      0) cmd_world matrix;;
      m|M) cmd_world matrix;;
      *) printf '\n   not a world yet. try 1-9 or 0\n'; sleep 1;;
    esac
  done
}

cmd_menu() {
  if [ "$TTY" = 1 ]; then menu_interactive; else menu_still; printf '\n'; fi
}

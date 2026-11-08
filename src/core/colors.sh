#!/usr/bin/env bash
# colors.sh - truecolor, 256, 16 colour and monochrome palettes

# rgb <r> <g> <b> -> sequence that prints a foreground colour
rgb() {
  local r=$1 g=$2 b=$3
  case "${COLOR_MODE:-basic}" in
    truecolor) printf '%s[38;2;%d;%d;%dm' "$ESC" "$r" "$g" "$b";;
    256)
      local n
      n=$(awk -v r="$r" -v g="$g" -v b="$b" 'BEGIN{
        if (r==g && g==b) { if (r<8) print 16; else if (r>248) print 231; else printf "%d", 232+int((r-8)/10) }
        else printf "%d", 16 + 36*int(r/51) + 6*int(g/51) + int(b/51) }')
      printf '%s[38;5;%sm' "$ESC" "$n";;
    basic) printf '%s[38;5;%sm' "$ESC" "$4";;
    *) printf '';;
  esac
}

theme_palette() {
  THEME=${THEME:-blossom}
  case "$THEME" in
    blossom)  SKY1="255 236 242"; SKY2="247 220 232"; ACCENT="201 143 162"; LEAF="146 186 150"; DIM="150 130 140";;
    forest)   SKY1="226 240 226"; SKY2="203 226 210"; ACCENT="106 153 118"; LEAF="74 130 92";  DIM="104 122 106";;
    autumn)   SKY1="253 235 214"; SKY2="246 214 184"; ACCENT="196 120 74";  LEAF="183 122 62";  DIM="140 112 92";;
    midnight) SKY1="26 26 46";    SKY2="38 34 62";    ACCENT="139 124 216"; LEAF="92 96 140";  DIM="96 96 128";;
    ocean)    SKY1="214 238 248"; SKY2="188 224 240"; ACCENT="58 138 176";  LEAF="74 150 160"; DIM="92 130 150";;
    pastel)   SKY1="250 244 255"; SKY2="240 232 250"; ACCENT="168 150 208"; LEAF="160 200 190"; DIM="150 140 160";;
    mono)     SKY1="238 238 238"; SKY2="214 214 214"; ACCENT="120 120 120"; LEAF="90 90 90";    DIM="140 140 140";;
    classic)  SKY1="0 0 0";       SKY2="0 0 0";       ACCENT="250 250 250"; LEAF="200 200 200"; DIM="120 120 120";;
    rainbow)  SKY1="250 240 250"; SKY2="240 240 250"; ACCENT="200 120 200"; LEAF="120 200 160"; DIM="160 140 160";;
    *)        SKY1="255 236 242"; SKY2="247 220 232"; ACCENT="201 143 162"; LEAF="146 186 150"; DIM="150 130 140";;
  esac
}

sgr0() { printf '%s[0m' "$ESC"; }

```
        ✦  a n i m a t e d . s h  ✦
        a little world inside your terminal
```

Procedural terminal animation engine in Bash + awk. No Python, no Node, no model
weights, no network. Forty-nine kilobytes of source, twelve worlds.

```bash
./animated.sh            # the menu
./animated.sh forest     # the flagship
```

## The worlds

| World | What it does |
| --- | --- |
| `forest` | multi-layer woodland: mountains, tree lines, ground cover, weather, seasons, day cycle |
| `pipes` | wandering pipes with corners, three glyph styles, a vine-like garden variant |
| `text` | nineteen typography effects for any sentence |
| `quote` | quote studio with six local collections |
| `clock` | block clock, 12h or 24h, optional date |
| `countdown` | counts to a moment you name |
| `ocean` | waves, bubbles, fish, coral |
| `cosmos` | stars, planet, drifting dust |
| `garden` | ripples, stones, falling petals |
| `fireplace` | flickering flames and sparks |
| `matrix` | falling characters |
| `starfield` | depth-scrolling stars |

## The forest

Three visual layers (distant mountains, mid tree line, foreground ground) with
tree types that are actually distinguishable: pine, oak, birch, willow,
blossom, autumn and deadwood. Weather, season and time of day are independent
axes, so `--weather snow --season winter --time night` is a real snowy night.

```

## Install

Needs bash and awk. That is the whole list.

```bash
git clone https://github.com/Dev2Creator/animated.sh
cd animated.sh
chmod +x animated.sh
./animated.sh
```

Or put it on your PATH:

```bash
make install          # symlinks into ~/.local/bin
make uninstall
```

### Termux (Android)

```bash
pkg update
pkg install git bash coreutils gawk
git clone https://github.com/Dev2Creator/animated.sh
cd animated.sh
chmod +x animated.sh
./animated.sh
```

Notes for phones: the on-screen keyboard often has no Escape key, so use `q` to
leave a scene and `h` for help. If the box-drawing glyphs look wrong in your font,
start with `--ascii`. `mawk` works too if you prefer it over `gawk`.

Created with Bash 5 and GNU awk, verified against mawk as well.
bash
./animated.sh forest --weather rain
./animated.sh forest --weather storm --time night
./animated.sh forest --season autumn --time evening --theme autumn
./animated.sh forest --seed 2026 --save "my forest"
./animated.sh forest --load "my forest"
./animated.sh forest --list-saves
```

Keys inside a world: `space` pause, `q` quit, `+`/`-` speed, and in the forest
`r` regenerate, `w` weather, `t` time, `s` season.

## Text studio

```bash
./animated.sh text "Hello World" --effect rainbow
./animated.sh text "Dream Big" --effect marquee
```

Effects: typewriter, rainbow, gradient, wave, bounce, marquee, scramble, reveal,
fade, pulse, glow, rotate, slide, scroll, matrix, star, fire, particle, spiral.

## Options and themes

`--speed --fps --seed --theme --no-color --ascii --no-animation --reduced-motion
--plain --frames`, plus per-world flags. Unknown options are refused with a
message rather than ignored.

Themes: blossom, forest, autumn, midnight, ocean, pastel, mono, classic,
rainbow. Settings live in `~/.config/animated.sh/config`:

```bash
./animated.sh settings set theme ocean
./animated.sh settings list
```

## How it is built

```
animated.sh          entry: parsing, dispatch, validation
src/core/            terminal, colours, config, input, renderer, timing
src/scenes/          awk frame programs + the bash wrappers that drive them
src/forest/          grid helpers and the forest frame program
src/ui/              menu, help, settings
data/quotes/         plain text collections, one line per quote
tests/run.sh         the whole suite
```

Frames are drawn into a character grid and emitted with a single cursor-home
plus colour changes only where the colour differs, so a forest frame costs about
7 KB of output instead of a full repaint. Timing is capped by `--fps` (4-60,
default 24) and `--speed`.

## Honest status

Working: every world above, weather, seasons, time of day, saves, config,
themes, ASCII and monochrome fallbacks, `--plain` single frames, doctor.

Not implemented, and not claimed: content search, plugin system, sound, image
export, inotify-based regeneration, per-frame GPU tricks.

## Tests

```bash
make test        # or: ./tests/run.sh
```

Thirty checks: CLI refusal behaviour, config round trip, every world rendering a
frame, text effects, clock, quotes, forest determinism for a fixed seed,
countdown validation, source size, and a check that no Python or Node runtime is
required.

## Requirements

Bash 4+, awk, coreutils. Linux first; macOS mostly works; Termux works with
`--ascii`. Colour degrades from truecolor to 256 to 16 to none automatically,
and `NO_COLOR` is respected.

MIT licensed. Built by Dev2Creator.

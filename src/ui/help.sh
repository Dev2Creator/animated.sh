#!/usr/bin/env bash
cmd_help() {
  cat <<'TXT'

  animated.sh — a little world inside your terminal

  USAGE
    animated.sh                      open the menu
    animated.sh <world> [options]    start a world directly
    animated.sh list                 list worlds and effects
    animated.sh settings [list|set]  read or change defaults
    animated.sh doctor               check the terminal environment
    animated.sh version | --version

  WORLDS
    forest     procedural woodland (weather, seasons, time of day)
    pipes      wandering pipe field            (--count --style)
    text       typography studio                (--effect)
    quote      quote studio                     (--category | --random)
    clock      clock                            (--format 12h|24h --show-date)
    countdown  countdown to a moment            (--to "YYYY-MM-DD HH:MM")
    ocean cosmos garden fireplace matrix starfield

  GLOBAL OPTIONS
    --speed N      animation speed, 0.25 or more
    --fps N        frames per second, 4 to 60
    --seed N       same seed, same world
    --theme NAME   blossom forest autumn midnight ocean pastel mono classic rainbow
    --no-color     plain text
    --ascii        ascii only glyphs
    --no-animation disable motion, keep layout
    --reduced-motion  calmer motion and no flashes
    --plain        print one frame and exit
    --frames N     render N frames then exit (used by the tests)

  KEYS INSIDE A WORLD
    space pause   q quit   h help   + / - speed
    forest: r regenerate  w weather  t time  s season  f fireflies

TXT
}

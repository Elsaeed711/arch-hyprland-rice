#!/bin/bash
# Start waybar exactly ONCE, race-proof across config reloads (flock on FD 9 is
# held for waybar's lifetime, so concurrent/later launchers bail instead of
# starting a second bar). Deliberately does NOT touch theme/wallpaper — those are
# applied separately so a wallpaper hiccup can never prevent the bar from starting.
{
  flock -n 9 || exit 0
  pgrep -x waybar >/dev/null && exit 0
  exec waybar
} 9>/tmp/hypr-waybar.lock

#!/bin/bash
# Apply the meowrch theme + wallpaper at startup, robustly.
# The old boot chain `set-current-theme && set-wallpaper && waybar` broke if
# set-wallpaper ran before swww-daemon's socket was ready: the && short-circuited,
# leaving a BLACK background AND no waybar. This waits for swww first, is fully
# independent of the waybar launch, and skips itself once a wallpaper is up (so
# it only really runs at boot, not on every config reload).
{
  flock -n 9 || exit 0

  # already showing a wallpaper image? -> nothing to do (this is a reload, not boot)
  swww query 2>/dev/null | grep -q "image:" && exit 0

  # ensure swww-daemon is up, then wait up to ~10s for its socket
  pgrep -x swww-daemon >/dev/null || { swww-daemon >/dev/null 2>&1 & }
  for _ in $(seq 1 50); do
    swww query >/dev/null 2>&1 && break
    sleep 0.2
  done

  # apply theme (also SIGUSR2-reloads waybar with fresh colors) then wallpaper
  python "$HOME/.config/meowrch/meowrch.py" --action set-current-theme
  python "$HOME/.config/meowrch/meowrch.py" --action set-wallpaper
} 9>/tmp/hypr-theme-wallpaper.lock

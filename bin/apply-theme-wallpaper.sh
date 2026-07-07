#!/bin/bash
# Apply the meowrch theme + wallpaper at startup, robustly.
#
# Root cause of the recurring BLACK background: at Hyprland config-parse time
# WAYLAND_DISPLAY isn't exported yet, so swww falls back to "wayland-0" (the
# wrong display) and the wallpaper never appears on the real output (wayland-1).
# Fix: derive the REAL WAYLAND_DISPLAY, make sure swww-daemon runs on it, then
# (re)apply the wallpaper until an image is actually being shown.
{
  flock -n 9 || exit 0

  # 1) pin the real WAYLAND_DISPLAY (never let swww default to wayland-0)
  if [ -z "${WAYLAND_DISPLAY:-}" ] || ! swww query >/dev/null 2>&1; then
    for _ in $(seq 1 50); do
      wd=$(ls -1 "$XDG_RUNTIME_DIR" 2>/dev/null | grep -E '^wayland-[0-9]+$' | head -1)
      [ -n "$wd" ] && { WAYLAND_DISPLAY="$wd"; break; }
      sleep 0.2
    done
  fi
  export WAYLAND_DISPLAY

  # already showing a wallpaper image? (this is a reload, not boot) -> done
  swww query 2>/dev/null | grep -q "image:" && exit 0

  # 2) ensure a swww-daemon that actually answers on THIS display
  if ! swww query >/dev/null 2>&1; then
    pkill -x swww-daemon 2>/dev/null; sleep 0.3
    swww-daemon >/dev/null 2>&1 &
    for _ in $(seq 1 60); do swww query >/dev/null 2>&1 && break; sleep 0.25; done
  fi

  # 3) apply theme once, then (re)apply the wallpaper until it's really shown
  python "$HOME/.config/meowrch/meowrch.py" --action set-current-theme >/dev/null 2>&1
  for _ in $(seq 1 12); do
    python "$HOME/.config/meowrch/meowrch.py" --action set-wallpaper >/dev/null 2>&1
    swww query 2>/dev/null | grep -q "image:" && break
    sleep 1
  done
} 9>/tmp/hypr-theme-wallpaper.lock

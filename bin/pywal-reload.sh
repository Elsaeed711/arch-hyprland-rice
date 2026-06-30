#!/bin/bash
# Regenerate pywal colors from the current meowrch wallpaper, then live-reload waybar.
# Wired to run automatically via the meowrch-pywal.path systemd user unit.

WALL="$(readlink -f "$HOME/.config/meowrch/current_wallpaper")"
[ -f "$WALL" ] || exit 0
command -v wal >/dev/null 2>&1 || exit 0

# -n: don't set wallpaper (swww/meowrch owns that)  -q: quiet  -e: don't reload other apps
wal -i "$WALL" -n -q -e

# Sync cava gradient to the new colors (cava live-config reloads it automatically)
[ -f "$HOME/.cache/wal/cava" ] && cp "$HOME/.cache/wal/cava" "$HOME/.config/cava/config"

# Sync the rofi wallpaper/theme picker colors to the new palette
[ -f "$HOME/.cache/wal/colors-rofi-theme.rasi" ] && cp "$HOME/.cache/wal/colors-rofi-theme.rasi" "$HOME/.config/rofi/theme.rasi"

# Live-reload waybar so it picks up ~/.cache/wal/colors-waybar.css
# Live-recolor running kitty terminals (so ANSI animations: pipes, asciiquarium, etc. follow)
kitty @ --to unix:/tmp/mykitty set-colors --all ~/.cache/wal/colors-kitty.conf 2>/dev/null || true

pkill -SIGUSR2 waybar 2>/dev/null || true

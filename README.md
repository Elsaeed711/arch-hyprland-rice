# 🌌 Hyprland Dotfiles

My Arch + Hyprland rice — a wallpaper-driven (pywal) setup, integrated with the meowrch theme engine.

## Components
- **Hyprland** — window manager (`.config/hypr/`)
- **Waybar** — bar with custom adaptive modules (volume follows buds, scrolling now-playing, brightness, gpu, battery, network…)
- **wofi** — app launcher · **rofi** — image-grid wallpaper/theme picker
- **hyprlock** — lock · **wlogout** — power menu · **swaync** — notifications
- **kitty** · **cava** · **fastfetch** · **btop**

## Theming (pywal: wallpaper → colors)
Changing the wallpaper regenerates the palette with `wal`; `bin/pywal-reload.sh` (fired by a systemd path unit) pushes the new colors to waybar, cava, kitty, the rofi picker, and `lavat`, so the whole system recolors with the background.

## Fun scripts (`bin/`)
- `dvd-bounce.py` — DVD-logo bouncing-windows screensaver (toggle: Super+Shift+D)
- `lavat` — adaptive lava-lamp wrapper (vivid pywal colors, live re-skin)
- `wb-*.sh` — the waybar module scripts

## Dependencies
hyprland hyprlock hypridle waybar wofi rofi swaync kitty cava fastfetch btop wlogout
pywal16 swww brightnessctl playerctl wpctl nmcli blueman + **[meowrch](https://github.com/meowrch/meowrch)** (wallpaper/theme engine, cloned separately).

## Notes
- Paths are hardcoded for user `Void` — adjust if you clone.
- The lock screen profile pic and wallpapers aren't included (personal/large) — drop your own in.

#!/bin/bash
# Boot-time xdg-desktop-portal init for screencast (Discord screenshare / OBS
# screen capture). It must run in the RIGHT order: sync the Wayland env to the
# systemd/dbus activation environment FIRST, then (re)start the portals so
# xdg-desktop-portal-hyprland comes up with a valid WAYLAND_DISPLAY.
#
# Guarded so it only runs at boot (when the hyprland portal isn't up yet) — NOT on
# every config reload, which would kill an in-progress screenshare.

# NOTE: pgrep -x fails here (process name >15 chars); match the full path instead.
pgrep -f "/xdg-desktop-portal-hyprland" >/dev/null && exit 0

# WAYLAND_DISPLAY may not be exported yet when hyprland.lua fires this — derive it
# from the wayland socket in the runtime dir.
if [ -z "$WAYLAND_DISPLAY" ]; then
  for _ in $(seq 1 30); do
    WAYLAND_DISPLAY=$(ls -1 "$XDG_RUNTIME_DIR"/wayland-* 2>/dev/null | grep -v '\.lock' | head -1 | xargs -r -n1 basename)
    [ -n "$WAYLAND_DISPLAY" ] && break
    sleep 0.2
  done
fi
export WAYLAND_DISPLAY

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
dbus-update-activation-environment --systemd --all
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE

exec "$HOME/bin/resetxdgportal.sh"

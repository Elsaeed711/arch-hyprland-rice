#!/bin/bash
# Load the scrolloverview hyprpm plugin and apply its settings.
# Called once at startup from hyprland.lua (the plugin loads async, and in Lua
# config mode `hyprctl keyword` can't set plugin config — must use hl.config via
# `hyprctl dispatch`, which evaluates Lua).

sleep 1
hyprpm reload >/dev/null 2>&1

# wait until the plugin is actually loaded (up to ~9s)
for _ in $(seq 1 30); do
    hyprctl plugins list 2>/dev/null | grep -qi scrolloverview && break
    sleep 0.3
done

# apply plugin config (numbers/bools/hex only -> no quoting headaches; strings ok too)
hyprctl dispatch 'hl.config({plugin={scrolloverview={gesture_distance=300,scale=0.65,workspace_gap=100,layout="vertical",wallpaper=0,blur=true,shadow={enabled=true,range=50,render_power=3,color=0xee1a1a1a}}}})' >/dev/null 2>&1

# trackpad gestures are a plugin keyword; try to set them (may be unsupported in Lua mode)
hyprctl dispatch 'hl.config({["scrolloverview-gesture"]="3, up, overview"})' >/dev/null 2>&1 || true
hyprctl dispatch 'hl.config({["scrolloverview-gesture"]="4, up, overview, mod:SUPER, scale:1.5"})' >/dev/null 2>&1 || true

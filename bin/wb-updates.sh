#!/bin/bash
# Waybar pending pacman updates counter (official repos via checkupdates).
PKG=$(printf '')
c=$(checkupdates 2>/dev/null | grep -c .)
echo "$PKG $c"

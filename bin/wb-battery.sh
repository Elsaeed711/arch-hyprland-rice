#!/bin/bash
# Waybar laptop battery (JSON): battery-shaped icon + % , bolt added while charging.
BAT=/sys/class/power_supply/BAT0
[ -d "$BAT" ] || exit 0
cap=$(cat "$BAT/capacity" 2>/dev/null)
stat=$(cat "$BAT/status" 2>/dev/null)
[ -z "$cap" ] && exit 0

# battery-shaped level icon (Font Awesome battery glyphs)
if   [ "$cap" -ge 90 ]; then icon=$(printf '')   # full
elif [ "$cap" -ge 65 ]; then icon=$(printf '')   # 3/4
elif [ "$cap" -ge 40 ]; then icon=$(printf '')   # 1/2
elif [ "$cap" -ge 15 ]; then icon=$(printf '')   # 1/4
else                          icon=$(printf '')   # empty
fi

cls="normal"
charge=""
if [ "$stat" = "Charging" ] || [ "$stat" = "Full" ]; then
    cls="charging"
    charge=" $(printf '')"          # bolt suffix = charging/plugged
elif [ "$cap" -le 15 ]; then cls="critical"
elif [ "$cap" -le 30 ]; then cls="warning"
fi

printf '{"text": "%s %s%%%s", "percentage": %s, "class": "%s", "tooltip": "Battery: %s%% (%s)"}\n' \
    "$icon" "$cap" "$charge" "$cap" "$cls" "$cap" "$stat"

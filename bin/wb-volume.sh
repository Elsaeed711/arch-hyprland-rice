#!/bin/bash
# Adaptive volume: headphone when output is bluetooth (buds), speaker levels otherwise.
sink=$(pactl get-default-sink 2>/dev/null)
raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
vol=$(echo "$raw" | grep -oP '[0-9]+\.[0-9]+' | head -1 | awk '{printf "%d", $1*100}')
buds=$(printf ''); mute=$(printf '')
hi=$(printf ''); lo=$(printf ''); off=$(printf '')
if echo "$raw" | grep -q MUTED; then icon="$mute"
elif echo "$sink" | grep -qi bluez; then icon="$buds"
elif [ "${vol:-0}" -ge 50 ]; then icon="$hi"
elif [ "${vol:-0}" -gt 0 ]; then icon="$lo"
else icon="$off"; fi
echo "$icon ${vol:-0}%"

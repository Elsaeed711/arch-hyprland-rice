#!/bin/bash
# Waybar microphone (JSON): icon reflects mute state. Click toggles mute.
on=$(printf '')    # microphone
off=$(printf '')   # microphone-slash

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
    printf '{"text": "%s", "class": "muted", "tooltip": "Microphone muted"}\n' "$off"
else
    printf '{"text": "%s", "class": "active", "tooltip": "Microphone on"}\n' "$on"
fi

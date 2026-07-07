#!/bin/bash
# Waybar microphone (JSON): adaptive icon for bluetooth buds vs laptop mic,
# reflects mute state of whatever the active default source is. Click toggles mute.
mic_on=$(printf '')    # microphone (laptop)
mic_off=$(printf '')   # microphone-slash (muted)
buds_on=$(printf '\uf590')   # headset mic (bluetooth buds)

src=$(pactl get-default-source 2>/dev/null)

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
    printf '{"text": "%s", "class": "muted", "tooltip": "Microphone muted"}\n' "$mic_off"
elif echo "$src" | grep -qiE 'bluez|bluetooth'; then
    printf '{"text": "%s", "class": "active", "tooltip": "Buds microphone on"}\n' "$buds_on"
else
    printf '{"text": "%s", "class": "active", "tooltip": "Laptop microphone on"}\n' "$mic_on"
fi

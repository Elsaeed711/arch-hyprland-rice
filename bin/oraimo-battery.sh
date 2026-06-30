#!/bin/bash
# Oraimo SpaceBuds Neo+ status/battery for waybar (Bluetooth).
# Battery % only shows if BlueZ "Experimental = true" exposes it; otherwise shows connected icon.
MAC="08:E4:DF:27:17:EE"
ICON=$(printf '')   # headphones

info=$(bluetoothctl info "$MAC" 2>/dev/null)
if ! echo "$info" | grep -q "Connected: yes"; then
    echo '{"text": "", "tooltip": "Oraimo SpaceBuds Neo+: disconnected"}'
    exit 0
fi

batt=$(echo "$info" | grep -oP 'Battery Percentage:.*\(\K[0-9]+')
if [ -n "$batt" ]; then
    echo "{\"text\": \"$ICON $batt%\", \"percentage\": $batt, \"tooltip\": \"Oraimo SpaceBuds Neo+ — $batt%\"}"
else
    echo "{\"text\": \"$ICON\", \"tooltip\": \"Oraimo SpaceBuds Neo+ — connected\"}"
fi

#!/bin/bash
# Waybar Wi-Fi/network indicator. Click -> rofi network manager.
WIFI=$(printf '')
WIRED=$(printf '')

essid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
if [ -n "$essid" ]; then
    echo "$WIFI $essid"
elif nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -q '^ethernet:connected'; then
    echo "$WIRED wired"
else
    echo "$WIFI off"
fi

#!/bin/bash
p=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')
icon=$(printf '')   # sun
echo "$icon ${p:-?}%"

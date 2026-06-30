#!/bin/bash
# Waybar NVIDIA GPU module (JSON): just the icon in the bar; small tooltip on hover.
GPU=$(printf '\U000f08ae')   # expansion-card / GPU glyph

line=$(nvidia-smi --query-gpu=name,utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
[ -z "$line" ] && exit 0

python3 - "$GPU" "$line" <<'PY'
import sys, json
icon, line = sys.argv[1], sys.argv[2]
name, util = [x.strip() for x in line.split(',')]
print(json.dumps({"text": icon, "tooltip": f"{name}\nUtilization: {util}%"}, ensure_ascii=False))
PY

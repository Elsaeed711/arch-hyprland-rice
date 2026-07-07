#!/bin/bash
# Waybar NVIDIA GPU (JSON): bar shows the GPU glyph + utilization; hover tooltip
# is a card with the GPU name, utilization, memory use and temperature.
GPU=$(printf '\U000f08ae')   # expansion-card / GPU glyph

line=$(nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu \
        --format=csv,noheader,nounits 2>/dev/null | head -1)
[ -z "$line" ] && exit 0

python3 - "$GPU" "$line" <<'PY'
import sys, json
icon, line = sys.argv[1], sys.argv[2]
name, util, mused, mtotal, temp = [x.strip() for x in line.split(',')]
tooltip = (f"  {name}\n"
           f"Utilization : {util}%\n"
           f"Memory      : {mused} / {mtotal} MiB\n"
           f"Temperature : {temp}°C")
print(json.dumps({"text": f"{icon} {util}%", "tooltip": tooltip}, ensure_ascii=False))
PY

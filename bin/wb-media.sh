#!/bin/bash
# Smooth now-playing marquee: metadata fetched ~1/s, scroll rendered fast.
WIDTH=32
STEP=0.13
REFRESH=8
SEP=$(printf '   •   ')
esc() { local s=$1; s=${s//&/&amp;}; s=${s//</&lt;}; s=${s//>/&gt;}; printf '%s' "$s"; }
yt=$(printf ''); sp=$(printf ''); sc=$(printf ''); play=$(printf '')
text=""; icon=""
fetch() {
  local status player title artist url svc
  status=$(playerctl status 2>/dev/null)
  if [ -z "$status" ]; then text=""; icon=""; return; fi
  IFS=$'\t' read -r player title artist url < <(playerctl metadata --format $'{{playerName}}\t{{title}}\t{{artist}}\t{{xesam:url}}' 2>/dev/null)
  text="$title"; [ -n "$artist" ] && text="$artist - $title"
  svc=""
  case "${player,,}" in *spotify*) svc=spotify ;; esac
  [ -z "$svc" ] && case "${url,,}" in *youtube*|*youtu.be*) svc=youtube;; *soundcloud*) svc=soundcloud;; *spotify*) svc=spotify;; esac
  [ -z "$svc" ] && case "${player,,}" in *brave*|*chrom*|*firefox*|*zen*|*vivaldi*) svc=youtube;; esac
  case "$svc" in
    spotify) icon="<span color='#1DB954'>$sp</span>";;
    youtube) icon="<span color='#FF0000'>$yt</span>";;
    soundcloud) icon="<span color='#FF5500'>$sc</span>";;
    *) icon="<span color='#74c7ec'>$play</span>";;
  esac
}
prev=""; off=0; c=0
while true; do
  [ $(( c % REFRESH )) -eq 0 ] && fetch
  c=$((c+1))
  if [ -z "$text" ]; then echo ""; prev=""; sleep 0.5; continue; fi
  [ "$text" != "$prev" ] && { off=0; prev="$text"; }
  if [ ${#text} -le $WIDTH ]; then
    disp="$text"
  else
    loop="$text$SEP"; len=${#loop}
    window="${loop:off}${loop}"; disp="${window:0:WIDTH}"
    off=$(( (off + 1) % len ))
  fi
  printf '%s  %s\n' "$icon" "$(esc "$disp")"
  sleep $STEP
done

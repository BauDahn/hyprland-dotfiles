#!/usr/bin/env bash
# Atenúa el brillo de forma gradual (hypridle). dim.sh down | up
STATE="$HOME/.cache/wallpaper/brightness"
fade() { # target% step_sleep
    local cur max target steps i
    max=$(brightnessctl max); cur=$(brightnessctl get)
    target=$(( max * $1 / 100 )); steps=15
    for ((i=1;i<=steps;i++)); do
        brightnessctl -q set $(( cur + (target-cur)*i/steps )); sleep 0.03
    done
}
case "$1" in
    down) brightnessctl get > "$STATE"; max=$(brightnessctl max)
          [ $(( $(brightnessctl get) * 100 / max )) -gt 15 ] && fade 12 ;;
    up)   [ -f "$STATE" ] && { max=$(brightnessctl max); fade $(( $(cat "$STATE") * 100 / max )); rm -f "$STATE"; } ;;
esac

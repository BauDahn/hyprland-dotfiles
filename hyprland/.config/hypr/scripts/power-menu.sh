#!/usr/bin/env bash
# Menú de energía con rofi
opts=$'󰌾  Bloquear\n󰤄  Suspender\n󰜉  Reiniciar\n󰐥  Apagar\n󰍃  Cerrar sesión'
sel=$(printf '%s' "$opts" | rofi -dmenu -i -p "Energía" -theme-str 'window{width:360px;} listview{columns:1;lines:5;} element-icon{size:0px;}')
case "$sel" in
    *Bloquear*)  hyprlock ;;
    *Suspender*) systemctl suspend ;;
    *Reiniciar*) systemctl reboot ;;
    *Apagar*)    systemctl poweroff ;;
    *Cerrar*)    hyprctl dispatch exit ;;
esac

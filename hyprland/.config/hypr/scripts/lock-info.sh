#!/usr/bin/env bash
# Texto para las labels de hyprlock: music | battery
case "$1" in
    music)
        s=$(playerctl status 2>/dev/null) || exit 0
        [ "$s" = "Stopped" ] && exit 0
        t=$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)
        [ -z "$t" ] && exit 0
        [ "$s" = "Playing" ] && i="󰎆" || i="󰏤"
        echo "$i  ${t:0:46}" ;;
    battery)
        b=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1) || exit 0
        [ -z "$b" ] && exit 0
        c=$(<"$b/capacity"); st=$(<"$b/status")
        icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
        i=${icons[$((c/10 >= 10 ? 9 : c/10))]}
        [ "$st" = "Charging" ] && i="󰂄"
        echo "$i  $c%" ;;
esac

#!/usr/bin/env bash
# Recarga todo lo que depende de colores/perfil.
hyprctl reload >/dev/null 2>&1
swaync-client -rs >/dev/null 2>&1
pkill -SIGUSR1 -x kitty 2>/dev/null
# waybar a veces pierde una señal si recarga justo en ese momento: se envía dos veces
pkill -SIGUSR2 waybar 2>/dev/null
( sleep 1; pkill -SIGUSR2 waybar 2>/dev/null ) >/dev/null 2>&1 &
pkill -SIGUSR2 -x cava 2>/dev/null
pkill -SIGUSR2 -x btop 2>/dev/null
command -v pywalfox >/dev/null && pywalfox update >/dev/null 2>&1 &
~/.config/hypr/scripts/spotify-theme.sh >/dev/null 2>&1 &
exit 0

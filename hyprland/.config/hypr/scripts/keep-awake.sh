#!/usr/bin/env bash
# Mantiene la pantalla despierta: inhibe la inactividad de systemd, así hypridle no bloquea,
# atenúa, apaga la pantalla ni suspende. Uso: keep-awake.sh [on|off|toggle|status]
PIDF="$HOME/.cache/wallpaper/keep-awake.pid"

active() { [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null; }

on() {
    active && return 0
    mkdir -p "$(dirname "$PIDF")"
    setsid systemd-inhibit --what=idle:sleep --who=keep-awake --why="Pantalla activa (compartiendo)" \
        --mode=block sleep infinity >/dev/null 2>&1 &
    echo $! > "$PIDF"
    notify-send -t 3000 "󰅶 Pantalla activa" "No se bloqueará ni suspenderá"
}

off() {
    active || { rm -f "$PIDF"; return 0; }
    local pid; pid=$(cat "$PIDF")
    pkill -P "$pid" 2>/dev/null; kill "$pid" 2>/dev/null
    rm -f "$PIDF"
    notify-send -t 3000 "󰅶 Pantalla activa" "Desactivada: vuelve el bloqueo automático"
}

case "${1:-toggle}" in
    on)     on ;;
    off)    off ;;
    toggle) if active; then off; else on; fi ;;
    status) active && echo true || echo false ;;
esac

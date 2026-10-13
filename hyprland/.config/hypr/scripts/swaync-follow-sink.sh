#!/usr/bin/env bash
# El slider de volumen de swaync queda atado a la salida que había al arrancar.
# Este vigilante reinicia swaync solo cuando cambia la salida por defecto
# (p. ej. al conectar auriculares), así el slider controla siempre el dispositivo activo.
last=$(pactl get-default-sink 2>/dev/null)
pactl subscribe 2>/dev/null | grep --line-buffered "on server" | while read -r _; do
    sleep 0.7                                  # dejar que el cambio se asiente
    cur=$(pactl get-default-sink 2>/dev/null)
    if [ -n "$cur" ] && [ "$cur" != "$last" ]; then
        last="$cur"
        pkill -x swaync
        sleep 0.3
        setsid swaync >/dev/null 2>&1 &
    fi
done

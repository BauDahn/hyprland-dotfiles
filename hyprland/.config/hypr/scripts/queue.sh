# Cola de cambios de tema/fondo (la usan theme.sh y wallpaper.sh con `source`).
# Si ya hay un cambio aplicándose, el pedido nuevo solo reemplaza al pendiente y sale.
# El proceso en curso espera a que no lleguen más pedidos (0.5 s) y aplica solo el ÚLTIMO.
QCACHE="$HOME/.cache/wallpaper"
queue_apply() { # $1 = ruta del script, resto = argumentos del pedido
    [ -n "$NOQUEUE" ] && return 1          # ya es el proceso que aplica: ejecutar directo
    mkdir -p "$QCACHE"
    printf '%q ' "$@" > "$QCACHE/want.tmp" && mv -f "$QCACHE/want.tmp" "$QCACHE/want"
    exec 9>"$QCACHE/apply.lock"
    flock -n 9 || exit 0                   # otro proceso está aplicando: él toma el pedido
    local cmd
    while :; do
        cmd=$(cat "$QCACHE/want")
        sleep 0.5                          # esperar a que dejen de llegar pulsaciones
        [ "$(cat "$QCACHE/want")" = "$cmd" ] || continue
        export NOQUEUE=1
        eval "$cmd" 9>&-                   # 9>&- : los hijos no heredan el lock
        [ "$(cat "$QCACHE/want")" = "$cmd" ] && break
    done
    exit 0
}

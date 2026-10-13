#!/usr/bin/env bash
# Selector de fondos: rofi con miniaturas + transición fade con awww + fondo de hyprlock sincronizado.
# Uso: wallpaper.sh [menu|random|next|prev|restore|set <archivo>]
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
DIR="$HOME/Pictures/Wallpapers"
CACHE="$HOME/.cache/wallpaper"
LOCK_IMG="$CACHE/lockscreen.jpg"   # hyprlock lee este archivo
STATE="$CACHE/current"
# shellcheck source=queue.sh
source "$(dirname "$0")/queue.sh"
THUMBS="$CACHE/thumbs"
mkdir -p "$THUMBS"

mapfile -t FILES < <(find -L "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)
[ ${#FILES[@]} -eq 0 ] && { notify-send "Wallpaper" "No hay fondos en $DIR"; exit 1; }

# Origen de la transición del fondo: WALL_ORIGIN=mouse (default) o center.
# Con "mouse" el círculo crece desde el cursor, en el monitor donde está.
transition_args() {
    local pos="center" cx cy mx my mw mh
    if [ "${WALL_ORIGIN:-mouse}" = mouse ] && command -v jq >/dev/null; then
        read -r cx cy < <(hyprctl cursorpos | tr -d ',')
        read -r mx my mw mh < <(hyprctl monitors -j | jq -r --argjson x "$cx" --argjson y "$cy" \
            '.[] | select($x >= .x and $x < .x + .width and $y >= .y and $y < .y + .height) | "\(.x) \(.y) \(.width) \(.height)"' | head -1)
        # awww cuenta los píxeles desde abajo-izquierda; Hyprland desde arriba-izquierda
        [ -n "$mw" ] && pos="$((cx - mx)),$((mh - (cy - my)))"
    fi
    TRANS=(--transition-type grow --transition-pos "$pos" --transition-duration 1.3 --transition-fps 144)
}

apply() {
    local img="$1"
    pgrep -x awww-daemon >/dev/null || { awww-daemon & sleep 0.5; }
    transition_args
    awww img "$img" "${TRANS[@]}"
    cp -f "$img" "$LOCK_IMG"
    echo "$img" > "$STATE"
    # paleta de colores del fondo -> waybar, rofi, hyprland, hyprlock, kitty, swaync
    if command -v wallust >/dev/null; then
        pal_cache "$img" && "$HOME/.config/hypr/scripts/palette.py"
        [ "$2" = noreload ] || "$HOME/.config/hypr/scripts/theme-reload.sh"
    fi
}

# Paleta por fondo con caché: wallust (kmeans) tarda ~15 s por imagen, así que cada fondo
# se calcula una sola vez y después se copia desde ~/.cache/wallpaper/palettes/.
pal_cache() {
    local img="$1" dir="$QCACHE/palettes" key
    mkdir -p "$dir"
    key="$dir/$(stat -c '%s %Y' "$img" | md5sum | cut -c1-16)-$(basename "$img").json"
    (
        flock 8                            # no pisar palette.json mientras otro cálculo o cambio lo usa
        if [ ! -f "$key" ]; then
            { wallust run -q "$img" || wallust run -q -b thumb -f interpolate "$img"; } >/dev/null 2>&1 || exit 1
            cp -f "$QCACHE/palette.json" "$key"
        fi
        cp -f "$key" "$QCACHE/palette.json"
    ) 8>"$QCACHE/palette.lock"
}

current() { cat "$STATE" 2>/dev/null; }

index_of() {
    local cur; cur="$(current)"
    for i in "${!FILES[@]}"; do [ "${FILES[$i]}" = "$cur" ] && { echo "$i"; return; }; done
    echo -1
}

thumb() {
    local t="$THUMBS/$(basename "${1%.*}").png"
    [ -f "$t" ] && [ "$t" -nt "$1" ] || magick "$1" -resize 400x225^ -gravity center -extent 400x225 "$t"
    echo "$t"
}

# imagen pendiente o actual (para que next/prev avancen por cada pulsación)
base_img() {
    local p; p=$(awk '$2=="set"{print $3}' "$QCACHE/want" 2>/dev/null)
    echo "${p:-$(current)}"
}
index_of_base() {
    local cur f i; cur="$(base_img)"
    for i in "${!FILES[@]}"; do [ "${FILES[$i]}" = "$cur" ] && { echo "$i"; return; }; done
    echo -1
}

case "${1:-menu}" in
    menu)
        sel=$(for f in "${FILES[@]}"; do
                printf '%s\0icon\x1f%s\n' "$(basename "${f%.*}")" "$(thumb "$f")"
              done | rofi -dmenu -i -p "Fondo" -show-icons -theme "$HOME/.config/rofi/wallpaper.rasi")
        [ -z "$sel" ] && exit 0
        for f in "${FILES[@]}"; do
            [ "$(basename "${f%.*}")" = "$sel" ] && apply "$f" && break
        done ;;
    random)  f="${FILES[RANDOM % ${#FILES[@]}]}"; queue_apply "$0" set "$f" || apply "$f" ;;
    next)    i=$(index_of_base); f="${FILES[(i+1) % ${#FILES[@]}]}"; queue_apply "$0" set "$f" || apply "$f" ;;
    prev)    i=$(index_of_base); f="${FILES[(i-1+${#FILES[@]}) % ${#FILES[@]}]}"; queue_apply "$0" set "$f" || apply "$f" ;;
    restore) c=$(current); [ -f "$c" ] || c="${FILES[0]}"; apply "$c" noreload ;;
    set)     [ -f "$2" ] && { queue_apply "$0" set "$2" || apply "$2"; } ;;
    # calcula la paleta de todos los fondos (en segundo plano, una sola vez)
    warm)    for f in "${FILES[@]}"; do pal_cache "$f"; done ;;
esac

#!/usr/bin/env bash
# Switcher de temas completo. Un perfil define: fondo (+lockscreen), colores (wallust),
# estilo y márgenes de waybar, y efectos de Hyprland (bordes, blur, sombras, animaciones).
# Uso: theme.sh [menu|<perfil>|gen|current|next]
PROFILES="$HOME/.config/themes"
HYPR="$HOME/.config/hypr"
WB="$HOME/.config/waybar"
CACHE="$HOME/.cache/wallpaper"
mkdir -p "$CACHE"
# shellcheck source=queue.sh
source "$HYPR/scripts/queue.sh"

load() { # name
    unset LABEL WALLPAPER WALLPAPERS WAYBAR_STYLE WAYBAR_MARGIN ROUNDING GAPS_IN GAPS_OUT BORDER BLUR_SIZE BLUR_PASSES INACTIVE_OPACITY SHADOW ANIM WS_ANIM SHADER BASE
    # shellcheck disable=SC1090
    source "$PROFILES/$1.conf"
}

gen_hypr() {
    local shadow_enabled=true shadow_color='$shadow' shadow_range=20
    case "$SHADOW" in
        glow) shadow_color='$glow'; shadow_range=24 ;;
        none) shadow_enabled=false ;;
    esac
    local ws_speed=5 ws_curve=smooth
    case "$ANIM" in snappy) ws_speed=4; ws_curve=snap ;; bouncy) ws_speed=6; ws_curve=bounce ;; esac
    # Shaders que leen píxeles vecinos dejan líneas rectas en los bordes de las zonas que Hyprland
    # redibuja parcialmente: con ellos se fuerza el redibujado completo (damage_tracking = 0).
    local damage=2
    case "$SHADER" in crt|cyberglow|glitch|noir|vhs|haze|streak) damage=0 ;; esac
    local shader_line=""
    [ -n "$SHADER" ] && [ -f "$HYPR/shaders/$SHADER.frag" ] && shader_line="screen_shader = $HYPR/shaders/$SHADER.frag"
    case "$ANIM" in
        snappy) bez='bezier = snap, 0.2, 1, 0.2, 1'
                anim='animation = windows, 1, 3, snap, popin 90%
    animation = windowsOut, 1, 3, snap, popin 90%
    animation = fade, 1, 3, snap
    animation = layers, 1, 3, snap, fade' ;;
        bouncy) bez='bezier = bounce, 0.05, 0.9, 0.1, 1.15
    bezier = smooth, 0.25, 1, 0.5, 1'
                anim='animation = windows, 1, 6, bounce, popin 70%
    animation = windowsOut, 1, 4, smooth, popin 70%
    animation = fade, 1, 5, smooth
    animation = layers, 1, 5, bounce, popin 80%' ;;
        *)      bez='bezier = smooth, 0.25, 1, 0.5, 1'
                anim='animation = windows, 1, 5, smooth, popin 85%
    animation = windowsOut, 1, 4, smooth, popin 85%
    animation = fade, 1, 4, smooth
    animation = layers, 1, 4, smooth, fade' ;;
    esac
    cat > "$HYPR/profile.conf" <<CONF
# GENERADO por scripts/theme.sh (perfil: $NAME) — no editar a mano
general {
    gaps_in = $GAPS_IN
    gaps_out = $GAPS_OUT
    border_size = $BORDER
    col.active_border = \$primary \$secondary 45deg
    col.inactive_border = \$inactive
    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding = $ROUNDING
    active_opacity = 1.0
    inactive_opacity = $INACTIVE_OPACITY

    blur {
        enabled = true
        size = $BLUR_SIZE
        passes = $BLUR_PASSES
        noise = 0.02
        contrast = 0.95
        brightness = 0.9
        vibrancy = 0.2
        vibrancy_darkness = 0.3
        new_optimizations = true
        popups = true
    }

    shadow {
        enabled = $shadow_enabled
        range = $shadow_range
        render_power = 3
        color = $shadow_color
    }

    $shader_line
}

debug {
    damage_tracking = $damage
}

animations {
    enabled = yes
    $bez
    bezier = linear, 0, 0, 1, 1
    $anim
    animation = workspaces, 1, $ws_speed, $ws_curve, ${WS_ANIM:-slide}
    animation = specialWorkspace, 1, 5, $ws_curve, slidefadevert 20%
    animation = border, 1, 8, default
    animation = borderangle, 1, 60, linear, loop
}
CONF
}

gen_waybar() {
    cp -f "$WB/styles/$WAYBAR_STYLE.css" "$WB/style.css"
    read -r mt ml mr <<<"$WAYBAR_MARGIN"
    sed -i -E "s/(\"margin-top\": )[0-9]+/\1$mt/; s/(\"margin-left\": )[0-9]+/\1$ml/; s/(\"margin-right\": )[0-9]+/\1$mr/" "$WB/config.jsonc"
}

# Elige un fondo al azar entre los del perfil (WALLPAPERS = patrones, ej. "forest-*"),
# evitando repetir el actual. Si no hay coincidencias usa WALLPAPER.
pick_wallpaper() {
    local dir="$HOME/Pictures/Wallpapers" cur f pat
    local -a cands=()
    cur=$(basename "$(cat "$CACHE/current" 2>/dev/null)")
    local -a pats
    read -ra pats <<<"${WALLPAPERS:-${NAME}-*}"   # sin expandir globs todavía
    shopt -s nullglob
    for pat in "${pats[@]}"; do
        for f in "$dir"/$pat; do
            [ -f "$f" ] && cands+=("$f")
        done
    done
    shopt -u nullglob
    if [ ${#cands[@]} -gt 1 ]; then
        local -a others=()
        for f in "${cands[@]}"; do [ "$(basename "$f")" != "$cur" ] && others+=("$f"); done
        [ ${#others[@]} -gt 0 ] && cands=("${others[@]}")
    fi
    if [ ${#cands[@]} -gt 0 ]; then echo "${cands[RANDOM % ${#cands[@]}]}"; else echo "$dir/$WALLPAPER"; fi
}

apply() {
    NAME="$1"
    [ -f "$PROFILES/$NAME.conf" ] || { echo "Perfil inexistente: $NAME" >&2; exit 1; }
    load "$NAME"
    echo "$NAME" > "$CACHE/profile"
    echo "${BASE:-auto}" > "$CACHE/base"   # palette.py: fondo de colores negro puro (OLED) o automático
    gen_hypr
    gen_waybar
    # wallpaper.sh aplica fondo, lockscreen, wallust y recarga todo
    "$HYPR/scripts/wallpaper.sh" set "$(pick_wallpaper)"
}

# pendiente o actual: el perfil más reciente pedido (para que "next" avance por cada pulsación)
profile_base() {
    local p; p=$(awk '$1 ~ /theme\.sh$/{print $2}' "$CACHE/want" 2>/dev/null)
    echo "${p:-$(cat "$CACHE/profile" 2>/dev/null)}"
}

case "${1:-menu}" in
    menu)
        sel=$(for f in "$PROFILES"/*.conf; do n=$(basename "${f%.conf}"); load "$n"; printf '%s\t%s\n' "$n" "$LABEL"; done \
              | rofi -dmenu -i -p "Tema" -display-columns 2 -theme-str 'window{width:420px;} listview{columns:1;lines:12;} element-icon{size:0px;}' | cut -f1)
        [ -n "$sel" ] && apply "$sel" ;;
    gen)     NAME=$(cat "$CACHE/profile" 2>/dev/null || echo nebula); load "$NAME"; gen_hypr; gen_waybar ;;
    current) cat "$CACHE/profile" 2>/dev/null ;;
    next)    mapfile -t L < <(ls "$PROFILES" | sed 's/\.conf$//'); cur=$(profile_base)
             for i in "${!L[@]}"; do [ "${L[$i]}" = "$cur" ] && break; done
             t="${L[(i+1) % ${#L[@]}]}"
             queue_apply "$0" "$t" || apply "$t" ;;
    *)       queue_apply "$0" "$1" || apply "$1" ;;
esac

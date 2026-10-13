#!/usr/bin/env bash
# Selector de ventanas con miniaturas reales (rofi + grim).
# Las ventanas visibles se capturan al abrir; las de otros workspaces usan su última captura.
CACHE="$HOME/.cache/rofi-windows"
mkdir -p "$CACHE"

clients=$(hyprctl clients -j)
active_ws=$(hyprctl monitors -j | jq -r '.[].activeWorkspace.id')
current=$(hyprctl activewindow -j | jq -r '.address // empty')

# Capturar ventanas visibles (workspace activo de cada monitor)
while read -r addr pos size; do
  { grim -g "$pos $size" - 2>/dev/null | magick png:- -resize 640x400 "$CACHE/$addr.png"; } &
done < <(echo "$clients" | jq -r --argjson ws "$(echo "$active_ws" | jq -s .)" \
  '.[] | select(.mapped and (.workspace.id as $w | $ws | index($w))) |
   "\(.address) \(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
wait

entries=$(echo "$clients" | jq -r '.[] | select(.mapped and .workspace.id >= 0) |
  "\(.address)\t\(.class)\t\(.title)\t\(.workspace.id)"')
[ -z "$entries" ] && exit 0

menu=""
while IFS=$'\t' read -r addr class title ws; do
  img="$CACHE/$addr.png"
  [ -f "$img" ] || img="$class"
  label="$(printf '%s' "$title" | cut -c1-34)  ·  $ws"
  menu+="$label\0icon\x1f$img\x1finfo\x1f$addr\n"
done <<< "$entries"

sel=$(printf "$menu" | rofi -dmenu -i -show-icons -p "Ventanas" \
  -theme ~/.config/rofi/windows.rasi -format i)
[ -z "$sel" ] && exit 0

addr=$(echo "$entries" | sed -n "$((sel+1))p" | cut -f1)
hyprctl dispatch focuswindow "address:$addr"

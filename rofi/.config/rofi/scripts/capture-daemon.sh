#!/usr/bin/env bash
# Mantiene fresca la caché de miniaturas: captura las ventanas visibles al cambiar de workspace
# o cuando cambia la ventana activa, así el selector tiene vista previa de TODAS las ventanas.
CACHE="$HOME/.cache/rofi-windows"
mkdir -p "$CACHE"
capture() {
  local clients active_ws
  clients=$(hyprctl clients -j)
  active_ws=$(hyprctl monitors -j | jq -s '[.[][].activeWorkspace.id]')
  while read -r addr pos size; do
    { grim -g "$pos $size" - 2>/dev/null | magick png:- -resize 1600x1000 "$CACHE/$addr.png"; } &
  done < <(echo "$clients" | jq -r --argjson ws "$active_ws" \
    '.[] | select(.mapped and (.workspace.id as $w | $ws | index($w))) |
     "\(.address) \(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
  wait
}
# Al cerrar una ventana, borrar su miniatura
python3 -I -c '
import os, socket, sys
s = socket.socket(socket.AF_UNIX)
s.connect(os.environ["XDG_RUNTIME_DIR"] + "/hypr/" + os.environ["HYPRLAND_INSTANCE_SIGNATURE"] + "/.socket2.sock")
for line in s.makefile():
    print(line.strip(), flush=True)
' | while read -r line; do
  case "$line" in
    workspacev2*|activewindowv2*) sleep 0.4; capture ;;
    closewindow*) rm -f "$CACHE/0x${line#closewindow>>}.png" ;;
  esac
done

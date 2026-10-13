#!/usr/bin/env bash
# Aplica el tema "wallust" a Spotify con spicetify.
# Si Spotify está abierto: solo refresh (no corta la música).
# Si está cerrado: NO aplica nada, porque `spicetify apply` arranca Spotify.
# color.ini ya lo escribe palette.py; se aplicará con el próximo apply manual.
export PATH="$HOME/.spicetify:$PATH"
command -v spicetify >/dev/null || exit 0
[ -d "$HOME/.config/spicetify/Themes/wallust" ] || exit 0
pgrep -x spotify >/dev/null || exit 0
cur=$(spicetify config current_theme 2>/dev/null)
[ "$cur" = wallust ] && spicetify refresh -q >/dev/null 2>&1
exit 0

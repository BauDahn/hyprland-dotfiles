#!/usr/bin/env bash
# Reinstala el entorno: paquetes + symlinks con stow.
set -euo pipefail
cd "$(dirname "$0")"
sudo pacman -S --needed - < packages.txt
yay -S --needed - < packages-aur.txt
for pkg in hyprland waybar kitty rofi swaync hyprlock cava btop swappy qt overview bash themes zsh; do
  stow -v -R --target="$HOME" "$pkg"
done
# wallust ya no está en los repos: se compila con cargo (queda en ~/.cargo/bin)
command -v wallust >/dev/null || cargo install wallust
# Shell por defecto: zsh (pide contraseña)
[ "$SHELL" = /usr/bin/zsh ] || chsh -s /usr/bin/zsh

# Tema GTK / iconos / cursor
gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-mauve-standard+default'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
echo "Listo. Reiniciá sesión de Hyprland."

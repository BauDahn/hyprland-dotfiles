# Hyprland dotfiles

[English](#english) · [Español](#español)

![Theme transition](docs/demo.gif)

## English

A desktop that changes personality with a keybind. Wallpaper, colors, bar, borders, blur, animations and screen shaders all change together.

> Desktop customization built with Claude Code. Vibecoded, with everything that implies: it works on my machine, but don't take it as a reference for best practices.

### What's included

- **12 ready-made themes**, from cyberpunk and synthwave to minimal and OLED pure black. Each one defines its wallpaper, palette, bar style and Hyprland effects.
- **Palette generated from the wallpaper** with wallust. The colors reach waybar, rofi, kitty, swaync, btop, cava, GTK, the lockscreen and Spotify.
- **Screen shaders** such as CRT, VHS, glitch, noir or haze.
- **Window overview** at full screen (`SUPER+TAB`): see all windows at once and pick one with the mouse, the arrows or the number keys.
- **Theme and wallpaper pickers** in rofi.

### Themes

| Theme | Bar style |
|---|---|
| Cyberpunk | cyber |
| Synthwave | cyber |
| Tokyo (night) | floating |
| Night City | cyber |
| Edgerunner (glitch) | cyber |
| Replicant (neo-noir) | minimal |
| Minimalist | minimal |
| OLED (pure black) | minimal |
| Nebula (neon) | floating |
| Chill (forest) | floating |
| Edgerunners · Luna | floating |
| Edgerunners · Rebecca | cyber |

Switch themes with `SUPER+T` (menu) or `SUPER+SHIFT+T` (next).

### Requirements

- EndeavourOS or any Arch-based distro (the installer uses `pacman` and `yay`).
- Hyprland. Tested with 0.56.
- Your own wallpapers in `~/Pictures/Wallpapers/` (see [Wallpapers](#wallpapers)).

### Installation

```bash
git clone git@github.com:BauDahn/hyprland-dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` installs the packages in `packages.txt` and `packages-aur.txt`, links each folder into `$HOME` with [GNU stow](https://www.gnu.org/software/stow/), builds wallust with cargo if needed, sets zsh as your shell, and configures the GTK theme, icons and cursor. Restart your Hyprland session when it finishes.

### Wallpapers

Wallpapers aren't in the repo because they are third-party artwork under copyright. Put yours in `~/Pictures/Wallpapers/`.

Each theme looks for a specific file, set in `WALLPAPER=` inside `themes/.config/themes/*.conf`. For example, `synthwave.conf` uses `synthwave-1.jpg`. You can use the same file names with your own images, or change the value in the profile.

### Keybinds

| Keybind | Action |
|---|---|
| `SUPER+Q` | Terminal |
| `SUPER+R` | Launcher |
| `SUPER+B` | Firefox |
| `SUPER+E` | File manager |
| `SUPER+C` | Close window |
| `SUPER+V` | Toggle floating |
| `SUPER+TAB` | Window overview |
| `SUPER+T` | Theme menu |
| `SUPER+SHIFT+T` | Next theme |
| `SUPER+W` | Wallpaper menu |
| `SUPER+SHIFT+W` | Random wallpaper |
| `SUPER+CTRL+←/→` | Previous / next wallpaper |
| `SUPER+SHIFT+S` | Capture a region (edit in swappy) |
| `SUPER+SHIFT+V` | Clipboard history |
| `SUPER+N` | Notification center |
| `SUPER+S` | Lock and suspend |
| `SUPER+SHIFT+L` | Lock |
| `SUPER+L` | ROG Control Center |

Full list in `hyprland/.config/hypr/binds.conf`.

### Structure

Each folder is a stow package that mirrors its path under `$HOME`. For example, `hyprland/.config/hypr/` links to `~/.config/hypr/`. Editing a file in `~/.config` edits the repo.

### Notes

- Built for an ASUS ROG notebook. `SUPER+L` opens its control center, so that keybind won't work on other machines.
- There are no secrets in the repo. Credentials and tokens live in local files ignored by `.gitignore`.

### Contact

Questions, ideas, or something that doesn't work? Email bdahcos@upv.edu.es

---

## Español

A desktop que cambia de personalidad con un atajo. Fondo, colores, barra, bordes, blur, animaciones y shaders de pantalla cambian juntos.

> Personalización del sistema hecha con ayuda de Claude Code. Vibecoded, con todo lo que eso implica: funciona en mi equipo, pero no lo tomes como referencia de buenas prácticas.

### Qué incluye

- **12 temas listos**, desde cyberpunk y synthwave hasta minimalista y OLED negro total. Cada uno define su fondo, su paleta, el estilo de la barra y los efectos de Hyprland.
- **Paleta generada desde el fondo** con wallust. Los colores llegan a waybar, rofi, kitty, swaync, btop, cava, GTK, el lockscreen y Spotify.
- **Shaders de pantalla** como CRT, VHS, glitch, noir o haze.
- **Overview de ventanas** a pantalla completa (`SUPER+TAB`): ves todas las ventanas del escritorio de un vistazo y elegís con el mouse, las flechas o los números.
- **Selector de temas y fondos** con rofi.

### Temas

| Tema | Estilo de barra |
|---|---|
| Cyberpunk | cyber |
| Synthwave | cyber |
| Tokyo (noche) | flotante |
| Night City | cyber |
| Edgerunner (glitch) | cyber |
| Replicant (neo-noir) | minimal |
| Minimalista | minimal |
| OLED (negro total) | minimal |
| Nebula (neón) | flotante |
| Chill (bosque) | flotante |
| Edgerunners · Luna | flotante |
| Edgerunners · Rebecca | cyber |

Cambiás de tema con `SUPER+T` (menú) o `SUPER+SHIFT+T` (siguiente).

### Requisitos

- EndeavourOS o cualquier Arch-based (el instalador usa `pacman` y `yay`).
- Hyprland. Probado con 0.56.
- Tus propios fondos en `~/Pictures/Wallpapers/` (ver [Fondos](#fondos)).

### Instalación

```bash
git clone git@github.com:BauDahn/hyprland-dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` instala los paquetes de `packages.txt` y `packages-aur.txt`, enlaza cada carpeta en `$HOME` con [GNU stow](https://www.gnu.org/software/stow/), compila wallust con cargo si hace falta, pone zsh como shell y configura el tema GTK, los iconos y el cursor. Al terminar, reiniciá la sesión de Hyprland.

### Fondos

Los fondos no están en el repo porque son obras de terceros con copyright. Poné los tuyos en `~/Pictures/Wallpapers/`.

Cada tema busca un archivo concreto, indicado en `WALLPAPER=` dentro de `themes/.config/themes/*.conf`. Por ejemplo, `synthwave.conf` usa `synthwave-1.jpg`. Podés usar esos mismos nombres con tus propias imágenes, o cambiar el valor en el perfil.

### Atajos

| Atajo | Acción |
|---|---|
| `SUPER+Q` | Terminal |
| `SUPER+R` | Launcher |
| `SUPER+B` | Firefox |
| `SUPER+E` | Administrador de archivos |
| `SUPER+C` | Cerrar ventana |
| `SUPER+V` | Alternar flotante |
| `SUPER+TAB` | Overview de ventanas |
| `SUPER+T` | Menú de temas |
| `SUPER+SHIFT+T` | Siguiente tema |
| `SUPER+W` | Menú de fondos |
| `SUPER+SHIFT+W` | Fondo aleatorio |
| `SUPER+CTRL+←/→` | Fondo anterior / siguiente |
| `SUPER+SHIFT+S` | Captura de una región (con edición en swappy) |
| `SUPER+SHIFT+V` | Historial del portapapeles |
| `SUPER+N` | Centro de notificaciones |
| `SUPER+S` | Bloquear y suspender |
| `SUPER+SHIFT+L` | Bloquear |
| `SUPER+L` | ROG Control Center |

Lista completa en `hyprland/.config/hypr/binds.conf`.

### Estructura

Cada carpeta del repo es un paquete de stow y espeja su ruta dentro de `$HOME`. Por ejemplo, `hyprland/.config/hypr/` se enlaza a `~/.config/hypr/`. Editar un archivo en `~/.config` edita el repo.

### Notas

- Pensado para una notebook ASUS ROG. `SUPER+L` abre su control center, así que ese atajo no sirve en otro equipo.
- No hay secretos en el repo. Credenciales y tokens viven en archivos locales ignorados por `.gitignore`.

### Contacto

¿Preguntas, ideas o algo que no funcione? Escribime a bdahcos@upv.edu.es

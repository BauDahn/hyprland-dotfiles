#!/usr/bin/env python3
"""Lee la paleta de wallust (palette.json), elige acentos vivos y genera los archivos
de color de waybar, rofi, swaync, kitty, hyprland y hyprlock."""
import colorsys, json, os, sys

H = os.path.expanduser("~")
pal = json.load(open(f"{H}/.cache/wallpaper/palette.json"))

def rgb(h): h = h.lstrip("#"); return tuple(int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
def hexc(c): return "#%02X%02X%02X" % tuple(round(max(0, min(1, x)) * 255) for x in c)
def mix(a, b, t): return tuple(x * (1 - t) + y * t for x, y in zip(a, b))
def hsv(h): return colorsys.rgb_to_hsv(*rgb(h))
def fromhsv(h, s, v): return colorsys.hsv_to_rgb(h % 1.0, max(0, min(1, s)), max(0, min(1, v)))
def hdiff(a, b): d = abs(a - b) % 1.0; return min(d, 1 - d)

cands = [(hsv(c), c) for c in pal["c"][1:] + [pal["fg"]]]
best_s = max(s for (h, s, v), _ in cands)
# imágenes casi grises (minimalistas): no inventar saturación
s_min = min(0.55, best_s * 1.8 + 0.05)
def score(x): (h, s, v), _ = x; return s * (0.4 + v)

cands.sort(key=score, reverse=True)
ph, ps, pv = cands[0][0]
sec = next((c for c in cands[1:] if hdiff(c[0][0], ph) >= 0.12), None)
sh = sec[0][0] if sec else ph + 0.42
ss = sec[0][1] if sec else ps

def accent(h, s): return fromhsv(h, max(s, s_min) if s_min > s else min(s, 0.85), 0.9)
primary, secondary = accent(ph, ps), accent(sh, ss)
tertiary = mix(primary, (1, 1, 1), 0.45)

bg_h, bg_s, bg_v = hsv(pal["bg"])
base = fromhsv(bg_h, min(bg_s, 0.45), min(bg_v, 0.11) if bg_v > 0.04 else 0.07)
try:
    if open(f"{H}/.cache/wallpaper/base").read().strip() == "black":
        base = (0.0, 0.0, 0.0)   # perfil OLED: negro total
except OSError:
    pass
mantle = mix(base, (0, 0, 0), 0.35)
text = (0.90, 0.91, 0.96)
surface0 = mix(base, text, 0.10)
surface1 = mix(base, text, 0.24)
subtext = mix(base, text, 0.72)
red, green, yellow, peach, teal = (rgb(x) for x in ("#f38ba8", "#a6e3a1", "#f9e2af", "#fab387", "#94e2d5"))

P, S, T = hexc(primary), hexc(secondary), hexc(tertiary)
strip = lambda c: hexc(c)[1:]

def write(path, content):
    path = os.path.expanduser(path); os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w").write(content)

write("~/.config/waybar/colors.css", f"""@define-color base     {hexc(base)};
@define-color mantle   {hexc(mantle)};
@define-color surface0 {hexc(surface0)};
@define-color surface1 {hexc(surface1)};
@define-color text     {hexc(text)};
@define-color subtext  {hexc(subtext)};
@define-color mauve    {P};
@define-color blue     {S};
@define-color lavender {T};
@define-color green    {hexc(green)};
@define-color yellow   {hexc(yellow)};
@define-color peach    {hexc(peach)};
@define-color red      {hexc(red)};
@define-color teal     {hexc(teal)};
""")
write("~/.config/swaync/colors.css", f"""@define-color base {hexc(base)};
@define-color surface {hexc(surface0)};
@define-color text {hexc(text)};
@define-color mauve {P};
@define-color red {hexc(red)};
""")
write("~/.config/rofi/colors.rasi", f"""* {{
    base: {hexc(base)}F0; mantle: {hexc(mantle)}; surface: {hexc(surface0)}; text: {hexc(text)};
    mauve: {P}; blue: {S}; subtext: {hexc(subtext)};
}}
""")
ansi = [surface1, red, green, yellow, secondary, primary, tertiary, subtext]
bright = [mix(surface1, text, 0.15), red, green, yellow, secondary, primary, tertiary, text]
k = f"""foreground              {hexc(text)}
background              {hexc(base)}
selection_foreground    {hexc(base)}
selection_background    {P}
cursor                  {P}
cursor_text_color       {hexc(base)}
url_color               {T}
active_border_color     {P}
inactive_border_color   {hexc(surface1)}
"""
for i, c in enumerate(ansi + bright): k += f"color{i} {hexc(c)}\n"
write("~/.config/kitty/colors-wallust.conf", k)
write("~/.config/hypr/colors.conf", f"""$primary   = rgb({strip(primary)})
$secondary = rgb({strip(secondary)})
$tertiary  = rgb({strip(tertiary)})
$inactive  = rgba({strip(surface1)}aa)
$glow      = rgba({strip(primary)}aa)
$shadow    = rgba({strip(mantle)}cc)
""")
write("~/.config/hypr/hyprlock-colors.conf", f"""$lk_text    = rgb({strip(text)})
$lk_accent  = rgb({strip(primary)})
$lk_accent2 = rgb({strip(secondary)})
$lk_inner   = rgba({strip(base)}cc)
$lk_dim     = rgb({strip(subtext)})
$lk_ok      = rgb({strip(green)})
$lk_fail    = rgb({strip(red)})
$lk_panel   = rgba({strip(base)}88)
""")

# ---------------------------------------------------------------------------
# Más apps: btop, cava, spotify (spicetify), libadwaita (GTK4), pywalfox (Firefox)
# ---------------------------------------------------------------------------
def lerp_list(a, b, n): return [mix(a, b, i / (n - 1)) for i in range(n)]

# btop
b = lambda c: f'"{hexc(c)}"'
write("~/.config/btop/themes/wallust.theme", f"""theme[main_bg]={b(base)}
theme[main_fg]={b(text)}
theme[title]={b(text)}
theme[hi_fg]={b(primary)}
theme[selected_bg]={b(surface1)}
theme[selected_fg]={b(text)}
theme[inactive_fg]={b(surface1)}
theme[graph_text]={b(subtext)}
theme[meter_bg]={b(surface0)}
theme[proc_misc]={b(secondary)}
theme[cpu_box]={b(primary)}
theme[mem_box]={b(secondary)}
theme[net_box]={b(tertiary)}
theme[proc_box]={b(primary)}
theme[div_line]={b(surface1)}
theme[temp_start]={b(green)}
theme[temp_mid]={b(yellow)}
theme[temp_end]={b(red)}
theme[cpu_start]={b(secondary)}
theme[cpu_mid]={b(primary)}
theme[cpu_end]={b(red)}
theme[free_start]={b(secondary)}
theme[free_mid]={b(secondary)}
theme[free_end]={b(tertiary)}
theme[cached_start]={b(secondary)}
theme[cached_mid]={b(primary)}
theme[cached_end]={b(tertiary)}
theme[available_start]={b(green)}
theme[available_mid]={b(green)}
theme[available_end]={b(teal)}
theme[used_start]={b(primary)}
theme[used_mid]={b(primary)}
theme[used_end]={b(red)}
theme[download_start]={b(secondary)}
theme[download_mid]={b(secondary)}
theme[download_end]={b(tertiary)}
theme[upload_start]={b(primary)}
theme[upload_mid]={b(primary)}
theme[upload_end]={b(tertiary)}
""")

# cava: degradé secundario -> primario -> claro
grad = lerp_list(secondary, primary, 5) + lerp_list(primary, tertiary, 4)[1:]
cv = "[color]\ngradient = 1\ngradient_count = 8\n"
for i, c in enumerate(grad): cv += f"gradient_color_{i+1} = '{hexc(c)}'\n"
write("~/.config/cava/themes/wallust", cv)

# spotify (spicetify): tema "wallust" con solo color.ini; scripts/spotify-theme.sh lo aplica
s = lambda c: strip(c).lower()
write("~/.config/spicetify/Themes/wallust/color.ini", f"""[wallust]
text               = {s(text)}
subtext            = {s(subtext)}
main               = {s(base)}
sidebar            = {s(mantle)}
player             = {s(mantle)}
card               = {s(surface0)}
shadow             = {s(mantle)}
selected-row       = {s(text)}
button             = {s(primary)}
button-active      = {s(primary)}
button-disabled    = {s(surface1)}
tab-active         = {s(surface0)}
notification       = {s(surface0)}
notification-error = {s(red)}
misc               = {s(surface1)}
""")
write("~/.config/spicetify/Themes/wallust/user.css", "/* colores en color.ini (generado por palette.py) */\n")

# libadwaita / GTK4
write("~/.config/gtk-4.0/gtk.css", f"""/* generado por palette.py */
@define-color accent_bg_color {P};
@define-color accent_color {P};
@define-color accent_fg_color {hexc(base)};
@define-color window_bg_color {hexc(base)};
@define-color window_fg_color {hexc(text)};
@define-color view_bg_color {hexc(mantle)};
@define-color view_fg_color {hexc(text)};
@define-color headerbar_bg_color {hexc(mantle)};
@define-color headerbar_fg_color {hexc(text)};
@define-color headerbar_border_color {hexc(surface1)};
@define-color card_bg_color {hexc(surface0)};
@define-color card_fg_color {hexc(text)};
@define-color sidebar_bg_color {hexc(mantle)};
@define-color sidebar_fg_color {hexc(text)};
@define-color popover_bg_color {hexc(surface0)};
@define-color popover_fg_color {hexc(text)};
@define-color dialog_bg_color {hexc(surface0)};
@define-color dialog_fg_color {hexc(text)};
@define-color destructive_bg_color {hexc(red)};
@define-color success_bg_color {hexc(green)};
@define-color warning_bg_color {hexc(yellow)};
@define-color error_bg_color {hexc(red)};
""")

# pywalfox (extensión de Firefox): formato de pywal
wal = {"wallpaper": open(f"{H}/.cache/wallpaper/current").read().strip() if os.path.exists(f"{H}/.cache/wallpaper/current") else "",
       "alpha": "100",
       "special": {"background": hexc(base), "foreground": hexc(text), "cursor": P},
       "colors": {f"color{i}": hexc(c) for i, c in enumerate(ansi + bright)}}
write("~/.cache/wal/colors.json", json.dumps(wal, indent=2))

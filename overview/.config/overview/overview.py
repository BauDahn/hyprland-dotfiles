#!/usr/bin/env python3
"""Overview a pantalla completa: la pantalla se divide en N partes iguales (una por ventana),
cada una con la captura de la ventana sobre un fondo difuminado."""
import json, math, os, subprocess

import cairo
import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
gi.require_version("GtkLayerShell", "0.1")
gi.require_version("Pango", "1.0")
gi.require_version("PangoCairo", "1.0")
from gi.repository import Gtk, Gdk, GdkPixbuf, GtkLayerShell, Pango, PangoCairo

CACHE = os.path.expanduser("~/.cache/rofi-windows")
MAUVE = (0xCB / 255, 0xA6 / 255, 0xF7 / 255)
TEXT = (0xCD / 255, 0xD6 / 255, 0xF4 / 255)
GAP = 14


def hypr(*args):
    return json.loads(subprocess.check_output(["hyprctl", *args, "-j"]))


def rounded(cr, x, y, w, h, r):
    cr.new_sub_path()
    cr.arc(x + w - r, y + r, r, -math.pi / 2, 0)
    cr.arc(x + w - r, y + h - r, r, 0, math.pi / 2)
    cr.arc(x + r, y + h - r, r, math.pi / 2, math.pi)
    cr.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2)
    cr.close_path()


def load_windows():
    os.makedirs(CACHE, exist_ok=True)
    clients = [c for c in hypr("clients") if c["mapped"] and c["workspace"]["id"] >= 0]
    active = {m["activeWorkspace"]["id"] for m in hypr("monitors")}
    # Capturar las visibles en alta calidad (antes de mostrar el overlay)
    procs = []
    for c in clients:
        if c["workspace"]["id"] in active:
            geo = f'{c["at"][0]},{c["at"][1]} {c["size"][0]}x{c["size"][1]}'
            procs.append(subprocess.Popen(
                ["grim", "-g", geo, f'{CACHE}/{c["address"]}.png'],
                stderr=subprocess.DEVNULL))
    for p in procs:
        p.wait()
    clients.sort(key=lambda c: (c["workspace"]["id"], c["at"][1], c["at"][0]))
    icons = Gtk.IconTheme.get_default()
    for c in clients:
        c["pix"], c["blur"], c["icon"] = None, None, None
        path = f'{CACHE}/{c["address"]}.png'
        try:
            c["pix"] = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, 1600, 1000, True)
            w, h = c["pix"].get_width(), c["pix"].get_height()
            small = c["pix"].scale_simple(max(2, w // 40), max(2, h // 40), GdkPixbuf.InterpType.BILINEAR)
            c["blur"] = small
        except Exception:
            pass
        for name in (c["class"], c["class"].lower(), "application-x-executable"):
            try:
                c["icon"] = icons.load_icon(name, 96, 0)
                break
            except Exception:
                continue
    return clients


class Overview(Gtk.Window):
    def __init__(self):
        super().__init__()
        self.wins = load_windows()
        if not self.wins:
            raise SystemExit
        n = len(self.wins)
        self.sel = 0
        if n > 1:
            by_hist = sorted(self.wins, key=lambda c: c.get("focusHistoryID", 99))
            self.sel = self.wins.index(by_hist[1]) if len(by_hist) > 1 else 0
        self.rects = []

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, "overview")
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.EXCLUSIVE)
        GtkLayerShell.set_exclusive_zone(self, -1)
        for edge in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM,
                     GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT):
            GtkLayerShell.set_anchor(self, edge, True)

        self.set_app_paintable(True)
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)
        self.area = Gtk.DrawingArea()
        self.area.add_events(Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.BUTTON_PRESS_MASK)
        self.area.connect("draw", self.on_draw)
        self.area.connect("motion-notify-event", self.on_motion)
        self.area.connect("button-press-event", self.on_click)
        self.add(self.area)
        self.connect("key-press-event", self.on_key)
        self.connect("destroy", Gtk.main_quit)

    # --- layout: N partes iguales ---
    def layout(self, W, H):
        n = len(self.wins)
        best = None
        for cols in range(1, n + 1):
            rows = math.ceil(n / cols)
            tw = (W - GAP * (cols + 1)) / cols
            th = (H - GAP * (rows + 1)) / rows
            score = abs(math.log((tw / th) / (W / H)))
            if best is None or score < best[0] - 1e-6 or (abs(score - best[0]) < 1e-6 and cols > best[1]):
                best = (score, cols, rows, tw, th)
        _, cols, rows, tw, th = best
        self.cols = cols
        rects = []
        for i in range(n):
            r, c = divmod(i, cols)
            in_row = cols if r < rows - 1 else n - cols * (rows - 1)
            off = (cols - in_row) * (tw + GAP) / 2
            rects.append((GAP + off + c * (tw + GAP), GAP + r * (th + GAP), tw, th))
        return rects

    def on_draw(self, widget, cr):
        W, H = widget.get_allocated_width(), widget.get_allocated_height()
        cr.set_source_rgba(0.067, 0.067, 0.106, 0.55)  # base oscura translúcida (el blur lo hace Hyprland)
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)
        self.rects = self.layout(W, H)
        for i, (c, (x, y, w, h)) in enumerate(zip(self.wins, self.rects)):
            self.draw_tile(cr, c, x, y, w, h, i == self.sel)
        return False

    def draw_tile(self, cr, c, x, y, w, h, selected):
        cr.save()
        rounded(cr, x, y, w, h, 22)
        cr.clip()
        # fondo: la propia captura, ampliada y difuminada
        if c["blur"]:
            bw, bh = c["blur"].get_width(), c["blur"].get_height()
            s = max(w / bw, h / bh)
            cr.save()
            cr.translate(x + (w - bw * s) / 2, y + (h - bh * s) / 2)
            cr.scale(s, s)
            Gdk.cairo_set_source_pixbuf(cr, c["blur"], 0, 0)
            cr.get_source().set_filter(cairo.FILTER_BILINEAR)
            cr.paint()
            cr.restore()
        cr.set_source_rgba(0.07, 0.07, 0.11, 0.45 if selected else 0.62)
        cr.paint()
        cr.restore()

        # captura nítida, ajustada al mosaico
        label_h = 44
        mx = 26
        aw, ah = w - 2 * mx, h - 2 * mx - label_h
        img = c["pix"] or c["icon"]
        if img and aw > 10 and ah > 10:
            iw, ih = img.get_width(), img.get_height()
            s = min(aw / iw, ah / ih)
            if not c["pix"]:
                s = min(s, 1.0)
            dw, dh = iw * s, ih * s
            dx, dy = x + (w - dw) / 2, y + mx + (ah - dh) / 2
            cr.save()
            rounded(cr, dx, dy, dw, dh, 12 if c["pix"] else 0)
            cr.clip()
            cr.translate(dx, dy)
            cr.scale(s, s)
            Gdk.cairo_set_source_pixbuf(cr, img, 0, 0)
            cr.paint()
            cr.restore()

        # título + workspace
        cr.save()
        layout = PangoCairo.create_layout(cr)
        layout.set_font_description(Pango.FontDescription("JetBrainsMono Nerd Font 12"))
        layout.set_width(int((w - 40) * Pango.SCALE))
        layout.set_ellipsize(Pango.EllipsizeMode.END)
        layout.set_alignment(Pango.Alignment.CENTER)
        layout.set_text(f'{c["title"] or c["class"]}   ·   {c["workspace"]["id"]}', -1)
        cr.set_source_rgb(*TEXT)
        cr.move_to(x + 20, y + h - label_h + 8)
        PangoCairo.show_layout(cr, layout)
        cr.restore()

        # borde de selección
        if selected:
            rounded(cr, x + 1.5, y + 1.5, w - 3, h - 3, 21)
            cr.set_source_rgb(*MAUVE)
            cr.set_line_width(3)
            cr.stroke()

    # --- interacción ---
    def tile_at(self, px, py):
        for i, (x, y, w, h) in enumerate(self.rects):
            if x <= px <= x + w and y <= py <= y + h:
                return i
        return None

    def on_motion(self, widget, ev):
        i = self.tile_at(ev.x, ev.y)
        if i is not None and i != self.sel:
            self.sel = i
            widget.queue_draw()

    def on_click(self, widget, ev):
        i = self.tile_at(ev.x, ev.y)
        if i is None:
            self.destroy()
        else:
            self.activate(i)

    def activate(self, i):
        addr = self.wins[i]["address"]
        subprocess.Popen(["hyprctl", "dispatch", "focuswindow", f"address:{addr}"],
                         stdout=subprocess.DEVNULL)
        self.destroy()

    def on_key(self, widget, ev):
        key = Gdk.keyval_name(ev.keyval)
        n = len(self.wins)
        cols = getattr(self, "cols", 1)
        if key in ("Escape", "q"):
            self.destroy()
        elif key in ("Return", "KP_Enter", "space"):
            self.activate(self.sel)
        elif key in ("Right", "l", "Tab"):
            self.sel = (self.sel + 1) % n
        elif key in ("Left", "h", "ISO_Left_Tab"):
            self.sel = (self.sel - 1) % n
        elif key in ("Down", "j"):
            self.sel = min(n - 1, self.sel + cols)
        elif key in ("Up", "k"):
            self.sel = max(0, self.sel - cols)
        elif key and key.isdigit() and 0 < int(key) <= n:
            self.activate(int(key) - 1)
            return True
        self.area.queue_draw()
        return True


if __name__ == "__main__":
    win = Overview()
    win.show_all()
    Gtk.main()

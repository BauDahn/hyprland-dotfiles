#!/usr/bin/env python3
# Popup de sensibilidad del ratón (Logitech) con la paleta de waybar (colors.css).
# Mismo porcentaje que muestra mouse_sens.sh: ((sens + 1) / 2) * 100.
# Se cierra con Esc o al volver a pulsar el módulo (nada automático).

import json
import os
import signal
import subprocess
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GLib, Gtk  # noqa: E402

DEVICE = "logitech-usb-receiver"
KEY = f"device[{DEVICE}]:sensitivity"
# Hyprland no expone la sensibilidad por dispositivo (getoption falla), así que
# guardamos el último valor aquí. Lo lee también mouse_sens.sh.
STATE = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "mouse-sensitivity"
DEFAULT_SENS = -0.2  # valor de hyprland/.config/hypr/input.conf
PIDFILE = Path(os.environ["XDG_RUNTIME_DIR"]) / "sens_slider.pid"
COLORS = Path.home() / ".config/waybar/colors.css"

CSS = """
window { background: transparent; }
.card {
    background-color: alpha(@base, 0.94);
    border: 1px solid alpha(@surface1, 0.8);
    border-radius: 16px;
    padding: 14px 18px 12px 18px;
}
.title { color: @subtext; font-size: 11px; font-weight: bold; }
.value { color: @mauve; font-size: 24px; font-weight: bold; }
.hint { color: @surface1; font-size: 10px; }
scale { margin: 6px 0 2px 0; }
scale trough {
    background-color: @surface0;
    border-radius: 6px;
    min-height: 6px;
}
scale highlight {
    background-image: linear-gradient(to right, @mauve, @lavender);
    border-radius: 6px;
}
scale slider {
    background-color: @text;
    border-radius: 50%;
    min-width: 16px;
    min-height: 16px;
    margin: -6px 0;
    box-shadow: 0 0 8px alpha(@mauve, 0.7);
}
"""


def hypr_json(*args):
    out = subprocess.run(["hyprctl", *args, "-j"], capture_output=True, text=True).stdout
    return json.loads(out) if out.strip() else {}


def read_sens():
    try:
        return float(STATE.read_text())
    except (OSError, ValueError):
        return DEFAULT_SENS


def sens_to_pct(sens):
    return round((sens + 1) / 2 * 100)


def pct_to_sens(pct):
    return round(pct / 50 - 1, 2)


def stop_running_instance():
    """Si ya hay un popup abierto lo cierra y devuelve True (toggle)."""
    try:
        pid = int(PIDFILE.read_text())
        cmdline = Path(f"/proc/{pid}/cmdline").read_bytes()
    except (OSError, ValueError):
        return False
    if b"sens_slider" not in cmdline:
        return False
    os.kill(pid, signal.SIGTERM)
    return True


class Popup(Gtk.Window):
    def __init__(self, pct):
        super().__init__(title="Sensibilidad")
        self.pending = None
        self.timer = 0

        self.set_decorated(False)
        self.set_resizable(False)
        self.set_skip_taskbar_hint(True)
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        visual = self.get_screen().get_rgba_visual()
        if visual:
            self.set_visual(visual)
        self.set_app_paintable(True)

        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        card.get_style_context().add_class("card")

        header = Gtk.Box()
        title = Gtk.Label(label="SENSIBILIDAD", xalign=0)
        title.get_style_context().add_class("title")
        self.value = Gtk.Label(label=f"{pct}%")
        self.value.get_style_context().add_class("value")
        header.pack_start(title, True, True, 0)
        header.pack_end(self.value, False, False, 0)

        self.scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.scale.set_value(pct)
        self.scale.set_draw_value(False)
        self.scale.set_size_request(240, -1)
        self.scale.connect("value-changed", self.on_changed)

        hint = Gtk.Label(label="rueda o arrastrar · Esc para cerrar", xalign=0)
        hint.get_style_context().add_class("hint")

        card.pack_start(header, False, False, 0)
        card.pack_start(self.scale, False, False, 0)
        card.pack_start(hint, False, False, 0)
        self.add(card)

        self.connect("key-press-event", self.on_key)
        self.connect("destroy", Gtk.main_quit)

    def on_key(self, _widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
            return True
        return False

    def on_changed(self, scale):
        pct = int(scale.get_value())
        self.value.set_text(f"{pct}%")
        # Debounce: agrupa los cambios rápidos al arrastrar en una sola llamada
        self.pending = pct_to_sens(pct)
        if not self.timer:
            self.timer = GLib.timeout_add(40, self.apply)

    def apply(self):
        self.timer = 0
        STATE.parent.mkdir(parents=True, exist_ok=True)
        STATE.write_text(f"{self.pending:.2f}\n")
        subprocess.run(["hyprctl", "keyword", KEY, f"{self.pending:.2f}"], capture_output=True)
        return False


def place_near_cursor(win):
    """Coloca el popup bajo el cursor, dentro del monitor donde está."""
    try:
        cur = hypr_json("cursorpos")
        cx, cy = int(cur["x"]), int(cur["y"])
    except (KeyError, TypeError, ValueError):
        return False
    w, _h = win.get_size()
    x, y = cx - w // 2, cy + 14

    display = Gdk.Display.get_default()
    monitor = display.get_monitor_at_point(cx, cy)
    if monitor:
        geo = monitor.get_geometry()
        x = max(geo.x + 8, min(x, geo.x + geo.width - w - 8))

    subprocess.run(
        ["hyprctl", "dispatch", "movewindowpixel", f"exact {x} {y},title:^Sensibilidad$"],
        capture_output=True,
    )
    return False


def main():
    if stop_running_instance():
        return

    PIDFILE.write_text(str(os.getpid()))

    provider = Gtk.CssProvider()
    provider.load_from_data((COLORS.read_text() + CSS).encode())
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    win = Popup(sens_to_pct(read_sens()))
    win.show_all()
    win.present()
    GLib.timeout_add(80, place_near_cursor, win)
    Gtk.main()

    PIDFILE.unlink(missing_ok=True)


if __name__ == "__main__":
    main()

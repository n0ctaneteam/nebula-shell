#!/usr/bin/env python3
"""Nebula Shell - default configuration with synthwave neon top bar."""

import gi

gi.require_version("GLib", "2.0")
from gi.repository import GLib
from datetime import datetime

from nebula_shell import Application
from nebula_shell.ui import (
    Panel,
    Box,
    Label,
    Icon,
    Separator,
    Spacer,
    Button,
    Stack,
    Orientation,
    Alignment,
    Anchor,
    Layer,
)
from nebula_shell.theme import Theme


def build_top_bar():
    """Build a synthwave-themed top bar."""
    bar = Panel()
    bar.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT
    bar.layer = Layer.TOP
    bar.exclusive = True
    bar.height = 38
    bar.set_id("top-bar")
    bar.add_style_class("top-bar")

    root = Box(orientation=Orientation.HORIZONTAL, name="bar-root")
    root.spacing = 2
    bar.add(root)

    # ── Left: workspace indicators ──
    left = Box(orientation=Orientation.HORIZONTAL, name="bar-left")
    left.spacing = 4
    left.add_style_class("bar-left")

    for ws in ("1", "2", "3", "4"):
        btn = Button(label=ws)
        btn.set_id(f"ws-{ws}")
        btn.add_style_class("workspace-btn")
        if ws == "1":
            btn.add_style_class("active")

        def make_switch(w):
            def switch():
                print(f"Switch to workspace {w}")

            return switch

        btn.connect("clicked", make_switch(ws))
        left.append(btn)

    root.append(left)

    # Separator with synthwave glow
    sep1 = Separator(orientation=Orientation.VERTICAL)
    sep1.thickness = 2
    sep1.add_style_class("bar-separator")
    root.append(sep1)

    # ── Center: clock + date ──
    center = Box(orientation=Orientation.VERTICAL, name="bar-center")
    center.alignment = Alignment.CENTER
    center.add_style_class("bar-center")

    clock = Label(text="00:00:00")
    clock.set_id("clock")
    clock.add_style_class("clock-text")

    date_lbl = Label(text="---")
    date_lbl.set_id("date")
    date_lbl.add_style_class("date-text")

    center.append(clock)
    center.append(date_lbl)
    root.append(center)

    sep2 = Separator(orientation=Orientation.VERTICAL)
    sep2.thickness = 2
    sep2.add_style_class("bar-separator")
    root.append(sep2)

    # ── Right: system tray ──
    right = Box(orientation=Orientation.HORIZONTAL, name="bar-right")
    right.spacing = 6
    right.add_style_class("bar-right")

    icons = {
        "audio-volume-high-symbolic": "volume",
        "network-wireless-signal-good-symbolic": "wifi",
        "battery-good-symbolic": "battery",
    }
    for name, cid in icons.items():
        ic = Icon(icon_name=name)
        ic.pixel_size = 18
        ic.set_id(cid)
        ic.add_style_class("tray-icon")
        right.append(ic)

    root.append(right)

    # ── Clock update ──
    def tick():
        now = datetime.now()
        clock.text = now.strftime("%H:%M:%S")
        date_lbl.text = now.strftime("%a %b %d")
        return True

    GLib.timeout_add_seconds(1, tick)
    tick()
    return bar


def main():
    app = Application()

    # Load synthwave theme
    Theme.load_css_string(open("shell.css").read())

    bar = build_top_bar()
    bar.show()
    app.run()


if __name__ == "__main__":
    main()

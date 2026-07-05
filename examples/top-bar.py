#!/usr/bin/env python3
"""Example: top bar with workspaces, clock, and system tray."""

import gi

gi.require_version("GLib", "2.0")
from gi.repository import GLib

from nebula_shell import Application
from nebula_shell.ui import (
    Panel,
    Box,
    Label,
    Button,
    Icon,
    Separator,
    Spacer,
    Orientation,
    Anchor,
    Alignment,
    Layer,
)


def build_top_bar():
    """Build the top bar panel with three sections."""
    bar = Panel()
    bar.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT
    bar.layer = Layer.TOP
    bar.exclusive = True
    bar.height = 36
    bar.add_style_class("top-bar")
    bar.set_id("top-bar")

    # Root horizontal layout
    root = Box(orientation=Orientation.HORIZONTAL)
    root.spacing = 4
    bar.add(root)

    # ── Left section: workspaces ──
    left = Box(orientation=Orientation.HORIZONTAL)
    left.spacing = 2
    left.add_style_class("bar-left")

    for i in range(1, 5):
        ws_label = Label(text=str(i))
        ws_label.add_style_class("workspace")
        if i == 1:
            ws_label.add_style_class("active")
        left.append(ws_label)

    root.append(left)
    root.append(Separator(orientation=Orientation.VERTICAL, name="sep1"))

    # ── Center section: clock ──
    center = Box(orientation=Orientation.HORIZONTAL)
    center.alignment = Alignment.CENTER
    center.add_style_class("bar-center")

    clock_label = Label(text="--:--:--")
    clock_label.add_style_class("clock")
    clock_label.set_id("clock")
    center.append(clock_label)

    date_label = Label(text="---")
    date_label.add_style_class("date")
    center.append(date_label)

    root.append(center)
    root.append(Separator(orientation=Orientation.VERTICAL, name="sep2"))

    # ── Right section: system tray ──
    right = Box(orientation=Orientation.HORIZONTAL)
    right.spacing = 4
    right.add_style_class("bar-right")

    battery_icon = Icon(icon_name="battery-symbolic")
    battery_icon.pixel_size = 18
    battery_icon.add_style_class("tray-icon")
    right.append(battery_icon)

    vol_icon = Icon(icon_name="audio-volume-high-symbolic")
    vol_icon.pixel_size = 18
    vol_icon.add_style_class("tray-icon")
    right.append(vol_icon)

    wifi_icon = Icon(icon_name="network-wireless-signal-good-symbolic")
    wifi_icon.pixel_size = 18
    wifi_icon.add_style_class("tray-icon")
    right.append(wifi_icon)

    root.append(right)

    # ── Clock update timer ──
    def update_clock():
        from datetime import datetime

        now = datetime.now()
        clock_label.text = now.strftime("%H:%M:%S")
        date_label.text = now.strftime("%a %b %d")
        return True  # keep timer alive

    GLib.timeout_add_seconds(1, update_clock)
    update_clock()  # immediate first render

    return bar


def main():
    app = Application()
    bar = build_top_bar()
    bar.show()
    app.run()


if __name__ == "__main__":
    main()

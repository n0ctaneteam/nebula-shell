#!/usr/bin/env python3
"""Example: desktop clock widget with sci-fi styling."""

import gi

gi.require_version("GLib", "2.0")
from gi.repository import GLib
from datetime import datetime

from nebula_shell import Application
from nebula_shell.ui import (
    Panel,
    Box,
    Label,
    Orientation,
    Anchor,
    Layer,
)


def build_clock_widget():
    """Build a floating desktop clock."""
    clock_panel = Panel()
    clock_panel.anchor = Anchor.RIGHT | Anchor.BOTTOM
    clock_panel.layer = Layer.BOTTOM
    clock_panel.exclusive = False
    clock_panel.height = 200
    clock_panel.width = 400
    clock_panel.add_style_class("clock-widget")
    clock_panel.set_id("clock-widget")

    # Margin from screen edges
    clock_panel.margin_right = 24
    clock_panel.margin_bottom = 24

    # Vertical box: time on top, date below
    root = Box(orientation=Orientation.VERTICAL, name="clock-root")
    root.alignment = 1  # center

    time_label = Label(text="00:00:00")
    time_label.add_style_class("clock-time")
    time_label.set_id("clock-time")

    date_label = Label(text="---")
    date_label.add_style_class("clock-date")
    date_label.set_id("clock-date")

    root.append(time_label)
    root.append(date_label)
    clock_panel.add(root)

    # Update every second
    def update():
        now = datetime.now()
        time_label.text = now.strftime("%H:%M:%S")
        date_label.text = now.strftime("%A, %B %d, %Y")
        return True

    GLib.timeout_add_seconds(1, update)
    update()
    return clock_panel


def main():
    app = Application()
    widget = build_clock_widget()
    widget.show()
    app.run()


if __name__ == "__main__":
    main()

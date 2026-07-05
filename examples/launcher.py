#!/usr/bin/env python3
"""Example: app launcher with search and grid."""

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
    Entry,
    Grid,
    Stack,
    Separator,
    Overlay,
    Orientation,
    Alignment,
    Anchor,
    Layer,
    GridAlignment,
)

APPS = [
    ("firefox", "Firefox"),
    ("terminal", "Terminal"),
    ("files", "Files"),
    ("settings", "Settings"),
    ("camera", "Camera"),
    ("music", "Music"),
    ("calendar", "Calendar"),
    ("calculator", "Calc"),
    ("maps", "Maps"),
    ("notes", "Notes"),
    ("code", "Code"),
    ("chat", "Chat"),
]


def build_launcher():
    """Build a launcher overlay panel."""
    panel = Panel()
    panel.anchor = Anchor.TOP
    panel.layer = Layer.OVERLAY
    panel.exclusive = False
    panel.height = 500
    panel.width = 600
    panel.set_id("launcher")
    panel.add_style_class("launcher")

    root = Box(orientation=Orientation.VERTICAL)

    # Category tabs (buttons in a horizontal row)
    tabs = Box(orientation=Orientation.HORIZONTAL, name="tabs")
    tabs.spacing = 4
    tabs.add_style_class("launcher-tabs")

    buttons = []
    for cat in ("All", "Dev", "Media", "System"):
        btn = Button(label=cat)
        btn.add_style_class("tab-button")
        tabs.append(btn)
        buttons.append(btn)

    root.append(tabs)

    # Separator
    root.append(Separator(orientation=Orientation.HORIZONTAL))

    # Search entry
    search = Entry(text="", name="search")
    search.placeholder = "Search apps..."
    search.add_style_class("search-entry")

    def on_search_activated(text):
        print(f"Launch: {text}")

    search.connect("activated", on_search_activated)
    root.append(search)

    # App grid
    grid = Grid(name="app-grid")
    grid.rows = 3
    grid.columns = 4
    grid.row_spacing = 8
    grid.column_spacing = 8
    grid.add_style_class("app-grid")

    for i, (icon_name, label_text) in enumerate(APPS):
        col = i % 4
        row = i // 4

        cell = Box(orientation=Orientation.VERTICAL, name=f"app-{icon_name}")
        cell.alignment = Alignment.CENTER
        cell.add_style_class("app-cell")

        icon_w = Icon(icon_name=f"{icon_name}-symbolic")
        icon_w.pixel_size = 32
        icon_w.add_style_class("app-icon")

        label_w = Label(text=label_text)
        label_w.add_style_class("app-label")

        cell.append(icon_w)
        cell.append(label_w)
        grid.attach(cell, col, row)

    root.append(grid)
    panel.add(root)
    return panel


def main():
    app = Application()
    launcher = build_launcher()
    launcher.show()
    app.run()


if __name__ == "__main__":
    main()

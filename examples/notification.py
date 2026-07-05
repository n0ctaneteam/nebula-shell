#!/usr/bin/env python3
"""Example: notification popup with auto-hide."""

import gi

gi.require_version("GLib", "2.0")
from gi.repository import GLib

from nebula_shell import Application
from nebula_shell.ui import (
    Panel,
    Box,
    Label,
    Icon,
    Button,
    Overlay,
    Stack,
    Separator,
    Spacer,
    Orientation,
    Anchor,
    Layer,
    OverlayAlignment,
)


NOTIFICATIONS = [
    ("dialog-information", "System Updated", "All packages are up to date."),
    ("dialog-warning", "Low Battery", "Battery at 15%. Plug in charger."),
    ("dialog-question", "VPN Disconnected", "Reconnect? Tap to retry."),
    ("network-offline", "No Network", "Check your connection."),
]


def build_notification_widget():
    """Build a notification overlay panel."""
    panel = Panel()
    panel.anchor = Anchor.TOP | Anchor.RIGHT
    panel.layer = Layer.OVERLAY
    panel.exclusive = False
    panel.width = 380
    panel.height = 520
    panel.margin_top = 48
    panel.margin_right = 16
    panel.set_id("notification-panel")
    panel.add_style_class("notification-panel")

    # Stack for multiple notifications
    stack = Stack(name="notif-stack")
    stack.animate_transitions = True
    stack.add_style_class("notification-stack")

    for i, (icon_name, title, message) in enumerate(NOTIFICATIONS):
        card = Box(orientation=Orientation.VERTICAL)
        card.add_style_class("notification-card")
        card.set_id(f"notif-{i}")

        header = Box(orientation=Orientation.HORIZONTAL)
        header.spacing = 8
        header.add_style_class("notif-header")

        icon_w = Icon(icon_name=icon_name)
        icon_w.pixel_size = 24
        header.append(icon_w)

        title_lbl = Label(text=title)
        title_lbl.add_style_class("notif-title")
        header.append(title_lbl)

        header.append(Spacer(expand=True))

        close_btn = Button(label="×")
        close_btn.add_style_class("notif-close")

        def make_dismiss(pan=panel):
            def dismiss():
                pan.hide()
                return False

            return dismiss

        close_btn.connect("clicked", make_dismiss(panel))
        header.append(close_btn)

        card.append(header)
        card.append(Separator(orientation=Orientation.HORIZONTAL))

        msg_lbl = Label(text=message)
        msg_lbl.wrap = True
        msg_lbl.max_width = 340
        msg_lbl.add_style_class("notif-message")
        card.append(msg_lbl)

        stack.add_named(f"notif-{i}", card)

    panel.add(stack)
    return panel, stack


def main():
    app = Application()
    panel, stack = build_notification_widget()
    panel.show()

    # Cycle through notifications every 4 seconds
    index = [0]

    def cycle():
        stack.visible_child_index = index[0]
        index[0] = (index[0] + 1) % stack.child_count
        return True

    GLib.timeout_add_seconds(4, cycle)
    cycle()
    app.run()


if __name__ == "__main__":
    main()

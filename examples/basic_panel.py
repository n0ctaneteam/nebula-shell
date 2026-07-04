"""
Basic Panel Example

This example demonstrates how to create a simple top panel
using the Nebula Shell Python API.

The panel displays a clock and a battery indicator.
"""

import nebula_shell
from nebula_shell.ui import Box, Label, Button, Orientation, Spacer
from nebula_shell.services import BatteryService, AudioService


def main():
    """Create and run a basic panel."""
    app = nebula_shell.Application()

    panel = Box(Orientation.HORIZONTAL, name="top-panel")
    panel.spacing = 8

    time_label = Label("12:00", name="clock")
    time_label.add_style_class("clock")

    battery_label = Label("100%", name="battery")
    battery_label.add_style_class("battery")

    battery = BatteryService.default()

    def update_battery():
        battery_label.text = f"{battery.percentage}%"
        if battery.percentage > 50:
            battery_label.add_style_class("high")
        elif battery.percentage > 20:
            battery_label.add_style_class("medium")
        else:
            battery_label.add_style_class("low")

    battery.connect("changed", update_battery)

    spacer = Spacer()

    quit_button = Button("Quit", name="quit-btn")
    quit_button.add_style_class("quit")
    quit_button.connect("clicked", lambda: app.quit())

    panel.append(time_label)
    panel.append(spacer)
    panel.append(battery_label)
    panel.append(quit_button)

    app.run()


if __name__ == "__main__":
    main()

# Nebula Shell Examples

Version: 1.0.0

Example code and explanations for building Nebula Shell components.

---

# Table of Contents

- [Basic Panel](#basic-panel)
- [Status Bar](#status-bar)
- [Notification Popup](#notification-popup)
- [Launcher](#launcher)
- [Battery Widget](#battery-widget)
- [Reactive Bindings](#reactive-bindings)
- [Animations](#animations)
- [Custom Styling](#custom-styling)
- [Grid Layout](#grid-layout)
- [Stacked Pages](#stacked-pages)

---

# Basic Panel

A simple top panel with clock and battery indicator.

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Button, Orientation, Spacer
from nebula_shell.services import BatteryService
from nebula_shell import Anchor

app = nebula_shell.Application()

# Create panel container
panel = Box(Orientation.HORIZONTAL)
panel.spacing = 8
panel.name = "top-panel"

# Clock label
time_label = Label.with_name_and_text("clock", "12:00")
time_label.add_style_class("clock")

# Battery label
battery_label = Label.with_name_and_text("battery", "100%")
battery_label.add_style_class("battery")

# Subscribe to battery service
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

# Spacer pushes quit button to right
spacer = Spacer()

# Quit button
quit_button = Button.with_name_and_label("quit-btn", "Quit")
quit_button.add_style_class("quit")
quit_button.clicked.connect(lambda: app.quit())

# Assemble panel
panel.append(time_label)
panel.append(spacer)
panel.append(battery_label)
panel.append(quit_button)

app.run()
```

**Explanation:**
- Creates horizontal box layout
- Adds clock and battery labels
- Subscribes to BatteryService for updates
- Uses Spacer to push button to right
- Button triggers application quit

---

# Status Bar

A comprehensive status bar with multiple indicators.

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Icon, Separator, Orientation, Spacer
from nebula_shell.services import AudioService, NetworkService
from nebula_shell import Anchor

app = nebula_shell.Application()

bar = Box(Orientation.HORIZONTAL)
bar.spacing = 12
bar.name = "status-bar"

# Workspace indicator
workspace_label = Label.with_name_and_text("workspace", "1")
workspace_label.add_style_class("workspace")

# Separator
sep1 = Separator.with_orientation(Orientation.VERTICAL)
sep1.thickness = 1

# Audio icon and volume
audio_icon = Icon.with_name("audio-volume-high")
audio_icon.pixel_size = 16

volume_label = Label.with_name_and_text("volume", "100%")
volume_label.add_style_class("volume")

audio = AudioService.default()

def update_audio():
    volume_label.text = f"{audio.volume}%"
    if audio.muted:
        audio_icon.icon_name = "audio-volume-muted"
    elif audio.volume > 66:
        audio_icon.icon_name = "audio-volume-high"
    elif audio.volume > 33:
        audio_icon.icon_name = "audio-volume-medium"
    else:
        audio_icon.icon_name = "audio-volume-low"

audio.connect("changed", update_audio)

# Network indicator
network_icon = Icon.with_name("network-wired")
network_icon.pixel_size = 16

network = NetworkService.default()

def update_network():
    if network.connected:
        network_icon.icon_name = "network-wired"
    else:
        network_icon.icon_name = "network-offline"

network.connect("changed", update_network)

# Spacer
spacer = Spacer()

# Clock
clock_label = Label.with_name_and_text("clock", "12:00")
clock_label.add_style_class("clock")

# Assemble
bar.append(workspace_label)
bar.append(sep1)
bar.append(audio_icon)
bar.append(volume_label)
bar.append(spacer)
bar.append(network_icon)
bar.append(clock_label)

app.run()
```

---

# Notification Popup

A notification overlay that displays messages.

```python
import nebula_shell
from nebula_shell.ui import Overlay, Box, Label, Button, Orientation
from nebula_shell import OverlayAlignment, Layer

app = nebula_shell.Application()

# Notification container
notifications = Overlay()
notifications.name = "notifications"
notifications.default_alignment = OverlayAlignment.TOP_RIGHT

# Track notification count
notification_count = 0

def show_notification(title, message):
    global notification_count

    # Create notification box
    notif_box = Box(Orientation.VERTICAL)
    notif_box.spacing = 4
    notif_box.name = f"notification-{notification_count}"
    notif_box.add_style_class("notification")

    # Title
    title_label = Label.with_text(title)
    title_label.add_style_class("notification-title")

    # Message
    msg_label = Label.with_text(message)
    msg_label.wrap = True
    msg_label.max_width = 300
    msg_label.add_style_class("notification-message")

    # Dismiss button
    dismiss = Button.with_label("×")
    dismiss.add_style_class("notification-dismiss")
    dismiss.clicked.connect(lambda: dismiss_notification(notif_box))

    notif_box.append(title_label)
    notif_box.append(msg_label)
    notif_box.append(dismiss)

    # Add to overlay
    notifications.append(notif_box)
    notifications.set_child_alignment(notif_box, OverlayAlignment.TOP_RIGHT)

    notification_count += 1

def dismiss_notification(widget):
    notifications.remove(widget)

# Show example notification
show_notification("Hello", "This is a test notification")

app.run()
```

---

# Launcher

A popup launcher for searching applications.

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Entry, Stack, Orientation
from nebula_shell import Anchor, Layer, KeyboardMode

app = nebula_shell.Application()

# Launcher window
launcher = Box(Orientation.VERTICAL)
launcher.spacing = 8
launcher.name = "launcher"

# Search entry
search = Entry.with_text_and_placeholder("", "Search applications...")
search.add_style_class("launcher-search")

# Results stack
results = Stack()
results.name = "launcher-results"

# Default page
default_label = Label.with_text("Type to search...")
default_label.add_style_class("launcher-hint")
results.append(default_label)

# Results page
results_list = Box(Orientation.VERTICAL)
results_list.spacing = 4
results_list.name = "results-list"
results_list.append(Label.with_text("Firefox"))
results_list.append(Label.with_text("Files"))
results_list.append(Label.with_text("Terminal"))
results.append(results_list)

# Handle search input
def on_search(text):
    if text:
        results.visible_child_name = "results-list"
    else:
        results.visible_child_index = 0

search.activated.connect(on_search)

# Assemble launcher
launcher.append(search)
launcher.append(results)

app.run()
```

---

# Battery Widget

A dedicated battery display widget.

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Icon, Orientation
from nebula_shell.services import BatteryService
from nebula_shell import Property

app = nebula_shell.Application()

battery_container = Box(Orientation.HORIZONTAL)
battery_container.spacing = 8
battery_container.name = "battery-widget"

# Battery icon
battery_icon = Icon.with_name("battery-full")
battery_icon.pixel_size = 24
battery_icon.add_style_class("battery-icon")

# Battery percentage
battery_label = Label.with_name_and_text("battery-text", "100%")
battery_label.add_style_class("battery-text")

# Reactive properties
battery_level = Property("level", 100)
is_charging = Property("charging", False)

# Bind label to battery level
battery_label.bind(battery_level.value, lambda v: f"{v}%")

# Update icon based on level
def update_icon(level):
    if level > 90:
        battery_icon.icon_name = "battery-full"
    elif level > 60:
        battery_icon.icon_name = "battery-good"
    elif level > 30:
        battery_icon.icon_name = "battery-medium"
    elif level > 10:
        battery_icon.icon_name = "battery-low"
    else:
        battery_icon.icon_name = "battery-caution"

battery_level.value_changed.connect(lambda n, v: update_icon(v))

# Subscribe to battery service
battery = BatteryService.default()

def on_battery_changed():
    battery_level.value = battery.percentage
    is_charging.value = battery.charging

battery.connect("changed", on_battery_changed)

# Assemble
battery_container.append(battery_icon)
battery_container.append(battery_label)

app.run()
```

---

# Reactive Bindings

Demonstrating the reactive system.

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Entry, Orientation
from nebula_shell import Property

app = nebula_shell.Application()

container = Box(Orientation.VERTICAL)
container.spacing = 8

# Source property
input_text = Property("input", "")

# Entry for input
entry = Entry()
entry.placeholder = "Type something..."
entry.activated.connect(lambda text: setattr(input_text, 'value', text))

# Label bound to input
output_label = Label.with_text("")
output_label.bind(input_text.value, lambda v: f"You typed: {v}")

# Character count bound to input
count_label = Label.with_text("0 characters")
count_label.bind(input_text.value, lambda v: f"{len(v)} characters")

# Two-way binding demonstration
mirror_property = Property("mirror", "")
input_text.bind_two_way(mirror_property)

container.append(entry)
container.append(output_label)
container.append(count_label)

app.run()
```

---

# Animations

Using the animation system.

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Button, Orientation
from nebula_shell.animation import FadeAnimation
from nebula_shell import Easing

app = nebula_shell.Application()

container = Box(Orientation.VERTICAL)
container.spacing = 8

# Target label
target = Label.with_text("Animate me!")
target.add_style_class("animated")

# Fade in animation
fade_in = FadeAnimation.fade_in("fade-in")
fade_in.duration = 500
fade_in.easing = Easing.ease_out

# Fade out animation
fade_out = FadeAnimation.fade_out("fade-out")
fade_out.duration = 500
fade_out.easing = Easing.ease_in

# Show button
show_btn = Button.with_label("Show")
show_btn.clicked.connect(lambda: fade_in.start())

# Hide button
hide_btn = Button.with_label("Hide")
hide_btn.clicked.connect(lambda: fade_out.start())

# Toggle button
toggle_btn = Button.with_label("Toggle")

def toggle():
    if fade_in.is_running:
        fade_in.cancel()
    elif fade_out.is_running:
        fade_out.cancel()
    else:
        fade_in.start()

toggle_btn.clicked.connect(toggle)

container.append(target)
container.append(show_btn)
container.append(hide_btn)
container.append(toggle_btn)

app.run()
```

---

# Custom Styling

Applying CSS styles to widgets.

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Button, Orientation
from nebula_shell import ThemeManager

app = nebula_shell.Application()

# Load custom theme
theme_manager = ThemeManager.default()
theme = Theme("custom", "/path/to/custom.css")
theme_manager.load(theme)

container = Box(Orientation.VERTICAL)
container.spacing = 8

# Widget with CSS class
label1 = Label.with_text("Styled with class")
label1.add_style_class("primary")
label1.add_style_class("large")

# Widget with CSS ID
label2 = Label.with_text("Styled with ID")
label2.set_id("special-label")

# Widget with inline CSS
label3 = Label.with_text("Inline styled")
label3.set_inline_css("color: blue; font-weight: bold;")

# Widget with pseudo-class
button = Button.with_label("Hover me")
button.set_pseudo_class("hover", True)

container.append(label1)
container.append(label2)
container.append(label3)
container.append(button)

app.run()
```

---

# Grid Layout

Creating grid-based interfaces.

```python
import nebula_shell
from nebula_shell.ui import Grid, Label, Box, Orientation
from nebula_shell import GridAlignment

app = nebula_shell.Application()

# Calculator-like grid
grid = Grid()
grid.rows = 4
grid.columns = 3
grid.row_spacing = 4
grid.column_spacing = 4
grid.row_alignment = GridAlignment.FILL
grid.column_alignment = GridAlignment.FILL

# Number pad layout
buttons = [
    ["7", "8", "9"],
    ["4", "5", "6"],
    ["1", "2", "3"],
    ["0", ".", "="]
]

for row_idx, row in enumerate(buttons):
    for col_idx, text in enumerate(row):
        btn = Label.with_text(text)
        btn.add_style_class("calculator-button")
        grid.attach(btn, col_idx, row_idx)

app.run()
```

---

# Stacked Pages

Creating tabbed interfaces.

```python
import nebula_shell
from nebula_shell.ui import Stack, Box, Label, Button, Orientation
from nebula_shell import OverlayAlignment

app = nebula_shell.Application()

container = Box(Orientation.VERTICAL)
container.spacing = 8

# Navigation buttons
nav = Box(Orientation.HORIZONTAL)
nav.spacing = 4

page1_btn = Button.with_label("Page 1")
page2_btn = Button.with_label("Page 2")
page3_btn = Button.with_label("Page 3")

# Stack with pages
stack = Stack()
stack.animate_transitions = True

page1 = Label.with_text("This is Page 1")
page1.add_style_class("page")

page2 = Label.with_text("This is Page 2")
page2.add_style_class("page")

page3 = Label.with_text("This is Page 3")
page3.add_style_class("page")

stack.append(page1)
stack.append(page2)
stack.append(page3)

# Wire up navigation
page1_btn.clicked.connect(lambda: setattr(stack, 'visible_child_index', 0))
page2_btn.clicked.connect(lambda: setattr(stack, 'visible_child_index', 1))
page3_btn.clicked.connect(lambda: setattr(stack, 'visible_child_index', 2))

nav.append(page1_btn)
nav.append(page2_btn)
nav.append(page3_btn)

container.append(nav)
container.append(stack)

app.run()
```

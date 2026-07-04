# Getting Started with Nebula Shell

Version: 0.1.0

This guide walks you through creating your first Nebula Shell desktop component.

---

# Prerequisites

Requirements:

- Linux with Wayland compositor (Hyprland recommended)
- Python 3.10+
- Nebula Shell installed

---

# Installation

From source:

```bash
git clone https://github.com/n0ctaneteam/nebula-shell.git
cd nebula-shell
meson setup builddir
ninja -C builddir
ninja -C builddir install
```

---

# Your First Component

Create a file named `panel.py`:

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Orientation

app = nebula_shell.Application()

panel = Box(Orientation.HORIZONTAL)
panel.spacing = 8
panel.append(Label("Hello, Nebula Shell!"))

app.run()
```

Run it:

```bash
nebula-shell panel.py
```

---

# Core Concepts

## Application

Application owns the lifecycle. Always create one first.

```python
app = nebula_shell.Application()
```

## Windows

Windows are layer shell surfaces. Types:

- Panel: docks, taskbars
- Popup: temporary floating windows
- Overlay: notifications, OSD

## Widgets

Widgets display information. Never fetch data directly.

Basic widgets:

- Label: text display
- Button: clickable element
- Icon: themed icons
- Image: file-based images
- Entry: text input
- Separator: visual divider
- Spacer: flexible spacing

## Containers

Containers hold child widgets:

- Box: single-line layout
- Grid: two-dimensional layout
- Stack: switchable pages
- Overlay: floating layers

## Services

Services own system state:

- BatteryService
- AudioService
- BluetoothService
- MediaService
- WorkspaceService
- NetworkService

---

# Adding Widgets

## Box Layout

```python
from nebula_shell.ui import Box, Label, Orientation

box = Box(Orientation.HORIZONTAL)
box.spacing = 8
box.append(Label("First"))
box.append(Label("Second"))
```

## Grid Layout

```python
from nebula_shell.ui import Grid, Label

grid = Grid()
grid.rows = 2
grid.columns = 2
grid.attach(Label("0,0"), 0, 0)
grid.attach(Label("1,0"), 1, 0)
```

## Stack (Pages)

```python
from nebula_shell.ui import Stack, Label

stack = Stack()
stack.append(Label("Page 1"))
stack.append(Label("Page 2"))
stack.visible_child_index = 0
```

---

# Using Services

## Battery

```python
from nebula_shell.services import BatteryService

battery = BatteryService.default()
print(f"Battery: {battery.percentage}%")

battery.connect("changed", lambda: print("Battery updated"))
```

## Audio

```python
from nebula_shell.services import AudioService

audio = AudioService.default()
print(f"Volume: {audio.volume}")
audio.volume = 75
```

---

# Styling

## CSS Classes

```python
label = Label("Styled")
label.add_style_class("primary")
label.set_id("status-label")
```

## Inline CSS

```python
label.set_inline_css("color: red; font-size: 16px;")
```

---

# Reactivity

## Properties

```python
from nebula_shell import Property

volume = Property("volume", 50)
volume.value = 75
```

## Bindings

```python
label.bind(battery.percentage, lambda p: f"{p}%")
```

---

# Configuration

Configuration is Python. No custom DSL.

```python
# config.py
from nebula_shell import *

app = Application()
panel = Panel()
panel.anchor = Anchor.TOP
panel.height = 32
panel.show()
app.run()
```

---

# Next Steps

- Read the API Reference
- Explore the examples directory
- Check the CONTRIBUTING guide

# Icon

A widget that renders a named icon from the current icon theme. `Icon` is the standard way to display symbolic icons in toolbars, buttons, status indicators, and menus throughout a Nebula Shell interface.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
       └── NebulaShell.Icon
```

Python alias: `nebula_shell.ui.icon.Icon`

---

## Constructor

### `Icon(icon_name="", name=None)`

| Parameter   | Type   | Default | Description                                               |
|-------------|--------|---------|-----------------------------------------------------------|
| `icon_name` | `str`  | `""`    | The named icon to display (e.g. `"folder-open-symbolic"`). |
| `name`      | `str`  | `None`  | Optional widget name for CSS styling and identification.  |

Creates an icon widget. If `icon_name` is empty the widget renders blank until `icon_name` is set.

---

## Properties

| Property    | Type   | Default | Description                                                     |
|-------------|--------|---------|-----------------------------------------------------------------|
| `icon_name` | `str`  | `""`    | The themed icon name. Setting this loads the new icon and emits `icon_name_changed`. |
| `pixel_size`| `int`  | `-1`    | Desired icon size in pixels. `-1` means use the default icon size from the theme. |
| `visible`   | `bool` | `True`  | Inherited from `Widget`.                                        |
| `tooltip`   | `str`  | `""`    | Inherited from `Widget`.                                        |
| `name`      | `str`  | `""`    | Inherited from `Widget`.                                        |

---

## Methods

This widget inherits all methods from `NebulaShell.Widget`:

| Method      | Parameters | Returns  | Description                              |
|-------------|------------|----------|------------------------------------------|
| `show()`    | —          | `None`   | Makes the icon visible.                  |
| `hide()`    | —          | `None`   | Hides the icon.                          |
| `destroy()` | —          | `None`   | Destroys the icon widget.                |

---

## Signals

| Signal              | Parameters             | Description                                              |
|---------------------|------------------------|----------------------------------------------------------|
| `icon_name_changed` | `new_name: str`        | Emitted when the `icon_name` property changes. The new icon name is passed as the argument. |

Inherited from `Widget`:

| Signal      | Parameters | Description                                     |
|-------------|------------|-------------------------------------------------|
| `shown`     | —          | Emitted when the icon becomes visible.          |
| `hidden`    | —          | Emitted when the icon is hidden.                |
| `destroyed` | —          | Emitted just before the icon is destroyed.      |

---

## Example

```python
from nebula_shell.ui.icon import Icon

# Create an icon from the current theme
battery = Icon(icon_name="battery-full-symbolic")
battery.pixel_size = 24

# React to icon changes
def on_icon_changed(new_name):
    print(f"Icon changed to: {new_name}")

battery.connect("icon_name_changed", on_icon_changed)

# Swap icons at runtime based on state
battery.icon_name = "battery-low-symbolic"

# Simple status icon at default theme size
notification = Icon(icon_name="bell-symbolic")
print(notification.icon_name)   # "bell-symbolic"
print(notification.pixel_size)  # -1 (theme default)
```


# Widget

Base class for all Nebula Shell UI elements. Every visible component in a Nebula Shell application inherits from `Widget`.

`Widget` provides the fundamental lifecycle (show, hide, destroy), visual properties (visibility, tooltip, name), and style management (CSS classes). It also implements the signal connection and disconnection machinery used throughout the framework.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
```

Python alias: `nebula_shell.ui.widget.Widget`

---

## Constructor

### `Widget(name=None)`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name`    | `str` | `None`  | Optional widget name used for CSS styling and identification |

Creates a new widget with an optional name. The widget is visible by default once added to a parent container.

---

## Properties

| Property   | Type   | Default | Description                                          |
|------------|--------|---------|------------------------------------------------------|
| `visible`  | `bool` | `True`  | Whether the widget is visible. Hiding also prevents layout allocation. |
| `tooltip`  | `str`  | `""`    | Tooltip text shown on hover.                         |
| `name`     | `str`  | `""`    | Widget name used for CSS selectors and identification. |

---

## Methods

| Method               | Parameters                       | Returns    | Description                                               |
|----------------------|----------------------------------|------------|-----------------------------------------------------------|
| `show()`             | —                                | `None`     | Makes the widget visible. Emits the `shown` signal.       |
| `hide()`             | —                                | `None`     | Hides the widget. Emits the `hidden` signal.              |
| `destroy()`          | —                                | `None`     | Destroys the widget and releases all resources. Emits `destroyed`. |
| `add_style_class()`  | `class_name: str`                | `None`     | Adds a CSS class to the widget.                           |
| `remove_style_class()` | `class_name: str`              | `None`     | Removes a CSS class from the widget.                      |
| `has_style_class()`  | `class_name: str`                | `bool`     | Returns `True` if the widget has the given CSS class.     |
| `connect()`          | `signal: str, callback: callable` | `int`    | Connects a callback to a signal. Returns the handler ID.  |
| `disconnect()`       | `handler_id: int`                | `None`     | Disconnects a previously connected signal handler by its ID. |

---

## Signals

| Signal      | Parameters | Description                                           |
|-------------|------------|-------------------------------------------------------|
| `shown`     | —          | Emitted when the widget becomes visible via `show()`. |
| `hidden`    | —          | Emitted when the widget is hidden via `hide()`.       |
| `destroyed` | —          | Emitted just before the widget is destroyed.          |

---

## Example

```python
from nebula_shell.ui.widget import Widget
from nebula_shell.ui.box import Box, Orientation

# Create a widget with a CSS-friendly name
widget = Widget(name="my-widget")
widget.tooltip = "Hello, Nebula!"

# Style management
widget.add_style_class("rounded")
widget.add_style_class("elevated")
print(widget.has_style_class("rounded"))   # True
widget.remove_style_class("elevated")

# Lifecycle
widget.show()

def on_hidden():
    print("Widget was hidden")

handler_id = widget.connect("hidden", on_hidden)
widget.hide()          # triggers the callback
widget.disconnect(handler_id)

# A widget must be added to a container to appear on screen
box = Box(orientation=Orientation.HORIZONTAL)
box.append(widget)
```

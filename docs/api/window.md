# Window

Abstract base class for all Nebula Shell windows. A `Window` represents a
Wayland surface managed by a compositor via the layer-shell protocol. Concrete
implementations (e.g. `Panel`) extend this class to build bars, docks,
dashboards, and other desktop chrome.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Window  (abstract)
        └── NebulaShell.Panel
```

- **Vala**: `NebulaShell.Window : NebulaShell.Object`
- **Python**: `nebula_shell.ui.window` — wraps GI `NebulaShell.Window`

---

## Constructor

### `Window(name=None)`

| Parameter | Type   | Default | Description                            |
|-----------|--------|---------|----------------------------------------|
| `name`    | `str`  | `None`  | Optional unique name for this window.  |

The constructor is called from concrete subclasses. Direct instantiation is
not allowed — `Window` is abstract.

---

## Properties

| Property        | Type       | Default | Access | Description                                      |
|-----------------|------------|---------|--------|--------------------------------------------------|
| `visible`       | `bool`     | `False` | **ro** | Whether the window is currently shown on screen. |
| `width`         | `int`      | `800`   | rw     | Window width in pixels.                          |
| `height`        | `int`      | `600`   | rw     | Window height in pixels.                         |
| `monitor`       | `Monitor?` | `null`  | rw     | Target monitor, or `null` for the current one.   |
| `anchor`        | `Anchor`   | `NONE`  | rw     | Edge anchors for positioning (flags).            |
| `layer`         | `Layer`    | `TOP`   | rw     | Compositor layer assignment.                     |
| `exclusive`     | `bool`     | `False` | rw     | Whether the window occupies exclusive space.     |
| `keyboard_mode` | `KeyboardMode` | `NONE` | rw | Keyboard interactivity policy.                   |
| `margin_top`    | `int`      | `0`     | rw     | Top margin in pixels.                            |
| `margin_bottom` | `int`      | `0`     | rw     | Bottom margin in pixels.                         |
| `margin_left`   | `int`      | `0`     | rw     | Left margin in pixels.                           |
| `margin_right`  | `int`      | `0`     | rw     | Right margin in pixels.                          |
| `title`         | `str`      | `""`    | rw     | Window title (may be used by the compositor).    |
| `child`         | `Widget?`  | `null`  | **ro** | Currently attached child widget, or `null`.      |

---

## Methods

| Method        | Parameters               | Returns | Description                                         |
|---------------|--------------------------|---------|-----------------------------------------------------|
| `show()`      | —                        | `None`  | Map the window on screen.                           |
| `hide()`      | —                        | `None`  | Unmap the window (it remains allocated).            |
| `toggle()`    | —                        | `None`  | Show if hidden, hide if shown.                      |
| `close()`     | —                        | `None`  | Request the window to close.                        |
| `destroy()`   | —                        | `None`  | Tear down the window and release all resources.     |
| `set_size()`     | `width: int`, `height: int` | `None` | Resize the window.                                  |
| `set_child()`    | `child: Widget`         | `None`  | Attach a child widget (replaces existing).          |
| `get_child()`    | —                        | `Widget?` | Return the current child widget, or `null`.       |
| `add()`          | `child: Widget`         | `None`  | Alias for `set_child()`.                            |

---

## Signals

| Signal    | Parameters | Description                                           |
|-----------|------------|-------------------------------------------------------|
| `shown`   | —          | Emitted after the window is mapped on screen.         |
| `hidden`  | —          | Emitted after the window is unmapped.                 |
| `closed`  | —          | Emitted when the window receives a close request.     |
| `destroyed` | —        | Emitted after the window has been torn down.          |

---

## Related Enums

### `Anchor` (flags)

| Value   | Description                          |
|---------|--------------------------------------|
| `NONE`  | No edge anchoring.                   |
| `TOP`   | Anchor to the top edge.              |
| `BOTTOM`| Anchor to the bottom edge.           |
| `LEFT`  | Anchor to the left edge.             |
| `RIGHT` | Anchor to the right edge.            |
| `ALL`   | Anchor to all edges (fullscreen).    |

Flags may be combined (e.g. `Anchor.TOP | Anchor.LEFT`).

### `Layer`

| Value        | Description                                   |
|--------------|-----------------------------------------------|
| `BACKGROUND`| Behind everything (wallpapers, desktop icons). |
| `BOTTOM`     | Below normal windows but above background.     |
| `TOP`        | Above normal windows (panels, bars).           |
| `OVERLAY`    | Above everything (popups, launchers, OSD).     |

### `KeyboardMode`

| Value        | Description                                       |
|--------------|---------------------------------------------------|
| `NONE`       | Window never receives keyboard focus.             |
| `EXCLUSIVE`  | Window always receives keyboard focus.            |
| `ON_DEMAND`  | Window receives focus on click / interaction.     |

---

## Python Example

```python
from nebula_shell.ui.window import Window
from nebula_shell.ui.widgets import Label

class MyWindow(Window):
    def __init__(self):
        super().__init__(name="my-window")
        self.title = "Example"
        self.anchor = Anchor.TOP | Anchor.LEFT
        self.layer = Layer.OVERLAY
        self.keyboard_mode = KeyboardMode.ON_DEMAND
        self.set_size(400, 300)

        label = Label("Hello from Nebula Shell")
        self.add(label)

        self.connect("shown", lambda w: print("Window shown"))
        self.connect("hidden", lambda w: print("Window hidden"))

    def run(self):
        self.show()

win = MyWindow()
win.run()
```

---

> **Note:** `Window` is abstract. Use `Panel` for creating concrete
> bar-style surfaces.

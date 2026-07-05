# Panel

A concrete `Window` subclass designed for bars, docks, panels, and other
edge-anchored desktop chrome. `Panel` is the primary surface type used by
most Nebula Shell widgets.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Window  (abstract)
        └── NebulaShell.Panel
```

- **Vala**: `NebulaShell.Panel : NebulaShell.Window`
- **Python**: `nebula_shell.ui.panel` — wraps GI `NebulaShell.Panel`

---

## Constructor

### `Panel(name=None)`

| Parameter | Type   | Default | Description                           |
|-----------|--------|---------|---------------------------------------|
| `name`    | `str`  | `None`  | Optional unique name for this panel.  |

The panel is fully constructed with sensible defaults (see below) and is
ready to be shown immediately.

### Default values applied at construction

| Property        | Default Value |
|-----------------|---------------|
| `anchor`        | `Anchor.TOP`  |
| `layer`         | `Layer.TOP`   |
| `exclusive`     | `True`        |
| `height`        | `32`          |
| `keyboard_mode` | `KeyboardMode.NONE` |

---

## Properties

| Property   | Type   | Default | Access | Description                             |
|------------|--------|---------|--------|-----------------------------------------|
| `children` | `list` | —       | **ro** | Read-only list of attached child widgets. |

Inherits all properties from [`Window`](window.md).

---

## Methods

| Method     | Parameters        | Returns | Description                                  |
|------------|-------------------|---------|----------------------------------------------|
| `append()` | `child: Widget`   | `None`  | Add a child widget to the end of the layout. |
| `prepend()`| `child: Widget`   | `None`  | Insert a child widget at the beginning.      |
| `remove()` | `child: Widget`   | `None`  | Remove a child widget from the panel.        |
| `clear()`  | —                 | `None`  | Remove all child widgets.                    |

Inherits all methods from [`Window`](window.md).

---

## Signals

Inherits all signals from [`Window`](window.md).

| Signal     | Parameters | Description                              |
|------------|------------|------------------------------------------|
| `shown`    | —          | Emitted after the panel is mapped.       |
| `hidden`   | —          | Emitted after the panel is unmapped.     |
| `closed`   | —          | Emitted on close request.                |
| `destroyed`| —          | Emitted after teardown.                  |

---

## Python Example

```python
from nebula_shell.ui.panel import Panel
from nebula_shell.ui.widgets import Label, Button
from nebula_shell.ui.window import Anchor

# Create a top bar panel
panel = Panel(name="top-bar")
panel.anchor = Anchor.TOP
panel.set_size(1920, 32)

# Add widgets
workspaces = Label("1:   2: ○  3: ○")
clock = Label("Mon 14:30")
launcher = Button("")

panel.append(workspaces)
panel.append(clock)
panel.append(launcher)

panel.show()
```

---

> **Note:** `Panel` is not abstract — it can be instantiated directly and is
> the recommended surface for most shell components.

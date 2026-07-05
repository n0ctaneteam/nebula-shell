# Separator

A visual divider line. `Separator` draws a thin horizontal or vertical rule used to group or separate content regions within panels, bars, and popups.

---

## Class Hierarchy

```
NebulaShell.Separator
    : NebulaShell.Widget
        : GLib.Object
```

---

## Constructor

| Constructor | Parameters | Description |
|---|---|---|
| `Separator(orientation=Orientation.HORIZONTAL, name=None)` | `orientation` — Axis along which the line is drawn (`Orientation`, default `HORIZONTAL`). `name` — Optional widget name (str or `None`, default `None`). | Creates a new Separator widget. |

---

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `orientation` | `Orientation` | `HORIZONTAL` | The direction of the separator line. When `HORIZONTAL` the line spans the full width of the widget. When `VERTICAL` it spans the full height. |
| `thickness` | `int` | `1` | The width of the drawn line in pixels. |

---

## Methods

This widget inherits all methods from `NebulaShell.Widget`. No additional methods are defined.

---

## Signals

This widget defines no signals.

---

## Related Enum

### `Orientation`

| Value | Description |
|---|---|
| `HORIZONTAL` | A horizontal line (extends along the x-axis). |
| `VERTICAL` | A vertical line (extends along the y-axis). |

---

## Python Example

```python
from nebula_shell import Application, Separator, Orientation

app = Application()

# Horizontal divider
h_sep = Separator(orientation=Orientation.HORIZONTAL, thickness=2)

# Vertical divider — useful between bar sections
v_sep = Separator(orientation=Orientation.VERTICAL, thickness=1)

# Separators are purely visual; they handle no input events.

app.run()
```

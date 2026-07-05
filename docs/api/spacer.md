# Spacer

An invisible widget used to create empty space or push neighbouring widgets apart inside a layout container. `Spacer` does not render any visual content and is purely a layout helper.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
       └── NebulaShell.Spacer
```

Python alias: `nebula_shell.ui.spacer.Spacer`

---

## Constructor

### `Spacer(name=None, min_size=0, expand=False)`

| Parameter  | Type    | Default | Description                                               |
|------------|---------|---------|-----------------------------------------------------------|
| `name`     | `str`   | `None`  | Optional widget name for identification.                  |
| `min_size` | `int`   | `0`     | Minimum size of the spacer in pixels along the container's layout axis. |
| `expand`   | `bool`  | `False` | Whether the spacer should grow to fill available space.   |

Creates a spacer widget.

---

## Properties

| Property   | Type    | Default | Description                                                       |
|------------|---------|---------|-------------------------------------------------------------------|
| `min_size` | `int`   | `0`     | Minimum size of the spacer in pixels. The spacer will never shrink below this value. |
| `expand`   | `bool`  | `False` | When `True`, the spacer expands to fill any extra space in the container along the layout axis. |
| `visible`  | `bool`  | `True`  | Inherited from `Widget`.                                          |
| `tooltip`  | `str`   | `""`    | Inherited from `Widget`.                                          |
| `name`     | `str`   | `""`    | Inherited from `Widget`.                                          |

---

## Methods

This widget inherits all methods from `NebulaShell.Widget`:

| Method      | Parameters | Returns  | Description                                |
|-------------|------------|----------|--------------------------------------------|
| `show()`    | —          | `None`   | Makes the spacer visible (still invisible visually, but takes up layout space). |
| `hide()`    | —          | `None`   | Hides the spacer, removing it from layout. |
| `destroy()` | —          | `None`   | Destroys the spacer widget.                |

---

## Signals

`Spacer` inherits all signals from `Widget`:

| Signal      | Parameters | Description                                       |
|-------------|------------|---------------------------------------------------|
| `shown`     | —          | Emitted when the spacer becomes visible.          |
| `hidden`    | —          | Emitted when the spacer is hidden.                |
| `destroyed` | —          | Emitted just before the spacer is destroyed.      |

---

## Example

```python
from nebula_shell.ui.box import Box, Orientation
from nebula_shell.ui.button import Button
from nebula_shell.ui.spacer import Spacer

# Create a toolbar with a spacer that pushes the right-side buttons apart
toolbar = Box(orientation=Orientation.HORIZONTAL, name="toolbar")
toolbar.spacing = 4

left_btn = Button(label="Open")
toolbar.append(left_btn)

# Expanding spacer pushes everything after it to the right edge
spacer = Spacer(min_size=8, expand=True)
toolbar.append(spacer)

right_btn = Button(label="Save")
toolbar.append(right_btn)

# Fixed-width spacer between elements
minimal_spacer = Spacer(min_size=16, expand=False)
toolbar.prepend(minimal_spacer)

print(spacer.min_size)  # 8
print(spacer.expand)    # True
```


# Box

A layout container that arranges its child widgets in a single horizontal row or vertical column. `Box` is the primary layout primitive in Nebula Shell.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
       └── NebulaShell.Container
            └── NebulaShell.Box
```

Python alias: `nebula_shell.ui.box.Box`

---

## Enums

### `Orientation`

Controls whether children are arranged left-to-right or top-to-bottom.

| Value        | Integer | Description                        |
|--------------|---------|------------------------------------|
| `HORIZONTAL` | `0`     | Children are laid out in a row.    |
| `VERTICAL`   | `1`     | Children are laid out in a column. |

### `Alignment`

Controls how children are positioned within the box along the cross axis.

| Value    | Integer | Description                                              |
|----------|---------|----------------------------------------------------------|
| `START`  | `0`     | Children are aligned to the start edge.                  |
| `CENTER` | `1`     | Children are centered along the cross axis.              |
| `END`    | `2`     | Children are aligned to the end edge.                    |
| `FILL`   | `3`     | Children are stretched to fill the available space.      |

---

## Constructor

### `Box(orientation=Orientation.HORIZONTAL, name=None)`

| Parameter     | Type          | Default                   | Description                                   |
|---------------|---------------|---------------------------|-----------------------------------------------|
| `orientation` | `Orientation` | `Orientation.HORIZONTAL`  | The axis along which children are laid out.   |
| `name`        | `str`         | `None`                    | Optional widget name for CSS and identification. |

---

## Properties

| Property      | Type          | Default                   | Description                                              |
|---------------|---------------|---------------------------|----------------------------------------------------------|
| `orientation` | `Orientation` | `Orientation.HORIZONTAL`  | The layout axis. Changing this reflows children immediately. |
| `spacing`     | `int`         | `0`                       | Spacing in pixels between adjacent children.             |
| `alignment`   | `Alignment`   | `Alignment.START`         | Cross-axis alignment of children.                        |
| `child_count` | `int`         | `0`                       | Read-only. Inherited from `Container`. Number of children. |
| `visible`     | `bool`        | `True`                    | Inherited from `Widget`.                                 |
| `tooltip`     | `str`         | `""`                      | Inherited from `Widget`.                                 |
| `name`        | `str`         | `""`                      | Inherited from `Widget`.                                 |

---

## Methods

`Box` inherits all methods from `Container` and `Widget`:

| Method       | Parameters               | Returns          | Description                                    |
|--------------|--------------------------|------------------|------------------------------------------------|
| `append()`   | `child: Widget`          | `None`           | Appends a child to the end of the box.         |
| `prepend()`  | `child: Widget`          | `None`           | Prepends a child to the beginning of the box.  |
| `remove()`   | `child: Widget`          | `None`           | Removes a child from the box.                  |
| `clear()`    | —                        | `None`           | Removes all children from the box.             |
| `__iter__()` | —                        | `Iterator[Widget]` | Iterates over all children.                  |
| `__len__()`  | —                        | `int`            | Returns the number of children.                |
| `show()`     | —                        | `None`           | Makes the box visible.                         |
| `hide()`     | —                        | `None`           | Hides the box.                                 |
| `destroy()`  | —                        | `None`           | Destroys the box and its children.             |

---

## Signals

`Box` inherits all signals from `Container` and `Widget`:

| Signal             | Parameters       | Description                                    |
|--------------------|------------------|------------------------------------------------|
| `child_added`      | `child: Widget`  | Emitted when a child is added.                 |
| `child_removed`    | `child: Widget`  | Emitted when a child is removed.               |
| `children_cleared` | —                | Emitted when all children are cleared.         |
| `shown`            | —                | Emitted when the box becomes visible.          |
| `hidden`           | —                | Emitted when the box is hidden.                |
| `destroyed`        | —                | Emitted just before the box is destroyed.      |

---

## Example

```python
from nebula_shell.ui.box import Box, Orientation, Alignment
from nebula_shell.ui.widget import Widget

# Create a horizontal box with spacing and centered alignment
box = Box(
    orientation=Orientation.HORIZONTAL,
    name="toolbar"
)
box.spacing = 8
box.alignment = Alignment.CENTER

# Populate with widgets
btn_a = Widget(name="button-a")
btn_b = Widget(name="button-b")
btn_c = Widget(name="button-c")

box.append(btn_a)
box.append(btn_b)
box.append(btn_c)

print(len(box))  # 3

# Switch to vertical layout at runtime
box.orientation = Orientation.VERTICAL

# Add a spacer widget to the front
spacer = Widget(name="spacer")
box.prepend(spacer)

# Remove the middle widget
box.remove(btn_b)

# Iterate children
for child in box:
    print(f"Child: {child.name}")

# Clear everything
box.clear()
print(box.child_count)  # 0
```

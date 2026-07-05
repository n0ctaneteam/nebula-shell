# Overlay

A container that layers all of its child widgets on top of each other. Each child occupies the same full area of the overlay but can be positioned independently using alignment anchors. `Overlay` is ideal for floating buttons, badges, tooltips, popups, and heads-up displays.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
       └── NebulaShell.Container
            └── NebulaShell.Overlay
```

Python alias: `nebula_shell.ui.overlay.Overlay`

---

## Enums

### `OverlayAlignment`

Controls the anchor point of a child widget within the overlay area.

| Value           | Integer | Description                                |
|-----------------|---------|--------------------------------------------|
| `TOP_LEFT`      | `0`     | Anchored to the top-left corner.           |
| `TOP_CENTER`    | `1`     | Anchored to the top edge, centered.        |
| `TOP_RIGHT`     | `2`     | Anchored to the top-right corner.          |
| `MIDDLE_LEFT`   | `3`     | Anchored to the left edge, vertically centered. |
| `CENTER`        | `4`     | Anchored to the exact center.              |
| `MIDDLE_RIGHT`  | `5`     | Anchored to the right edge, vertically centered. |
| `BOTTOM_LEFT`   | `6`     | Anchored to the bottom-left corner.        |
| `BOTTOM_CENTER` | `7`     | Anchored to the bottom edge, centered.     |
| `BOTTOM_RIGHT`  | `8`     | Anchored to the bottom-right corner.       |

---

## Constructor

### `Overlay(name=None, default_alignment=OverlayAlignment.CENTER)`

| Parameter           | Type                | Default                          | Description                                               |
|---------------------|---------------------|----------------------------------|-----------------------------------------------------------|
| `name`              | `str`               | `None`                           | Optional widget name for CSS styling and identification.  |
| `default_alignment` | `OverlayAlignment`  | `OverlayAlignment.CENTER`        | Default alignment applied to newly added children.        |

Creates an empty overlay.

---

## Properties

| Property            | Type                | Default                          | Description                                                    |
|---------------------|---------------------|----------------------------------|----------------------------------------------------------------|
| `default_alignment` | `OverlayAlignment`  | `OverlayAlignment.CENTER`        | Alignment applied to children that do not have an explicit one. |
| `child_count`       | `int`               | `0`                              | Read-only. Inherited from `Container`. Number of children.     |
| `visible`           | `bool`              | `True`                           | Inherited from `Widget`.                                       |
| `tooltip`           | `str`               | `""`                             | Inherited from `Widget`.                                       |
| `name`              | `str`               | `""`                             | Inherited from `Widget`.                                       |

---

## Methods

`Overlay` defines the following additional methods beyond `Container`:

| Method                  | Parameters                                | Returns           | Description                                                 |
|-------------------------|-------------------------------------------|-------------------|-------------------------------------------------------------|
| `set_child_alignment()` | `child: Widget, alignment: OverlayAlignment` | `None`         | Sets the alignment anchor for a specific child.             |
| `get_child_alignment()` | `child: Widget`                           | `OverlayAlignment`| Returns the alignment anchor currently set for `child`.     |

Inherited from `Container`:

| Method      | Parameters               | Returns          | Description                                       |
|-------------|--------------------------|------------------|---------------------------------------------------|
| `append()`  | `child: Widget`          | `None`           | Appends a child to the overlay.                   |
| `prepend()` | `child: Widget`          | `None`           | Prepends a child to the overlay.                  |
| `remove()`  | `child: Widget`          | `None`           | Removes a child from the overlay.                 |
| `clear()`   | —                        | `None`           | Removes all children from the overlay.            |
| `__iter__()`| —                        | `Iterator[Widget]` | Iterates over all children.                     |
| `__len__()` | —                        | `int`            | Returns the number of children.                   |

Inherited from `Widget`:

| Method      | Parameters | Returns  | Description                                  |
|-------------|------------|----------|----------------------------------------------|
| `show()`    | —          | `None`   | Makes the overlay visible.                   |
| `hide()`    | —          | `None`   | Hides the overlay.                           |
| `destroy()` | —          | `None`   | Destroys the overlay and its children.       |

---

## Signals

`Overlay` inherits all signals from `Container` and `Widget`:

| Signal             | Parameters       | Description                                       |
|--------------------|------------------|---------------------------------------------------|
| `child_added`      | `child: Widget`  | Emitted when a child is added.                    |
| `child_removed`    | `child: Widget`  | Emitted when a child is removed.                  |
| `children_cleared` | —                | Emitted when all children are cleared.            |
| `shown`            | —                | Emitted when the overlay becomes visible.         |
| `hidden`           | —                | Emitted when the overlay is hidden.               |
| `destroyed`        | —                | Emitted just before the overlay is destroyed.     |

---

## Example

```python
from nebula_shell.ui.overlay import Overlay, OverlayAlignment
from nebula_shell.ui.label import Label

# Create an overlay for a badge-on-avatar pattern
overlay = Overlay(name="avatar-overlay")

# Base layer: centered avatar label
avatar = Label(text="JD")
overlay.append(avatar)  # uses default_alignment (CENTER)

# Badge: top-right aligned
badge = Label(text="3")
badge.tooltip = "Unread notifications"
overlay.append(badge)
overlay.set_child_alignment(badge, OverlayAlignment.TOP_RIGHT)

# Status dot: bottom-right aligned
status = Label(text="●")
overlay.append(status)
overlay.set_child_alignment(status, OverlayAlignment.BOTTOM_RIGHT)

# Query alignment
print(overlay.get_child_alignment(badge))  # OverlayAlignment.TOP_RIGHT

# Remove the status dot
overlay.remove(status)
print(len(overlay))  # 2

# Clear everything
overlay.clear()
print(overlay.child_count)  # 0
```


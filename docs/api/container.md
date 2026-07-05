# Container

Base class for widgets that hold zero or more child `Widget` instances. `Container` extends `Widget` with child management — append, prepend, remove, and iterate over children.

`Container` is the building block for layout widgets like `Box` and `Stack`. It is not meant to be used directly; use one of its subclasses instead.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
       └── NebulaShell.Container
```

Python alias: `nebula_shell.ui.container.Container`

---

## Constructor

### `Container(name=None)`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name`    | `str` | `None`  | Optional widget name used for CSS styling and identification |

Creates an empty container.

---

## Properties

| Property      | Type  | Default | Description                                              |
|---------------|-------|---------|----------------------------------------------------------|
| `child_count` | `int` | `0`     | Read-only. Returns the number of child widgets currently in the container. |
| `visible`     | `bool`| `True`  | Inherited from `Widget`.                                 |
| `tooltip`     | `str` | `""`    | Inherited from `Widget`.                                 |
| `name`        | `str` | `""`    | Inherited from `Widget`.                                 |

---

## Methods

| Method        | Parameters               | Returns          | Description                                              |
|---------------|--------------------------|------------------|----------------------------------------------------------|
| `append()`    | `child: Widget`          | `None`           | Adds `child` to the end of the container's child list.   |
| `prepend()`   | `child: Widget`          | `None`           | Inserts `child` at the beginning of the container's child list. |
| `remove()`    | `child: Widget`          | `None`           | Removes `child` from the container.                      |
| `clear()`     | —                        | `None`           | Removes and destroys all child widgets.                  |
| `__iter__()`  | —                        | `Iterator[Widget]` | Iterates over all child widgets.                       |
| `__len__()`   | —                        | `int`            | Returns the number of child widgets (same as `child_count`). |

Inherited from `Widget`:

| Method               | Parameters                       | Returns    | Description                                   |
|----------------------|----------------------------------|------------|-----------------------------------------------|
| `show()`             | —                                | `None`     | Makes the container visible.                  |
| `hide()`             | —                                | `None`     | Hides the container.                          |
| `destroy()`          | —                                | `None`     | Destroys the container and all children.      |
| `add_style_class()`  | `class_name: str`                | `None`     | Adds a CSS class.                             |
| `remove_style_class()` | `class_name: str`              | `None`     | Removes a CSS class.                          |
| `has_style_class()`  | `class_name: str`                | `bool`     | Checks for a CSS class.                       |
| `connect()`          | `signal: str, callback: callable` | `int`    | Connects a signal.                            |
| `disconnect()`       | `handler_id: int`                | `None`     | Disconnects a signal handler.                 |

---

## Signals

| Signal            | Parameters            | Description                                            |
|-------------------|-----------------------|--------------------------------------------------------|
| `child_added`     | `child: Widget`       | Emitted after a child widget has been appended or prepended. |
| `child_removed`   | `child: Widget`       | Emitted after a child widget has been removed.         |
| `children_cleared`| —                     | Emitted after all children have been removed via `clear()`. |

Inherited from `Widget`:

| Signal      | Parameters | Description                                   |
|-------------|------------|-----------------------------------------------|
| `shown`     | —          | Emitted when the container becomes visible.   |
| `hidden`    | —          | Emitted when the container is hidden.         |
| `destroyed` | —          | Emitted just before the container is destroyed. |

---

## Example

```python
from nebula_shell.ui.widget import Widget
from nebula_shell.ui.container import Container

# Create a container and a couple of widgets
container = Container(name="my-container")
child_a = Widget(name="child-a")
child_b = Widget(name="child-b")

# Add children
container.append(child_a)
container.append(child_b)

# Iteration and length
for child in container:
    print(child.name)

print(len(container))       # 2
print(container.child_count)  # 2

# Remove a specific child
container.remove(child_a)
print(len(container))       # 1

# Clear all children
container.clear()
print(len(container))       # 0

# Signal example
def on_child_added(widget):
    print(f"Added: {widget.name}")

container.connect("child_added", on_child_added)
container.append(Widget(name="child-c"))
```

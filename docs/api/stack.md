# Stack

A container that shows only one child widget at a time. `Stack` manages a list of named pages and allows switching between them by index or name.

`Stack` is ideal for tabbed interfaces, wizard dialogs, slideshows, or any situation where only one view should be visible at a time.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
       └── NebulaShell.Container
            └── NebulaShell.Stack
```

Python alias: `nebula_shell.ui.stack.Stack`

---

## Constructor

### `Stack(name=None)`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name`    | `str` | `None`  | Optional widget name used for CSS styling and identification |

Creates an empty stack with no visible child.

---

## Properties

| Property             | Type   | Default | Description                                              |
|----------------------|--------|---------|----------------------------------------------------------|
| `visible_child_index`| `int`  | `0`     | The index of the currently visible child. Setting this switches the view. |
| `visible_child_name` | `str`  | `""`    | Read-only. The name of the currently visible child.      |
| `animate_transitions`| `bool` | `True`  | Whether child transitions are animated.                  |
| `child_count`        | `int`  | `0`     | Read-only. Inherited from `Container`. Number of children. |
| `visible`            | `bool` | `True`  | Inherited from `Widget`.                                 |
| `tooltip`            | `str`  | `""`    | Inherited from `Widget`.                                 |
| `name`               | `str`  | `""`    | Inherited from `Widget`.                                 |

---

## Methods

| Method                | Parameters                              | Returns           | Description                                              |
|-----------------------|-----------------------------------------|-------------------|----------------------------------------------------------|
| `get_visible_child()` | —                                       | `Widget` or `None`| Returns the currently visible child, or `None` if empty. |
| `set_visible_child()` | `child: Widget`                         | `None`            | Makes `child` visible. `child` must already be in the stack. |
| `add_named()`         | `name: str, child: Widget`              | `None`            | Adds a child widget with a lookup name.                  |
| `append()`            | `child: Widget`                         | `None`            | Appends a child. Its name is set to an auto-generated string. |
| `prepend()`           | `child: Widget`                         | `None`            | Prepends a child. Its name is set to an auto-generated string. |
| `remove()`            | `child: Widget`                         | `None`            | Removes a child from the stack.                          |
| `clear()`             | —                                       | `None`            | Removes all children from the stack.                     |
| `__iter__()`          | —                                       | `Iterator[Widget]`| Iterates over all children.                              |
| `__len__()`           | —                                       | `int`             | Returns the number of children.                          |

---

## Signals

| Signal                 | Parameters       | Description                                           |
|------------------------|------------------|-------------------------------------------------------|
| `visible_child_changed`| `index: int`     | Emitted when the visible child changes. Provides the new index. |

Inherited from `Container` and `Widget`:

| Signal             | Parameters       | Description                                    |
|--------------------|------------------|------------------------------------------------|
| `child_added`      | `child: Widget`  | Emitted when a child is added.                 |
| `child_removed`    | `child: Widget`  | Emitted when a child is removed.               |
| `children_cleared` | —                | Emitted when all children are cleared.         |
| `shown`            | —                | Emitted when the stack becomes visible.        |
| `hidden`           | —                | Emitted when the stack is hidden.              |
| `destroyed`        | —                | Emitted just before the stack is destroyed.    |

---

## Example

```python
from nebula_shell.ui.stack import Stack
from nebula_shell.ui.widget import Widget

# Create a stack with named pages
stack = Stack(name="wizard")

# Add pages with explicit names
page1 = Widget(name="page-welcome")
page2 = Widget(name="page-settings")
page3 = Widget(name="page-finish")

stack.add_named("welcome", page1)
stack.add_named("settings", page2)
stack.add_named("finish", page3)

# The first added child is visible by default
print(stack.visible_child_index)  # 0
print(stack.visible_child_name)   # "welcome"

# Switch to the second page
stack.set_visible_child(page2)
print(stack.visible_child_index)  # 1
print(stack.visible_child_name)   # "settings"

# Switch by index
stack.visible_child_index = 2
print(stack.visible_child_name)   # "finish"

# Disable transitions
stack.animate_transitions = False

# Listen for page changes
def on_page_changed(index):
    print(f"Switched to page index {index}")

stack.connect("visible_child_changed", on_page_changed)
stack.visible_child_index = 0  # triggers callback

# Get the currently visible widget
current = stack.get_visible_child()
print(current.name if current else None)

# Remove a page and clear
stack.remove(page2)
print(len(stack))  # 2

stack.clear()
print(len(stack))  # 0
```

# Label

A read-only text display widget. `Label` renders a single line or wrapped block of text and is the primary way to display static or dynamic string content in Nebula Shell.

---

## Class Hierarchy

```
NebulaShell.Label
    : NebulaShell.Widget
        : GLib.Object
```

---

## Constructor

| Constructor | Parameters | Description |
|---|---|---|
| `Label(text="", name=None)` | `text` — Initial text content (str, default `""`). `name` — Optional widget name (str or `None`, default `None`). | Creates a new Label widget. |

---

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `text` | `str` | `""` | The displayed text content. Setting this property emits `text_changed`. |
| `wrap` | `bool` | `False` | Whether text lines that exceed the allocated width should wrap to the next line. |
| `max_width` | `int` | `-1` | Maximum width in pixels before wrapping or truncation is applied. `-1` means no maximum. |
| `xalign` | `str` | `"start"` | Horizontal alignment of the text. Accepted values: `"start"`, `"center"`, `"end"`. |

---

## Methods

This widget inherits all methods from `NebulaShell.Widget`. No additional methods are defined.

---

## Signals

| Signal | Parameters | Description |
|---|---|---|
| `text_changed` | `new_text` (`str`) | Emitted when the `text` property changes. The new text value is passed as the argument. |

---

## Python Example

```python
from nebula_shell import Application, Label

app = Application()

# Simple greeting label
label = Label(text="Hello, Nebula!")
label.xalign = "center"

# Multi-line wrapped label
description = Label(
    text="This is a longer piece of text that will wrap when it exceeds the maximum width.",
    wrap=True,
    max_width=200,
)

# Reactive label — update text at runtime
status = Label(text="Ready")
# Later: status.text = "Running..."

app.run()
```

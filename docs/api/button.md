# Button

A clickable action widget. `Button` displays a label and emits a `clicked` signal when activated by the user. It is **not** a container — it manages exactly one child widget internally and does not support adding arbitrary children.

---

## Class Hierarchy

```
NebulaShell.Button
    : NebulaShell.Widget
        : GLib.Object
```

---

## Constructor

| Constructor | Parameters | Description |
|---|---|---|
| `Button(label="", name=None)` | `label` — Text displayed on the button (str, default `""`). `name` — Optional widget name (str or `None`, default `None`). | Creates a new Button widget with the given label. |

---

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `label_text` | `str` | `""` | The text displayed on the button face. |
| `enabled` | `bool` | `True` | Whether the button responds to user input. When `False`, the button appears greyed out and does not emit `clicked`. |

---

## Methods

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `press()` | — | `None` | Programmatically activates the button. Calling this method emits the `clicked` signal exactly as if the user had clicked the widget. |

---

## Signals

| Signal | Parameters | Description |
|---|---|---|
| `clicked` | — | Emitted when the button is activated, either by user interaction or by calling `press()`. |

---

## Python Example

```python
from nebula_shell import Application, Button

app = Application()

def on_button_clicked():
    print("Button was pressed!")

button = Button(label="Click Me")
button.connect("clicked", on_button_clicked)

# Disable the button after first use
def disable_after_click():
    button.enabled = False
    button.label_text = "Done"

button.connect("clicked", disable_after_click)

# Programmatic activation
button.press()

app.run()
```

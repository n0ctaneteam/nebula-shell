# Entry

A single-line text input widget. `Entry` allows users to type and edit a line of text, with support for placeholder text, character limits, and read-only mode.

---

## Class Hierarchy

```
NebulaShell.Entry
    : NebulaShell.Widget
        : GLib.Object
```

---

## Constructor

| Constructor | Parameters | Description |
|---|---|---|
| `Entry(text="", name=None)` | `text` — Initial text content (str, default `""`). `name` — Optional widget name (str or `None`, default `None`). | Creates a new Entry widget. |

---

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `text` | `str` | `""` | The current text content of the entry. Setting this property overwrites the displayed text and emits `text_changed`. |
| `placeholder` | `str` | `""` | Ghost text displayed when the entry is empty. Commonly used as a hint or label (e.g. `"Search…"`). |
| `editable` | `bool` | `True` | Whether the user can modify the text. When `False`, the entry is read-only. |
| `max_length` | `int` | `-1` | Maximum number of characters allowed. `-1` means no limit. |

---

## Methods

This widget inherits all methods from `NebulaShell.Widget`. No additional methods are defined.

---

## Signals

| Signal | Parameters | Description |
|---|---|---|
| `text_changed` | `new_text` (`str`) | Emitted every time the text content changes, whether by user input or programmatic assignment. The complete new text is passed as the argument. |
| `activated` | `text` (`str`) | Emitted when the user presses Enter / Return while the entry is focused. The current text is passed as the argument. |

---

## Python Example

```python
from nebula_shell import Application, Entry

app = Application()

# Simple text entry
search = Entry(placeholder="Search…", max_length=100)

def on_search_changed(new_text):
    print(f"Search query: {new_text}")

def on_search_activated(text):
    print(f"Search submitted: {text}")
    # Perform search action…

search.connect("text_changed", on_search_changed)
search.connect("activated", on_search_activated)

# Read-only log display
log_entry = Entry(text="System ready.", editable=False)

app.run()
```

# Theme

Manages CSS-based theming for Nebula Shell. Wraps a `Gtk.CssProvider` under
the hood, loading CSS files from a well-known directory on the filesystem.
Themes are plain `.css` files stored under
`~/.config/nebula-shell/themes/`.

---

## Class Hierarchy

This class is **pure Python** — it does not inherit from any
GI/Vala type and has no Vala counterpart.

```
Python object
  └── nebula_shell.theme.Theme
```

- **Python**: `nebula_shell.theme` — wraps `Gtk.CssProvider`

---

## Constructor

### `Theme(name: str)`

| Parameter | Type   | Default | Description                                        |
|-----------|--------|---------|----------------------------------------------------|
| `name`    | `str`  | —       | Basename of the CSS file (without `.css` suffix).  |

**Raises:** `FileNotFoundError` if
`~/.config/nebula-shell/themes/<name>.css` does not exist.

The theme is **not loaded** automatically on construction; call
`load()` or `reload()` to apply it.

---

## Properties

| Property | Type     | Default | Access | Description                                       |
|----------|----------|---------|--------|---------------------------------------------------|
| `name`   | `str`    | —       | **ro** | Basename of the theme file (without extension).   |
| `path`   | `Path`   | —       | **ro** | Full `pathlib.Path` to the `.css` file.           |

---

## Methods

### Instance methods

| Method                | Parameters                  | Returns       | Description                                          |
|-----------------------|-----------------------------|---------------|------------------------------------------------------|
| `load()`              | —                           | `None`        | Load and apply the CSS file. Replaces current theme. |
| `reload()`            | —                           | `None`        | Re-read and re-apply the CSS file from disk.         |

### Class methods

| Method               | Parameters           | Returns              | Description                                         |
|----------------------|----------------------|----------------------|-----------------------------------------------------|
| `set_themes_dir()`   | `path: str \| Path`  | `None`               | Override the default themes directory.              |
| `get_themes_dir()`   | —                     | `Path`               | Return the current themes directory path.           |
| `list_themes()`      | —                     | `list[str]`          | List available theme names (basenames without `.css`). |
| `current()`          | —                     | `Optional[str]`      | Return the name of the currently active theme, or `None`. |
| `load_default()`     | —                     | `None`               | Load the built-in default theme (Adwaita-like).     |
| `load_css_string()`  | `css: str`            | `None`               | Load and apply a raw CSS string immediately.        |
| `apply_pending_css()`| —                     | `None`               | Flush and apply any queued CSS changes.             |

---

### `set_themes_dir(path)`

Override the standard themes directory. The default is
`~/.config/nebula-shell/themes/`. The new path must exist or be creatable.

### `list_themes()`

Scans the themes directory for `*.css` files and returns their basenames
without the `.css` extension. Returns an empty list if the themes directory
does not exist.

### `load_css_string(css)`

Loads arbitrary CSS at runtime without touching the filesystem. Useful for
dynamic styling or user-provided CSS snippets.

### `apply_pending_css()`

GTK batches CSS changes for performance. Call this method after a batch of
style mutations to force an immediate update.

---

## Python Example

### Loading a theme from disk

```python
from nebula_shell.theme import Theme

# List available themes
print("Available themes:", Theme.list_themes())

# Load a theme by name
theme = Theme("catppuccin-mocha")
theme.load()
```

### Using class methods

```python
from nebula_shell.theme import Theme

# Override themes directory
Theme.set_themes_dir("/home/user/my-custom-themes")

# List themes from the new directory
themes = Theme.list_themes()
print("Themes available:", themes)

# Check current theme
if Theme.current() is None:
    Theme.load_default()
```

### Dynamic CSS injection

```python
from nebula_shell.theme import Theme

Theme.load_css_string("""
    .nebula-panel {
        background-color: #1e1e2e;
        border-bottom: 1px solid #313244;
    }

    .nebula-clock {
        color: #cdd6f4;
        font-family: "JetBrains Mono";
    }
""")

# Force immediate application
Theme.apply_pending_css()
```

### Runtime theme switching

```python
from nebula_shell.theme import Theme

themes = Theme.list_themes()
for name in themes:
    t = Theme(name)
    t.load()
    # Theme is now active — subsequent windows use the new styles
```

---

> **Note:** Themes are stored as plain CSS files in
> `~/.config/nebula-shell/themes/`. The directory is created automatically
> on first run if it does not exist.

# nebula/label

The **label** widget renders static or dynamically updatable text using `Gtk.Label`. It is the simplest widget in NebulaShell — a lightweight text element with no interactivity. Labels are commonly used for titles, status indicators, section headers, or any read-only text display.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | Unique identifier for the label. Used for registration and runtime text updates. |
| `style_class` | `string` | `"label"` | CSS class(es) applied to the label. |
| `text` | `string` | `""` | The initial text content of the label. |

## Usage Example

```yaml
# Simple title label
nebula/label:
  id: panel_title
  text: "NebulaShell Control Panel"
  style_class: "panel-title"

# Dynamic status label (text updated from Lua later)
nebula/label:
  id: status_text
  text: "Ready"
  style_class: "status-label"

# Empty label (placeholder, text set programmatically)
nebula/label:
  id: dynamic_label
  style_class: "dynamic-text"
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new label widget.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions (not used by labels).
- **`Returns`** (`table`) — The merged configuration table with internal metadata (`_type = "label"`).

The `text` property is stored as `config._text` for the WidgetBuilder to use when creating the GTK widget.

### `M.set_text(config, text)`
Updates the label's displayed text at runtime.

- **`config`** (`table`) — The label's configuration table.
- **`text`** (`string`) — The new text content.

This updates both the config's `_text` field and the underlying `Gtk.Label` via `widget_set_label()`.

```lua
-- Update a label from an event handler
function update_status(source_widget)
    local status = "Last updated: " .. os.date("%H:%M:%S")
    widget_set_label("status_text", status)
end
```

### `M.destroy(config)`
Logs a destruction message.

- **`config`** (`table`) — The configuration table returned by `M.create()`.

### `M.merge_defaults(props)`
Merges provided properties with `M.defaults`.

- **`props`** (`table`) — User-provided properties.
- **`Returns`** (`table`) — Merged configuration.

## Internal Fields

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"label"`. Tells the builder to create a `Gtk.Label`. |
| `_text` | `string` | The label's text content. Used by the WidgetBuilder when creating the GTK widget. |

## Behavior

- **Static display**: The label renders text as-is with no formatting, timers, or interactivity. It is a pure display element.
- **Dynamic updates**: Any code with access to the widget's ID can call `widget_set_label(id, text)` to change the text at runtime. This makes labels useful for status indicators, counters, or any value that changes over time.
- **No event handling**: Labels do not support click handlers or any other interaction. Use a `nebula/button` if you need clickable text.
- **CSS styling**: The label is a standard `Gtk.Label` with the configured `style_class`. Style it with font properties, colors, padding, and alignment:
  ```css
  .panel-title {
      font-size: 16px;
      font-weight: bold;
      padding: 8px 12px;
  }
  .status-label {
      font-size: 12px;
      color: #888;
  }
  ```
- **Markup support**: `Gtk.Label` supports Pango markup. You can use `widget_set_label()` with markup text:
  ```lua
  widget_set_label("my_label", '<span foreground="red">Warning:</span> CPU high')
  ```
  To use markup, you may need to enable it via `gtk_label_set_markup` — check if the core engine exposes this. Otherwise, text is treated as plain text.

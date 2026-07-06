# nebula/separator

The **separator** widget renders a visual divider line using `Gtk.Separator`. It is used to visually group or distinguish sections within a container. Separators can be horizontal (for vertical box layouts) or vertical (for horizontal box layouts).

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | Unique identifier for the separator. Used for registration. |
| `style_class` | `string` | `"separator"` | CSS class(es) applied to the separator. |
| `orientation` | `string` | `"horizontal"` | Direction of the separator line. Must be `"horizontal"` (a horizontal line) or `"vertical"` (a vertical line). |

## Usage Example

```yaml
# Horizontal separator (for vertical layouts)
nebula/separator:
  id: section_divider
  style_class: "separator"

# Vertical separator (for horizontal layouts)
nebula/separator:
  id: toolbar_divider
  orientation: vertical
  style_class: "toolbar-sep"

# Common pattern: section divider in a panel
nebula/box:
  id: panel_content
  orientation: vertical
  spacing: 8
  children:
    - nebula/label:
        id: header
        text: "Settings"
    - nebula/separator:
        id: header_sep
    - nebula/button:
        id: save_btn
        label: "Save"
    - nebula/button:
        id: cancel_btn
        label: "Cancel"
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new separator widget.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions (not used by separators).
- **`Returns`** (`table`) — The merged configuration table with internal metadata (`_type = "separator"`).

The orientation is stored as `_orientation` for the WidgetBuilder to map to `Gtk.Orientation`.

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
| `_type` | `string` | Set to `"separator"`. Tells the builder to create a `Gtk.Separator`. |
| `_orientation` | `string` | The resolved orientation string. Maps to `Gtk.Orientation.HORIZONTAL` or `Gtk.Orientation.VERTICAL`. |

## Behavior

- **Purely visual**: The separator has no interactivity, no timers, and no event handlers. It is a decorative element only.
- **Orientation must match parent layout**: Place horizontal separators inside vertical `Gtk.Box` layouts, and vertical separators inside horizontal `Gtk.Box` layouts. A mismatched orientation may result in an invisible or zero-width/zero-height element.
- **CSS styling**: The separator is a standard `Gtk.Separator` with the configured `style_class`. Style it for color, thickness, margins, and style:
  ```css
  .separator {
      background: rgba(255, 255, 255, 0.15);
      min-height: 1px;
      margin: 4px 0;
  }
  .toolbar-sep {
      min-width: 1px;
      min-height: 24px;
      background: rgba(255, 255, 255, 0.2);
      margin: 0 4px;
  }
  ```
- **No label or text**: Separators cannot display text. Use a `nebula/label` with styled borders if you need a titled section divider.

# nebula/box

The **box** widget is a container that arranges its children in a horizontal or vertical row using `Gtk.Box`. It is the primary layout widget in NebulaShell — used for grouping widgets, creating toolbars, organizing panel content, and controlling spacing between elements.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | Unique identifier for the box. Used for registration. |
| `style_class` | `string` | `"box"` | CSS class(es) applied to the box container. |
| `orientation` | `string` | `"horizontal"` | Layout direction. Must be `"horizontal"` (left-to-right) or `"vertical"` (top-to-bottom). |
| `spacing` | `number` | `0` | Pixel spacing between child widgets. |
| `children` | `array` | `[]` | List of child widget configurations to arrange inside the box. |

## Usage Example

```yaml
# Horizontal toolbar with spacing
nebula/box:
  id: toolbar
  orientation: horizontal
  spacing: 8
  style_class: "toolbar"
  children:
    - nebula/button:
        id: btn1
        label: "File"
    - nebula/button:
        id: btn2
        label: "Edit"
    - nebula/separator:
        id: sep1
        orientation: vertical
    - nebula/button:
        id: btn3
        label: "Help"

# Vertical panel layout
nebula/box:
  id: panel_content
  orientation: vertical
  spacing: 12
  style_class: "panel-layout"
  children:
    - nebula/label:
        id: title
        text: "Dashboard"
    - nebula/cpu:
        id: cpu_meter
    - nebula/clock:
        id: clock

# Nested boxes for complex layouts
nebula/box:
  id: main_container
  orientation: horizontal
  spacing: 4
  children:
    - nebula/box:
        id: left_section
        orientation: vertical
        spacing: 6
        children:
          - nebula/clock:
              id: clock
          - nebula/label:
              id: date_label
              text: "Mon Jan 6"

    - nebula/separator:
        id: div
        orientation: vertical

    - nebula/box:
        id: right_section
        orientation: horizontal
        spacing: 8
        children:
          - nebula/cpu:
              id: cpu
          - nebula/button:
              id: menu
              label: "\u2630"
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new box container configuration.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions (passed through to children).
- **`Returns`** (`table`) — The merged configuration table with internal metadata (`_type = "box"`).

The `spacing` and `orientation` values are stored under `_spacing` and `_orientation` respectively for the WidgetBuilder to consume when creating the `Gtk.Box`.

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
| `_type` | `string` | Set to `"box"`. Tells the builder to create a `Gtk.Box`. |
| `_orientation` | `string` | The resolved orientation string. Used by the WidgetBuilder to set `Gtk.Orientation`. |
| `_spacing` | `number` | The resolved spacing value. Passed directly to `Gtk.Box()` constructor. |
| `_children` | `array` | Child widget configurations. Recursively built and appended to the box. |

## Behavior

- **Child layout**: Children are appended to the `Gtk.Box` in declaration order. Horizontal boxes place children left-to-right; vertical boxes place children top-to-bottom.
- **Nested containers**: Boxes can be nested to arbitrary depth, enabling complex grid-like layouts. Use horizontal boxes for toolbars and vertical boxes for panel content.
- **Child expand/fill**: By default, `Gtk.Box` children are homogeneous (`false`) — each child takes only the space it needs. To make a child expand to fill available space, you may need to set `hexpand`/`vexpand` via CSS or GTK properties (check if the core engine exposes this).
- **CSS styling**: The box is a standard `Gtk.Box` with the configured `style_class`. Style it for backgrounds, borders, margins, and padding:
  ```css
  .toolbar {
      background: rgba(0, 0, 0, 0.3);
      border-radius: 6px;
      padding: 4px 8px;
  }
  .panel-layout {
      padding: 12px;
      spacing: 16px;
  }
  ```
- **Empty boxes**: A box with no children renders as an invisible spacer. You can use an empty box with a fixed width/height via CSS for custom spacing needs.

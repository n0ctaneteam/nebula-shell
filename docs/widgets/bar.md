# nebula/bar

The **bar** widget is a top-level window container that creates a fixed-height anchored panel at the top or bottom of the screen. It is the primary layout widget for desktop panels (similar to a taskbar). The bar acts as a Wayland layer-shell window and serves as a host container for child widgets like workspaces, clocks, CPU meters, and buttons.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | **Required.** Unique identifier for the bar. Used for registration and cross-widget references. |
| `style_class` | `string` | `"bar"` | CSS class(es) applied to the bar window. Multiple classes can be space-separated. |
| `anchor` | `string` | `"top"` | Screen edge to anchor the bar. Must be `"top"` or `"bottom"`. |
| `height` | `number` | `32` | Height of the bar in pixels. Controls the window default size. |
| `children` | `array` | `[]` | List of child widget configurations rendered inside the bar. |

## Usage Example

```yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: top
  height: 36
  children:
    - nebula/workspaces:
        id: workspaces
        style_class: "workspaces"

    - nebula/box:
        id: right_section
        orientation: horizontal
        spacing: 8
        children:
          - nebula/clock:
              id: system_clock
              format: "%H:%M:%S"

          - nebula/cpu:
              id: cpu_meter
              update_interval: 1

          - nebula/button:
              id: menu_btn
              label: "\u2630"
              on_click: "toggle_panel_visibility"
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new bar widget configuration.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions from `events.lua`.
- **Returns** (`table`) — The merged configuration table with internal metadata (`_type = "window"`, `_window_type = "bar"`).

The configuration table is registered via `register_widget()` if an `id` is provided. The `_children` array is preserved for the WidgetBuilder to recursively construct child GTK widgets inside a `Gtk.Box` child of the window.

### `M.destroy(config)`
Logs a destruction message. The core engine handles actual GTK cleanup.

- **`config`** (`table`) — The configuration table returned by `M.create()`.

### `M.merge_defaults(props)`
Merges provided properties with `M.defaults` using a priority scheme where explicit `props` values always win over defaults.

- **`props`** (`table`) — User-provided properties.
- **Returns** (`table`) — Merged configuration.

## Internal Fields

When the WidgetBuilder processes the bar's configuration, it reads the following internal fields:

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"window"`. Tells the builder to create a `Gtk.Window`. |
| `_window_type` | `string` | Set to `"bar"`. Not currently used for dispatch but reserved for future behavior distinction. |
| `_children` | `array` | Child widget configs. Recursively built into a `Gtk.Box` child of the window. |

## Behavior

- **Anchored positioning**: The bar is initialized as a Wayland layer-shell window anchored to the specified edge (`top` or `bottom`) with full width and the configured height.
- **Child layout**: A `Gtk.Box` (horizontal by default) is set as the window's child. All `children` are appended into this box. To create a vertically oriented bar, nest a `nebula/box` with `orientation: vertical` as a child.
- **Visibility**: Bars are always visible by default (there is no `visible` property). Use the `panel` widget for toggleable overlay panels.
- **CSS styling**: The `style_class` is applied directly to the window, allowing you to style background, borders, transparency, etc.

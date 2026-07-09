# nebula/bar

The **bar** widget is a top-level window container that creates a fixed-height anchored panel at the top or bottom of the screen. It is the primary layout widget for desktop panels (similar to a taskbar). The bar acts as a Wayland layer-shell window and serves as a host container for child widgets like workspaces, clocks, CPU meters, and buttons.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | **Required.** Unique identifier for the bar. Used for registration and cross-widget references. |
| `style_class` | `string` | `"bar"` | CSS class(es) applied to the bar window. Multiple classes can be space-separated. |
| `anchor` | `string` | `"top"` | Screen edge to anchor the bar. Must be `"top"` or `"bottom"`. |
| `height` | `number` | `32` | Height of the bar in pixels. Legacy field; prefer `size.h` for consistency. |
| `size` | `any` | `"auto"` | Controls the bar dimensions. See [Size Modes](#size-modes) below. Takes precedence over `height`. |
| `children` | `array` | `[]` | List of child widget configurations rendered inside the bar. |
| `exclusive` | `boolean` | `true` | Reserve space on the screen edge so other windows don't occlude the bar. |
| `margin` | `table` | — | Edge distances from screen edges: `{top: N, bottom: N, left: N, right: N}`. |
| `padding` | `table` | — | Inner padding inside the bar window. Same format as `margin`. |

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
- **Returns** (`table`) — The merged configuration table with internal metadata.

The function sets:
- `config._type = "window"` — creates a `Gtk.Window`
- `config._window_type = "bar"` — identifies it as a bar
- `config._orientation = config.orientation or "horizontal"` — internal orientation for the child `Gtk.Box`
- `config._spacing = config.spacing or 0` — internal spacing for the child `Gtk.Box`
- `config._children = config.children` — child widget configs

The configuration is registered via `register_widget()` if an `id` is provided.

### `M.destroy(config)`
Logs a destruction message. The core engine handles actual GTK cleanup.

- **`config`** (`table`) — The configuration table returned by `M.create()`.

### `M.merge_defaults(props)`
Merges provided properties with `M.defaults` using a priority scheme where explicit `props` values always win over defaults.

- **`props`** (`table`) — User-provided properties.
- **Returns** (`table`) — Merged configuration.

## Size Modes

The `size` property supports three modes:

| Value | Description |
|-------|-------------|
| `"auto"` | Width fills the screen edge (anchored). Height determined by `height` or content. |
| `"fill"` | Anchors to all four edges, filling the entire screen. |
| `{h: 36}` | Explicit height in pixels. Width is still full-screen (anchored). |

When both `height` and `size.h` are specified, `size.h` takes precedence.

## Internal Fields

When the WidgetBuilder processes the bar's configuration, it reads the following internal fields:

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"window"`. Tells the builder to create a `Gtk.Window`. |
| `_window_type` | `string` | Set to `"bar"`. Not currently used for dispatch but reserved for future behavior distinction. |
| `_orientation` | `string` | Orientation for the internal `Gtk.Box` child (defaults to `"horizontal"`). |
| `_spacing` | `number` | Spacing for the internal `Gtk.Box` child (defaults to `0`). |
| `_children` | `array` | Child widget configs. Recursively built into a `Gtk.Box` child of the window. |

## Behavior

- **Anchored positioning**: The bar is initialized as a Wayland layer-shell window anchored to the specified edge (`top` or `bottom`) with full width and the configured height.
- **Child layout**: A `Gtk.Box` (horizontal by default, using `_orientation` and `_spacing`) is set as the window's child. All `children` are appended into this box. To create a vertically oriented bar, set `orientation: vertical` on the bar.
- **Visibility**: Bars are always visible by default (there is no `visible` property). Use the `panel` widget for toggleable overlay panels.
- **CSS styling**: The `style_class` is applied directly to the window, allowing you to style background, borders, transparency, etc.

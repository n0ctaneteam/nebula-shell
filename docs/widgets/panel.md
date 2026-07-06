# nebula/panel

The **panel** widget is a toggleable overlay window anchored to the top or bottom edge of the screen. Unlike the `bar` widget, panels are hidden by default and can be shown/hidden programmatically — typically via a button click or keybind. Panels are ideal for control centers, notification drawers, application launchers, or settings dashboards.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | **Required.** Unique identifier for the panel. Used for registration, visibility toggling, and cross-widget references. |
| `style_class` | `string` | `"panel"` | CSS class(es) applied to the panel window. |
| `visible` | `boolean` | `false` | Initial visibility state. Panels start hidden by default. |
| `anchor` | `string` | `"bottom"` | Screen edge to anchor the panel. Must be `"top"` or `"bottom"`. |
| `height` | `number` | `300` | Height of the panel in pixels. Controls the window default size. |
| `children` | `array` | `[]` | List of child widget configurations rendered inside the panel. |

## Usage Example

```yaml
nebula/panel:
  id: main_panel
  style_class: "panel"
  visible: false
  anchor: bottom
  height: 300
  children:
    - nebula/box:
        id: panel_content
        orientation: vertical
        spacing: 10
        children:
          - nebula/label:
              id: panel_title
              text: "Control Panel"
              style_class: "panel-title"

          - nebula/button:
              id: close_btn
              label: "Close Panel"
              on_click: "toggle_panel_visibility"

          - nebula/separator:
              id: panel_sep
              style_class: "panel-separator"

          - nebula/box:
              id: actions_row
              orientation: horizontal
              spacing: 8
              children:
                - nebula/button:
                    id: about_btn
                    label: "About"
                    on_click: "show_about_dialog"

                - nebula/button:
                    id: reload_btn
                    label: "Reload Config"
                    on_click: "reload_config"
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new panel widget configuration.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions from `events.lua`.
- **Returns** (`table`) — The merged configuration table with internal metadata (`_type = "window"`, `_window_type = "panel"`).

The configuration is registered via `register_widget()` if an `id` is provided. The `visible` property is passed to the core engine, which initializes the layer-shell window in the correct visibility state.

### `M.toggle_visibility(config)`
Toggles the panel's visibility on the screen.

- **`config`** (`table`) — The configuration table.
- **Returns** (`boolean`) — The new visibility state (`true` = visible, `false` = hidden).

This function queries the current GTK visibility via `widget_get_visible(id)`, flips it with `widget_set_visible(id, not is_visible)`, and returns the new state. It is commonly called from event handlers bound to a toggle button.

### `M.destroy(config)`
Logs a destruction message.

- **`config`** (`table`) — The configuration table returned by `M.create()`.

### `M.merge_defaults(props)`
Merges provided properties with `M.defaults`. Explicit `props` values always win.

- **`props`** (`table`) — User-provided properties.
- **Returns** (`table`) — Merged configuration.

## Toggle Pattern (events.lua)

The recommended toggle pattern in your `events.lua`:

```lua
function toggle_panel_visibility(source_widget)
    local config = get_widget_by_id("main_panel")
    local is_visible = widget_get_visible("main_panel")
    widget_set_visible("main_panel", not is_visible)

    -- Update the toggle button icon
    local toggle_btn = get_widget_by_id("toggle_panel_btn")
    if toggle_btn then
        if not is_visible then
            widget_set_label("toggle_panel_btn", "\u2715")  -- ✕
        else
            widget_set_label("toggle_panel_btn", "\u2630")  -- ☰
        end
    end

    log_info("Panel visibility toggled: " .. tostring(not is_visible))
end
```

## Internal Fields

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"window"`. Tells the builder to create a `Gtk.Window`. |
| `_window_type` | `string` | Set to `"panel"`. Reserved for distinguishing panel vs. bar behavior. |
| `_children` | `array` | Child widget configs built into a `Gtk.Box` inside the window. |

## Behavior

- **Hidden by default**: The panel starts invisible. Set `visible: true` if you want it shown at startup.
- **Anchored positioning**: Anchored to `top` or `bottom` via the Wayland layer-shell protocol. Full width at the configured height.
- **Toggle via Lua**: Use `M.toggle_visibility()` or call `widget_set_visible(id, bool)` directly from any event handler.
- **Child layout**: A `Gtk.Box` (horizontal by default) is set as the window's child. For vertical layouts, nest a `nebula/box` with `orientation: vertical`.
- **CSS styling**: The `style_class` is applied to the window. Use it for background colors, borders, shadows, and slide-in animations where supported.

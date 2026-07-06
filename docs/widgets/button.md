# nebula/button

The **button** widget renders a clickable `Gtk.Button` with a text label. It supports click event handlers defined in your `events.lua` file. Buttons are the primary interactive element in NebulaShell — used for toggling panels, triggering actions, and navigating workspaces.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | Unique identifier for the button. Used for registration and runtime label updates. |
| `style_class` | `string` | `"button"` | CSS class(es) applied to the button. |
| `label` | `string` | `"Button"` | The text displayed on the button. |
| `on_click` | `string` | — | Name of a global event handler function from `events.lua` to call when the button is clicked. |

## Usage Example

```yaml
# Simple button
nebula/button:
  id: menu_btn
  label: "\u2630"
  style_class: "panel-toggle-btn"
  on_click: "toggle_panel_visibility"

# Button with custom handler
nebula/button:
  id: about_btn
  label: "About NebulaShell"
  style_class: "panel-about-btn"
  on_click: "show_about_dialog"

# Stateless button (no handler)
nebula/button:
  id: decorative_btn
  label: "N/A"
  style_class: "disabled-btn"
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new button widget.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions from `events.lua`.
- **`Returns`** (`table`) — The merged configuration table with internal metadata (`_type = "button"`).

If `on_click` is set and the named function exists in `event_handlers`, it is stored as `config._on_click`. The WidgetBuilder connects this to the GTK button's `clicked` signal.

### `M.set_label(config, label)`
Updates the button's displayed text at runtime.

- **`config`** (`table`) — The button's configuration table.
- **`label`** (`string`) — The new label text.

This updates both the config's `_text` field and the underlying GTK widget via `widget_set_label()`. Useful for dynamic buttons that change appearance based on state.

```lua
-- Example: update button text from an event handler
function toggle_panel_visibility(source_widget)
    local is_visible = widget_get_visible("main_panel")
    widget_set_visible("main_panel", not is_visible)

    -- Update the toggle button icon
    local toggle_btn = get_widget_by_id("toggle_panel_btn")
    if toggle_btn then
        if not is_visible then
            widget_set_label("toggle_panel_btn", "\u2715")  -- closed state
        else
            widget_set_label("toggle_panel_btn", "\u2630")  -- open state
        end
    end
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
| `_type` | `string` | Set to `"button"`. Tells the builder to create a `Gtk.Button`. |
| `_text` | `string` | The button's label text. Copied from `props.label`. Used by the WidgetBuilder when creating the GTK widget. |
| `_on_click` | `function` | The resolved click handler function (if `on_click` was specified and found in `event_handlers`). The WidgetBuilder connects this to `Gtk.Button.clicked`. |

## Behavior

- **Click handling**: When `on_click` is specified, the WidgetBuilder connects the GTK button's `clicked` signal to a Lua function call. The handler receives the widget's `id` as a string argument.
- **Label updates**: Labels can be changed at runtime via `widget_set_label(id, new_text)` from any Lua context. The `M.set_label()` convenience function wraps this.
- **No default handler**: If `on_click` is omitted, the button is rendered without any click behavior — useful for purely decorative or display-only buttons.
- **CSS styling**: The button is a standard `Gtk.Button` with the configured `style_class`. Style it for borders, backgrounds, hover states, and active states.

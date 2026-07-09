# nebula/popup

The **popup** widget is a GTK `Popover` — a lightweight, non-modal overlay anchored to a parent widget. Popups are ideal for context menus, tooltips, dropdown selectors, quick-action panels, and input prompts. Unlike dialogs, popups do not block input and automatically dismiss when clicking outside.

> **Note on naming**: The YAML type is `nebula/popup` (matching the file name `popup.lua`), but internally the widget registers as `_type = "popover"` to use GTK's `Gtk.Popover` implementation.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | **Required.** Unique identifier for the popup. Used for registration and programmatic show/hide. |
| `style_class` | `string` | `"popup"` | CSS class(es) applied to the popup. |
| `visible` | `boolean` | `false` | Initial visibility state. Popups are hidden by default. |
| `size` | `any` | `"auto"` | Size mode for the popup content area. |
| `orientation` | `string` | `"horizontal"` | Layout direction for child widgets. Must be `"horizontal"` or `"vertical"`. |
| `spacing` | `number` | `0` | Pixel spacing between child widgets inside the popup. |
| `autohide` | `number` | `0` | Time in seconds after which the popup automatically hides. `0` means no autohide (dismissal via clicking outside only). The timer is reset whenever the cursor enters the popup — it only fires after the cursor leaves and the full duration elapses without re-entry. |
| `showPointer` | `boolean` | `false` | Whether to show the arrow pointer pointing to the parent widget. |
| `margin` | `table` | — | Margin around the popup's content box edges. |
| `padding` | `table` | — | Padding inside the popup's content box. |
| `children` | `array` | `[]` | List of child widget configurations rendered inside the popup. |

## Usage Example

```yaml
nebula/button:
  id: menu_btn
  label: "\u2630"
  on_click: "show_quick_menu"

nebula/popup:
  id: quick_menu
  style_class: "app-menu"
  orientation: vertical
  spacing: 2
  autohide: 5
  showPointer: false
  children:
    - nebula/button:
        id: settings_btn
        label: "Settings"
        on_click: "lua[log_info('Settings clicked')]"

    - nebula/button:
        id: about_btn
        label: "About"
        on_click: "lua[widget_set_visible('demo_dialog', true)]"

    - nebula/separator:
        id: menu_sep
        style_class: "menu-separator"

    - nebula/button:
        id: quit_btn
        label: "Quit"
        on_click: "quit_application"
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new popup widget.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions from `events.lua`.
- **`Returns`** (`table`) — The merged configuration table with internal metadata (`_type = "popover"`).

The function sets:
- `config._type = "popover"` — creates a `Gtk.Popover`
- `config._orientation = config.orientation` — passes to the internal `Gtk.Box`
- `config._spacing = config.spacing` — passes to the internal `Gtk.Box`

The configuration is registered via `register_widget()` if an `id` is provided.

### `M.show(config, parent_id)`
Shows the popup anchored to a parent widget.

- **`config`** (`table`) — The popup's configuration table.
- **`parent_id`** (`string`) — The ID of the widget to anchor the popup to.

This function retrieves the parent `Gtk.Widget` via `get_widget_by_id()`, attaches the popup to it with `widget_set_parent()`, and calls `popup_widget()` to display it.

```lua
-- Show popup from an event handler
function show_quick_menu(source_widget)
    local parent = get_widget_by_id(source_widget)
    if parent == nil then return end
    widget_set_parent("quick_menu", parent)
    popup_widget("quick_menu")
end
```

### `M.hide(config)`
Hides the popup by calling `widget_set_visible(config.id, false)`.

- **`config`** (`table`) — The popup's configuration table.

### `M.destroy(config)`
Logs a destruction message.

- **`config`** (`table`) — The configuration table returned by `M.create()`.

### `M.merge_defaults(props)`
Merges provided properties with `M.defaults`. Explicit `props` values always win.

## Internal Fields

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"popover"`. Tells the builder to create a `Gtk.Popover`. |
| `_children` | `array` | Child widget configs built into a `Gtk.Box` inside the popup. |
| `_orientation` | `string` | The resolved orientation for the internal `Gtk.Box`. |
| `_spacing` | `number` | The resolved spacing for the internal `Gtk.Box`. |

## Behavior

- **Non-modal overlay**: Popups do not block input to other widgets. Clicking outside the popup automatically dismisses it.
- **Anchored to parent**: A popup must be shown relative to a parent widget (typically a button). Use `M.show(config, parent_id)` or the lower-level `widget_set_parent()` + `popup_widget()` to display it. The popup positions itself automatically near the parent.
- **Autohide timer (hover-aware)**: Set `autohide` to a positive number of seconds for automatic dismissal. The timer is hover-aware — it only fires `popdown()` when the popup is **not** being hovered. If the cursor enters the popup, the timer is cancelled. When the cursor leaves, a fresh timer starts. This prevents the popup from disappearing while the user is interacting with its contents. The timer is also cancelled if the popup is hidden manually or by an outside click.
- **Child layout**: Children are packed into a `Gtk.Box` set as the popup's child widget, using `_orientation` and `_spacing` from the config. For vertical menus, set `orientation: vertical`.
- **Arrow pointer**: The `showPointer` property controls whether a small triangular arrow appears between the parent widget and the popup. Set to `false` for flat dropdowns.
- **Hidden at startup**: `Registry.show_all()` skips `Gtk.Popover` widgets, so popups remain hidden until explicitly shown.
- **CSS styling**: The `style_class` is applied directly to the `Gtk.Popover`:
  ```css
  .app-menu {
      padding: 4px;
      border-radius: 8px;
  }
  ```

# NebulaShell Lua API Reference

This document describes the complete Lua API surface available to widget scripts, event handlers, and configuration files. NebulaShell embeds a Lua 5.2+ VM and exposes a set of global functions, tables, and conventions that bridge Lua logic with the Vala/GTK4 core.

---

## Global Functions

These functions are registered by the core engine and available anywhere in Lua — widget files, `events.lua`, and inline code.

### Widget Registration & Lookup

#### `register_widget(id, config)`
Registers a widget configuration under a unique identifier. This is called by widget modules at creation time so the framework can track and later manipulate the widget.

```lua
register_widget("my_clock", { id = "my_clock", _type = "label", _text = "12:00" })
```

- **`id`** (string) — Unique widget identifier. Must match the `id` field in the config table.
- **`config`** (table) — The widget's configuration table (see [Config Table](#config-table-fields) below).
- **Returns**: nothing.

> **Note:** Each widget module calls this automatically in its `M.create()` function. You rarely need to call it directly unless building a widget entirely from scratch in Lua.

#### `get_widget_by_id(id)`
Retrieves a light userdata pointer to the GTK widget associated with the given ID. The pointer can be passed back to native C functions but is **not** a callable Lua object.

```lua
local widget_ptr = get_widget_by_id("main_bar")  -- returns light userdata or nil
```

- **`id`** (string) — Widget identifier.
- **Returns**: light userdata pointer, or `nil` if no widget with that ID exists.

> **Warning:** The returned pointer is opaque. You cannot call methods on it directly in Lua. Use the dedicated `widget_*` functions below to interact with widgets.

---

### Widget Manipulation

#### `widget_set_visible(id, visible)`
Show or hide a widget by ID.

```lua
widget_set_visible("main_panel", false)   -- hide
widget_set_visible("main_panel", true)    -- show
```

- **`id`** (string) — Widget identifier.
- **`visible`** (boolean) — `true` to show, `false` to hide.
- **Returns**: nothing.

#### `widget_get_visible(id)`
Check whether a widget is currently visible.

```lua
if widget_get_visible("main_panel") then
    log_info("Panel is visible")
end
```

- **`id`** (string) — Widget identifier.
- **Returns**: boolean — `true` if visible, `false` otherwise.

#### `widget_set_label(id, label)`
Set the text of a `Gtk.Label` or `Gtk.Button` widget.

```lua
widget_set_label("system_clock", os.date("%H:%M:%S"))
widget_set_label("toggle_panel_btn", "\u{2715}")
```

- **`id`** (string) — Widget identifier.
- **`label`** (string) — The new label text.
- **Returns**: nothing.
- **Fails silently** if the widget is neither a `Gtk.Label` nor a `Gtk.Button`.

#### `widget_get_label(id)`
Get the current text of a `Gtk.Label` or `Gtk.Button` widget.

```lua
local current = widget_get_label("system_clock")
```

- **`id`** (string) — Widget identifier.
- **Returns**: string — the current label text, or `""` if the widget is neither a `Gtk.Label` nor a `Gtk.Button`.

#### `widget_set_fraction(id, fraction)`
Set the progress fraction of a `Gtk.ProgressBar` widget. Value should be between `0.0` and `1.0`.

```lua
widget_set_fraction("cpu_meter", 0.45)  -- 45%
```

- **`id`** (string) — Widget identifier.
- **`fraction`** (number) — Fraction between `0.0` and `1.0`.
- **Returns**: nothing.
- **Fails silently** if the widget is not a `Gtk.ProgressBar`.

#### `widget_set_text(id, text)`
Set the overlay text of a `Gtk.ProgressBar` widget (shown above the progress bar).

```lua
widget_set_text("cpu_meter", "45%")
```

- **`id`** (string) — Widget identifier.
- **`text`** (string) — Text to display on the progress bar.
- **Returns**: nothing.
- **Fails silently** if the widget is not a `Gtk.ProgressBar`.

#### `widget_add_css_class(id, class)`
Add a CSS class to a widget's style context.

```lua
widget_add_css_class("cpu_meter", "warning")
```

- **`id`** (string) — Widget identifier.
- **`class`** (string) — CSS class name to add.
- **Returns**: nothing.

#### `widget_remove_css_class(id, class)`
Remove a CSS class from a widget's style context.

```lua
widget_remove_css_class("cpu_meter", "warning")
```

- **`id`** (string) — Widget identifier.
- **`class`** (string) — CSS class name to remove.
- **Returns**: nothing.

#### `widget_set_parent(widget_id, parent_widget)`
Sets the parent GTK widget of a popup or other widget. The `parent_widget` must be a light userdata pointer obtained via `get_widget_by_id()`.

```lua
local parent = get_widget_by_id("menu_btn")
if parent then
    widget_set_parent("quick_menu", parent)
end
```

- **`widget_id`** (string) — Widget identifier of the child widget (typically a `Gtk.Popover`).
- **`parent_widget`** (light userdata) — Pointer to the parent GTK widget, obtained from `get_widget_by_id()`.
- **Returns**: nothing.
- **Fails silently** if the widget ID is not found or the parent pointer is nil.

> **Note:** This is the low-level counterpart to `M.show()` in `popup.lua`. You normally call `popup_widget()` after setting the parent to display the popup.

#### `popup_widget(id)`
Calls `Gtk.Popover.popup()` on the widget, making it visible and positioned relative to its parent. The widget must be a `Gtk.Popover` and must have a parent set (via `widget_set_parent()` or GTK parent assignment).

```lua
popup_widget("quick_menu")
```

- **`id`** (string) — Widget identifier. Must resolve to a `Gtk.Popover`.
- **Returns**: nothing.
- **Fails silently** if the widget is not found or is not a `Gtk.Popover`.

#### `show_dialog(id)`
Builds and shows a dialog widget from YAML config. The dialog is created on-demand — it does not need to exist at startup.

```lua
show_dialog("about_dialog")
```

- **`id`** (string) — Widget identifier of the dialog.
- **Returns**: nothing.
- **Fails silently** if the YAML config for `nebula/dialog` cannot be found or the widget fails to build.

The function performs these steps:

1. Reads `_nebula_config["nebula/dialog"]` (the YAML config tree).
2. Loads the Lua module and calls `M.create(props)`.
3. Stores the config in `_nebula_widget_configs`.
4. Builds the GTK widget and registers it in the Registry.
5. Shows the widget.

#### `destroy_dialog(id)`
Fully destroys a dialog widget. This calls `Gtk.Widget.destroy()` on the underlying GTK window, removes the widget from the registry via `Registry.remove()`, and cleans up the internal `_nebula_widget_configs[id]` entry. The dialog can be re-created on the next call to `show_dialog(id)`.

```lua
destroy_dialog("about_dialog")
```

- **`id`** (string) — Widget identifier of the dialog to destroy.
- **Returns**: nothing.
- **Fails silently** if the widget ID is not found.

#### `toggle_dialog(id)`

Toggles a dialog's lifecycle. If a dialog with the given `id` exists in the registry, it is destroyed. If not, it is built from the YAML config and shown.

```lua
toggle_dialog("demo_dialog")
```

- **`id`** (string) — Widget identifier of the dialog to toggle.
- **Returns**: nothing.

> `toggle_dialog` is the recommended function for dialog-launch buttons — it handles both opening and closing from a single call. Internally it delegates to `show_dialog(id)` or `destroy_dialog(id)` as needed.

---

### Logging

#### `log_info(msg)`
Log an informational message to stderr (prefixed with `[INFO]` and tagged `[Lua]`).

```lua
log_info("Panel toggled at " .. os.date("%H:%M:%S"))
```

- **`msg`** (string) — Message to log.
- **Returns**: nothing.

#### `log_error(msg)`
Log an error message to stderr (prefixed with `[ERROR]` and tagged `[Lua]`).

```lua
log_error("Failed to read CPU stats")
```

- **`msg`** (string) — Message to log.
- **Returns**: nothing.

---

## Widget Protocol

Every widget module (e.g., `nebula/clock.lua`, `custom/greeting.lua`) must return a table `M` that conforms to the following protocol.

### `M.schema` (table)
A property validation schema. Each key is a property name; each value is a table describing constraints.

```lua
M.schema = {
    id          = { type = "string", required = true },
    style_class = { type = "string", default = "my-widget" },
    interval    = { type = "number", default = 1 },
    on_click    = { type = "string" }
}
```

Supported schema fields per property:

| Field      | Type    | Description                                |
|------------|---------|--------------------------------------------|
| `type`     | string  | Expected type: `"string"`, `"number"`, `"boolean"`, `"array"`, `"table"`, `"any"` |
| `default`  | any     | Default value if not provided              |
| `required` | boolean | Whether the property must be provided      |
| `enum`     | table   | List of allowed string values              |

### `M.defaults` (table)
Default property values used by `M.merge_defaults()`. Keys and values mirror the properties in `M.schema`.

```lua
M.defaults = {
    style_class = "my-widget",
    interval    = 1
}
```

### `M.create(props, event_handlers)`
Called by the `WidgetBuilder` to instantiate a widget. **Must return a config table** that the builder uses to create the GTK widget.

```lua
function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "label"           -- required: maps to a GTK widget type
    config._timer_enabled = true     -- optional: enable periodic update
    config._timer_interval = 1       -- optional: update interval in seconds

    if config.id then
        register_widget(config.id, config)
    end

    return config
end
```

**Parameters:**

| Parameter        | Type   | Description                                             |
|------------------|--------|---------------------------------------------------------|
| `props`          | table  | Properties from the YAML config merged with defaults    |
| `event_handlers` | table  | Optional. The `_widget_event_handlers` global table, or `nil` |

**Returns:** A config table (see [Config Table](#config-table-fields) below).

The returned config table tells the WidgetBuilder:
- **`_type`** — Which GTK widget to create (see [GTK Widget Type Mapping](#gtk-widget-type-mapping))
- **Special fields** starting with `_` — Internal directives consumed by the builder (see below)
- **All other fields** — Passed through and available for the widget's own logic

### `M.update(config)` (optional)
Called each timer tick for widgets that set `_timer_enabled = true`. Use it to refresh the widget's display.

```lua
function M.update(config)
    local now = os.date(config._format or "%H:%M:%S")
    config._text = now
    widget_set_label(config.id, now)
end
```

If `M.update` is defined, the framework calls it on every timer tick. If it is not defined, the timer tick is a no-op. This allows widgets like `nebula/clock` and `nebula/cpu` to drive their own refresh logic while letting `widget_builder.vala` handle the timing.

### `M.destroy(config)` (optional)
Called during application shutdown to perform cleanup. Use it to stop timers, close file handles, or release resources.

```lua
function M.destroy(config)
    config._timer_enabled = false
    log_info("Widget destroyed: " .. (config.id or "unknown"))
end
```

### `M.merge_defaults(props)`
A helper function that merges user-provided properties with `M.defaults`. User values always take precedence.

```lua
function M.merge_defaults(props)
    local result = {}
    for key, default in pairs(M.defaults) do
        result[key] = props[key] or default
    end
    for key, value in pairs(props) do
        result[key] = value
    end
    return result
end
```

---

## Config Table Fields

The config table is the central data structure that flows from YAML through Lua to the GTK widget builder. Fields prefixed with `_` are **internal directives** consumed by the core engine. All other fields are user-defined and available to your widget's Lua code.

### Internal Fields (consumed by WidgetBuilder)

| Field               | Type    | Applies To                    | Description                                      |
|---------------------|---------|-------------------------------|--------------------------------------------------|
| `_type`             | string  | All                           | GTK widget type: `"window"`, `"label"`, `"button"`, `"box"`, `"separator"`, `"progress_bar"`, `"dialog"`, `"popover"` |
| `_text`             | string  | label, button                 | The text content (set from `label` or `text` prop) |
| `_timer_enabled`    | boolean | All                           | Enable periodic timer updates                     |
| `_timer_interval`   | number  | All (if timer enabled)        | Timer interval in seconds (float)                 |
| `_children`         | table   | window, box, popover          | Array of child config tables                      |
| `_format`           | string  | clock                         | `os.date()` format string for time display        |
| `_orientation`      | string  | box, separator, window, popover | `"horizontal"` or `"vertical"`                  |
| `_spacing`          | number  | box, window, popover          | Pixel spacing between children                    |
| `_on_click`         | function| button                        | Lua function to call on button click              |
| `_window_type`      | string  | window                        | `"bar"` or `"panel"` (for LayerShell config)      |
| `_value`            | number  | progress_bar                  | Current progress value (0.0–1.0)                  |
| `_workspace_buttons`| table   | workspaces                    | Internal list of workspace button configs         |
| `_layer`            | string  | window, dialog                | LayerShell layer set from YAML `layer` property: `"background"`, `"bottom"`, `"top"` (default), `"overlay"` |
| `blockInput`        | boolean | dialog                        | Block input events behind the dialog (modal)      |
| `autohide`          | number  | popover                       | Auto-hide delay in ms (0 = no auto-hide)          |
| `showPointer`       | boolean | popover                       | Show a pointer arrow pointing to the parent widget|

### User-Facing Fields (from YAML)

These are the properties users set in `config.yaml`. Widget modules map them to internal fields during `M.create()`.

| Field               | Type            | Widgets                     | Description                                     |
|---------------------|-----------------|-----------------------------|-------------------------------------------------|
| `id`                | string          | All                         | Unique widget identifier                        |
| `style_class`       | string          | All                         | CSS class(es) (space-separated)                 |
| `layer`             | string          | bar, panel, dialog          | Wayland layer-shell layer: `"top"` (default for bar/panel) or `"overlay"` (default for dialog) |
| `anchor`            | string or array | bar, panel                  | Edge(s) to anchor: string `"top"` or array `["top", "bottom"]`; `"center"`=no anchors |
| `height`            | number          | bar, panel                  | Window height in pixels (legacy; prefer `size.h`) |
| `visible`           | boolean         | panel, dialog, popover      | Initial visibility (`false` = hidden)           |
| `exclusive`         | boolean         | bar, panel, box             | Reserve space on the layer-shell edge (default varies by widget) |
| `margin`            | table           | All windows and box         | Edge distances: `{all: 4}`, `{top: 2, horizontal: 4}`, etc. (last-wins per axis) |
| `padding`           | table           | All windows and box         | Inner padding (same format as `margin`)         |
| `size`              | string or table | bar, panel, dialog          | `"auto"` (fit content), `{w: 400, h: 300}`, or `"fill"` |
| `blockInput`        | boolean         | dialog                      | Block input events behind the dialog (modal)    |
| `autohide`          | number          | popover                     | Auto-hide delay in ms (0 = no auto-hide)        |
| `showPointer`       | boolean         | popover                     | Show pointer arrow pointing to parent widget    |
| `title`             | string          | dialog                      | Dialog title text                               |
| `content`           | string          | dialog                      | Dialog content text                             |
| `buttons`           | array           | dialog                      | Array of button definitions for the dialog      |
| `label`             | string          | button                      | Button label text                               |
| `text`              | string          | label                       | Label text                                      |
| `on_click`          | string or array | button, clock, all          | Event handler(s): string `"events[func]"`, `"lua[code]"`, `"bash[cmd]"`, or array of these; plain string `"func_name"` for backward compat |
| `format`            | string          | clock                       | `os.date()` format string                       |
| `interval`          | number          | clock                       | Update interval in seconds                      |
| `update_interval`   | number          | cpu, workspaces             | Update interval in seconds                      |
| `orientation`       | string          | box, separator, popup       | `"horizontal"` or `"vertical"`                  |
| `spacing`           | number          | box, popup                  | Pixel spacing between children                  |
| `children`          | array           | bar, panel, box, popup        | Nested widget definitions                    |
| `warning_threshold` | number          | cpu                         | CPU % to trigger warning CSS class              |
| `critical_threshold`| number          | cpu                         | CPU % to trigger critical CSS class             |

#### Margin / Padding Resolution

The `margin` and `padding` tables support these keys (last-wins per axis):

```yaml
margin:
  all: 8            # all four edges
  vertical: 4       # overrides top/bottom
  horizontal: 12    # overrides left/right
  top: 2            # overrides vertical/all for top edge
  bottom: 2         # overrides vertical/all for bottom edge
  left: 6           # overrides horizontal/all for left edge
  right: 6          # overrides horizontal/all for right edge
```

Resolution order (later keys override earlier ones):
1. `all` → sets top, bottom, left, right
2. `vertical` → overrides top, bottom
3. `horizontal` → overrides left, right
4. `top`, `bottom`, `left`, `right` → override any previous value for that edge

For window widgets, `margin` controls distance from the layer-shell edge (via `GtkLayerShell.set_margin`).
For non-window widgets (boxes, buttons, etc.), margin controls the CSS margin via GTK4 widget properties.

#### Anchor Options

The `anchor` field accepts either a single string or an array of strings:

```yaml
# Single edge (backward compatible)
anchor: top

# Multiple edges
anchor: [top, bottom, left, right]

# Center — no anchors applied (compositor manages placement)
anchor: center
```

Valid edge values: `"top"`, `"bottom"`, `"left"`, `"right"`.
When `"center"` is present in the array, no anchors are applied at all.

### Click Handler Resolution

When a YAML entry specifies `on_click`, the WidgetBuilder supports three command types plus backward-compatible plain strings.

#### Multi-Type Command Syntax

Each entry can be a single string or an array of strings using one of these command types:

| Syntax                | Type     | Description                                      |
|-----------------------|----------|--------------------------------------------------|
| `events[function_name]` | events | Call a global Lua function from `events.lua` with the widget ID as argument |
| `lua[lua_code]`         | lua     | Execute an inline Lua expression                  |
| `bash[shell_cmd]`       | bash    | Run a shell command asynchronously                |

These can be combined in an array to execute multiple commands sequentially on click:

```yaml
# Single command — opens a dialog
on_click: "lua[widget_set_visible(\"my_dialog\", true)]"

# Multiple commands — log, toggle panel, and run a script
on_click:
  - "events[toggle_panel_visibility]"
  - "lua[log_info('Panel toggled from about_btn')]"
  - "bash[notify-send 'Panel Toggled']"
```

Commands are executed in order. Each command runs independently — if one fails, subsequent commands still execute.

#### Backward Compatibility

Plain strings without a `type[...]` prefix are treated as `events[function_name]`:

```yaml
on_click: "toggle_panel_visibility"     # Same as events[toggle_panel_visibility]
```

This matches the Phase 2 behavior, so existing configs remain compatible.

#### Programmatic Closures (`_on_click`)

For widgets created entirely in Lua (e.g., workspace buttons), use the internal `_on_click` field with a Lua closure:

```lua
-- In a widget module's M.create():
local btn = {
    _type = "button",
    _on_click = function(source_id)
        M.switch_to_workspace(ws_id)
    end
}
```

The framework tries YAML `on_click` first (with multi-type dispatch), then falls back to `_on_click` (closure dispatch).

---

## Global Lua Tables

NebulaShell exposes several global tables that hold configuration and state.

### `_nebula_config`
Set by `ConfigLoader` after parsing the YAML file. Contains the full parsed widget tree as a Lua table, keyed by widget type.

```lua
-- Internal structure (not typically accessed directly)
_nebula_config = {
    ["nebula/bar"] = { id = "main_bar", ... },
    ["nebula/panel"] = { id = "main_panel", ... },
}
```

### `_nebula_widget_configs`
Populated by `register_widget()`. Maps widget IDs to their config tables. Available globally at runtime.

```lua
-- Accessed by the framework; also available to Lua code
_nebula_widget_configs["system_clock"]  -- config table for system_clock
_nebula_widget_configs["main_bar"]      -- config table for main_bar
```

### `_widget_event_handlers`
Set before widget construction. Contains the event handler functions parsed from `events.lua` or other sources. Passed as the second argument to every `M.create(props, event_handlers)` call.

```lua
-- Structure (set internally, rarely accessed directly)
_widget_event_handlers = {
    toggle_panel_visibility = function(source) ... end,
    toggle_clock_format     = function(source) ... end,
    show_about_dialog       = function(source) ... end,
    reload_config           = function(source) ... end,
    show_quick_menu         = function(source) ... end,
    quit_application        = function(source) ... end,
}
```

### `_widget_<id>` (internal)
For every registered widget, the framework stores a light userdata pointer in a global variable named `_widget_<id>`. These are set and removed by `LuaBridge.set_global_widget()` / `remove_global_widget()`.

```lua
-- Internal — exists for every registered widget
_widget_main_bar      -- light userdata pointer to the GTK widget
_widget_system_clock  -- light userdata pointer
```

> **Warning:** Do not rely on these directly. Use `get_widget_by_id(id)` instead.

---

## GTK Widget Type Mapping

The `_type` field in a config table determines which GTK widget is created:

| `_type`         | GTK Class        | Key Fields                    |
|-----------------|------------------|-------------------------------|
| `"window"`      | `Gtk.Window`     | `anchor`, `exclusive`, `_layer`, `height`, `size`, `_orientation`, `_spacing`, `_children` |
| `"label"`       | `Gtk.Label`      | `_text`                       |
| `"button"`      | `Gtk.Button`     | `_text`, `on_click`           |
| `"box"`         | `Gtk.Box`        | `_orientation`, `_spacing`, `_children`, `margin`, `padding` |
| `"separator"`   | `Gtk.Separator`  | `_orientation`                |
| `"progress_bar"`| `Gtk.ProgressBar`| `_text`, `_value`             |
| `"dialog"`      | `Gtk.Window`     | Full-screen overlay with all 4 anchors, centered dialog-box (`title`, `content`, `buttons`), `blockInput` via GestureClick, on-demand lifecycle (created by `show_dialog`, destroyed by `destroy_dialog`) |
| `"popover"`     | `Gtk.Popover`    | `autohide`, `showPointer`, `_orientation`, `_spacing`, `_children` |

When `_type` is `"window"`, the WidgetBuilder additionally applies LayerShell settings via the `anchor`, `_layer`, and `exclusive` fields, making the window a proper Wayland layer-surface (bar or panel).

When `_type` is `"dialog"`, the WidgetBuilder creates a **full-screen layer-shell** `Gtk.Window` on the layer specified by the YAML `layer` property (defaults to `OVERLAY`) with all four anchors, making it span the entire display. Inside, a centered dialog-box is constructed using the `title`, `content`, and `buttons` config fields. Input blocking is implemented via a `GestureClick` on the backdrop — no separate shadow widget or close button is used. Dialogs follow an **on-demand** lifecycle: they are **not** created at startup; `show_dialog(id)` builds them at runtime, and `destroy_dialog(id)` removes them (enabling re-creation). If a window has `set_data("no-layer", win)`, layer-shell initialization is skipped.

> **Note:** Dialogs are **not** regular `Gtk.Window` instances — they use the Wayland layer-shell protocol's `OVERLAY` layer with all four anchors, ensuring they block input across the entire screen.

When `_type` is `"popover"`, the WidgetBuilder creates a `Gtk.Popover` anchored to the trigger widget. Popovers are lightweight, auto-hiding surfaces that follow their parent widget's position. `Registry.show_all()` skips `Gtk.Popover` widgets, so they remain hidden until explicitly shown via `M.show()` or `popup_widget()`.

> **Note:** When `autohide` is set, the auto-hide timer is **hover-aware**: it resets whenever the pointer enters the popover, and only fires after the pointer leaves and the full delay has elapsed. This prevents the popover from disappearing while the user is interacting with its contents.

---

## Package & Module Resolution

### `require()` Paths

The Lua package path is configured to search in this order:

1. `~/.config/nebula-shell/widgets/?.lua`
2. `~/.config/nebula-shell/widgets/?/init.lua`
3. `/etc/nebula-shell/widgets/?.lua`
4. `/etc/nebula-shell/widgets/?/init.lua`
5. `~/.config/nebula-shell/?.lua`
6. `/etc/nebula-shell/?.lua`
7. System default paths

This means `require("nebula/clock")` resolves to either:
- `~/.config/nebula-shell/widgets/nebula/clock.lua` (user override)
- `/etc/nebula-shell/widgets/nebula/clock.lua` (system default)

### Built-in Widget Modules

| Module             | Widget Type    | Description                          |
|--------------------|----------------|--------------------------------------|
| `nebula/bar`       | window (bar)   | Top/bottom anchored bar              |
| `nebula/panel`     | window (panel) | Toggleable overlay panel             |
| `nebula/dialog`    | dialog         | Modal overlay dialog (layer-shell)   |
| `nebula/popup`     | popover        | Popover anchored to a parent widget  |
| `nebula/clock`     | label          | Time display with auto-update        |
| `nebula/cpu`       | progress_bar   | CPU usage meter with color thresholds|
| `nebula/button`    | button         | Clickable button                     |
| `nebula/label`     | label          | Static text label                    |
| `nebula/box`       | box            | Horizontal or vertical container     |
| `nebula/separator` | separator      | Visual divider line                  |
| `nebula/workspaces`| box            | Hyprland workspace switcher          |

---

## CSS Styling

NebulaShell uses GTK4 CSS for widget styling. All CSS is loaded from the `styles/style.css` file, with user files taking priority over system defaults.

> **Important:** CSS is loaded **before** widget building to prevent render-order crashes. This means your CSS is always applied when widgets first appear.

### CSS File Location

| Priority | Path                                    |
|----------|-----------------------------------------|
| 1 (dev)  | `$NEBULA_SYSROOT/etc/nebula-shell/styles/style.css` |
| 2 (user) | `~/.config/nebula-shell/styles/style.css`           |
| 3 (sys)  | `/etc/nebula-shell/styles/style.css`                 |

### CSS Selectors

All widgets use the `style_class` property (mapped to GTK CSS classes):

```css
/* Style a bar by its class */
.bar {
    background: rgba(30, 30, 30, 0.95);
    color: #ffffff;
    padding: 4px 8px;
}

/* Style a specific clock widget by class */
.clock {
    font-family: monospace;
    font-size: 14px;
    color: #ffffff;
}

/* Dynamic classes — added/removed at runtime */
.cpu-bar.warning progress {
    background: #ffcc00;
}

.cpu-bar.critical progress {
    background: #ff0000;
}

/* Dialog — full-screen overlay background */
.dialog {
    background: rgba(0, 0, 0, 0.5);
}

/* Centered dialog surface */
.dialog-box {
    background: rgba(30, 30, 40, 0.97);
    border: 1px solid #555555;
    border-radius: 8px;
    padding: 20px;
    min-width: 300px;
}

/* Dialog title */
.dialog-title {
    font-size: 16px;
    font-weight: bold;
    color: #ffffff;
    margin-bottom: 8px;
}

/* Dialog content text */
.dialog-content {
    font-size: 14px;
    color: #abb2bf;
    margin-bottom: 16px;
}

/* Dialog action buttons */
.dialog-button {
    background: rgba(255, 255, 255, 0.1);
    color: #ffffff;
    border-radius: 4px;
    padding: 6px 16px;
}

.dialog-button:hover {
    background: rgba(255, 255, 255, 0.2);
}

/* Destructive / critical action buttons */
.dialog-button.critical {
    background: rgba(255, 0, 0, 0.3);
    color: #ff6666;
}

.dialog-button.critical:hover {
    background: rgba(255, 0, 0, 0.5);
}

/* Popover widget styling */
.popover {
    background: rgba(40, 40, 50, 0.98);
    border: 1px solid #555555;
    border-radius: 6px;
    padding: 8px;
}

/* Hover states for interactive widgets */
.workspace-btn:hover {
    background: #5294e2;
    color: #ffffff;
}

/* Active/selected states */
.workspace-btn.active {
    background: #5294e2;
    color: #ffffff;
}
```

### Manipulating CSS at Runtime

Use the `widget_add_css_class()` and `widget_remove_css_class()` Lua functions to toggle CSS classes dynamically:

```lua
-- In events.lua or M.update():
widget_add_css_class("cpu_meter", "warning")
widget_remove_css_class("cpu_meter", "warning")
```

---

## YAML Unicode Escapes

NebulaShell's YAML parser supports Unicode escape sequences in double-quoted strings:

| Format      | Example                 | Result   |
|-------------|-------------------------|----------|
| `\u{HEX}`   | `\u{2715}`              | ✕        |
| `\u{1F600}` | `\u{1F600}`             | 😀       |
| `\uHEX`     | `\u2630`                | ☰        |

This works in all YAML string values, including widget properties:

```yaml
nebula/button:
  id: toggle_btn
  label: "\u{2630}"
```

---

## Complete Widget Lifecycle

```
YAML config.yaml
       │
       ▼
  ConfigLoader.load()
       │  Parses YAML → _nebula_config (Lua table)
       │  Loads events.lua → global functions
       ▼
  ConfigLoader.load_widget_events()
       │  Parses event handlers from events.lua
       ▼
  CssManager.load()               ← CSS loaded BEFORE widget building
       │
       ▼
   WidgetBuilder.build_from_config()
        │  Iterates _nebula_config keys
        │  Skips "nebula/dialog" — deferred for on-demand creation
        │
        ▼
   For each widget type (excluding dialog):
        │  1. Resolve widget file (user then system path)
        │  2. Load widget .lua file (gets M table)
        │  3. Call M.create(props, _widget_event_handlers)
        │     ├─ Merges defaults: config = M.merge_defaults(props)
        │     ├─ Sets internal fields: config._type = "..."
        │     ├─ Calls register_widget(config.id, config)
        │     └─ Returns config table
        │  4. Builder reads config to create GTK widget
        │     ├─ create_gtk_widget(id, config._type)
        │     ├─ Applies CSS classes
        │     ├─ Initializes LayerShell (if window or dialog)
        │     │   ├─ anchors (string or array)
        │     │   ├─ exclusive zone
        │     │   ├─ layer via parse_layer() (reads _layer from config)
        │     │   ├─ margin (edge distances)
        │     │   └─ no-layer flag skip (if set_data("no-layer", win))
        │     ├─ Applies size (auto / explicit / fill)
        │     ├─ Sets up timers (if _timer_enabled)
        │     ├─ Wires click handlers (if on_click, multi-type dispatch)
        │     └─ Builds children recursively (if _children)
        │
        ▼
    Application.activate()
         │  All widgets shown via Registry.show_all()
         │  (skips Gtk.Popover — popups start hidden)
         │  (dialog not present at startup — created on-demand via show_dialog())
         │
         ▼
    Dialog Lifecycle (on-demand)
         │  show_dialog(id)
         │  ├─ Reads _nebula_config["nebula/dialog"] (YAML config)
         │  ├─ Loads dialog.lua → M.create(props)
         │  ├─ Stores config → builds GTK → registers → shows
         │  │
         │  destroy_dialog(id)
         │  ├─ Registry.remove(id) → widget.destroy()
         │  ├─ _nebula_widget_configs[id] = nil
         │  └─ Ready to be re-created on next show_dialog
         │  │
         │  toggle_dialog(id)
         │  ├─ If widget exists in Registry → destroy_dialog(id)
         │  └─ If not → show_dialog(id)
         │
         ▼
    Runtime (event-driven)
        │  Timer callbacks → M.update() calls
        │  Button clicks → global handler functions
        │  Lua bridge calls → widget_* functions
        │
        ▼
   Application.shutdown()
        Registry.cleanup()
        M.destroy() called for each widget
```

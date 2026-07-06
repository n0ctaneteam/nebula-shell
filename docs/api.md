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
| `type`     | string  | Expected type: `"string"`, `"number"`, `"boolean"`, `"array"` |
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
- **`_type`** — Which GTK widget to create (`"window"`, `"label"`, `"button"`, `"box"`, `"separator"`, or `"progress_bar"`)
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

| Field               | Type    | Applies To             | Description                                      |
|---------------------|---------|------------------------|--------------------------------------------------|
| `_type`             | string  | All                    | GTK widget type: `"window"`, `"label"`, `"button"`, `"box"`, `"separator"`, `"progress_bar"` |
| `_text`             | string  | label, button          | The text content (set from `label` or `text` prop) |
| `_timer_enabled`    | boolean | All                    | Enable periodic timer updates                     |
| `_timer_interval`   | number  | All (if timer enabled) | Timer interval in seconds (float)                 |
| `_children`         | table   | window, box            | Array of child config tables                      |
| `_format`           | string  | clock                  | `os.date()` format string for time display        |
| `_orientation`      | string  | box, separator, window | `"horizontal"` or `"vertical"`                    |
| `_spacing`          | number  | box, window            | Pixel spacing between children                    |
| `_on_click`         | function| button                 | Lua function to call on button click              |
| `_window_type`      | string  | window                 | `"bar"` or `"panel"` (for LayerShell config)      |
| `_value`            | number  | progress_bar           | Current progress value (0.0–1.0)                  |
| `_workspace_buttons`| table   | workspaces             | Internal list of workspace button configs         |

### User-Facing Fields (from YAML)

These are the properties users set in `config.yaml`. Widget modules map them to internal fields during `M.create()`.

| Field          | Type    | Widgets               | Description                                |
|----------------|---------|-----------------------|--------------------------------------------|
| `id`           | string  | All                   | Unique widget identifier                   |
| `style_class`  | string  | All                   | CSS class(es) (space-separated)            |
| `anchor`       | string  | bar, panel            | `"top"` or `"bottom"`                      |
| `height`       | number  | bar, panel            | Window height in pixels                    |
| `visible`      | boolean | panel                 | Initial visibility (`false` = hidden)      |
| `label`        | string  | button                | Button label text                          |
| `text`         | string  | label                 | Label text                                 |
| `on_click`     | string  | button, clock         | Name of an event handler function in `events.lua` |
| `format`       | string  | clock                 | `os.date()` format string                  |
| `interval`     | number  | clock                 | Update interval in seconds                 |
| `update_interval`| number| cpu, workspaces       | Update interval in seconds                 |
| `orientation`  | string  | box, separator        | `"horizontal"` or `"vertical"`             |
| `spacing`      | number  | box                   | Pixel spacing between children             |
| `children`     | array   | bar, panel, box       | Nested widget definitions                  |
| `warning_threshold`| number| cpu                 | CPU % to trigger warning CSS class         |
| `critical_threshold`| number| cpu               | CPU % to trigger critical CSS class        |

### Click Handler Resolution

When a YAML entry specifies `on_click: "function_name"`, the WidgetBuilder looks up `function_name` in the global Lua scope (i.e., a function defined in `events.lua`). At click time, the framework calls the function with the widget's ID as the single argument:

```lua
function toggle_panel_visibility(source_widget_id)
    -- source_widget_id is the string ID of the clicked widget
end
```

For programmatic widgets (e.g., workspace buttons created entirely in Lua), the `_on_click` field stores a Lua closure directly. The framework checks for this closure at click time via the `_nebula_widget_configs[id]._on_click` lookup:

```lua
-- In a widget module's M.create():
local btn = {
    _type = "button",
    _on_click = function(source_id)
        M.switch_to_workspace(ws_id)
    end
}
```

The framework tries `on_click` (string lookup) first, then falls back to `_on_click` (closure dispatch).

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
| `"window"`      | `Gtk.Window`     | `anchor`, `height`, `_orientation`, `_spacing`, `_children` |
| `"label"`       | `Gtk.Label`      | `_text`                       |
| `"button"`      | `Gtk.Button`     | `_text`, `on_click`           |
| `"box"`         | `Gtk.Box`        | `_orientation`, `_spacing`, `_children` |
| `"separator"`   | `Gtk.Separator`  | `_orientation`                |
| `"progress_bar"`| `Gtk.ProgressBar`| `_text`, `_value`             |

When `_type` is `"window"`, the WidgetBuilder additionally applies LayerShell settings via the `anchor` field, making the window a proper Wayland layer-surface (bar or panel).

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
| `nebula/clock`     | label          | Time display with auto-update        |
| `nebula/cpu`       | progress_bar   | CPU usage meter with color thresholds|
| `nebula/button`    | button         | Clickable button                     |
| `nebula/label`     | label          | Static text label                    |
| `nebula/box`       | box            | Horizontal or vertical container     |
| `nebula/separator` | separator      | Visual divider line                  |
| `nebula/workspaces`| box            | Hyprland workspace switcher          |

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
  WidgetBuilder.build_from_config()
       │  Iterates _nebula_config keys
       │
       ▼
  For each widget type:
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
       │     ├─ Initializes LayerShell (if window)
       │     ├─ Sets up timers (if _timer_enabled)
       │     ├─ Wires click handlers (if on_click)
       │     └─ Builds children recursively (if _children)
       │
       ▼
  Application.activate()
       │  CSS loaded
       │  All widgets shown via Registry.show_all()
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

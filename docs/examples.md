# NebulaShell Examples

Practical YAML + Lua examples for building widgets with NebulaShell.

---

## Table of Contents

- [Example 1: Basic Bar with Clock and CPU Meter](#example-1-basic-bar-with-clock-and-cpu-meter)
- [Example 2: Toggle Panel](#example-2-toggle-panel)
- [Example 3: Custom Widget (nebula/custom/greeting)](#example-3-custom-widget-nebulacustomgreeting)
- [Example 4: Complete config.yaml](#example-4-complete-configyaml)
- [Example 5: events.lua with Multiple Handlers](#example-5-eventslua-with-multiple-handlers)
- [Example 6: Workspace Switcher with Custom Styling](#example-6-workspace-switcher-with-custom-styling)
- [Example 7: Nested Box Layout](#example-7-nested-box-layout)
- [Example 8: Popup Widget](#example-8-popup-widget)
- [CSS Styling Reference](#css-styling-reference)
- [CLI Usage](#cli-usage)

---

## Example 1: Basic Bar with Clock and CPU Meter

A minimal top bar with a clock on the right and a CPU meter next to it.

### config.yaml

```yaml
# ~/.config/nebula-shell/config.yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  exclusive: true
  children:
    - nebula/clock:
        id: system_clock
        style_class: "clock"
        format: "%H:%M:%S"
        interval: 1
        on_click: "toggle_clock_format"

    - nebula/cpu:
        id: cpu_meter
        style_class: "cpu-bar"
        update_interval: 2
        warning_threshold: 70
        critical_threshold: 90
```

### events.lua

```lua
-- ~/.config/nebula-shell/events.lua

function toggle_clock_format(source_widget)
    local format = widget_get_label("system_clock")
    if format:find(":") then
        widget_set_label("system_clock", os.date("%I:%M %p"))
    else
        widget_set_label("system_clock", os.date("%H:%M:%S"))
    end
    log_info("Clock format toggled")
end
```

### What happens

1. The bar is created as a `Gtk.Window` anchored to the top edge via Wayland Layer Shell.
2. `exclusive: true` reserves the top edge space so other windows don't occlude the bar.
3. The clock is a `Gtk.Label` that updates every second via its internal timer.
4. The CPU meter is a `Gtk.ProgressBar` that reads `/proc/stat` every 2 seconds.
5. Clicking the clock toggles between 24-hour and 12-hour formats.
6. The CPU meter automatically adds/removes the CSS classes `"warning"` or `"critical"` based on the configured thresholds.

---

## Example 2: Toggle Panel

A panel that starts hidden and can be toggled visible/invisible by clicking a button on the bar.

### config.yaml

```yaml
# ~/.config/nebula-shell/config.yaml

# --- Bar (always visible) ---
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  children:
    - nebula/button:
        id: toggle_panel_btn
        label: "\u2630"           # ☰ hamburger icon
        style_class: "panel-toggle-btn"
        on_click: "toggle_panel_visibility"

    - nebula/clock:
        id: system_clock
        style_class: "clock"
        format: "%H:%M:%S"

    - nebula/button:
        id: about_btn
        label: "?"
        style_class: "about-btn"
        on_click: "show_about_dialog"

# --- Panel (hidden by default) ---
nebula/panel:
  id: main_panel
  style_class: "panel"
  visible: false                   # Starts hidden
  anchor: [bottom]
  exclusive: false                 # Don't reserve edge space
  height: 300
  children:
    - nebula/label:
        id: panel_title
        style_class: "panel-title"
        text: "NebulaShell Controls"

    - nebula/separator:
        id: panel_separator
        style_class: "panel-separator"
        orientation: horizontal

    - nebula/box:
        id: panel_actions
        style_class: "panel-actions"
        orientation: horizontal
        spacing: 10
        children:
          - nebula/button:
              id: close_panel_btn
              label: "Close Panel"
              style_class: "panel-close-btn"
              on_click: "toggle_panel_visibility"

          - nebula/button:
              id: toggle_clock_btn
              label: "Toggle Clock"
              style_class: "panel-clock-btn"
              on_click: "toggle_clock_format"
```

### events.lua

```lua
-- ~/.config/nebula-shell/events.lua

function toggle_panel_visibility(source_widget)
    local is_visible = widget_get_visible("main_panel")
    widget_set_visible("main_panel", not is_visible)

    -- Update the toggle button icon
    if not is_visible then
        widget_set_label("toggle_panel_btn", "\u2715")  -- ✕ close icon
        widget_add_css_class("toggle_panel_btn", "active")
    else
        widget_set_label("toggle_panel_btn", "\u2630")   -- ☰ hamburger
        widget_remove_css_class("toggle_panel_btn", "active")
    end

    log_info("Panel visibility toggled: " .. tostring(not is_visible))
end

function toggle_clock_format(source_widget)
    local current = widget_get_label("system_clock")
    if current:find(":") then
        widget_set_label("system_clock", os.date("%I:%M %p"))
    else
        widget_set_label("system_clock", os.date("%H:%M:%S"))
    end
end

function show_about_dialog(source_widget)
    log_info("NebulaShell v0.1.0")
    log_info("Lightweight Wayland Widget Framework")
    log_info("License: Apache 2.0 — Owner: N0ctaneTeam")
end
```

### Key points

- The panel uses `visible: false` so it starts hidden.
- The toggle button's label changes between a hamburger and close icon to indicate state.
- Both the bar button and the panel's "Close Panel" button call the same handler.
- The panel is a `Gtk.Window` anchored to the bottom with a fixed height of 300px.
- `exclusive: false` on the panel means it does not reserve edge space — it covers content.

---

## Example 3: Custom Widget (nebula/custom/greeting)

A custom widget that displays a greeting message updated on a timer.

### 1. Create the widget module

```lua
-- ~/.config/nebula-shell/widgets/custom/greeting.lua

local M = {}

M.schema = {
    id          = { type = "string", required = true },
    style_class = { type = "string", default = "greeting" },
    greeting    = { type = "string", default = "Hello" },
    name        = { type = "string", default = "World" },
    interval    = { type = "number", default = 5 }
}

M.defaults = {
    style_class = "greeting",
    greeting    = "Hello",
    name        = "World",
    interval    = 5
}

-- Called by the WidgetBuilder when creating this widget
function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "label"               -- Use Gtk.Label as the base
    config._timer_enabled = true
    config._timer_interval = config.interval

    -- Set initial text
    config._text = config.greeting .. ", " .. config.name .. "!"
    config._counter = 0

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

-- Called on each timer tick (every `interval` seconds)
function M.update(config)
    config._counter = (config._counter or 0) + 1
    local greetings = {
        "Hello", "Hi", "Hey", "Howdy", "Greetings", "Salutations"
    }
    local idx = (config._counter % #greetings) + 1
    config._text = greetings[idx] .. ", " .. config.name .. "!"
    widget_set_label(config.id, config._text)

    -- Log the update
    if config._counter % 3 == 0 then
        log_info("Greeting updated to: " .. config._text)
    end
end

-- Called when NebulaShell shuts down
function M.destroy(config)
    config._timer_enabled = false
    log_info("Greeting widget destroyed: " .. (config.id or "unknown"))
end

-- Standard merge helper
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

return M
```

### 2. Use it in config.yaml

```yaml
# ~/.config/nebula-shell/config.yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  children:
    - custom/greeting:
        id: hello_widget
        style_class: "greeting"
        greeting: "Hey"
        name: "Nebula"
        interval: 3

    - nebula/clock:
        id: system_clock
        style_class: "clock"
        format: "%H:%M:%S"
```

### What the custom widget does

1. Creates a `Gtk.Label` that displays a greeting like `"Hello, Nebula!"`.
2. Every 3 seconds, cycles through a list of greetings and updates the label.
3. Logs every third update for debugging.
4. Properly cleans up its timer on destroy.

---

## Example 4: Complete config.yaml

A comprehensive configuration demonstrating all built-in widget types and features.

```yaml
# ~/.config/nebula-shell/config.yaml
# Complete NebulaShell configuration example

# ── Main Bar ─────────────────────────────────────────
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  exclusive: true
  margin:
    horizontal: 4
  children:
    # Left section: workspaces
    - nebula/workspaces:
        id: workspaces
        style_class: "workspaces"
        update_interval: 0.5

    # Spacer (empty box with fixed width via CSS)
    - nebula/box:
        id: spacer
        style_class: "spacer"

    # Right section: clock, cpu, buttons
    - nebula/box:
        id: right_section
        style_class: "right-section"
        orientation: horizontal
        spacing: 6
        children:
          - nebula/clock:
              id: system_clock
              style_class: "clock"
              format: "%H:%M:%S"
              interval: 1
              on_click: "toggle_clock_format"

          - nebula/separator:
              id: clock_separator
              style_class: "separator"
              orientation: vertical

          - nebula/cpu:
              id: cpu_meter
              style_class: "cpu-bar"
              update_interval: 2
              warning_threshold: 70
              critical_threshold: 90

          - nebula/separator:
              id: cpu_separator
              style_class: "separator"
              orientation: vertical

          - nebula/button:
              id: toggle_panel_btn
              label: "\u2630"
              style_class: "panel-toggle-btn"
              on_click: "toggle_panel_visibility"

# ── Popup Demo ───────────────────────────────────────
nebula/popup:
  id: demo_popup
  style_class: "popup"
  anchor: center
  size: {w: 400, h: 300}
  visible: false
  overlay:
    intensity: 4
  children:
    - nebula/box:
        id: popup_content
        orientation: vertical
        spacing: 8
        children:
          - nebula/label:
              id: popup_title
              text: "Popup Demo"
              style_class: "popup-title"

          - nebula/button:
              id: popup_close_btn
              label: "\u{2715}"
              style_class: "popup-close-btn"
              on_click: "close_demo_popup"

          - nebula/separator:
              id: popup_sep
              style_class: "popup-separator"

          - nebula/label:
              id: popup_body
              text: "This popup appears on the OVERLAY layer."
              style_class: "popup-content"
```

---

## Example 5: events.lua with Multiple Handlers

A complete `events.lua` demonstrating all handler patterns.

```lua
-- ~/.config/nebula-shell/events.lua
-- Global event handlers for NebulaShell

-- ============================================================
-- Panel Visibility
-- ============================================================

--- Toggle the main panel's visibility and update toggle button icon.
--- @param source_widget string  The ID of the widget that triggered this handler.
function toggle_panel_visibility(source_widget)
    local is_visible = widget_get_visible("main_panel")
    widget_set_visible("main_panel", not is_visible)

    -- Update the toggle button appearance
    if not is_visible then
        widget_set_label("toggle_panel_btn", "\u2715")
        widget_add_css_class("toggle_panel_btn", "active")
        log_info("Panel opened")
    else
        widget_set_label("toggle_panel_btn", "\u2630")
        widget_remove_css_class("toggle_panel_btn", "active")
        log_info("Panel closed")
    end
end

-- ============================================================
-- Clock Format
-- ============================================================

--- Toggle between 24-hour (%H:%M:%S) and 12-hour (%I:%M %p) formats.
--- @param source_widget string  The ID of the widget that triggered this handler.
function toggle_clock_format(source_widget)
    local current = widget_get_label("system_clock")

    if current:find(":") then
        -- Switch to 12-hour format
        widget_set_label("system_clock", os.date("%I:%M %p"))
    else
        -- Switch to 24-hour format with seconds
        widget_set_label("system_clock", os.date("%H:%M:%S"))
    end

    log_info("Clock format toggled: " .. widget_get_label("system_clock"))
end

-- ============================================================
-- About Dialog
-- ============================================================

--- Log application information.
--- @param source_widget string  The ID of the widget that triggered this handler.
function show_about_dialog(source_widget)
    log_info("╔══════════════════════════════════════╗")
    log_info("║        NebulaShell v0.1.0            ║")
    log_info("║  Lightweight Wayland Widget Framework ║")
    log_info("║  License: Apache 2.0                 ║")
    log_info("║  Owner: N0ctaneTeam                  ║")
    log_info("╚══════════════════════════════════════╝")

    -- Also show current widget state for debugging
    log_info("Registered widgets:")
    local ids = { "main_bar", "system_clock", "cpu_meter",
                  "main_panel", "toggle_panel_btn", "workspaces" }
    for _, id in ipairs(ids) do
        local visible = widget_get_visible(id)
        if visible ~= nil then
            log_info("  " .. id .. " (visible: " .. tostring(visible) .. ")")
        end
    end
end

-- ============================================================
-- Config Reload
-- ============================================================

--- Request a configuration reload.
--- @param source_widget string  The ID of the widget that triggered this handler.
function reload_config(source_widget)
    log_info("Config reload requested")

    -- TODO: Implement full config reload
    -- The current version does not support hot-reload of the widget tree.
    -- This is reserved for a future release.
    -- For now, log the state of all widgets as a preview.
    local panel_visible = widget_get_visible("main_panel")
    local clock_text = widget_get_label("system_clock")
    log_info("Current state — Panel: " .. tostring(panel_visible)
             .. ", Clock: " .. clock_text)
end

-- ============================================================
-- Custom: Show/Hide CPU Meter on Panel
-- ============================================================

--- Toggle the visibility of the panel's CPU meter.
--- @param source_widget string  The ID of the widget that triggered this handler.
function toggle_panel_cpu(source_widget)
    local is_visible = widget_get_visible("panel_cpu_meter")
    widget_set_visible("panel_cpu_meter", not is_visible)

    if not is_visible then
        widget_set_label("btn_toggle_cpu", "Show CPU")
    else
        widget_set_label("btn_toggle_cpu", "Hide CPU")
    end

    log_info("Panel CPU meter visibility: " .. tostring(not is_visible))
end

-- ============================================================
-- Initialize: Called once at startup
-- ============================================================

--- Runs once when events.lua is first loaded.
--- Use this for one-time setup, validation, or logging.
log_info("events.lua loaded successfully — " .. os.date("%Y-%m-%d %H:%M:%S"))

-- ============================================================
-- Popup Demo
-- ============================================================

--- Close the demo popup.
--- @param source_widget string  The ID of the widget that triggered this handler.
function close_demo_popup(source_widget)
    widget_set_visible("demo_popup", false)
    log_info("Popup closed")
end
```

---

## Example 6: Workspace Switcher with Custom Styling

Integrate the workspace switcher widget with CSS styling for active/inactive states.

### config.yaml

```yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  exclusive: true
  children:
    - nebula/workspaces:
        id: workspaces
        style_class: "workspaces"
        update_interval: 0.5

    - nebula/box:
        id: center_spacer
        style_class: "spacer"

    - nebula/clock:
        id: system_clock
        style_class: "clock"
        format: "%H:%M:%S"
```

### style.css

```css
/* ~/.config/nebula-shell/styles/style.css */

/* Workspace buttons */
.workspaces {
    background: transparent;
    spacing: 2px;
}

.workspace-btn {
    min-width: 28px;
    min-height: 28px;
    border-radius: 4px;
    padding: 2px 6px;
    background: rgba(255, 255, 255, 0.08);
    color: #abb2bf;
    font-size: 12px;
    font-weight: bold;
}

.workspace-btn:hover {
    background: rgba(255, 255, 255, 0.15);
}

.workspace-btn.active {
    background: rgba(97, 175, 239, 0.35);
    color: #61afef;
    border: 1px solid rgba(97, 175, 239, 0.5);
}

/* Bar styling */
.bar {
    background: rgba(30, 30, 40, 0.92);
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    padding: 2px 8px;
}

.clock {
    padding: 0 8px;
    font-size: 13px;
    font-weight: 600;
    color: #e5e5e5;
}

.cpu-bar {
    min-width: 100px;
    min-height: 16px;
}

.cpu-bar trough {
    min-height: 12px;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.06);
}

.cpu-bar progress {
    border-radius: 6px;
    background: #98c379;
}

.cpu-bar.warning progress {
    background: #e5c07b;
}

.cpu-bar.critical progress {
    background: #e06c75;
}

/* Panel styling */
.panel {
    background: rgba(30, 30, 40, 0.95);
    border-top: 1px solid rgba(255, 255, 255, 0.08);
    padding: 12px;
}

.panel-title {
    font-size: 16px;
    font-weight: bold;
    color: #e5e5e5;
    padding: 4px 0;
}

.panel-btn {
    padding: 6px 14px;
    border-radius: 4px;
    background: rgba(255, 255, 255, 0.06);
    color: #abb2bf;
}

.panel-btn:hover {
    background: rgba(255, 255, 255, 0.12);
}

/* Toggle button states */
.panel-toggle-btn {
    min-width: 32px;
    font-size: 16px;
}

.panel-toggle-btn.active {
    color: #e06c75;
}

/* Separator */
.separator {
    min-width: 1px;
    min-height: 1px;
    background: rgba(255, 255, 255, 0.1);
    margin: 2px 4px;
}

/* Popup widget */
.popup {
    background: rgba(30, 30, 40, 0.97);
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 8px;
    padding: 12px;
}

.popup-overlay {
    background: rgba(0, 0, 0, 0.4);
}

.popup-title {
    font-size: 16px;
    font-weight: bold;
    color: #e5e5e5;
    padding: 4px 8px;
}

.popup-close-btn {
    padding: 4px 12px;
    border-radius: 4px;
    background: rgba(255, 255, 255, 0.06);
    color: #abb2bf;
}

.popup-close-btn:hover {
    background: rgba(255, 255, 255, 0.12);
}

.popup-content {
    padding: 8px;
    color: #abb2bf;
}

.popup-separator {
    background: rgba(255, 255, 255, 0.08);
    min-height: 1px;
    margin: 6px 0;
}
```

---

## Example 7: Nested Box Layout

Build a complex layout using nested `nebula/box` containers.

### config.yaml

```yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  children:
    # Outer container: left, center, right sections
    - nebula/box:
        id: bar_layout
        style_class: "bar-layout"
        orientation: horizontal
        spacing: 0
        children:
          # Left section: workspaces
          - nebula/workspaces:
              id: ws_left
              style_class: "workspaces"
              update_interval: 0.5

          # Center section: expands to fill space
          - nebula/box:
              id: center_group
              style_class: "center-group"
              orientation: horizontal
              spacing: 4
              children:
                - nebula/label:
                    id: status_text
                    style_class: "status-text"
                    text: "Ready"

          # Right section: clock + system tray
          - nebula/box:
              id: right_group
              style_class: "right-group"
              orientation: horizontal
              spacing: 6
              children:
                - nebula/clock:
                    id: system_clock
                    style_class: "clock"
                    format: "%H:%M:%S"

                - nebula/cpu:
                    id: cpu_meter
                    style_class: "cpu-bar"
                    update_interval: 2
```

### Layout Visualization

```
┌──────────────────────────────────────────────────────────────┐
│  [1][2][3]                Ready                14:30:45  ███░  │
│  └──workspaces──┘  └───center───┘   └──clock──└──cpu─────┘  │
└──────────────────────────────────────────────────────────────┘
```

The three `nebula/box` containers (`left`, `center`, `right`) act as flex-like sections within the bar. The center section expands naturally because the left and right sections only occupy their content width.

---

## Example 8: Popup Widget

A centered popup widget with a semi-transparent backdrop overlay.

### config.yaml

```yaml
nebula/popup:
  id: info_popup
  style_class: "popup"
  anchor: center
  size: {w: 480, h: 320}
  visible: true
  overlay:
    intensity: 5
  margin:
    all: 16
  padding:
    all: 8
  children:
    - nebula/box:
        id: popup_root
        orientation: vertical
        spacing: 10
        children:
          - nebula/box:
              id: popup_header
              orientation: horizontal
              spacing: 0
              children:
                - nebula/label:
                    id: popup_title
                    text: "Information"
                    style_class: "popup-title"

                - nebula/box:
                    id: header_spacer
                    orientation: horizontal

                - nebula/button:
                    id: close_btn
                    label: "\u{2715}"
                    style_class: "popup-close-btn"
                    on_click: "close_info_popup"

          - nebula/separator:
              id: header_sep
              style_class: "popup-separator"

          - nebula/box:
              id: popup_body
              orientation: horizontal
              spacing: 8
              style_class: "popup-content"
              children:
                - nebula/label:
                    id: body_text
                    text: "This popup has:\n- A backdrop overlay (intensity 5)\n- 16px margin from screen edges\n- 8px inner padding\n- A close button in the header\n- Explicit size (480x320)"
```

### events.lua

```lua
function close_info_popup(source_widget)
    widget_set_visible("info_popup", false)
    log_info("Info popup closed")
end
```

### What it does

1. Creates a window on the `OVERLAY` layer (topmost layer, above all other windows).
2. Creates a backdrop window on the `TOP` layer that covers the full screen.
3. The backdrop has `intensity: 5` which translates to 50% opacity black overlay.
4. The popup has 16px margin from screen edges and 8px inner padding.

---

## CSS Styling Reference

### Where CSS files go

| Priority | Path                                    |
|----------|-----------------------------------------|
| 1 (dev)  | `$NEBULA_SYSROOT/etc/nebula-shell/styles/style.css` |
| 2 (user) | `~/.config/nebula-shell/styles/style.css`           |
| 3 (sys)  | `/etc/nebula-shell/styles/style.css`                 |

### CSS class naming

Use the `style_class` property in YAML to apply CSS classes to any widget:

```yaml
nebula/label:
  id: my_label
  style_class: "my-label emphasized"
```

```css
.my-label {
    color: #ffffff;
    font-size: 14px;
}

.my-label.emphasized {
    font-weight: bold;
    color: #61afef;
}
```

### Dynamic CSS class manipulation

Use the Lua API to add/remove classes at runtime:

```lua
-- Add a CSS class
widget_add_css_class("cpu_meter", "warning")

-- Remove a CSS class
widget_remove_css_class("cpu_meter", "warning")
```

### Common CSS patterns

**Hover effects on buttons:**
```css
.my-btn {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 4px;
    padding: 4px 12px;
}

.my-btn:hover {
    background: rgba(255, 255, 255, 0.2);
}
```

**Progress bar theming:**
```css
.my-progress-bar {
    min-width: 100px;
    min-height: 16px;
}

.my-progress-bar trough {
    background: #404040;
    border-radius: 4px;
}

.my-progress-bar progress {
    background: #98c379;
    border-radius: 4px;
}
```

**Popup backdrop:**
```css
.popup-overlay {
    background: rgba(0, 0, 0, 0.4);
}
```

---

## File Locations Summary

| File                        | Purpose                                    |
|-----------------------------|--------------------------------------------|
| `~/.config/nebula-shell/config.yaml`     | Your widget tree configuration |
| `~/.config/nebula-shell/events.lua`      | Event handler functions        |
| `~/.config/nebula-shell/styles/style.css`| Custom GTK CSS styling         |
| `~/.config/nebula-shell/widgets/custom/` | Your custom widget modules     |

System defaults are in `/etc/nebula-shell/`. User files in `~/.config/nebula-shell/` take priority.

---

## CLI Usage

```bash
# Run NebulaShell
nebula-shell run

# Quit a running instance
nebula-shell quit

# Inspect running widgets
nebula-shell inspect --tree

# Generate JSON Schema for YAML intellisense
nebula-shell schema --output ~/.config/nebula-shell/nebula-shell.schema.json

# Test from build directory (avoids stale system files)
export NEBULA_SYSROOT=$PWD
./build/nebula-shell run
```

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
- [Example 8: Dialog Widget](#example-8-dialog-widget)
- [Example 9: Popover Widget](#example-9-popover-widget)
- [Example 10: Multi-Type Commands](#example-10-multi-type-commands)
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
        on_click: "lua[widget_set_visible('demo_dialog', true)]"

# --- Panel (hidden by default) ---
nebula/panel:
  id: main_panel
  style_class: "panel"
  visible: false                   # Starts hidden
  anchor: [top]
  exclusive: false                 # Don't reserve edge space
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
- The panel is a `Gtk.Window` anchored to the top with content-driven height.
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

A comprehensive configuration demonstrating all 11 built-in widget types and features, matching the default NebulaShell config.

```yaml
# ~/.config/nebula-shell/config.yaml
# Complete NebulaShell configuration — showcases all built-in widget modules

# ── Main Bar ─────────────────────────────────────────
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  exclusive: true
  children:
    # Workspace switcher (left)
    - nebula/workspaces:
        id: workspaces
        style_class: "workspaces"

    # Clock (center-left)
    - nebula/clock:
        id: system_clock
        style_class: "clock"
        format: "%H:%M:%S"
        on_click: "toggle_clock_format"

    # Right section: CPU, buttons, separator, label
    - nebula/box:
        id: right_section
        orientation: horizontal
        spacing: 8
        style_class: "right-section"
        children:
          - nebula/cpu:
              id: cpu_meter
              style_class: "cpu-bar"
              update_interval: 1

          - nebula/button:
              id: toggle_panel_btn
              label: "\u2630"
              style_class: "panel-toggle-btn"
              on_click: "toggle_panel_visibility"

          - nebula/button:
              id: show_dialog_btn
              label: "\u2139"
              style_class: "dialog-launch-btn"
              on_click: "lua[widget_set_visible('demo_dialog', true)]"

          - nebula/separator:
              id: bar_sep
              style_class: "bar-separator"

          - nebula/label:
              id: status_label
              text: "Ready"
              style_class: "status-label"

# ── Panel (hidden by default) ─────────────────────────
nebula/panel:
  id: main_panel
  style_class: "panel"
  visible: false
  anchor: [top]
  exclusive: false
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

          - nebula/box:
              id: button_row
              orientation: horizontal
              spacing: 8
              children:
                - nebula/button:
                    id: about_btn
                    label: "About"
                    style_class: "panel-btn"
                    on_click: "lua[widget_set_visible('demo_dialog', true)]"

                - nebula/button:
                    id: reload_btn
                    label: "Reload"
                    style_class: "panel-btn"
                    on_click: "reload_config"

                - nebula/button:
                    id: close_panel_btn
                    label: "Close"
                    style_class: "panel-btn panel-close-btn"
                    on_click: "toggle_panel_visibility"

          - nebula/separator:
              id: panel_sep
              style_class: "panel-separator"

          - nebula/box:
              id: info_section
              orientation: horizontal
              spacing: 12
              children:
                - nebula/label:
                    id: cpu_label
                    text: "CPU:"
                    style_class: "info-label"

                - nebula/cpu:
                    id: panel_cpu
                    style_class: "cpu-bar"
                    update_interval: 2

          - nebula/button:
              id: show_popup_btn
              label: "Quick Menu \u25BE"
              style_class: "panel-btn"
              on_click: "show_quick_menu"

# ── Dialog (overlay, hidden by default) ───────────────
nebula/dialog:
  id: demo_dialog
  style_class: "dialog"
  blockInput: true
  visible: false
  shadow: { color: "#000000", intensity: 0.6 }
  children:
    - nebula/box:
        id: dialog_body
        orientation: vertical
        spacing: 12
        children:
          - nebula/label:
              id: dialog_title
              text: "About NebulaShell"
              style_class: "dialog-title"

          - nebula/separator:
              id: dialog_title_sep
              style_class: "dialog-separator"

          - nebula/label:
              id: dialog_message
              text: "NebulaShell v0.1.0\n\nA lightweight Wayland widget framework\nfor Hyprland and wlroots compositors.\n\nBuilt with Vala + GTK4 + Lua."
              style_class: "dialog-text"

          - nebula/box:
              id: dialog_buttons
              orientation: horizontal
              spacing: 8
              style_class: "dialog-button-row"
              children:
                - nebula/button:
                    id: dialog_ok
                    label: "OK"
                    style_class: "dialog-btn dialog-btn-primary"
                    on_click: "lua[widget_set_visible('demo_dialog', false)]"

                - nebula/button:
                    id: dialog_cancel
                    label: "Cancel"
                    style_class: "dialog-btn"
                    on_click: "lua[widget_set_visible('demo_dialog', false)]"

# ── Popup (context menu, shown programmatically) ──────
nebula/popup:
  id: quick_menu
  style_class: "popup"
  autohide: 5
  showPointer: false
  orientation: vertical
  spacing: 2
  children:
    - nebula/button:
        id: menu_settings
        label: "Settings"
        style_class: "menu-item"
        on_click: "lua[log_info('Settings clicked')]"

    - nebula/button:
        id: menu_about
        label: "About"
        style_class: "menu-item"
        on_click: "lua[widget_set_visible('demo_dialog', true)]"

    - nebula/separator:
        id: menu_sep
        style_class: "menu-separator"

    - nebula/button:
        id: menu_quit
        label: "Quit"
        style_class: "menu-item menu-item-danger"
        on_click: "quit_application"
```

---

## Example 5: events.lua with Multiple Handlers

A complete `events.lua` demonstrating all handler patterns, including the new `show_quick_menu` and `quit_application` functions.

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

--- Request a configuration reload (placeholder — not yet fully implemented).
--- @param source_widget string  The ID of the widget that triggered this handler.
function reload_config(source_widget)
    log_info("Config reload requested (not yet implemented)")
end

-- ============================================================
-- Quick Menu / Popup
-- ============================================================

--- Show a popup menu anchored to the source widget.
--- Uses widget_set_parent() and popup_widget() to display a Gtk.Popover.
--- @param source_widget string  The ID of the button that triggered this handler.
function show_quick_menu(source_widget)
    local parent = get_widget_by_id(source_widget)
    if parent == nil then return end
    widget_set_parent("quick_menu", parent)
    popup_widget("quick_menu")
end

-- ============================================================
-- Quit Application
-- ============================================================

--- Exit the NebulaShell application cleanly.
--- @param source_widget string  The ID of the widget that triggered this handler.
function quit_application(source_widget)
    log_info("Quit requested")
    os.exit(0)
end

-- ============================================================
-- Initialize: Called once at startup
-- ============================================================

--- Runs once when events.lua is first loaded.
--- Use this for one-time setup, validation, or logging.
log_info("events.lua loaded successfully — " .. os.date("%Y-%m-%d %H:%M:%S"))
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

/* Dialog widget */
.dialog {
    background: rgba(30, 30, 40, 0.97);
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 8px;
    padding: 12px;
}

/* Dynamic shadow backdrop (styled by CssProvider from shadow config) */
shadow {
    background: alpha(#000000, 0.6);
}

.dialog-title {
    font-size: 16px;
    font-weight: bold;
    color: #e5e5e5;
    padding: 4px 8px;
}

.dialog-close-btn {
    min-width: 28px;
    min-height: 28px;
    border-radius: 14px;
    padding: 2px 8px;
    background: rgba(255, 255, 255, 0.06);
    color: #abb2bf;
    font-size: 14px;
}

.dialog-close-btn:hover {
    background: rgba(255, 255, 255, 0.12);
}

.dialog-text {
    padding: 8px;
    color: #abb2bf;
}

.dialog-separator {
    background: rgba(255, 255, 255, 0.08);
    min-height: 1px;
    margin: 6px 0;
}

.dialog-btn {
    padding: 6px 16px;
    border-radius: 4px;
}

.dialog-btn-primary {
    background: #5294e2;
    color: #ffffff;
}

/* Popup/menu styling */
.popup {
    background: rgba(40, 40, 50, 0.98);
    border: 1px solid #555555;
    border-radius: 6px;
    padding: 4px;
}

.menu-item {
    padding: 6px 16px;
    border-radius: 4px;
    background: transparent;
    color: #abb2bf;
}

.menu-item:hover {
    background: rgba(255, 255, 255, 0.1);
}

.menu-item-danger {
    color: #e06c75;
}

.menu-separator {
    background: rgba(255, 255, 255, 0.08);
    min-height: 1px;
    margin: 4px 8px;
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

          # Right section: clock + CPU
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

## Example 8: Dialog Widget

A modal dialog widget with a shadow backdrop that blocks input behind it. The dialog uses the layer-shell `OVERLAY` layer to float above all other surfaces.

### config.yaml

```yaml
nebula/dialog:
  id: info_dialog
  style_class: "dialog"
  blockInput: true
  visible: true
  shadow:
    color: "#000000"
    intensity: 0.6
  children:
    - nebula/box:
        id: dialog_root
        orientation: vertical
        spacing: 10
        children:
          - nebula/label:
              id: dialog_title
              text: "Information"
              style_class: "dialog-title"

          - nebula/separator:
              id: header_sep
              style_class: "dialog-separator"

          - nebula/label:
              id: body_text
              text: "This dialog has:\n- A shadow backdrop (60% intensity)\n- blockInput: true (modal, blocks clicks behind)\n- A built-in close button (top-right ×)\n- Layer-shell OVERLAY layer (above bars)"
              style_class: "dialog-text"

          - nebula/box:
              id: dialog_buttons
              orientation: horizontal
              spacing: 8
              children:
                - nebula/button:
                    id: close_btn
                    label: "Close"
                    on_click: "lua[widget_set_visible('info_dialog', false)]"
```

### What it does

1. Creates a layer-shell `Gtk.Window` on the `OVERLAY` layer with **no anchors** and **no exclusive zone** — it floats centered above all other surfaces.
2. A shadow backdrop (`Gtk.Box` with CSS name `"shadow"`) fills the window behind the content. The color and intensity are dynamically generated from `shadow.color` and `shadow.intensity`.
3. `blockInput: true` sets the window as modal, blocking interaction with other windows.
4. A built-in close button (round ×) is automatically placed in the top-right corner — you do not need to add one in your YAML. Style it with the `dialog-close-btn` CSS class.
5. No separate backdrop window is created; the shadow is part of the dialog's internal `Gtk.Overlay`.

## Example 9: Popup / Popover Widget

A popup that appears as a child of a button, useful for dropdown menus, tooltips, or quick info panels. Popups use `widget_set_parent()` and `popup_widget()` to anchor to a trigger widget.

### config.yaml

```yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  exclusive: true
  children:
    - nebula/button:
        id: info_btn
        label: "Info"
        style_class: "info-btn"
        on_click: "show_quick_menu"

    - nebula/clock:
        id: system_clock
        style_class: "clock"
        format: "%H:%M:%S"

nebula/popup:
  id: info_popup
  style_class: "popup"
  autohide: 5
  showPointer: false
  orientation: vertical
  spacing: 4
  children:
    - nebula/button:
        id: popup_title_btn
        label: "System Info"
        style_class: "popup-title"
        on_click: "lua[log_info('System Info clicked')]"

    - nebula/separator:
        id: popup_sep
        style_class: "popup-sep"

    - nebula/label:
        id: popup_body
        text: "CPU: 23%\nMemory: 4.2 GB\nUptime: 2h 14m"
        style_class: "popup-body"

    - nebula/button:
        id: popup_quit_btn
        label: "Quit"
        style_class: "popup-quit-btn"
        on_click: "quit_application"
```

### events.lua

```lua
--- Show popup anchored to the source button.
--- Uses widget_set_parent() + popup_widget() — the new Lua API.
function show_quick_menu(source_widget)
    local parent = get_widget_by_id(source_widget)
    if parent == nil then return end
    widget_set_parent("info_popup", parent)
    popup_widget("info_popup")
end

--- Quit the application cleanly.
function quit_application(source_widget)
    log_info("Quit requested")
    os.exit(0)
end
```

### style.css

```css
.popup {
    background: rgba(40, 40, 50, 0.98);
    border: 1px solid #555555;
    border-radius: 6px;
    padding: 4px;
    min-width: 200px;
}

.popup-title {
    font-size: 14px;
    font-weight: bold;
    color: #ffffff;
    padding: 4px;
    background: transparent;
    border: none;
}

.popup-body {
    font-size: 12px;
    color: #abb2bf;
    padding: 4px 8px;
    line-height: 1.5;
}

.popup-sep {
    background: rgba(255, 255, 255, 0.08);
    min-height: 1px;
    margin: 4px 0;
}

.popup-quit-btn {
    padding: 6px 12px;
    border-radius: 4px;
    background: transparent;
    color: #e06c75;
}

.popup-quit-btn:hover {
    background: rgba(224, 108, 117, 0.15);
}
```

### What it does

1. Creates a `Gtk.Popover` that is anchored to the trigger button (`info_btn`) at runtime via `widget_set_parent()`.
2. `showPointer: false` hides the arrow pointer for a flat dropdown appearance.
3. `autohide: 5` automatically closes the popover after 5 seconds.
4. `orientation: vertical` and `spacing: 4` lay out children in a vertical column with 4px gaps.
5. The popover follows the button's position on screen — if the bar moves, the popover moves with it.
6. Popovers are lightweight — they don't create separate Wayland surfaces.
7. `Registry.show_all()` skips `Gtk.Popover` widgets, so popups remain hidden until shown explicitly.

---

## Example 10: Multi-Type Commands

Demonstrates the three command types (`events[]`, `lua[]`, `bash[]`) and array composition on `on_click`.

### config.yaml

```yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: [top]
  children:
    - nebula/button:
        id: multi_action_btn
        label: "Do All"
        style_class: "action-btn"
        on_click:
          - "events[toggle_panel_visibility]"
          - "lua[widget_set_label(\"status_label\", \"Action triggered!\")]"
          - "bash[notify-send 'NebulaShell' 'Multi-action button clicked']"

    - nebula/label:
        id: status_label
        style_class: "status-label"
        text: "Ready"
```

### events.lua

```lua
function toggle_panel_visibility(source_widget)
    local is_visible = widget_get_visible("main_panel")
    widget_set_visible("main_panel", not is_visible)
    log_info("Panel visibility toggled by multi-type command")
end
```

### What happens when you click "Do All"

1. **`events[toggle_panel_visibility]`** — Calls the global Lua function (defined in `events.lua`) with the widget ID as argument. The panel visibility toggles.
2. **`lua[widget_set_label("status_label", "Action triggered!")]`** — Executes the inline Lua, updating the status label text.
3. **`bash[notify-send 'NebulaShell' 'Multi-action button clicked']`** — Runs a shell command asynchronously, showing a desktop notification.

Commands execute in order. If one fails (e.g., a Lua error or missing function), the remaining commands still run.

### Backward Compatibility

Existing configs using plain string `on_click` continue to work:

```yaml
# Phase 2 style — still works
on_click: "toggle_panel_visibility"

# Equivalent Phase 3 style
on_click: "events[toggle_panel_visibility]"
```

The framework automatically treats un-prefixed strings as `events[...]`.

---

## CSS Styling Reference

### Where CSS files go

| Priority | Path                                    |
|----------|-----------------------------------------|
| 1 (dev)  | `$NEBULA_SYSROOT/etc/nebula-shell/styles/style.css` |
| 2 (user) | `~/.config/nebula-shell/styles/style.css`           |
| 3 (sys)  | `/etc/nebula-shell/styles/style.css`                 |

> **Note:** CSS is loaded **before** widget building, ensuring styles are applied when widgets first appear.

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

**Dialog shadow backdrop:**
```css
.dialog {
    background: rgba(30, 30, 40, 0.97);
    border: 1px solid #555555;
    border-radius: 8px;
    padding: 12px;
}

shadow {
    background: alpha(#000000, 0.5);
}

.dialog-close-btn {
    min-width: 28px;
    min-height: 28px;
    border-radius: 14px;
}
```

**Popup menu:**
```css
.popup {
    background: rgba(40, 40, 50, 0.98);
    border: 1px solid #555555;
    border-radius: 6px;
    padding: 4px;
}

.menu-item {
    padding: 6px 16px;
    border-radius: 4px;
}

.menu-item:hover {
    background: rgba(255, 255, 255, 0.1);
}

.menu-item-danger {
    color: #e06c75;
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

# Toggle a widget's visibility (show/hide)
nebula-shell toggle main_panel
nebula-shell toggle demo_dialog

# Inspect running widgets
nebula-shell inspect --tree

# Generate JSON Schema for YAML intellisense
nebula-shell schema --output ~/.config/nebula-shell/nebula-shell.schema.json

# Test from build directory (avoids stale system files)
export NEBULA_SYSROOT=$PWD
./build/nebula-shell run
```

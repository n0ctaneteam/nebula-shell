# NebulaShell - Project Summary

## 🎯 What We're Building

NebulaShell is a lightweight, modular Wayland widget framework. Users create custom desktop bars, panels, and widgets using:

- **YAML**: For declarative widget layout and structure
- **Lua**: For widget logic, event handlers, and custom behavior
- **CSS**: For styling all widgets
- **Vala/GTK4**: For the fast, low-level core engine

## 🏗️ Key Architecture Decisions

### 1. Three-Layer Design
User Config (YAML + Lua)
↓
Framework Scripting (Lua Bridge)
↓
Core Engine (Vala + GTK4 + Wayland)


### 2. Configuration Override System

- System defaults: `/etc/nebula-shell/` (read-only)
- User overrides: `~/.config/nebula-shell/` (writable)
- User config always takes precedence

### 3. Widget Resolution

When a user defines `nebula/clock` in YAML:
1. Check `~/.config/nebula-shell/widgets/nebula/clock.lua`
2. If not found, check `/etc/nebula-shell/widgets/nebula/clock.lua`
3. If not found, error

When a user defines `custom/clock` in YAML:
1. Check `~/.config/nebula-shell/widgets/custom/clock.lua`
2. If not found, check `/etc/nebula-shell/widgets/custom/clock.lua`
3. If not found, error

### 4. Event System

- Widgets expose events like `on_click: "function_name"`
- Functions are defined in `events.lua`
- Core binds Lua functions to GTK signals

### 5. Component Communication

- Widgets have unique IDs
- Global registry stores all widgets by ID
- Any widget can access any other widget via ID
- No direct coupling between widgets

## 📋 What Needs to Be Built

### Core Framework (Vala)

- [ ] `application.vala` - GTK app with Wayland layer shell
- [ ] `config_loader.vala` - YAML parser with override support
- [ ] `widget_builder.vala` - Builds GTK widgets from YAML
- [ ] `lua_bridge.vala` - Lua VM integration
- [ ] `css_manager.vala` - GTK CSS provider
- [ ] `registry.vala` - Widget registry with lookup

### Built-in Widgets (Lua) [/etc/nebula-shell/widgets/nebula/*.lua]

- [ ] `bar.lua` - Main horizontal bar
- [ ] `panel.lua` - Toggleable panel
- [ ] `clock.lua` - Time display with click toggling
- [ ] `cpu.lua` - CPU usage meter
- [ ] `button.lua` - Clickable button
- [ ] `label.lua` - Text label
- [ ] `box.lua` - Container
- [ ] `separator.lua` - Visual separator
- [ ] `workspaces.lua` - Workspace switcher for Hyprland

### CLI Tool (Vala)

- [ ] `nebula-shell run` - Run with default/custom config
- [ ] `nebula-shell inspect` - Inspect running widgets
  - [ ] `--id` filter
  - [ ] `--class` filter
  - [ ] `--type` filter
  - [ ] `--tree` view
  - [ ] `--json` output

### Configuration (YAML + Lua)

- [ ] `config.yaml` - Default widget tree
- [ ] `events.lua` - Default event handlers
- [ ] `style.css` - Default styling

### Documentation

- [ ] README.md - Project overview and quick start
- [ ] Man page (`nebula-shell.1`)
- [ ] API documentation

### Build System

- [ ] `meson.build` - Build configuration
- [ ] `makefile` - Build shortcuts
- [ ] `LICENSE` - Apache 2.0

## 🚀 Getting Started for AI Agent

1. **Review existing code**: Examine `src/`, `etc/`, and `data/` directories
2. **Complete core widgets**: Implement all widget `.lua` files
3. **Implement config parser**: Full YAML parsing with nested widget support
4. **Build inspector**: Complete `--id`, `--class`, `--type`, `--tree`, `--json`
5. **Test everything**: Build and run with `make` and `meson`
6. **Write docs**: Complete README and man page

## 🎨 Example User Config

```yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: top
  children:
    - nebula/workspaces:
        id: workspaces
        on_switch: "handle_workspace_switch"
    - nebula/clock:
        id: system_clock
        format: "%H:%M:%S"
        on_click: "toggle_clock_format"
    - nebula/button:
        id: toggle_panel_btn
        label: "☰"
        on_click: "toggle_panel_visibility"
```

-- events.lua
``` lua
function toggle_panel_visibility(source_widget)
    local panel = get_widget_by_id("main_panel")
    if panel then
        local panel_module = require("nebula.panel")
        panel_module.toggle_visibility(panel)
    end
end
```
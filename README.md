# NebulaShell

A lightweight, modular Wayland widget framework for Hyprland and other wlroots-based compositors.

## Features

- **Fast & Lightweight** - Written in Vala with GTK4 for maximum performance
- **Fully Customizable** - YAML configuration with Lua scripting
- **Modular Widget System** - Built-in widgets with easy extension
- **Layer Shell** - Wayland layer-shell protocol integration
- **CLI Tool** - Run, inspect, and manage NebulaShell from the command line
- **YAML Intellisense** - JSON Schema support for autocompletion in editors
- **Memory Safe** - Built with modern Vala/GLib practices

## Dependencies

- `gtk4` - GTK4 toolkit
- `gtk4-layer-shell` - Wayland layer shell protocol
- `glib-2.0`, `gobject-2.0`, `gio-2.0` - GLib/GObject/GIO
- `lua5.4` (or 5.3/5.2) - Lua VM

## Installation

### Build from source

```bash
# Install dependencies (Arch Linux)
sudo pacman -S gtk4 gtk4-layer-shell lua54 meson vala

# Install dependencies (Ubuntu/Debian)
sudo apt install libgtk-4-dev libgtk4-layer-shell-dev liblua5.4-dev meson valac

# Build
meson setup build --prefix=/usr
meson compile -C build

# Install
sudo meson install -C build
```

### Quick start

```bash
# Run with default config
nebula-shell run

# Run with custom config
nebula-shell run ~/.config/nebula-shell/config.yaml

# Quit a running instance
nebula-shell quit

# Debug mode
GTK_DEBUG=interactive nebula-shell run

# Test from build directory (uses repo files instead of stale system install)
export NEBULA_SYSROOT=$PWD
./build/nebula-shell run
```

## Configuration

### File locations

| Path | Purpose |
|------|---------|
| `/etc/nebula-shell/` | System defaults (read-only) |
| `~/.config/nebula-shell/` | User overrides (takes priority) |

### Config structure

```yaml
# ~/.config/nebula-shell/config.yaml
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: top
  children:
    - nebula/clock:
        id: system_clock
        format: "%H:%M:%S"
        on_click: "toggle_clock_format"

    - nebula/button:
        id: app_launcher
        label: "\u2630"
        on_click: "open_app_launcher"

nebula/panel:
  id: main_panel
  style_class: "panel"
  visible: false
  anchor: bottom
  height: 300
  children:
    - nebula/label:
        id: panel_title
        text: "Control Panel"
    - nebula/button:
        id: close_btn
        label: "Close"
        on_click: "toggle_panel_visibility"
```

### Event handlers

```lua
-- ~/.config/nebula-shell/events.lua
function toggle_panel_visibility(source)
    local panel = get_widget_by_id("main_panel")
    if panel then
        local visible = panel:get_visible()
        panel:set_visible(not visible)
        log_info("Panel visibility: " .. tostring(not visible))
    end
end

function toggle_clock_format(source)
    local clock = get_widget_by_id("system_clock")
    if clock then
        local fmt = clock:get_label()
        clock:set_label(os.date("%I:%M %p"))
    end
end
```

### YAML Editor Intellisense

NebulaShell provides a JSON Schema for YAML language server support.
Configure your editor:

**VS Code** (`settings.json`):
```json
"yaml.schemas": {
    "~/.config/nebula-shell/nebula-shell.schema.json": ["config.yaml"]
}
```

**Neovim** (with `yaml-companion.nvim`):
```lua
require('yaml-companion').setup({
    schemas = {
        { name = "NebulaShell", uri = "~/.config/nebula-shell/nebula-shell.schema.json" }
    }
})
```

Generate the full schema:
```bash
nebula-shell schema --output ~/.config/nebula-shell/nebula-shell.schema.json
```

## CLI Reference

```bash
nebula-shell run [config.yaml]         # Run with default or custom config
nebula-shell quit                      # Quit a running instance
nebula-shell inspect [options]         # Inspect running widgets
nebula-shell schema [options]          # Generate JSON Schema
nebula-shell help                      # Show help
nebula-shell version                   # Show version
```

### Inspect options

| Option | Description |
|--------|-------------|
| `--id <id>` | Filter by widget ID |
| `--class <class>` | Filter by CSS class |
| `--type <type>` | Filter by GTK type |
| `--tree` | Show full GTK widget tree |
| `--json` | JSON output |

### Schema options

| Option | Description |
|--------|-------------|
| `--output <path>` | Write schema to file |

## Built-in Widgets

| Widget | Description | Properties |
|--------|-------------|------------|
| `nebula/bar` | Top/bottom bar | `id`, `style_class`, `anchor`, `height`, `children` |
| `nebula/panel` | Toggleable panel | `id`, `style_class`, `visible`, `anchor`, `height`, `children` |
| `nebula/clock` | Time display | `id`, `style_class`, `format`, `interval`, `on_click` |
| `nebula/cpu` | CPU usage meter | `id`, `style_class`, `update_interval`, `warning_threshold`, `critical_threshold` |
| `nebula/button` | Clickable button | `id`, `style_class`, `label`, `on_click` |
| `nebula/label` | Text label | `id`, `style_class`, `text` |
| `nebula/box` | Container | `id`, `style_class`, `orientation`, `spacing`, `children` |
| `nebula/separator` | Visual separator | `id`, `style_class`, `orientation` |
| `nebula/workspaces` | Hyprland workspace switcher | `id`, `style_class`, `update_interval` |

## Custom Widgets

Create custom widgets in `~/.config/nebula-shell/widgets/custom/`.

Each widget file must export:

```lua
local M = {}

M.schema = {
    id = { type = "string" },
    style_class = { type = "string", default = "my-widget" },
    -- your properties here
}

M.defaults = {
    style_class = "my-widget"
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "label"  -- or "button", "box", "progress_bar"
    return config
end

function M.destroy(config)
    -- cleanup
end

function M.merge_defaults(props)
    local result = {}
    for k, v in pairs(M.defaults) do result[k] = props[k] or v end
    for k, v in pairs(props) do result[k] = v end
    return result
end

return M
```

Use in config.yaml:
```yaml
custom/my-widget:
  id: my_custom_widget
  style_class: "custom"
```

## Project Architecture

```
User Config (YAML + Lua)
       |
Framework Layer (Lua Bridge + Widget Builder)
       |
Core Engine (Vala + GTK4 + Wayland)
```

## Links

- **GitHub**: https://github.com/n0ctaneteam/nebula-shell
- **Documentation**: https://n0ctaneteam.github.io/docs/nebula-shell
- **License**: Apache 2.0

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

Apache License 2.0 - See LICENSE for details. Copyright N0ctaneTeam.

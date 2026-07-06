# AGENTS.md - NebulaShell Development Guide

## Project Overview

**NebulaShell** is a lightweight, modular Wayland widget framework for Hyprland and other wlroots-based compositors. It combines a fast Vala/GTK4 core with a flexible Lua/YAML configuration system.

## Repository Information

- **GitHub**: https://github.com/n0ctaneteam/nebula-shell
- **Owner**: N0ctaneTeam
- **License**: Apache 2.0
- **Docs**: https://n0ctaneteam.github.io/docs/nebula-shell

## Architecture

### Three-Layer Design
┌─────────────────────────────────────────────┐
│ CONFIGURATION LAYER (User) │
│ YAML (Structure) + Lua (Logic) │
├─────────────────────────────────────────────┤
│ SCRIPTING LAYER (Framework) │
│ Lua Bridge + Widget Definitions │
├─────────────────────────────────────────────┤
│ CORE LAYER (Vala/GTK4) │
│ Wayland Integration + Widget Rendering │
└─────────────────────────────────────────────┘


### Key Components

| Component | Technology | Responsibility |
|-----------|------------|----------------|
| **Core Engine** | Vala + GTK4 | Wayland layer shell, event loop, window management |
| **Widget System** | Vala + Lua | Widget creation, lifecycle management, GTK integration |
| **Configuration** | YAML | Declarative widget tree and properties |
| **Scripting** | Lua | Dynamic behavior, event handlers, custom logic |
| **Styling** | CSS | GTK styling for all widgets |
| **CLI Tool** | Vala | Runtime management, inspection, debugging |

## Development Priorities

1. **Speed**: Low-latency, compiled Vala/GTK4 core
2. **Memory Efficiency**: Minimal RAM usage, no leaks
3. **User Configurability**: Lua scripting + YAML layout
4. **Clean API**: Well-documented, intuitive for users
5. **Extensibility**: Easy to add custom widgets

## File Structure
nebula-shell/
├── src/
│ ├── nebula_shell.vala # Main entry point
│ ├── core/ # Core framework
│ │ ├── application.vala # GTK Application
│ │ ├── config_loader.vala # YAML loader with override support
│ │ ├── widget_builder.vala # Builds widget tree from config
│ │ ├── lua_bridge.vala # Lua VM integration
│ │ ├── css_manager.vala # CSS provider
│ │ └── registry.vala # Widget registry with lookup
│ └── cli/ # CLI tool
│ ├── main.vala # CLI entry point
│ ├── commands.vala # Command dispatcher
│ ├── runner.vala # 'run' command
│ └── inspector.vala # 'inspect' command
├── etc/nebula-shell/ # System defaults (read-only)
│ ├── config.yaml
│ ├── events.lua
│ ├── styles/style.css
│ └── widgets/
|   └── nebula/ # Built-in widgets
|   └── custom/ # custom widgets
├── data/ # Application data
│ ├── nebula-shell.desktop
│ └── nebula-shell.1
├── meson.build
├── makefile
├── LICENSE
└── README.md


## Configuration System

### Override Priority

1. User config: `~/.config/nebula-shell/`
2. System config: `/etc/nebula-shell/`
3. Hardcoded defaults

### Widget Resolution Path

1. `~/.config/nebula-shell/widgets/<namespace>/<widget>.lua`
2. `/etc/nebula-shell/widgets/<namespace>/<widget>.lua`

### YAML Structure

```yaml
nebula/bar:           # Widget type (namespace/name)
  id: main_bar              # Unique identifier
  style_class: "bar"        # CSS class
  children:                 # Child widgets (nested)
    - nebula/button:
        label: "Click Me"
        on_click: "handler_function"  # References events.lua
```

### CLI TOOL

`nebula-shell [command] [options]`

Commands:
  run [config.lua]     Run NebulaShell with optional custom config
  inspect [options]    Inspect running widgets
  help                 Show help
  version              Show version

Inspect Options:
  --id <id>           Filter by widget ID
  --class <class>     Filter by CSS class
  --type <type>       Filter by GTK type
  --tree              Show full GTK widget tree
  --json              JSON output

### Widget Development
**Widget File Structure**

Each widget .lua file must define:
M.schema - Property validation schema
M.defaults - Default property values
M.create(props, event_handlers) - Creates GTK widget
M.destroy(widget) - Cleanup (optional)
M.merge_defaults(props) - Helper for merging

**Available Built-in Widgets** (to be made)
nebula/bar - Main panel bar
nebula/panel - Toggleable panel
nebula/clock - Time display
nebula/cpu - CPU usage meter
nebula/button - Clickable button
nebula/label - Text label
nebula/box - Container
nebula/separator - Visual separator
nebula/workspaces - Workspace switcher

**Naming Conventions**
Context	| Convention |	Example
Brand/Display |	NebulaShell |	"Welcome to NebulaShell"
Executable |	nebula-shell |	/usr/bin/nebula-shell
Code Namespace |	NebulaShell |	namespace NebulaShell
Lua Module |	nebula/ |	require("nebula/clock")
YAML Type |	nebula/panel |	Widget type in config
Config Directory |	nebula-shell |	/etc/nebula-shell/
Application ID |	com.n0ctaneteam.nebula.shell |	Gtk application ID

Development Workflow

**Build**
```bash
meson setup build --prefix=/usr
meson compile -C build```

**Test**
```bash
./build/src/nebula-shell run```

**Debug**
```bash
GTK_DEBUG=interactive ./build/src/nebula-shell run```

**Install**
```bash
sudo meson install -C build```


### Dependencies

GTK4 (gtk4)
GTK4 Layer Shell (gtk4-layer-shell-0.1)
GLib (glib-2.0)
GObject (gobject-2.0)
GIO (gio-2.0)
Lua 5.2+ (lua5.2, lua5.3, or lua5.4)

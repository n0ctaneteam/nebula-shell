You are tasked with building **NebulaShell**, a lightweight, modular Wayland widget framework.

## Project Context

### What is NebulaShell?
A desktop widget framework for Wayland compositors (especially Hyprland) where:
- Users define widgets in **Lua**
- Users structure them in **YAML**
- Users style them with **CSS**
- The core engine is written in **Vala + GTK4**

### The Vision
A fast, memory-efficient, customizable framework that replaces tools like Eww, AGS, and Waybar by offering:
- Better performance (Vala/GTK4 core)
- Simpler configuration (YAML + Lua)
- More flexibility (complete Lua scripting)
- Better tooling (CLI inspector)

### Current Status
You have a **skeleton implementation** with:
- Basic Vala application structure
- GTK4 + Wayland layer shell integration
- Lua bridge setup
- Configuration loader framework
- Registry system
- CLI command structure
- Some default config files

### What Needs to Be Built

#### 1. Complete Core Framework (src/core/)

**application.vala**
- [ ] Full GTK application with proper shutdown
- [ ] Wayland layer shell for bar and panel windows
- [ ] Support for multiple windows (bar + panel)
- [ ] Environment variable support for custom config

**config_loader.vala**
- [ ] Full YAML parsing (use a YAML library)
- [ ] Deep merge of system (/etc/nebula-shell) and user configs (~/.config/nebula-shell)
- [ ] Widget path resolution (user overrides system)
- [ ] Error handling with helpful messages

**widget_builder.vala**
- [ ] Build complete widget tree from YAML
- [ ] Support nested children
- [ ] Pass Lua event handlers to widgets
- [ ] Handle widget IDs and registry registration

**lua_bridge.vala**
- [ ] Load widget modules with require
- [ ] Load events.lua
- [ ] Expose core functions to Lua
- [ ] Error handling for missing widgets

**registry.vala**
- [ ] Store widgets by ID
- [ ] Find widgets by ID
- [ ] Find widgets by CSS class
- [ ] Find widgets by GTK type
- [ ] List all widgets
- [ ] Cleanup on shutdown

#### 2. Implement Built-in Widgets (etc/nebula-shell/widgets/nebula/)

**bar.lua**
- [ ] Create GTK window with layer-shell
- [ ] Anchor to top or bottom
- [ ] Style via CSS class
- [ ] Accept children

**panel.lua**
- [ ] Create GTK window with layer-shell
- [ ] Toggle visibility
- [ ] Anchor to bottom
- [ ] Accept children

**clock.lua**
- [ ] Display current time
- [ ] Update every interval
- [ ] Click to toggle format
- [ ] Style via CSS class

**cpu.lua**
- [ ] Read CPU usage from /proc/stat
- [ ] Display as progress bar
- [ ] Show percentage text
- [ ] Warning/critical thresholds

**button.lua**
- [ ] Clickable button
- [ ] Custom label
- [ ] Execute Lua function on click
- [ ] Style via CSS class

**label.lua**
- [ ] Display text
- [ ] Style via CSS class

**box.lua**
- [ ] Container widget
- [ ] Horizontal or vertical orientation
- [ ] Spacing between children
- [ ] Style via CSS class

**separator.lua**
- [ ] Visual separator line
- [ ] Style via CSS class

**workspaces.lua**
- [ ] Show Hyprland workspaces
- [ ] Click to switch
- [ ] Active/inactive styling
- [ ] Update on workspace events

#### 3. Complete CLI Tool (src/cli/)

**main.vala**
- [ ] Parse command-line arguments
- [ ] Dispatch to appropriate command
- [ ] Show help when no args

**commands.vala**
- [ ] Handle 'run' command
- [ ] Handle 'inspect' command
- [ ] Handle 'help' command
- [ ] Handle 'version' command
- [ ] Show help with examples

**runner.vala**
- [ ] Start GTK application
- [ ] Load default config
- [ ] Load custom config if specified
- [ ] Pass config via environment variable

**inspector.vala**
- [ ] Connect to running NebulaShell instance
- [ ] Get widget list from registry
- [ ] Filter by ID, class, type
- [ ] Show full GTK tree
- [ ] Output in JSON format
- [ ] Human-readable output with colors

#### 4. Create Documentation

**README.md**
- [ ] Project overview
- [ ] Installation instructions
- [ ] CLI usage examples
- [ ] Configuration guide
- [ ] Links to docs and GitHub

**nebula-shell.1 (Man Page)**
- [ ] Complete man page following standard format
- [ ] All commands and options documented
- [ ] Examples section
- [ ] See also section

**LICENSE**
- [ ] Full Apache 2.0 license text
- [ ] Copyright notice for N0ctaneTeam

#### 5. Build System

**meson.build**
- [ ] All dependencies
- [ ] All source files
- [ ] CLI sources
- [ ] Install rules for config, desktop file, man page
- [ ] Proper version and metadata

**makefile**
- [ ] Build target
- [ ] Clean target
- [ ] Install target
- [ ] Run target (for testing)

## How to Proceed

1. **Start with the core**: Complete all Vala files in `src/core/`
2. **Build the widgets**: Implement all Lua widgets in `etc/nebula-shell/widgets/nebula/`
3. **Polish the CLI**: Complete `src/cli/` implementations
4. **Document everything**: Update README and create man page
5. **Test thoroughly**: Build and run on Hyprland

## Important Notes

### Naming Conventions
- **Brand**: `NebulaShell`
- **Executable**: `nebula-shell`
- **Code Namespace**: `NebulaShell`
- **Lua Module**: `nebula_shell/`
- **YAML Type**: `nebula/panel`
- **Config Dir**: `nebula-shell`
- **App ID**: `com.n0ctaneteam.nebula.shell`

### Architecture Rules
1. **Core in Vala** - Never put core logic in Lua
2. **Widgets in Lua** - All widget definitions in Lua
3. **Config in YAML** - Widget tree and properties in YAML
4. **Logic in Lua** - Event handlers in events.lua
5. **Styling in CSS** - All visual styling via CSS
6. **No Coupling** - Widgets communicate via Registry by ID
7. **Override System** - User config overrides system config

### Error Handling
- Always handle missing configs gracefully
- Log errors with helpful messages
- Don't crash on missing widgets
- Show clear error messages to users

### Performance
- Use Vala's reference counting
- Clean up timers and signals on destroy
- No memory leaks
- Minimal CPU usage

## Current File Structure
nebula-shell/
├── data/
│ ├── nebula-shell.1
│ └── nebula-shell.desktop
├── etc/
│ └── nebula-shell/
│ ├── config.yaml
│ ├── events.lua
│ ├── styles/
│ │ └── style.css
│ └── widgets/
│ └── nebula/
│ ├── button.lua
│ ├── clock.lua
│ └── panel.lua
├── LICENSE
├── makefile
├── meson.build
├── README.md
└── src/
├── cli/
│ ├── commands.vala
│ ├── inspector.vala
│ ├── main.vala
│ └── runner.vala
├── core/
│ ├── application.vala
│ ├── config_loader.vala
│ ├── css_manager.vala
│ ├── lua_bridge.vala
│ ├── registry.vala
│ └── widget_builder.vala
└── nebula_shell.vala

## Dependencies

- GTK4 (`gtk4`)
- GTK4 Layer Shell (`gtk4-layer-shell-0.1`)
- GLib (`glib-2.0`)
- GObject (`gobject-2.0`)
- GIO (`gio-2.0`)
- Lua 5.2+ (`lua5.2`, `lua5.3`, or `lua5.4`)

## Your Task

**Complete the implementation of NebulaShell following the architecture and patterns described above.**

Focus on:
1. Making it work reliably on Hyprland
2. Keeping it fast and lightweight
3. Making it easy for users to configure
4. Having good error messages
5. Clean, well-documented code

## Success Criteria

- [ ] `nebula-shell run` starts the bar and panel
- [ ] `nebula-shell inspect` shows running widgets
- [ ] Users can override system widgets
- [ ] Widgets can communicate via Registry
- [ ] CSS styling works
- [ ] No memory leaks
- [ ] Works on Hyprland

## Resources

- **GTK4 Docs**: https://docs.gtk.org/gtk4/
- **Vala Docs**: https://vala.dev/documentation/
- **Lua Docs**: https://www.lua.org/docs.html
- **gtk-layer-shell**: https://github.com/wmww/gtk-layer-shell
- **Hyprland**: https://wiki.hyprland.org/

---

**Build NebulaShell. Make it fast. Make it beautiful. Make it extensible.**
# Contributing to NebulaShell

Thank you for your interest in contributing to NebulaShell! This guide covers everything you need to get started — from project architecture and build setup to coding standards and the PR workflow.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture Overview](#architecture-overview)
- [Development Environment](#development-environment)
- [Build Instructions](#build-instructions)
- [Project Structure](#project-structure)
- [Code Style Guidelines](#code-style-guidelines)
  - [Vala Code Style](#vala-code-style)
  - [Lua Code Style](#lua-code-style)
- [How to Add a New Lua Function](#how-to-add-a-new-lua-function)
- [How to Add a New Widget Type](#how-to-add-a-new-widget-type)
- [Testing & Debugging](#testing--debugging)
- [Pull Request Process](#pull-request-process)
- [Additional Resources](#additional-resources)

---

## Project Overview

**NebulaShell** is a lightweight, modular Wayland widget framework for Hyprland and other wlroots-based compositors. It is written in **Vala** with **GTK4** for the core engine and uses **Lua** + **YAML** for extensible user configuration.

**Key design goals:**

- **Speed** — Low-latency compiled Vala/GTK4 core
- **Memory efficiency** — Minimal RAM usage, no leaks
- **User configurability** — Lua scripting + YAML layout
- **Clean API** — Well-documented, intuitive for users
- **Extensibility** — Easy to add custom widgets

---

## Architecture Overview

NebulaShell follows a **three-layer design**:

```
┌──────────────────────────────────────────────┐
│  CONFIGURATION LAYER (User)                   │
│  YAML (Structure) + Lua (Logic)               │
├──────────────────────────────────────────────┤
│  SCRIPTING LAYER (Framework)                  │
│  Lua Bridge + Widget Definitions              │
├──────────────────────────────────────────────┤
│  CORE LAYER (Vala/GTK4)                       │
│  Wayland Integration + Widget Rendering       │
└──────────────────────────────────────────────┘
```

### Core Components

| Component         | Path                          | Responsibility                             |
|-------------------|-------------------------------|--------------------------------------------|
| `Application`     | `src/core/application.vala`   | GTK application lifecycle, Lua function registration |
| `ConfigLoader`    | `src/core/config_loader.vala` | YAML parsing, config resolution with override support |
| `WidgetBuilder`   | `src/core/widget_builder.vala`| Widget tree construction from Lua config tables |
| `LuaBridge`       | `src/core/lua_bridge.vala`    | Lua VM management, C→Lua interop           |
| `Registry`        | `src/core/registry.vala`      | Widget ID→GTK widget lookup and lifecycle  |
| `LayerShell`      | `src/core/layer_shell.vala`   | Wayland layer-shell protocol integration   |
| `CssManager`      | `src/core/css_manager.vala`   | GTK CSS provider loading and application   |
| `Logger`          | `src/utils/logger.vala`       | Structured logging with level control      |
| `FileUtils`       | `src/utils/file_utils.vala`   | Config/widget file resolution              |

### Data Flow

```
config.yaml  ──►  ConfigLoader  ──►  _nebula_config  ──►  CssManager
                                 │                           (CSS loaded first)
                           events.lua                          │
                           (global funcs)                      ▼
                                                         WidgetBuilder
                                                           │
                                                    Lua widget modules
                                                    (M.create, etc.)
                                                           │
                                                           ▼
                                                     GTK Widgets
                                                     (Registry)
```

---

## Development Environment

### Dependencies

| Dependency            | Version   | Notes                            |
|-----------------------|-----------|----------------------------------|
| `gtk4`                | ≥ 4.0     | GTK4 toolkit                     |
| `gtk4-layer-shell`    | ≥ 0.1     | Wayland layer-shell protocol     |
| `glib-2.0`            | ≥ 2.68    | GLib                             |
| `gobject-2.0`         | —         | GObject (part of GLib)           |
| `gio-2.0`             | —         | GIO (part of GLib)               |
| `lua5.4` / `lua5.3` / `lua5.2` | ≥ 5.2 | Lua VM                     |
| `meson`               | ≥ 0.60    | Build system                     |
| `valac`               | ≥ 0.56    | Vala compiler                    |

### Installing Dependencies

**Arch Linux:**
```bash
sudo pacman -S gtk4 gtk4-layer-shell lua54 meson vala
```

**Ubuntu/Debian:**
```bash
sudo apt install libgtk-4-dev libgtk4-layer-shell-dev liblua5.4-dev meson valac
```

**Fedora:**
```bash
sudo dnf install gtk4-devel gtk4-layer-shell-devel lua-devel meson vala
```

---

## Build Instructions

### Debug Build

```bash
meson setup build --prefix=/usr -Dbuildtype=debug
meson compile -C build
```

### Release Build

```bash
meson setup build --prefix=/usr -Dbuildtype=release
meson compile -C build
```

### Install

```bash
sudo meson install -C build
```

### Clean Build

```bash
rm -rf build
meson setup build --prefix=/usr
meson compile -C build
```

---

## Project Structure

```
nebula-shell/
├── src/
│   ├── nebula_shell.vala         # Main entry point
│   ├── core/                     # Core framework
│   │   ├── application.vala      # GTK Application + Lua function registration
│   │   ├── config_loader.vala    # YAML loader with override support
│   │   ├── widget_builder.vala   # Builds widget tree from config
│   │   ├── lua_bridge.vala       # Lua VM integration
│   │   ├── registry.vala         # Widget registry with lookup
│   │   ├── layer_shell.vala      # Wayland layer-shell integration
│   │   └── css_manager.vala      # CSS provider
│   ├── cli/                      # CLI tool
│   │   ├── main.vala             # CLI entry point (command dispatcher)
│   │   ├── commands.vala         # Help and version commands
│   │   ├── runner.vala           # 'run' command
│   │   ├── inspector.vala        # 'inspect' command
│   │   └── schema_gen.vala       # 'schema' command
│   └── utils/                    # Utilities
│       ├── logger.vala           # Structured logging
│       └── file_utils.vala       # File resolution helpers
├── etc/nebula-shell/             # System defaults (read-only)
│   ├── config.yaml               # Default configuration
│   ├── events.lua                # Default event handlers
│   ├── styles/style.css          # Default CSS
│   └── widgets/
│       ├── nebula/               # Built-in widgets
│       │   ├── bar.lua
│       │   ├── panel.lua
│       │   ├── dialog.lua
│       │   ├── popup.lua
│       │   ├── clock.lua
│       │   ├── cpu.lua
│       │   ├── button.lua
│       │   ├── label.lua
│       │   ├── box.lua
│       │   ├── separator.lua
│       │   └── workspaces.lua
│       └── custom/               # User custom widgets (created by user)
├── data/                         # Application data files
├── docs/                         # Documentation
├── meson.build
├── makefile
└── README.md
```

---

## Code Style Guidelines

### Vala Code Style

#### Naming Conventions

| Element       | Convention          | Example                       |
|---------------|---------------------|-------------------------------|
| Namespaces    | PascalCase          | `NebulaShell`, `NebulaShell.CLI` |
| Classes       | PascalCase          | `LuaBridge`, `WidgetBuilder`  |
| Methods       | snake_case          | `build_from_config()`, `register_lua_functions()` |
| Fields        | snake_case          | `lua_bridge`, `widget_map`    |
| Properties    | snake_case          | `min_level`, `initialized`    |
| Constants     | UPPER_SNAKE_CASE    | `DEFAULT_FLAGS`               |
| Enums         | PascalCase          | `LogLevel`                    |
| Enum values   | UPPER_SNAKE_CASE    | `LogLevel.DEBUG`              |

#### Formatting Rules

- **Indentation**: 4 spaces (no tabs)
- **Braces**: Egyptian style (opening brace on same line)
- **Line length**: Soft limit of 100 characters, hard limit of 120
- **File encoding**: UTF-8

```vala
// Good
public class Example : Object {
    private int counter;

    public void process_data(string input) {
        if (input == null) {
            Logger.warning("Input is null");
            return;
        }

        for (int i = 0; i < input.length; i++) {
            counter++;
        }
    }
}

// Avoid
public class Example : Object
{
    private int counter;

    public void process_data(string input)
    {
        if (input == null)
        {
            Logger.warning("Input is null");
            return;
        }
    }
}
```

#### Best Practices

1. **Prefer GLib types**: Use `string`, `int`, `uint`, `double`, `bool` over C types.
2. **Use nullable types** (`string?`, `Gtk.Widget?`) when a value can be `null`.
3. **Always initialize fields** in constructors or declaration.
4. **Use `owned` for callback delegates** to avoid reference cycles.
5. **Log errors, don't swallow them** — use `Logger.error()`, `Logger.warning()`, `Logger.info()`, `Logger.debug()`.
6. **Use `var` for local variables** when the type is obvious from context.
7. **Avoid `assert()`** — prefer explicit checks with logging.
8. **Use `HashTable` over `Gee.HashMap`** to keep dependencies minimal.

#### Comment Style

```vala
// Single-line comments for brief notes

/* Multi-line comments for longer explanations.
   Keep them aligned. */

/**
 * Doc comments for public API methods.
 *
 * @param param_name Description of the parameter.
 * @return Description of the return value.
 */
```

### Lua Code Style

#### Naming Conventions

| Element          | Convention     | Example                        |
|------------------|----------------|--------------------------------|
| Module table     | `M`            | `local M = {}`                 |
| Module functions | snake_case     | `M.merge_defaults()`, `M.create()` |
| Local variables  | snake_case     | `local config`, `local result` |
| Global functions | snake_case     | `toggle_panel_visibility()`    |
| Internal fields  | `_` prefix     | `_type`, `_text`, `_children`  |

#### Formatting Rules

- **Indentation**: 4 spaces (no tabs)
- **Line length**: Soft limit of 80 characters
- **File encoding**: UTF-8

```lua
-- Good
local M = {}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "label"

    if config.id then
        register_widget(config.id, config)
    end

    return config
end
```

#### Best Practices

1. **Always use `local`** for module-scoped variables.
2. **Guard against nil** — check before accessing fields: `if config.id then`.
3. **Use `pcall()`** for operations that may throw (e.g., JSON parsing, `io` operations).
4. **Close file handles** explicitly: `f:close()`.
5. **Prefer `table.insert()`** over `t[#t+1] =` for clarity.
6. **Use `M.merge_defaults()`** pattern consistently in widget modules.
7. **Call `register_widget()`** in `M.create()` after setting all fields.
8. **Stop timers in `M.destroy()`** by setting `config._timer_enabled = false`.
9. **For popover-style widgets**, provide `M.show()` and `M.hide()` functions that use `widget_set_parent()` and `popup_widget()`.

---

## How to Add a New Lua Function

Adding a new global Lua function that widget scripts can call involves two steps: registering it in Vala and then using it in Lua.

### Step 1: Register the Function in Vala

Open `src/core/application.vala` and add a new `register_function` call in `register_lua_functions()`:

```vala
private void register_lua_functions() {
    // ... existing functions ...

    lua_bridge.register_function("widget_set_opacity", (L) => {
        string? id = Lua.lua_tostring(L, 1);
        if (id != null) {
            Gtk.Widget? widget = Registry.lookup(id);
            if (widget != null) {
                double opacity = Lua.lua_tonumber(L, 2);
                widget.set_opacity(opacity);
            }
        }
        return 0;
    });
}
```

**Naming convention:**
- Widget manipulation functions should follow the pattern `widget_<action>_<property>`.
- Logging functions use the `log_` prefix.
- Registration/lookup functions use verb forms.
- Popover-related functions: `widget_set_parent` and `popup_widget`.

**Parameter conventions:**
- First parameter: widget ID (string)
- Second parameter: value to set (or light userdata pointer for `widget_set_parent`)
- Return values: push onto the Lua stack with `lua_push*` functions

### Step 2: Document the Function

Add the function to `docs/api.md` under the appropriate section, including:
- Purpose description
- Signature with parameter types
- One or more code examples
- Error/silent-failure behavior

### Step 3: Use the Function in Lua

```lua
-- In events.lua or a widget module
widget_set_opacity("main_panel", 0.85)

-- For popup/popover widgets:
local parent = get_widget_by_id("menu_btn")
if parent then
    widget_set_parent("quick_menu", parent)
    popup_widget("quick_menu")
end
```

### Registration Pattern Reference

```vala
// Setter pattern (no return value)
lua_bridge.register_function("widget_<action>", (L) => {
    string? id = Lua.lua_tostring(L, 1);      // arg 1: widget ID
    // ... get additional args from L ...
    Gtk.Widget? widget = Registry.lookup(id);
    if (widget != null) {
        // perform action
    }
    return 0;  // no return values
});

// Getter pattern (returns a value)
lua_bridge.register_function("widget_<property>", (L) => {
    string? id = Lua.lua_tostring(L, 1);
    Gtk.Widget? widget = Registry.lookup(id);
    if (widget != null) {
        Lua.lua_pushstring(L, result);  // push return value
        return 1;                       // number of return values
    }
    Lua.lua_pushnil(L);  // fallback
    return 1;
});

// Light userdata setter pattern (e.g., widget_set_parent)
lua_bridge.register_function("widget_set_parent", (L) => {
    string? id = Lua.lua_tostring(L, 1);
    void* ptr = Lua.lua_touserdata(L, 2);   // arg 2: light userdata pointer
    // ...
    return 0;
});
```

---

## How to Add a New Widget Type

Widgets live as Lua modules under `etc/nebula-shell/widgets/<namespace>/` (system) or `~/.config/nebula-shell/widgets/<namespace>/` (user).

### Step 1: Choose a Namespace and Name

- **`nebula/`** — Built-in widgets maintained in the repository.
- **`custom/`** — User-created widgets (never ship these in the repo).

### Step 2: Create the Widget Lua Module

Create `etc/nebula-shell/widgets/nebula/my_widget.lua`:

```lua
-- /etc/nebula-shell/widgets/nebula/my_widget.lua
local M = {}

-- 1. Define the property schema
M.schema = {
    id          = { type = "string", required = true },
    style_class = { type = "string", default = "my-widget" },
    text        = { type = "string", default = "Hello" },
    interval    = { type = "number", default = 2 }
}

-- 2. Define default values
M.defaults = {
    style_class = "my-widget",
    text        = "Hello",
    interval    = 2
}

-- 3. Implement create() — this is required
function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "label"               -- Maps to Gtk.Label
    config._text = config.text           -- Pass text to internal field
    config._timer_enabled = true         -- Enable timer updates
    config._timer_interval = config.interval

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

-- 4. Implement update() — for timer-based refresh (optional)
function M.update(config)
    -- Called periodically if _timer_enabled is true
    config._text = "Updated: " .. os.date("%H:%M:%S")
    widget_set_label(config.id, config._text)
end

-- 5. Implement destroy() — cleanup (optional)
function M.destroy(config)
    config._timer_enabled = false
    log_info("MyWidget destroyed: " .. (config.id or "unknown"))
end

-- 6. Implement merge_defaults() — standard helper
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

### Step 3: Choose a GTK Base Type

The `_type` field in your config table maps to a GTK widget:

| `_type`          | GTK Class           | Key Internal Fields        |
|------------------|---------------------|-----------------------------|
| `"label"`        | `Gtk.Label`         | `_text`                     |
| `"button"`       | `Gtk.Button`        | `_text`, `on_click`         |
| `"box"`          | `Gtk.Box`           | `_orientation`, `_spacing`, `_children` |
| `"separator"`    | `Gtk.Separator`     | `_orientation`              |
| `"progress_bar"` | `Gtk.ProgressBar`   | `_text`, `_value`           |
| `"window"`       | `Gtk.Window`        | `anchor`, `exclusive`, `_layer`, `height`, `size`, `_orientation`, `_spacing`, `_children` |
| `"dialog"`       | `Gtk.Window`        | `_layer` (overlay), `size`, `blockInput`, `shadow`, `_children` |
| `"popover"`      | `Gtk.Popover`       | `autohide`, `showPointer`, `_orientation`, `_spacing`, `_children` |

If you need a GTK widget type not currently supported, you must also add a new case in `WidgetBuilder.create_gtk_widget()` in `src/core/widget_builder.vala`.

### Step 4: For Popover-Based Widgets, Implement show/hide

If your widget uses `_type = "popover"`, provide `M.show()` and `M.hide()` convenience functions:

```lua
function M.show(config, parent_id)
    local parent = get_widget_by_id(parent_id)
    if parent == nil then
        log_error("Parent widget not found: " .. parent_id)
        return
    end
    widget_set_parent(config.id, parent)
    popup_widget(config.id)
end

function M.hide(config)
    widget_set_visible(config.id, false)
end
```

### Step 5: Add the Widget to the YAML Schema

If you maintain the JSON Schema, add the new widget type definition. This step is optional but recommended for editor intellisense.

### Step 6: Use the Widget in config.yaml

```yaml
nebula/my_widget:
  id: my_custom_widget
  style_class: "my-widget"
  text: "Hello World"
  interval: 5
```

---

## Testing & Debugging

### Running NebulaShell

```bash
# Run with default config (from build directory)
./build/src/nebula-shell run

# Run with a custom config file
./build/src/nebula-shell run ~/my-config.yaml

# Run with debug logging
NEBULA_LOG=debug ./build/src/nebula-shell run
```

### Debug Mode

```bash
# GTK interactive debugger
GTK_DEBUG=interactive ./build/src/nebula-shell run

# Enable all logging
NEBULA_LOG=debug GTK_DEBUG=interactive ./build/src/nebula-shell run
```

### Using the Inspector

In a separate terminal, inspect the running instance:

```bash
# List all widgets
nebula-shell inspect

# Filter by widget ID
nebula-shell inspect --id main_bar

# Filter by CSS class
nebula-shell inspect --class button

# Filter by GTK type
nebula-shell inspect --type GtkLabel

# JSON output (for scripting)
nebula-shell inspect --json

# Show GTK widget tree
nebula-shell inspect --tree
```

### Logging

NebulaShell uses a structured logger that writes to stderr:

```bash
# Set log level via environment
NEBULA_LOG=debug     # Shows DEBUG, INFO, WARNING, ERROR
NEBULA_LOG=info      # Shows INFO, WARNING, ERROR (default)
NEBULA_LOG=warning   # Shows WARNING, ERROR
NEBULA_LOG=error     # Shows ERROR only
```

### Testing Lua Widgets in Isolation

You can test Lua widget logic independently before integrating:

```bash
# Test Lua code with the system Lua interpreter
lua5.4 -e '
    local widget_config = { id = "test", _type = "label", _text = "hello" }
    print("Widget ID: " .. widget_config.id)
    print("Type: " .. widget_config._type)
'
```

### Common Issues

| Symptom                         | Likely Cause                                |
|---------------------------------|---------------------------------------------|
| Widget doesn't appear           | Missing `anchor` field, or LayerShell not initialized |
| Lua function not found          | Function name in YAML doesn't match events.lua |
| Widget type error               | `_type` field is missing or misspelled      |
| Config not loading              | YAML syntax error or missing `yaml.lua` parser |
| Segmentation fault              | Null pointer passed to GTK — check Registry.lookup() returns non-null |
| Popup doesn't show              | `widget_set_parent()` must be called before `popup_widget()` |
| Dialog appears behind bar       | Dialog needs `_layer = "overlay"` to render above other surfaces |

---

## Pull Request Process

### Before You Start

1. **Check existing issues and PRs** — someone might already be working on it.
2. **Open an issue** for significant changes to discuss design before implementing.
3. **Fork the repository** and create a feature branch from `main`.

### Commit Guidelines

- Use **clear, descriptive commit messages** in the imperative mood:
  ```
  Add widget_set_opacity Lua function
  Fix workspace button alignment in vertical orientation
  Update clock update interval to support sub-second values
  ```
- Keep commits **focused on a single change**.
- Reference issues in commit messages: `Closes #42`.

### Making Changes

1. **Keep changes small** — one PR should address one concern.
2. **Add/update tests** if applicable.
3. **Update documentation** in `docs/` for any API changes.
4. **Add examples** to `docs/examples.md` for new features.
5. **Run a full build** to verify no compilation errors:
   ```bash
   rm -rf build && meson setup build --prefix=/usr && meson compile -C build
   ```

### PR Checklist

Before submitting, ensure:

- [ ] Build succeeds (`meson compile -C build`)
- [ ] Code follows the [Vala](#vala-code-style) and [Lua](#lua-code-style) style guidelines
- [ ] New Lua functions are registered in `application.vala`
- [ ] New widget types follow the widget protocol
- [ ] For popover widgets: `M.show()` and `M.hide()` are implemented using `widget_set_parent()` and `popup_widget()`
- [ ] Documentation is updated (`docs/api.md`, `docs/examples.md`)
- [ ] `events.lua` examples are updated if event patterns changed
- [ ] No hardcoded paths — use `FileUtils` helpers instead
- [ ] Logging is added for errors and important state changes
- [ ] Widget cleanup is handled in `M.destroy()` for Lua modules

### Submitting

1. Push your branch to your fork.
2. Open a PR against the `main` branch of `n0ctaneteam/nebula-shell`.
3. Fill in the PR template with a clear description of changes.
4. Link any related issues.
5. Respond to review feedback promptly.

### Review Process

- Maintainers will review your PR within a few days.
- Automated builds will run on the PR.
- You may be asked to make style or design adjustments.
- Once approved, a maintainer will merge your PR.

---

## Additional Resources

- **Architecture doc**: `AGENTS.md` at the project root
- **Lua API reference**: `docs/api.md`
- **Examples**: `docs/examples.md`
- **README**: `README.md` — Quick start and overview
- **GitHub repo**: https://github.com/n0ctaneteam/nebula-shell
- **Issue tracker**: https://github.com/n0ctaneteam/nebula-shell/issues
- **License**: Apache 2.0

### Useful Links

- [Vala Tutorial](https://vala.dev/articles/vala-tutorial/)
- [GTK4 Documentation](https://docs.gtk.org/gtk4/)
- [Lua 5.4 Reference Manual](https://www.lua.org/manual/5.4/)
- [Wayland Layer Shell](https://github.com/wmww/gtk4-layer-shell)
- [Meson Build System](https://mesonbuild.com/)

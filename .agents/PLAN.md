# NebulaShell - Complete Build Plan

## Project: NebulaShell
## Lightweight Wayland Widget Framework (Vala + GTK4 + Lua + YAML)

---

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Namespace | `nebula/` | Matches docs (AGENTS.md, SUMMARY.md), shorter |
| YAML Parsing | Lua-based (`yaml.lua`) | No extra C deps; bundle tiny YAML parser |
| Binary | Single binary with subcommands | Simpler for users |
| Inspector IPC | D-Bus via GLib | Built into GLib/GIO, no extra deps |
| Schema | JSON Schema for YAML editor intellisense | Language server support (yaml-language-server) |
| Schema Generation | Bundled core + CLI regenerate (`nebula-shell schema`) | Covers built-in + custom widgets |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     USER LAYER                              │
│  config.yaml ← validated by ← JSON Schema (editor)          │
│  events.lua (event handlers)                                │
│  ~/.config/nebula-shell/widgets/custom/* (user widgets)     │
├─────────────────────────────────────────────────────────────┤
│                   FRAMEWORK LAYER                           │
│  Lua Bridge (Vala↔Lua)   YAML Parser (yaml.lua)             │
│  Widget Builder           Schema Validator                   │
│  Widget Registry          Event Dispatcher                   │
├─────────────────────────────────────────────────────────────┤
│                     CORE LAYER                              │
│  GTK4 widgets  Wayland layer-shell  D-Bus IPC               │
│  CSS styling   Timers / IO         CLI tool                 │
└─────────────────────────────────────────────────────────────┘
```

---

## File Inventory & Status

### Phase 0: YAML Schema System

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `data/nebula-shell.schema.json` | NEW | ~150 | Bundled JSON Schema for built-in widgets |
| `src/cli/schema_gen.vala` | NEW | ~100 | `nebula-shell schema` CLI command |

### Phase 1: Foundation

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `vapi/lua.vapi` | NEW | ~80 | Lua 5.4 C API bindings |
| `src/utils/logger.vala` | NEW | ~60 | Colored stderr logging |
| `src/utils/file_utils.vala` | NEW | ~40 | Config/widget file resolution |

### Phase 2: Core Framework

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `src/core/lua_bridge.vala` | REWRITE | ~200 | Lua VM wrapper (load, call, register functions, table↔HashTable) |
| `src/core/config_loader.vala` | REWRITE | ~150 | YAML config load + merge via yaml.lua |
| `src/core/registry.vala` | REWRITE | ~120 | Widget registry + D-Bus exposure |
| `src/core/widget_builder.vala` | REWRITE | ~180 | Build widget tree from config |
| `src/core/layer_shell.vala` | NEW | ~60 | Wayland layer-shell wrapper |
| `src/core/css_manager.vala` | REWRITE | ~50 | GTK CSS provider + override system |
| `src/core/application.vala` | REWRITE | ~100 | GTK Application lifecycle |

### Phase 3: Lua Widgets (etc/nebula-shell/widgets/nebula/)

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `bar.lua` | NEW | ~50 | Top bar window with children |
| `panel.lua` | REWRITE | ~70 | Toggleable panel, layer-shell |
| `clock.lua` | REWRITE | ~80 | Time display, click toggle format |
| `cpu.lua` | NEW | ~100 | CPU usage meter |
| `button.lua` | REWRITE | ~50 | Clickable button |
| `label.lua` | NEW | ~30 | Text label |
| `box.lua` | NEW | ~40 | Container (HBox/VBox) |
| `separator.lua` | NEW | ~25 | Visual separator |
| `workspaces.lua` | NEW | ~120 | Hyprland workspace switcher |

### Phase 4: YAML Parser + Config

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `etc/nebula-shell/widgets/yaml.lua` | NEW | ~200 | Minimal YAML→Lua table parser |
| `etc/nebula-shell/config.yaml` | UPDATE | ~70 | Fix namespace: nebula_shell/ → nebula/ |
| `etc/nebula-shell/events.lua` | UPDATE | ~40 | Fix require paths |

### Phase 5: CLI

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `src/nebula_shell.vala` | REWRITE | ~15 | Single entry point, dispatch |
| `src/cli/main.vala` | REWRITE | ~50 | Arg parser + dispatch |
| `src/cli/commands.vala` | REWRITE | ~90 | Help/version display |
| `src/cli/runner.vala` | REWRITE | ~30 | Application runner |
| `src/cli/inspector.vala` | REWRITE | ~200 | D-Bus based inspector |

### Phase 6: Build System

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `meson.build` | REWRITE | ~80 | Fix deps, sources, install rules |
| `makefile` | UPDATE | ~17 | Fix run target |

### Phase 7: Documentation

| File | Status | Lines | Description |
|------|--------|-------|-------------|
| `README.md` | REWRITE | ~200 | Full project docs |
| `data/nebula-shell.1` | UPDATE | ~70 | Man page updates |

---

## Implementation Order (Dependency-Aware)

```
 1. vapi/lua.vapi          (no deps)
 2. src/utils/logger.vala  (no deps)
 3. src/utils/file_utils.vala (no deps)
 4. src/core/lua_bridge.vala  (dep: 1)
 5. etc/nebula-shell/widgets/yaml.lua (no deps)
 6. src/core/config_loader.vala  (dep: 4, 5)
 7. src/core/registry.vala  (dep: 4, 2)
 8. src/core/layer_shell.vala (no deps)
 9. src/core/widget_builder.vala (dep: 4, 6, 7)
10. src/core/css_manager.vala (no deps)
11. src/core/application.vala (dep: 4-10)
12. All 9 Lua widgets (dep: 4, for testing)
13. data/nebula-shell.schema.json (dep: 12)
14. src/cli/schema_gen.vala (dep: 4)
15. src/cli/main.vala (dep: 4)
16. src/cli/commands.vala (dep: 15)
17. src/cli/runner.vala (dep: 15, 11)
18. src/cli/inspector.vala (dep: 15, 7)
19. src/nebula_shell.vala (dep: 15, 11)
20. etc/nebula-shell/config.yaml (dep: 12)
21. etc/nebula-shell/events.lua (dep: 12)
22. meson.build, makefile
23. README.md, man page
```

---

## Key Design Patterns

### Lua Widget Contract
```lua
local M = {}
M.schema = {
    id          = { type = "string" },
    style_class = { type = "string", default = "widget-class" },
    -- ...
}
M.defaults = {
    style_class = "widget-class",
}
function M.create(props, event_handlers) ... end
function M.destroy(widget) ... end         -- optional
function M.merge_defaults(props) ... end   -- helper
return M
```

### Vala ↔ Lua Binding Pattern
- Bridge exposes: `get_widget_by_id(id)`, `register_widget(id, widget)`, `log_info()`, `log_error()`
- Lua calls Vala functions via `lua_bridge.register_function("name", callback)`
- GTK4 widget pointers stored as Lua lightuserdata

### Config Override Priority
1. `~/.config/nebula-shell/` (user)
2. `/etc/nebula-shell/` (system)
3. Hardcoded defaults

### Widget Resolution Path
1. `~/.config/nebula-shell/widgets/<ns>/<name>.lua`
2. `/etc/nebula-shell/widgets/<ns>/<name>.lua`

### JSON Schema for YAML Intellisense
- Bundled: `data/nebula-shell.schema.json` (built-in widgets)
- Regenerated via `nebula-shell schema` (includes custom widgets)
- Referenced by YAML language server for autocompletion
- VS Code: `"yaml.schemas": { "~/.config/nebula-shell/schema.json": ["config.yaml"] }`
- Inline: `# yaml-language-server: $schema=~/.config/nebula-shell/schema.json`

---

## Dependencies

- `gtk4` - GTK4 toolkit
- `gtk4-layer-shell-0.1` - Wayland layer shell protocol
- `glib-2.0`, `gobject-2.0`, `gio-2.0` - GLib/GObject/GIO
- `lua5.4` (or 5.3/5.2) - Lua VM

---

## Post-Build Pipeline

```
Build → QA Testing (sub-agents) → Optimization (sub-agents) → Docs (sub-agents) → notify-send
```

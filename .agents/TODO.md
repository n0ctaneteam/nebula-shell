# NebulaShell - Build TODO

## Status Legend
- [ ] Pending
- [x] Completed
- [-] Blocked/Skipped

---

## P0: YAML Schema System

- [ ] `data/nebula-shell.schema.json` - Core JSON Schema for built-in widgets
- [ ] `src/cli/schema_gen.vala` - `nebula-shell schema` CLI command

## P1: Foundation

- [ ] `vapi/lua.vapi` - Lua 5.4 C API bindings
- [ ] `src/utils/logger.vala` - Colored stderr logging
- [ ] `src/utils/file_utils.vala` - File resolution utilities

## P2: Core Framework

- [ ] `src/core/lua_bridge.vala` - Lua VM wrapper
- [ ] `src/core/config_loader.vala` - YAML config loader
- [ ] `src/core/registry.vala` - Widget registry + D-Bus
- [ ] `src/core/widget_builder.vala` - Widget tree builder
- [ ] `src/core/layer_shell.vala` - Wayland layer-shell wrapper
- [ ] `src/core/css_manager.vala` - CSS provider
- [ ] `src/core/application.vala` - GTK Application lifecycle

## P3: Lua Widgets

- [ ] `etc/nebula-shell/widgets/nebula/bar.lua`
- [ ] `etc/nebula-shell/widgets/nebula/panel.lua`
- [ ] `etc/nebula-shell/widgets/nebula/clock.lua`
- [ ] `etc/nebula-shell/widgets/nebula/cpu.lua`
- [ ] `etc/nebula-shell/widgets/nebula/button.lua`
- [ ] `etc/nebula-shell/widgets/nebula/label.lua`
- [ ] `etc/nebula-shell/widgets/nebula/box.lua`
- [ ] `etc/nebula-shell/widgets/nebula/separator.lua`
- [ ] `etc/nebula-shell/widgets/nebula/workspaces.lua`

## P4: YAML Parser + Config

- [ ] `etc/nebula-shell/widgets/yaml.lua` - Minimal YAML parser
- [ ] `etc/nebula-shell/config.yaml` - Update namespace
- [ ] `etc/nebula-shell/events.lua` - Update require paths

## P5: CLI

- [ ] `src/nebula_shell.vala` - Entry point
- [ ] `src/cli/main.vala` - Arg parser + dispatch
- [ ] `src/cli/commands.vala` - Help/version
- [ ] `src/cli/runner.vala` - Application runner
- [ ] `src/cli/inspector.vala` - D-Bus inspector

## P6: Build System

- [ ] `meson.build` - Fix build config
- [ ] `makefile` - Fix targets

## P7: Documentation

- [ ] `README.md` - Full project docs
- [ ] `data/nebula-shell.1` - Man page updates

---

## Post-Build

- [ ] QA Testing (sub-agents)
- [ ] Optimization (sub-agents)
- [ ] Docs Writing (sub-agents)
- [ ] `notify-send` completion notification

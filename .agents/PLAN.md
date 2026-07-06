# NebulaShell - Build Plan

## Project: NebulaShell
## Lightweight Wayland Widget Framework (Vala + GTK4 + Lua + YAML)

---

## Current Status: BUILD COMPLETE (all 20 widgets compile and run)

All core files, Lua widgets, CLI tool, and build system are implemented and functional.
The application starts cleanly, builds all widgets, and shuts down gracefully.
Several bugs and polish items remain before a 1.0 release.

---

## Remaining Bugs (High Priority)

| # | Bug | File(s) | Description |
|---|-----|---------|-------------|
| 1 | **Workspace buttons don't click** | `widget_builder.vala`, `workspaces.lua` | `_on_click` stores a Lua closure, but `setup_click_handler` looks for `on_click` (string function name). Need a generic `_on_click` bridge that can dispatch closures or function names. |
| 2 | **CPU meter set_fraction before registration** | `cpu.lua` | `M.create` calls `widget_set_fraction()` before GTK widget is registered (happens after `M.create` returns). Calls fail silently. Move to `M.update` or defer to timer callback. |
| 3 | **Workspaces never refresh** | `workspaces.lua`, `widget_builder.vala` | Workspace has `_timer_enabled` + `_timer_interval` but no `M.update()` function. `timer_tick` skips if `M.update` absent. Add `M.update` that calls `refresh_workspaces`. |

## Remaining Issues (Medium Priority)

| # | Issue | File(s) | Description |
|---|-------|---------|-------------|
| 4 | **Panel toggle not verified** | `config.yaml`, `events.lua`, `bar.lua` | Bar's "toggle_panel_btn" references `on_click: toggle_panel` in events.lua. Need to verify the global function exists and works end-to-end. |
| 5 | **CSS syntax warning** | `styles/style.css:123` | `Expected a number` warning on CSS parse. Minor syntax issue. |
| 6 | **NEBULA_SYSROOT path confusion** | `file_utils.vala` | Must point to repo root, not `etc/nebula-shell/`. `find_config` appends `/etc/nebula-shell/` making the env var unintuitive. |
| 7 | **CLI commands incomplete** | `commands.vala`, `inspector.vala`, `schema_gen.vala` | Only `run` command works. `inspect`, `schema`, `help/version` need verification/testing. |
| 8 | **Binary path mismatch in docs** | `AGENTS.md`, docs | Actual binary at `./build/nebula-shell`, docs reference `./build/src/nebula-shell`. |

## Remaining Tasks (Low Priority)

| # | Task | Description |
|---|------|-------------|
| 9 | **Test on real Hyprland** | All testing done via `timeout 5`. Verify gtk4-layer-shell presentation in actual Wayland session. |
| 10 | **Install documentation** | `README.md`, man page updates, installation docs. |

---

## Implementation Order

```
 1. Fix workspace button click handler   (P0 bug)
 2. Fix CPU meter init timing            (P0 bug)
 3. Add workspace M.update + refresh     (P0 bug)
 4. Verify panel toggle                  (P1)
 5. Fix CSS warning                      (P1)
 6. Fix NEBULA_SYSROOT path confusion    (P1)
 7. Test/verify CLI commands             (P1)
 8. Fix binary path in docs              (P2)
 9. Write/update documentation           (P2)
10. Test on real Hyprland                (P2)
```

---

## Dependencies

- `gtk4` - GTK4 toolkit
- `gtk4-layer-shell-0.1` - Wayland layer shell protocol
- `glib-2.0`, `gobject-2.0`, `gio-2.0` - GLib/GObject/GIO
- `lua5.4` (or 5.3/5.2) - Lua VM

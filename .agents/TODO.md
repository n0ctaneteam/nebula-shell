# NebulaShell - Build TODO

## Status Legend
- [ ] Pending
- [x] Completed
- [~] In Progress

---

## P0: Critical Bugs

- [ ] **1. Fix workspace button click handler** — `_on_click` closure stored but not dispatched by `setup_click_handler`. Add generic closure dispatch in C bridge.
- [ ] **2. Fix CPU meter init timing** — `widget_set_fraction()` called before GTK widget registered. Move to deferred timer or `M.update`.
- [ ] **3. Add workspace M.update** — Workspace has timer but no `M.update()`. Add function that calls `refresh_workspaces(config)`.

## P1: Medium Issues

- [ ] **4. Verify panel toggle end-to-end** — Ensure `toggle_panel` global function in events.lua works with button click handler.
- [ ] **5. Fix CSS syntax warning** — `style.css:123:18-22: Expected a number`.
- [ ] **6. Fix NEBULA_SYSROOT path confusion** — Make env var intuitive (point to `etc/nebula-shell/` or fix path building).
- [ ] **7. Verify/test CLI commands** — `inspect`, `schema`, `help`, `version`.

## P2: Polish

- [ ] **8. Fix binary path in AGENTS.md/docs** — Change `./build/src/nebula-shell` to `./build/nebula-shell`.
- [ ] **9. Update documentation** — Deploy docs-writer sub-agent for README/man page.
- [ ] **10. Test on real Hyprland** — Run without `timeout` in a Wayland session.

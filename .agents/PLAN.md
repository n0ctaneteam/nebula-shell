# NebulaShell - Build Plan

## Project: NebulaShell
## Lightweight Wayland Widget Framework (Vala + GTK4 + Lua + YAML)

---

## Status: PHASE 2 — Container Enhancements + Popup Widget

Phase 1 (stability) is complete. Phase 2 adds proper container properties (exclusive, margin, padding, multi-anchor), YAML unicode support, and a popup widget.

---

## Implementation Order

```
 1. yaml.lua unicode fix                    (no deps)
 2. layer_shell.vala refactor               (anchors as array, layer param)
 3. widget_builder.vala changes             (exclusive, margin, padding, multi-anchor, layer)
 4. Container Lua module updates            (bar, panel, box schema)
 5. popup.lua                               (new widget + backdrop)
 6. style.css                               (popup classes)
 7. config.yaml                             (demo update)
 8. Build + test
 9. CSS styling docs in api.md/examples.md/README.md
10. Sub-agent pipeline: QA → optimizer → quick test → docs-writer
```

---

## Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `etc/nebula-shell/widgets/yaml.lua` | EDIT | Unicode `\u` / `\u{}` escape in parse_value() |
| `src/core/layer_shell.vala` | EDIT | string[] anchors, GtkLayerShell.Layer param, optional margin[] param |
| `src/core/widget_builder.vala` | EDIT | exclusive, margin/padding tables, multi-anchor (string OR array), _layer field, popup size |
| `etc/nebula-shell/widgets/nebula/bar.lua` | EDIT | exclusive:bool schema, anchor: string|array |
| `etc/nebula-shell/widgets/nebula/panel.lua` | EDIT | exclusive:bool schema, anchor: string|array |
| `etc/nebula-shell/widgets/nebula/box.lua` | EDIT | margin/padding passthrough in schema/defaults |
| **NEW** `etc/nebula-shell/widgets/nebula/popup.lua` | CREATE | Popup widget + backdrop window |
| `etc/nebula-shell/styles/style.css` | EDIT | .popup, .popup-overlay, .transparency-* classes |
| `etc/nebula-shell/config.yaml` | EDIT | Update anchor syntax, add popup demo |
| `docs/api.md` | EDIT | Container props, popup, unicode YAML, CSS styling guide |
| `docs/examples.md` | EDIT | Popup example, CSS styles reference |
| `README.md` | EDIT | Popup widget table entry, CSS customization section |

---

## Dependencies

- `gtk4` - GTK4 toolkit
- `gtk4-layer-shell-0.1` - Wayland layer shell protocol
- `glib-2.0`, `gobject-2.0`, `gio-2.0` - GLib/GObject/GIO
- `lua5.4` (or 5.3/5.2) - Lua VM

# NebulaShell - Build TODO (Phase 2)

## Status Legend
- [ ] Pending
- [x] Completed
- [~] In Progress

---

## Phase 2: Container Enhancements + Popup Widget

### Step 1: YAML Unicode Escape Fix
- [ ] **1a** — Edit `yaml.lua` `parse_value()`: add `\u{HEX}` and `\uHEX` → UTF-8 conversion after quote-stripping
- [ ] **1b** — Add Lua 5.2 fallback for `utf8.char()`

### Step 2: layer_shell.vala Refactor
- [ ] **2a** — Change `init_window()` signature: `(Gtk.Window, string[] anchors, bool exclusive, GtkLayerShell.Layer layer, int[]? margin)`
- [ ] **2b** — Iterate `string[] anchors`, set each edge; `center` → skip anchors
- [ ] **2c** — Accept optional `Layer` param, call `set_layer()`
- [ ] **2d** — Accept optional margin array, call `set_margin()` per edge

### Step 3: widget_builder.vala Changes
- [ ] **3a** — Read `exclusive` as separate bool (not from `visible`)
- [ ] **3b** — Read `margin`/`padding` tables, resolve last-wins, apply to widget/window
- [ ] **3c** — Read `anchor` as string OR table → convert to `string[]`
- [ ] **3d** — Read `_layer` field → pass to `init_window()`
- [ ] **3e** — Read `size` field for window sizing (auto / {w,h} / fill)
- [ ] **3f** — Popup backdrop support: create backdrop window when `_has_overlay`

### Step 4: Container Lua Module Updates
- [ ] **4a** — `bar.lua`: add `exclusive` (default true), `anchor` as string|array
- [ ] **4b** — `panel.lua`: add `exclusive` (default false), `anchor` as string|array
- [ ] **4c** — `box.lua`: add `exclusive`, `margin`, `padding` to schema/defaults

### Step 5: popup.lua (NEW)
- [ ] **5a** — Create `popup.lua` with schema (id, style_class, anchor, size, overlay, margin, padding, children)
- [ ] **5b** — `M.create()`: build config with `_type=window, _layer=overlay`, handle overlay backdrop
- [ ] **5c** — `M.destroy()`: cleanup backdrop window

### Step 6: style.css
- [ ] **6a** — Add `.popup` class
- [ ] **6b** — Add `.popup-overlay` class

### Step 7: config.yaml Demo Update
- [ ] **7a** — Update anchor syntax to array format
- [ ] **7b** — Add popup demo entry

### Step 8: Build + Test
- [ ] **8a** — `meson compile -C build`
- [ ] **8b** — Fix any compilation errors
- [ ] **8c** — Run `NEBULA_SYSROOT=$PWD timeout 5 ./build/nebula-shell run`

### Step 9: CSS Styling Docs
- [ ] **9a** — `docs/api.md`: CSS styling reference section
- [ ] **9b** — `docs/examples.md`: CSS examples with style.css snippets
- [ ] **9c** — `README.md`: CSS customization section

### Step 10: Sub-Agent Pipeline
- [ ] **10a** — Deploy QA-tester for code review
- [ ] **10b** — Deploy optimizer for perf review
- [ ] **10c** — Quick build + test
- [ ] **10d** — Deploy docs-writer for final doc pass

---

## Dependencies

- `gtk4` - GTK4 toolkit
- `gtk4-layer-shell-0.1` - Wayland layer shell protocol
- `glib-2.0`, `gobject-2.0`, `gio-2.0` - GLib/GObject/GIO
- `lua5.4` (or 5.3/5.2) - Lua VM

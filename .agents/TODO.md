# NebulaShell — Build TODO

## Status Legend
- [ ] Pending
- [x] Completed
- [~] In Progress

---

## Dialog Rewrite + Popup Fix + Size Fix

### Step 1: dialog.lua — rewrite
- [ ] **1a** — Rewrite schema: remove `children`/`shadow`, add `title`/`content`/`buttons`
- [ ] **1b** — Rewrite `M.create`: build config with no `_children`

### Step 2: registry.vala — add remove()
- [ ] **2a** — Add `Registry.remove(id)`: lookup, destroy widget, remove from map + list

### Step 3: widget_builder.vala — dialog case rewrite
- [ ] **3a** — Rewrite `case "dialog"`: full-screen window → centered dialog-surface → title/content/buttons
- [ ] **3b** — Parse buttons table → create Gtk.Buttons with CSS classes + click wiring (cancel → destroy_dialog)
- [ ] **3c** — Apply size/margin/padding to dialog-surface box, not window
- [ ] **3d** — Skip generic container properties (margin/padding/size/layer) for dialogs
- [ ] **3e** — blockInput via GestureClick on window

### Step 4: widget_builder.vala — popover autohide fix
- [ ] **4a** — Add `Gtk.EventControllerMotion` to popover for hover tracking
- [ ] **4b** — Timer callback checks `!hovered` before `popdown()`
- [ ] **4c** — Hover-enter resets timer

### Step 5: widget_builder.vala — size:auto fix
- [ ] **5a** — Remove `set_default_size(800, h)` fallback when size is null
- [ ] **5b** — For dialogs: already covered by step 3c

### Step 6: application.vala — Lua functions
- [ ] **6a** — Register `show_dialog(id)` → `widget_set_visible(id, true)`
- [ ] **6b** — Register `destroy_dialog(id)` → `widget.destroy()` + `Registry.remove(id)` + remove config

### Step 7: config.yaml — update
- [ ] **7a** — Replace old dialog config with new format (title, content, buttons)

### Step 8: style.css — update
- [ ] **8a** — Replace old dialog CSS with new classes (.dialog-box, .dialog-button, .critical)

### Step 9: Build + test
- [ ] **9a** — `meson compile -C build` and fix errors
- [ ] **9b** — `NEBULA_SYSROOT=$PWD timeout 5 ./build/nebula-shell run` smoke test

### Step 10: Quality loop
- [ ] **10a** — QA review → fix issues
- [ ] **10b** — Optimizer review → fix issues
- [ ] **10c** — Rebuild + retest until clean

### Step 11: Docs update
- [ ] **11a** — Deploy docs-writer agents for api.md, examples.md, README.md

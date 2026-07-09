# NebulaShell — Build Plan

## Project: NebulaShell
## Lightweight Wayland Widget Framework (Vala + GTK4 + Lua + YAML)

---

## Status: Dialog Rewrite + Popup Fix + Size Fix

Current phase rewrites the dialog widget from scratch, fixes popover autohide to respect hover state, and makes `size: auto` mean content-fit sizing.

---

## Changes

### 1. Dialog Rewrite (`dialog.lua` + `widget_builder.vala`)

**New schema** — no `children` field:
```yaml
nebula/dialog:
  id: <string>
  style_class: <string>
  visible: <bool>
  blockInput: <bool>
  size: <auto|{w,h}>
  shadow: <nil>  # removed — window BG is the shadow
  padding: <table>
  margin: <table>
  title: <string>   # bold header label
  content: <string> # body text label
  buttons:          # array of button entries
    - <id>:
        label: <string>
        on_click: <string>  (optional)
        isCritical: <bool>  (optional, default false)
    - cancel:
        label: <string>     # auto isCritical=true, auto on_click=destroy_dialog
```

**New GTK Tree:**
```
Gtk.Window  (OVERLAY layer, full-screen via 4-edge anchors, .dialog, .style_class)
  └── Gtk.Box "dialog-surface" (.dialog-box, halign=CENTER, valign=CENTER)
        ├── Gtk.Label (.dialog-title)   ← bold, large
        ├── Gtk.Label (.dialog-content) ← body, wrap, max-width-chars
        └── Gtk.Box (.dialog-buttons, halign=END, spacing=8)
              ├── Gtk.Button (.dialog-button, .<id>, .critical?)  ← wired from YAML
              ├── Gtk.Button (.dialog-button, .<id>, .critical?)
              └── Gtk.Button (.dialog-button, .cancel, .critical) ← auto-wired to destroy_dialog
```

**blockInput:** `Gtk.GestureClick` with `set_button(0)` on the window claims all pointer events. No `set_modal`.

**Size/margin/padding:** Applied to dialog-surface box, not the window.

**Lua functions:**
- `show_dialog(id)` — calls `widget_set_visible(id, true)`
- `destroy_dialog(id)` — calls `widget.destroy()` + `Registry.remove(id)` + removes config from `_nebula_widget_configs`. Frees all memory. Dialog cannot be re-shown after destruction.

### 2. Popup Autohide Fix (`widget_builder.vala` popover case)

**Current:** Timer always fires after X seconds → `popdown()` regardless of hover.

**Fix:** Add `Gtk.EventControllerMotion`. Track `hovered` bool. Timer callback checks `!hovered` before calling `popdown()`. Re-enter resets the timer.

### 3. `size: auto` as Fit-Content (`widget_builder.vala` container properties)

**Current behavior:**
- Anchored widgets (bar/panel): compositor determines width, height from content or fallback
- Dialog: no size request → hexpand shadow forces large window → broken

**Fix (already covered by dialog rewrite):** For dialog, `size:auto` → no `set_size_request` → GTK computes natural size from content. For anchored widgets: unchanged (already works). For non-anchored widgets with no size: remove the `set_default_size(800, h)` fallback.

---

## Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `etc/nebula-shell/widgets/nebula/dialog.lua` | REWRITE | New schema (title, content, buttons, no children) |
| `src/core/widget_builder.vala` | EDIT | Rewrite dialog case; fix popover autohide; fix size:auto |
| `src/core/registry.vala` | EDIT | Add `remove()` method for full widget destruction |
| `src/core/application.vala` | EDIT | Add show_dialog/destroy_dialog Lua functions |
| `etc/nebula-shell/config.yaml` | EDIT | Update dialog demo to new format |
| `etc/nebula-shell/styles/style.css` | EDIT | Replace old dialog CSS with new classes |
| `.agents/PLAN.md` | UPDATE | This file |
| `.agents/TODO.md` | UPDATE | This file |

---

## Implementation Order

```
 1. dialog.lua — rewrite
 2. registry.vala — add remove() method
 3. widget_builder.vala — dialog case rewrite
 4. widget_builder.vala — popover autohide fix
 5. widget_builder.vala — size:auto fix
 6. application.vala — show_dialog/destroy_dialog
 7. config.yaml — update
 8. style.css — update
 9. Build + test (meson compile, smoke test)
10. QA review → fix issues
11. Docs update via docs-writer agents
```

---

## CSS Accessors

| Selector | Target |
|----------|--------|
| `.dialog-box` | The centered dialog surface box |
| `.dialog-title` | Title label |
| `.dialog-content` | Content body label |
| `.dialog-buttons` | Button row box |
| `.dialog-button` | Any button inside dialog |
| `.dialog-button.critical` | Destructive buttons (cancel etc) |
| `.dialog-button.<id>` | Specific button by id |

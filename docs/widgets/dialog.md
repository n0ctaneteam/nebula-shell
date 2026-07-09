# nebula/dialog

The **dialog** widget is a centered overlay window displayed on top of all other content. Unlike bars and panels, dialogs are not anchored to a screen edge — they float in the center of the display using the Wayland layer-shell `OVERLAY` layer with full-screen four-edge anchors, with a backdrop that captures pointer events outside the dialog surface.

Dialogs are **not** created at startup. They are built on-demand at runtime: `show_dialog(id)` reads the YAML config, loads the Lua module, creates the GTK widget, and shows it. `destroy_dialog(id)` removes it entirely, enabling re-creation on the next `show_dialog` call.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | **Required.** Unique identifier for the dialog. Used for registration and runtime control. |
| `style_class` | `string` | `"dialog"` | CSS class(es) applied to the dialog window. |
| `layer` | `string` | `"overlay"` | Wayland layer-shell layer. `"overlay"` renders above all other surfaces; `"top"` places it in the top layer (beneath other overlays). |
| `visible` | `boolean` | `true` | Initial visibility. Dialogs are **created visible by default**; set to `false` in config so they start hidden. |
| `blockInput` | `boolean` | `true` | When `true`, the backdrop consumes all pointer events outside the dialog surface. See [Input Blocking](#input-blocking). |
| `title` | `string` | `""` | Dialog title text, displayed in a bold header label. |
| `content` | `string` | `""` | Dialog body text, displayed in a wrapping label. Supports `\n` for line breaks. |
| `buttons` | `array` | `[]` | List of button definitions. See [Buttons Format](#buttons-format) below. |
| `size` | `any` | `"auto"` | Controls the dialog surface dimensions. See [Size Modes](#size-modes) below. |
| `margin` | `table` | — | Margin around the dialog surface (spacing between window edge and dialog). Format: `{top: N, bottom: N, left: N, right: N}`. |
| `padding` | `table` | — | Padding *inside* the dialog surface, applied to the inner content wrapper. Same format as `margin`. |

## Buttons Format

The `buttons` property is an array of button entries. Each entry is a table with a **single key**: the button's ID. The value contains `label`, optional `on_click`, and optional `isCritical`.

```yaml
buttons:
  - <button_id>:
      label: "Button Label"
      on_click: "lua[...]"  # optional
      isCritical: false      # optional, default false
  - cancel:
      label: "Cancel"        # auto isCritical=true, auto-wired to destroy_dialog
```

### Behaviour by Button ID

| Button ID | `isCritical` | Default wiring |
|-----------|--------------|----------------|
| `cancel` | `true` (auto) | Auto-wired to call `destroy_dialog(id)` — removes the widget from the registry, destroys the GTK window, and cleans up `_nebula_widget_configs`. |
| Any other | `false` (default) | No auto-wiring. Supply `on_click` to attach behaviour. |

### Field Details

- **`label`** (`string`, default: button ID) — Display text on the button.
- **`on_click`** (`string`, optional) — A command string (`"lua[...]"` or event handler name) executed when the button is clicked. If omitted for a `cancel` button, the default destroy behaviour applies.
- **`isCritical`** (`boolean`, default `false`) — When `true`, adds the `critical` CSS class for destructive-button styling (e.g. red background). `cancel` buttons automatically get `isCritical: true`.

> **Note:** The `cancel` button auto-destroy only activates when no explicit `on_click` is provided. If you supply `on_click` on a `cancel` button, you must handle dialog destruction yourself.

## Size Modes

The `size` property supports two modes:

| Value | Description |
|-------|-------------|
| `"auto"` | Both dimensions determined by content — no size request is set, GTK computes natural size from the title, content, and buttons. |
| `{w: 400, h: 300}` | Explicit dimensions in pixels applied to the dialog surface via `set_size_request()`. Either `w` or `h` can be omitted to use content-determined sizing for that axis. |

## GTK Widget Tree

```
Gtk.Window (OVERLAY layer, full-screen via 4-edge anchors, .style_class)
  └── Gtk.Overlay
       ├── Gtk.Box (backdrop, captures clicks for blockInput)
       └── [overlay] Gtk.Box (.dialog-box, centered, halign=CENTER, valign=CENTER)
            └── Gtk.Box (content_wrap, inner padding via margins)
                 ├── Gtk.Label (.dialog-title, xalign=0.0)
                 ├── Gtk.Label (.dialog-content, wrap, max-width-chars=60, xalign=0.0)
                 └── Gtk.Box (.dialog-buttons, orientation=HORIZONTAL, halign=END)
                      ├── Gtk.Button (.dialog-button, .<button_id>)
                      └── Gtk.Button (.dialog-button, .cancel, .critical)
```

## CSS Classes

| Class | Applied to | Purpose |
|-------|-----------|---------|
| `.dialog-box` | Dialog surface `Gtk.Box` | Centered dialog surface — background, border, border-radius, min-width. |
| `.dialog-title` | Title `Gtk.Label` | Bold large header text. |
| `.dialog-content` | Content `Gtk.Label` | Body text — wraps, max-width 60 chars. |
| `.dialog-buttons` | Button row `Gtk.Box` | End-aligned horizontal button row with spacing. |
| `.dialog-button` | Every `Gtk.Button` | Base button styling. |
| `.dialog-button.critical` | Cancel / destructive buttons | Red/danger styling. |
| `.dialog-button.\<id\>` | Each button individually | Per-button custom styling by ID. |

Refer to `etc/nebula-shell/styles/style.css` for the default dialog theme.

## Usage Example

```yaml
nebula/dialog:
  id: demo_dialog
  style_class: "dialog"
  layer: overlay
  blockInput: true
  visible: false
  size:
    w: 420
    h: 220
  padding: { top: 24, bottom: 24, left: 32, right: 32 }
  title: "About NebulaShell"
  content: "NebulaShell v0.1.0\n\nA lightweight Wayland widget framework\nfor Hyprland and wlroots compositors.\n\nBuilt with Vala + GTK4 + Lua."
  buttons:
    - confirm:
        label: "OK"
        on_click: "lua[destroy_dialog('demo_dialog')]"
    - cancel:
        label: "Cancel"
```

### Triggering the Dialog from Other Widgets

```yaml
nebula/button:
  id: show_dialog_btn
  label: "\u2139"
  style_class: "dialog-launch-btn"
  on_click: "lua[toggle_dialog('demo_dialog')]"
```

## Lua API

### `M.create(props, event_handlers)`

Creates a new dialog widget configuration.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions from `events.lua` (unused by dialog).
- **`Returns`** (`table`) — The merged configuration table with internal metadata.

The function sets:

- `config._type = "dialog"` — signals the builder to construct a full-screen overlay dialog window
- `config._layer = config.layer or "overlay"` — reads the `layer` property from YAML and maps it to the internal `_layer` field

> The `layer` property is optional. Omitting it defaults to `"overlay"`, rendering the dialog above all other layer-shell surfaces. Use `layer: top` to place it in the top layer (beneath other overlays).

### `M.destroy(config)`

Logs a destruction message. The core engine handles actual GTK cleanup.

### `M.merge_defaults(props)`

Merges provided properties with `M.defaults`. Explicit `props` values always win.

## Internal Fields

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"dialog"`. Tells the builder to construct a full-screen overlay dialog. |
| `_layer` | `string` | Set from YAML `layer` property (`config.layer or "overlay"`). Controls which layer-shell layer the dialog renders on. |

## Runtime API (Lua Functions)

### `show_dialog(id)`

Builds and shows a dialog widget from YAML config. The dialog is created on-demand — it does **not** need to exist at startup.

```lua
show_dialog("demo_dialog")
```

- Reads `_nebula_config["nebula/dialog"]` (the YAML config tree).
- Loads the Lua module and calls `M.create(props)`.
- Stores the config in `_nebula_widget_configs`.
- Builds the GTK widget and registers it in the Registry.
- Calls `widget.set_visible(true)`.

### `destroy_dialog(id)`

Fully destroys a dialog, freeing all GTK resources. The dialog can be re-created later by calling `show_dialog(id)` again.

```lua
destroy_dialog("demo_dialog")
```

The function performs three cleanup steps:

1. **`Registry.remove(id)`** — removes the widget from the internal lookup map and widget list, then calls `widget.destroy()` on the `Gtk.Window` (which cascades to all child widgets).
2. **`_nebula_widget_configs[id] = nil`** — removes the config entry from the global Lua table so the framework no longer knows about it.
3. **Lua stack cleanup** — pops the modified table.

> **Note:** The auto-wired cancel button performs the same three steps internally. If you supply a custom `on_click` that calls `destroy_dialog`, the behaviour is identical.

### `toggle_dialog(id)`

Toggles a dialog between shown and destroyed states. If the dialog exists in the registry, it is destroyed. If not, it is built from config and shown.

```lua
toggle_dialog("demo_dialog")
```

- If the widget ID exists in the Registry: calls `destroy_dialog(id)` (removes widget, cleans config).
- If the widget ID does **not** exist: calls `show_dialog(id)` (builds from config, shows it).

> This is the recommended function for dialog-launch buttons, as it handles both opening and closing from a single call.

## Behaviour

- **Layer-shell overlay window**: The dialog uses the Wayland layer-shell protocol on the `OVERLAY` layer with **all four edges anchored** (top, bottom, left, right) and **zero margins** on the window. This makes the window fill the entire screen while the dialog surface floats centered inside it. The dialog is a full `Gtk.Window` with decorations disabled.

- **No close button**: Unlike a traditional window, there is no built-in close/× button. The cancel button (or any button with an appropriate `on_click`) handles dialog dismissal.

- **Input blocking**: When `blockInput: true` (default), a `Gtk.GestureClick` controller with `set_button(0)` is attached to the backdrop `Gtk.Box`. This captures **all** pointer button events (left, right, middle, etc.) outside the dialog surface and claims them via `Gtk.EventSequenceState.CLAIMED`, preventing them from reaching underlying widgets. The dialog does **not** use `set_modal()`.

- **Button wiring**: Each button receives its button ID as a CSS class (e.g. `.confirm`, `.cancel`). Buttons with `isCritical: true` (or auto-detected `cancel`) also receive the `.critical` CSS class. The cancel button without an explicit `on_click` is auto-wired to call `destroy_dialog` on click.

- **Size application**: `size` is applied as `set_size_request()` on the **dialog surface** (`Gtk.Box`), not on the window. When `size` is `"auto"`, no size request is set and GTK computes the natural size from content.

- **Margin vs Padding**:
  - `margin` → applied as margins on the **dialog surface** (`Gtk.Box`), creating space between the window edge and the dialog box.
  - `padding` → applied as margins on the **inner content wrapper** (`Gtk.Box`), creating space between the dialog surface border and the title/content/buttons.

- **CSS styling**: The `style_class` is applied to the dialog window. The dialog surface uses the `.dialog-box` CSS class. Title, content, and buttons each have their own dedicated CSS classes for fine-grained styling.

- **Dialog lifecycle**: Dialogs are created on-demand — call `show_dialog(id)` to build and show, `destroy_dialog(id)` to remove. `toggle_dialog(id)` toggles between the two. Destroyed dialogs can be re-created on the next `show_dialog` call. Previously used `widget_set_visible` patterns should be replaced with `show_dialog` / `destroy_dialog` / `toggle_dialog`.

## Schema (for reference)

```lua
M.schema = {
    id         = { type = "string",  required = true },
    style_class = { type = "string",  default = "dialog" },
    layer      = { type = "string",  default = "overlay" },
    visible    = { type = "boolean", default = true },
    blockInput = { type = "boolean", default = true },
    size       = { type = "any",     default = "auto" },
    margin     = { type = "table" },
    padding    = { type = "table" },
    title      = { type = "string",  default = "" },
    content    = { type = "string",  default = "" },
    buttons    = { type = "table",   default = {} }
}
```

## Migration from the Old Dialog API

| Old Field | New Replacement |
|-----------|----------------|
| `children` (array of widgets) | Removed. Use `title` + `content` + `buttons` instead. |
| `shadow` (color + intensity) | Removed. The backdrop is now a plain `Gtk.Box` styled via CSS. |
| Built-in × close button | Removed. Use a cancel button instead. |
| `widget_set_visible(id, false)` | Replace with `destroy_dialog(id)`. |
| `widget_set_visible(id, true)` | Replace with `show_dialog(id)`. |
| `set_default_size` on window | Replaced by `set_size_request` on dialog surface via `size` property. |
| `set_modal()` | Replaced by `Gtk.GestureClick` on the backdrop (`blockInput`). |

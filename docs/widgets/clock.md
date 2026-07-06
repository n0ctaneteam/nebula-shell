# nebula/clock

The **clock** widget displays the current time and automatically updates at a configurable interval. It renders as a `Gtk.Label` under the hood, supporting `strftime`-style format strings. The clock also supports click-to-toggle between 24-hour and 12-hour formats, and can trigger a custom event handler on click.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | Unique identifier for the clock. Used for registration and label updates. |
| `style_class` | `string` | `"clock"` | CSS class(es) applied to the clock label. |
| `format` | `string` | `"%H:%M:%S"` | `strftime`-compatible format string for the time display. |
| `interval` | `number` | `1` | Update interval in seconds. The clock refreshes the displayed time at this rate. |
| `on_click` | `string` | — | Name of a global event handler function from `events.lua` to call on click. When set, the clock also toggles between 24h and 12h format before calling the handler. |

## Usage Example

```yaml
# Simple 24-hour clock updating every second
nebula/clock:
  id: system_clock
  style_class: "clock"
  format: "%H:%M:%S"
  interval: 1

# 12-hour clock with click toggle and custom handler
nebula/clock:
  id: main_clock
  style_class: "clock"
  format: "%I:%M %p"
  interval: 30
  on_click: "toggle_clock_format"
```

### Supported strftime Formats

| Format | Example Output | Description |
|--------|----------------|-------------|
| `%H:%M:%S` | `14:05:23` | 24-hour with seconds (default) |
| `%I:%M %p` | `02:05 PM` | 12-hour with AM/PM |
| `%H:%M` | `14:05` | 24-hour, no seconds |
| `%A, %B %d` | `Monday, January 06` | Full date |
| `%Y-%m-%d` | `2026-01-06` | ISO date |
| `%c` | `Mon Jan 06 14:05:23 2026` | Locale's default date+time |

## Lua API

### `M.create(props, event_handlers)`
Creates a new clock widget.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions from `events.lua`.
- **Returns** (`table`) — The merged configuration table with internal metadata (`_type = "label"`, timer fields).

When `on_click` is provided and the handler exists, the clock wraps the handler to call `M.toggle_format(config)` first, so clicking always toggles the display format before running the custom logic.

### `M.update(config)`
Refreshes the clock display with the current time.

- **`config`** (`table`) — The clock's configuration table.

Reads the current time via `os.date(config._format)`, updates `config._text`, and pushes the new label to the GTK widget via `widget_set_label()`. This function is called automatically by the core engine's timer system at the configured `interval`.

### `M.toggle_format(config)`
Toggles between 24-hour and 12-hour format.

- **`config`** (`table`) — The clock's configuration table.

If the current format is `"%H:%M:%S"` (24-hour), switches to `"%I:%M %p"` (12-hour). Otherwise, switches back to `"%H:%M:%S"`. This is called automatically before the click handler when `on_click` is configured.

### `M.destroy(config)`
Disables the update timer and logs destruction.

- **`config`** (`table`) — The configuration table.

Sets `config._timer_enabled = false` to signal the core engine to stop the timer.

### `M.merge_defaults(props)`
Merges provided properties with `M.defaults`. Explicit `props` values always win.

- **`props`** (`table`) — User-provided properties.
- **Returns** (`table`) — Merged configuration.

## Internal Fields

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"label"`. Tells the builder to create a `Gtk.Label`. |
| `_timer_enabled` | `boolean` | Set to `true`. Enables periodic timer updates. |
| `_timer_interval` | `number` | Copied from `interval`. Controls the update frequency in seconds. |
| `_format` | `string` | The active format string (may change on toggle). |
| `_text` | `string` | The current formatted time string. Used as the label text. |
| `_on_click` | `function` | Optional click handler wrapping `M.toggle_format` + the user's handler (present when `on_click` is set). |

## Behavior

- **Auto-updating**: A GLib timeout timer fires at the configured `interval`. Each tick calls `M.update()`, which reads `os.date()` and updates the label. The timer continues until the widget is destroyed.
- **Format toggle on click**: If `on_click` is set, the clock toggles between 24h (`%H:%M:%S`) and 12h (`%I:%M %p`) before calling the user's event handler. This allows the event handler to respond to the new format if needed.
- **Manual updates**: You can call `M.update(config)` from Lua at any time to force a refresh.
- **CSS styling**: The clock is a `Gtk.Label` with the configured `style_class`. Style it as you would any text label — font family, size, weight, color, padding, etc.

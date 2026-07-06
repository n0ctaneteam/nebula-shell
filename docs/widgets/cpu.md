# nebula/cpu

The **CPU** widget displays a real-time CPU usage meter. It renders as a `Gtk.ProgressBar` with percentage text. The widget reads `/proc/stat` to calculate CPU utilization between sampling intervals and dynamically applies CSS classes (`warning`, `critical`) based on configurable thresholds.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | Unique identifier for the CPU meter. Used for registration and progress bar updates. |
| `style_class` | `string` | `"cpu-bar"` | CSS class(es) applied to the progress bar. |
| `update_interval` | `number` | `2` | Sampling interval in seconds. CPU usage is calculated between consecutive reads. |
| `warning_threshold` | `number` | `70` | Usage percentage at which the `"warning"` CSS class is added. |
| `critical_threshold` | `number` | `90` | Usage percentage at which the `"critical"` CSS class is added (overrides warning). |

## Usage Example

```yaml
nebula/cpu:
  id: cpu_meter
  style_class: "cpu-bar"
  update_interval: 2
  warning_threshold: 70
  critical_threshold: 90

# More sensitive thresholds
nebula/cpu:
  id: cpu_meter_sensitive
  update_interval: 1
  warning_threshold: 50
  critical_threshold: 80
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new CPU meter widget.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions (not used by CPU).
- **`Returns`** (`table`) — The merged configuration table with internal metadata (`_type = "progress_bar"`, timer and state fields).

The initial CPU reading is taken immediately during creation so the widget shows data on first render instead of waiting for the first timer tick.

### `M.read_cpu(config)`
Reads and parses `/proc/stat` to calculate CPU usage percentage.

- **`config`** (`table`) — The CPU meter's configuration table. Updated in-place with new `_value` and `_text`.

**Calculation logic:**

1. Opens `/proc/stat` and reads the first line (the `cpu` line with aggregate values).
2. Parses the 8 numeric fields: `user`, `nice`, `system`, `idle`, `iowait`, `irq`, `softirq`, `steal`.
3. Computes `total` (sum of all fields) and `idle_all` (`idle + iowait`).
4. On the second and subsequent reads, calculates delta values:
   ```
   usage = (delta_total - delta_idle) / delta_total * 100
   ```
5. Updates the progress bar fraction and text via `widget_set_fraction()` and `widget_set_text()`.
6. Applies CSS classes based on thresholds:
   - `usage >= critical_threshold` → adds `"critical"`, removes `"warning"`
   - `usage >= warning_threshold` → adds `"warning"`, removes `"critical"`
   - otherwise → removes both `"warning"` and `"critical"`

### `M.destroy(config)`
Disables the update timer and logs destruction.

- **`config`** (`table`) — The configuration table.

Sets `config._timer_enabled = false` to stop the timer.

### `M.merge_defaults(props)`
Merges provided properties with `M.defaults`.

- **`props`** (`table`) — User-provided properties.
- **`Returns`** (`table`) — Merged configuration.

## Internal Fields

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"progress_bar"`. Tells the builder to create a `Gtk.ProgressBar`. |
| `_timer_enabled` | `boolean` | Set to `true`. Enables periodic sampling. |
| `_timer_interval` | `number` | Copied from `update_interval`. Controls the sampling rate. |
| `_value` | `number` | Current CPU usage as a fraction (0.0 to 1.0). |
| `_text` | `string` | Current CPU usage as a formatted percentage string (e.g. `"45%"`). |
| `_prev_idle` | `number` | Previous sample's idle + iowait value. |
| `_prev_total` | `number` | Previous sample's total CPU time. |

## Behavior

- **Real-time sampling**: The widget reads `/proc/stat` on a timer at `update_interval` seconds. CPU usage is calculated as the difference between two consecutive reads, providing a delta (instantaneous) measurement rather than a system-boot average.
- **Threshold-based CSS classes**: The widget dynamically adds and removes `"warning"` and `"critical"` CSS classes. Use these in your CSS to change colors:
  ```css
  .cpu-bar { background: #2d2d2d; }
  .cpu-bar.warning progress { background: #ff9800; }
  .cpu-bar.critical progress { background: #f44336; }
  ```
- **Graceful degradation**: If `/proc/stat` is unreadable or malformed, the widget shows `"N/A"` text and sets the bar to 0%.
- **Timer cleanup**: Setting `config._timer_enabled = false` (via `M.destroy()`) stops the core engine's GLib timeout.
- **Initial read**: `M.read_cpu()` is called once during `M.create()` so the first display is immediate — no blank bar on startup.

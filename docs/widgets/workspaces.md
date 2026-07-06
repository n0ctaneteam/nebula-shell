# nebula/workspaces

The **workspaces** widget displays a dynamic row of workspace indicators for the [Hyprland](https://hyprland.org/) window manager. It queries Hyprland's IPC (via `hyprctl`) to discover available workspaces and highlight the currently active one. Each workspace is rendered as a clickable button — clicking it dispatches a workspace switch command to Hyprland.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `string` | — | Unique identifier for the workspaces widget. Used for registration. |
| `style_class` | `string` | `"workspaces"` | CSS class(es) applied to the outer container. |
| `update_interval` | `number` | `0.5` | Polling interval in seconds. The widget re-queries Hyprland for workspace state at this rate. |

## Usage Example

```yaml
nebula/workspaces:
  id: workspaces
  style_class: "workspaces"
  update_interval: 0.5

# Inside a bar:
nebula/bar:
  id: main_bar
  style_class: "bar"
  anchor: top
  children:
    - nebula/workspaces:
        id: workspace_indicators
        style_class: "workspaces"
        update_interval: 1.0

    - nebula/box:
        id: right_section
        orientation: horizontal
        spacing: 8
        children:
          - nebula/clock:
              id: clock
```

## Lua API

### `M.create(props, event_handlers)`
Creates a new workspaces widget.

- **`props`** (`table`) — Property table matching the schema above.
- **`event_handlers`** (`table`) — Global event handler functions (not used directly by this widget).
- **`Returns`** (`table`) — The merged configuration table with internal metadata (`_type = "box"`, timer fields).

The widget immediately calls `M.refresh_workspaces(config)` during creation so the workspace buttons appear on first render.

### `M.refresh_workspaces(config)`
Queries Hyprland's current workspace state and rebuilds the child button configurations.

- **`config`** (`table`) — The workspaces widget's configuration table.

This function:
1. Calls `M.get_workspaces()` to retrieve all available workspaces.
2. Calls `M.get_active_workspace()` to determine the currently active workspace.
3. Rebuilds `config._children` as an array of button configurations, one per workspace.
4. The active workspace button receives the CSS class `"workspace-btn active"`.
5. Each button's `_on_click` handler calls `M.switch_to_workspace(ws.id)`.

### `M.get_workspaces()`
Retrieves the list of available workspaces from Hyprland.

- **Returns** (`table`) — Array of workspace objects `{ id = number, name = string? }`.

Uses `hyprctl workspaces -j` and parses the JSON output. If `hyprctl` is unavailable, JSON parsing fails, or no workspaces are reported, it falls back to returning workspaces 1 through 5 as a reasonable default for most setups.

### `M.get_active_workspace()`
Retrieves the currently active workspace ID from Hyprland.

- **Returns** (`number`) — The active workspace ID. Defaults to `1` on error.

Uses `hyprctl activeworkspace -j` and parses the JSON output. Returns `1` if the command fails or the output is unparseable.

### `M.switch_to_workspace(id)`
Dispatches a workspace switch to Hyprland.

- **`id`** (`number`) — The target workspace ID.

Executes `hyprctl dispatch workspace <id>`. This switches the Hyprland compositor to the specified workspace.

### `M.destroy(config)`
Disables the update timer and logs destruction.

- **`config`** (`table`) — The configuration table.

Sets `config._timer_enabled = false` to stop the polling timer.

### `M.merge_defaults(props)`
Merges provided properties with `M.defaults`.

- **`props`** (`table`) — User-provided properties.
- **`Returns`** (`table`) — Merged configuration.

## Internal Fields

| Field | Type | Description |
|-------|------|-------------|
| `_type` | `string` | Set to `"box"`. Tells the builder to create a `Gtk.Box` as the container. |
| `_timer_enabled` | `boolean` | Set to `true`. Enables periodic workspace polling. |
| `_timer_interval` | `number` | Copied from `update_interval`. Controls polling frequency. |
| `_children` | `array` | Rebuilt on every poll cycle. Contains button configs for each workspace. |
| `_workspace_buttons` | `table` | Reserved for future use (potential optimization for incremental updates). |
| `_active_workspace` | `number` | The currently active workspace ID. Updated every poll cycle. |
| `_orientation` | `string` | Hardcoded to `"horizontal"`. Workspace buttons are always arranged in a row. |
| `_spacing` | `number` | Hardcoded to `2` pixels between workspace buttons. |

## Behavior

- **Hyprland dependency**: This widget is designed exclusively for Hyprland. It relies on `hyprctl` being installed and available on `PATH`. If `hyprctl` is missing, the widget falls back to showing workspaces 1–5 with no active highlighting.
- **Polling model**: The widget polls `hyprctl` every `update_interval` seconds. Lower values (e.g., `0.3`) feel more responsive but increase IPC overhead. The default of `0.5` balances responsiveness and performance.
- **Dynamic workspace discovery**: Workspaces are discovered dynamically. If you create or destroy workspaces in Hyprland, the widget reflects the change on the next poll cycle.
- **Button rebuilding**: On each poll cycle, the entire `_children` array is rebuilt. This is simple and correct but means any externally added child widgets would be overwritten. Avoid adding children to this widget via YAML — the `children` property is managed internally.
- **Active workspace highlighting**: The active workspace button gets the combined CSS class `"workspace-btn active"`. Style it distinctly:
  ```css
  .workspace-btn {
      background: rgba(255, 255, 255, 0.1);
      border-radius: 4px;
      padding: 2px 8px;
      min-width: 24px;
  }
  .workspace-btn.active {
      background: rgba(255, 255, 255, 0.3);
      font-weight: bold;
  }
  ```
- **Click to switch**: Clicking a workspace button calls `hyprctl dispatch workspace <id>`, switching the compositor to that workspace.

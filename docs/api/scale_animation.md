# ScaleAnimation

An animation that scales a widget from one size to another. `ScaleAnimation` is a concrete subclass of `Animation` and supports both uniform scaling (via `from_scale` / `to_scale`) and per-axis scaling (via `from_x` / `from_y` / `to_x` / `to_y`).

When uniform scale properties are set, they are internally mapped to the per-axis properties.

---

## Class Hierarchy

```
Animation
  └── ScaleAnimation
```

Python alias: `nebula_shell.animation.scale.ScaleAnimation`

---

## Constructor

### `ScaleAnimation(widget=None, from_scale=0.0, to_scale=1.0, from_x=None, from_y=None, to_x=None, to_y=None, name="scale")`

| Parameter    | Type    | Default   | Description                                                |
|--------------|---------|-----------|------------------------------------------------------------|
| `widget`     | `Widget`| `None`    | The target widget to scale.                                |
| `from_scale` | `float` | `0.0`     | Uniform starting scale factor. Mapped to both `from_x` and `from_y` when per-axis values are not set. |
| `to_scale`   | `float` | `1.0`     | Uniform ending scale factor. Mapped to both `to_x` and `to_y` when per-axis values are not set.     |
| `from_x`     | `float` | `None`    | Starting scale factor on the X axis. Overrides `from_scale` for X when set. |
| `from_y`     | `float` | `None`    | Starting scale factor on the Y axis. Overrides `from_scale` for Y when set. |
| `to_x`       | `float` | `None`    | Ending scale factor on the X axis. Overrides `to_scale` for X when set.     |
| `to_y`       | `float` | `None`    | Ending scale factor on the Y axis. Overrides `to_scale` for Y when set.     |
| `name`       | `str`   | `"scale"` | A human-readable identifier for the animation instance.    |

---

## Properties

### Inherited from `Animation`

| Property     | Type    | Default    | Access | Description                                      |
|--------------|---------|------------|--------|--------------------------------------------------|
| `name`       | `str`   | `"scale"`  | rw     | Human-readable identifier for this animation.    |
| `duration`   | `float` | `300.0`    | rw     | Animation duration in milliseconds.              |
| `is_running` | `bool`  | `False`    | ro     | Whether the animation is currently in progress.  |

### Own properties

| Property    | Type    | Default | Access | Description                                                   |
|-------------|---------|---------|--------|---------------------------------------------------------------|
| `from_x`    | `float` | `0.0`   | ro     | Starting scale factor on the X axis.                          |
| `from_y`    | `float` | `0.0`   | ro     | Starting scale factor on the Y axis.                          |
| `to_x`      | `float` | `1.0`   | ro     | Ending scale factor on the X axis.                            |
| `to_y`      | `float` | `1.0`   | ro     | Ending scale factor on the Y axis.                            |
| `from_scale`| `float` | `0.0`   | rw     | Uniform starting scale factor. Setting this updates both `from_x` and `from_y`. |
| `to_scale`  | `float` | `1.0`   | rw     | Uniform ending scale factor. Setting this updates both `to_x` and `to_y`.       |

> **Note:** `from_x`, `from_y`, `to_x`, and `to_y` are read-only. To modify them, use the uniform `from_scale` and `to_scale` accessors or create a new animation with the desired per-axis values.

---

## Methods

`ScaleAnimation` inherits all methods from `Animation`:

| Method       | Parameters                                   | Returns | Description                                                      |
|--------------|----------------------------------------------|---------|------------------------------------------------------------------|
| `start()`    | —                                            | `None`  | Begins the animation. Emits `started`. No-op if already running. |
| `stop()`     | —                                            | `None`  | Stops the animation immediately. Emits `completed`.              |
| `cancel()`   | —                                            | `None`  | Cancels the animation without completing.                        |
| `complete()` | —                                            | `None`  | Marks the animation as finished. Emits `completed`.              |
| `connect()`  | `signal: str, callback: callable`            | `int`   | Connects a callback to a named signal. Returns a handler ID.     |

---

## Signals

`ScaleAnimation` inherits all signals from `Animation`:

| Signal      | Parameters | Description                                               |
|-------------|------------|-----------------------------------------------------------|
| `started`   | —          | Emitted when the animation begins via `start()`.          |
| `completed` | —          | Emitted when the animation finishes via `stop()` or `complete()`. |

---

## Python Example

```python
from nebula_shell.ui.widget import Widget
from nebula_shell.animation.scale import ScaleAnimation

widget = Widget(name="my-widget")

# Uniform scale: pop in from invisible to full size
pop_in = ScaleAnimation(
    widget=widget,
    from_scale=0.0,
    to_scale=1.0,
    name="pop-in"
)
pop_in.duration = 250.0
pop_in.start()

# Per-axis scale: stretch horizontally only
stretch = ScaleAnimation(
    widget=widget,
    from_x=0.5,
    from_y=1.0,
    to_x=1.5,
    to_y=1.0,
    name="stretch"
)
stretch.duration = 400.0
stretch.start()

# Update uniform scale at runtime
stretch.from_scale = 0.8
stretch.to_scale = 1.2
```

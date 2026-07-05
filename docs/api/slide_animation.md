# SlideAnimation

An animation that slides a widget from one position to another. `SlideAnimation` is a concrete subclass of `Animation` and supports both explicit coordinate-based movement and direction-based movement via the `SlideDirection` enum.

When a direction is provided, `from_x` and `from_y` are automatically computed relative to the widget's current position, and `to_x` / `to_y` default to `(0, 0)` (the widget's resting position).

---

## Class Hierarchy

```
Animation
  └── SlideAnimation
```

Python alias: `nebula_shell.animation.slide.SlideAnimation`

---

## Enums

### `SlideDirection`

| Value   | Integer | Description                                          |
|---------|---------|------------------------------------------------------|
| `LEFT`  | `0`     | Slides in from the left. `from_x` set to `-100`.     |
| `RIGHT` | `1`     | Slides in from the right. `from_x` set to `100`.     |
| `UP`    | `2`     | Slides in from the top. `from_y` set to `-100`.      |
| `DOWN`  | `3`     | Slides in from the bottom. `from_y` set to `100`.    |

When a `SlideDirection` is specified:

- `from_x` / `from_y` are automatically computed based on the direction.
- `to_x` and `to_y` are set to `0` (the widget's origin).

---

## Constructor

### `SlideAnimation(widget=None, from_x=0.0, from_y=0.0, to_x=0.0, to_y=0.0, direction=None, name="slide")`

| Parameter   | Type             | Default       | Description                                               |
|-------------|------------------|---------------|-----------------------------------------------------------|
| `widget`    | `Widget`         | `None`        | The target widget to animate.                             |
| `from_x`    | `float`          | `0.0`         | Starting X offset. Auto-computed when `direction` is set. |
| `from_y`    | `float`          | `0.0`         | Starting Y offset. Auto-computed when `direction` is set. |
| `to_x`      | `float`          | `0.0`         | Ending X offset.                                          |
| `to_y`      | `float`          | `0.0`         | Ending Y offset.                                          |
| `direction` | `SlideDirection` | `None`        | Direction preset. Overrides `from_x` and `from_y` if set. |
| `name`      | `str`            | `"slide"`     | A human-readable identifier for the animation instance.   |

---

## Properties

### Inherited from `Animation`

| Property     | Type    | Default   | Access | Description                                      |
|--------------|---------|-----------|--------|--------------------------------------------------|
| `name`       | `str`   | `"slide"` | rw     | Human-readable identifier for this animation.    |
| `duration`   | `float` | `300.0`   | rw     | Animation duration in milliseconds.              |
| `is_running` | `bool`  | `False`   | ro     | Whether the animation is currently in progress.  |

### Own properties

All position properties are read-only. Use the constructor or `set_offset()` to configure them.

| Property    | Type             | Default | Access | Description                                              |
|-------------|------------------|---------|--------|----------------------------------------------------------|
| `direction` | `SlideDirection` | `None`  | ro     | The direction preset, if one was provided.               |
| `from_x`    | `float`          | `0.0`   | ro     | Starting X offset in pixels.                             |
| `from_y`    | `float`          | `0.0`   | ro     | Starting Y offset in pixels.                             |
| `to_x`      | `float`          | `0.0`   | ro     | Ending X offset in pixels.                               |
| `to_y`      | `float`          | `0.0`   | ro     | Ending Y offset in pixels.                               |

---

## Methods

### Inherited from `Animation`

| Method       | Parameters                                   | Returns | Description                                                      |
|--------------|----------------------------------------------|---------|------------------------------------------------------------------|
| `start()`    | —                                            | `None`  | Begins the animation. Emits `started`. No-op if already running. |
| `stop()`     | —                                            | `None`  | Stops the animation immediately. Emits `completed`.              |
| `cancel()`   | —                                            | `None`  | Cancels the animation without completing.                        |
| `complete()` | —                                            | `None`  | Marks the animation as finished. Emits `completed`.              |
| `connect()`  | `signal: str, callback: callable`            | `int`   | Connects a callback to a named signal. Returns a handler ID.     |

### Own methods

| Method        | Parameters       | Returns | Description                                              |
|---------------|------------------|---------|----------------------------------------------------------|
| `set_offset()`| `offset: float`  | `None`  | Updates both `to_x` and `to_y` to the same offset value. Useful for repositioning at runtime. |

---

## Signals

`SlideAnimation` inherits all signals from `Animation`:

| Signal      | Parameters | Description                                               |
|-------------|------------|-----------------------------------------------------------|
| `started`   | —          | Emitted when the animation begins via `start()`.          |
| `completed` | —          | Emitted when the animation finishes via `stop()` or `complete()`. |

---

## Python Example

```python
from nebula_shell.ui.widget import Widget
from nebula_shell.animation.slide import SlideAnimation, SlideDirection

widget = Widget(name="panel")

# Slide in from the left using the direction preset
slide_in = SlideAnimation(
    widget=widget,
    direction=SlideDirection.LEFT,
    name="slide-in"
)
# from_x auto-computed to -100, from_y to 0, to_x to 0, to_y to 0
slide_in.duration = 400.0
slide_in.start()

# Slide out to the right with explicit coordinates
slide_out = SlideAnimation(
    widget=widget,
    from_x=0.0,
    from_y=0.0,
    to_x=200.0,
    to_y=0.0,
    name="slide-out"
)
slide_out.duration = 300.0
slide_out.start()

# Use set_offset to adjust the target position at runtime
slide_out.set_offset(150.0)
```

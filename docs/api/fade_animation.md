# FadeAnimation

An animation that smoothly transitions the opacity of a widget between two values. `FadeAnimation` is a concrete subclass of `Animation` and operates on a target widget's opacity property.

---

## Class Hierarchy

```
Animation
  └── FadeAnimation
```

Python alias: `nebula_shell.animation.fade.FadeAnimation`

---

## Constructor

### `FadeAnimation(widget=None, from_value=0.0, to_value=1.0, name="fade")`

| Parameter    | Type    | Default   | Description                                                  |
|--------------|---------|-----------|--------------------------------------------------------------|
| `widget`     | `Widget`| `None`    | The target widget whose opacity will be animated.            |
| `from_value` | `float` | `0.0`     | Starting opacity value (typically in the range `[0.0, 1.0]`). |
| `to_value`   | `float` | `1.0`     | Ending opacity value (typically in the range `[0.0, 1.0]`).   |
| `name`       | `str`   | `"fade"`  | A human-readable identifier for the animation instance.      |

---

## Properties

### Inherited from `Animation`

| Property     | Type    | Default   | Access | Description                                      |
|--------------|---------|-----------|--------|--------------------------------------------------|
| `name`       | `str`   | `"fade"`  | rw     | Human-readable identifier for this animation.    |
| `duration`   | `float` | `300.0`   | rw     | Animation duration in milliseconds.              |
| `is_running` | `bool`  | `False`   | ro     | Whether the animation is currently in progress.  |

### Own properties

| Property     | Type    | Default | Access | Description                                            |
|--------------|---------|---------|--------|--------------------------------------------------------|
| `from_value` | `float` | `0.0`   | rw     | Starting opacity value for the animation.              |
| `to_value`   | `float` | `1.0`   | rw     | Ending opacity value for the animation.                |

---

## Methods

`FadeAnimation` inherits all methods from `Animation`:

| Method       | Parameters                                   | Returns | Description                                                      |
|--------------|----------------------------------------------|---------|------------------------------------------------------------------|
| `start()`    | —                                            | `None`  | Begins the animation. Emits `started`. No-op if already running. |
| `stop()`     | —                                            | `None`  | Stops the animation immediately. Emits `completed`.              |
| `cancel()`   | —                                            | `None`  | Cancels the animation without completing. Does **not** emit `completed`. |
| `complete()` | —                                            | `None`  | Marks the animation as finished. Emits `completed`.              |
| `connect()`  | `signal: str, callback: callable`            | `int`   | Connects a callback to a named signal. Returns a handler ID.     |

---

## Signals

`FadeAnimation` inherits all signals from `Animation`:

| Signal      | Parameters | Description                                               |
|-------------|------------|-----------------------------------------------------------|
| `started`   | —          | Emitted when the animation begins via `start()`.          |
| `completed` | —          | Emitted when the animation finishes via `stop()` or `complete()`. |

---

## Python Example

```python
from nebula_shell.ui.widget import Widget
from nebula_shell.animation.fade import FadeAnimation

# Target widget
widget = Widget(name="my-widget")

# Fade in: go from transparent to fully opaque over 500 ms
fade_in = FadeAnimation(
    widget=widget,
    from_value=0.0,
    to_value=1.0,
    name="fade-in"
)
fade_in.duration = 500.0

def on_fade_completed():
    print("Fade-in finished")

fade_in.connect("completed", on_fade_completed)
fade_in.start()

# Fade out: go from fully opaque to transparent
fade_out = FadeAnimation(
    widget=widget,
    from_value=1.0,
    to_value=0.0,
    name="fade-out"
)
fade_out.duration = 300.0
fade_out.start()
```

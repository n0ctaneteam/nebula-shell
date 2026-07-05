# Easing

A pure function library providing standard easing curves for animation interpolation. All easing functions accept a time value `t` in the range `[0, 1]` and return an eased value also in the range `[0, 1]`.

Easing functions are callables conforming to the type `EasingFunc`, defined as:

```
EasingFunc = Callable[[float], float]
```

---

## Class Hierarchy

`Easing` is a module of standalone functions. There is no class hierarchy.

Python alias: `nebula_shell.core.easing`

---

## Functions

| Function      | Parameters | Returns  | Description                                                        |
|---------------|------------|----------|--------------------------------------------------------------------|
| `linear()`    | `t: float` | `float`  | No easing — direct linear interpolation. Returns `t` unchanged.    |
| `ease_in()`   | `t: float` | `float`  | Slow start, then accelerates. Quadratic ease-in (`t²`).            |
| `ease_out()`  | `t: float` | `float`  | Fast start, then decelerates. Quadratic ease-out (`t * (2 - t)`).  |
| `ease_in_out()`| `t: float`| `float`  | Slow start and end, fast middle. Quadratic ease-in-out.            |
| `bounce()`    | `t: float` | `float`  | Simulates a bouncing ball effect at the end of the animation.      |
| `elastic()`   | `t: float` | `float`  | Simulates an elastic spring overshoot effect.                      |

### Parameter contract

| Parameter | Range | Description                          |
|-----------|-------|--------------------------------------|
| `t`       | `[0]` to `[1]` | Normalized time progress. `0.0` = start, `1.0` = end. |

All functions return a value in the range `[0, 1]`, though `bounce()` and `elastic()` may briefly exceed `1.0` during overshoot phases.

---

## Python Example

```python
from nebula_shell.core.easing import linear, ease_in, ease_out, ease_in_out, bounce, elastic

# Basic usage: each function maps [0, 1] -> [0, 1]
for i in range(11):
    t = i / 10.0
    print(f"t={t:.1f}: linear={linear(t):.3f}, ease_in={ease_in(t):.3f}, ease_out={ease_out(t):.3f}")

# Using an easing function with an animation
from nebula_shell.animation.fade import FadeAnimation
from nebula_shell.ui.widget import Widget

widget = Widget(name="demo")
fade = FadeAnimation(widget=widget, from_value=0.0, to_value=1.0, name="eased-fade")
fade.duration = 500.0

# Custom easing function can be passed to an animation
def custom_elastic(t: float) -> float:
    """A softened elastic curve."""
    return 0.5 * elastic(t) + 0.5 * linear(t)

# Bounce is especially useful for entrance animations
bounce_in = FadeAnimation(
    widget=widget,
    from_value=0.0,
    to_value=1.0,
    name="bounce-in"
)
bounce_in.duration = 600.0
bounce_in.start()
```

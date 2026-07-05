# Animation

Base class for all Nebula Shell animations. `Animation` provides the core lifecycle — start, stop, cancel, complete — and a signal-based notification system for animation events.

This is a pure Python base class (not backed by GObject Introspection) and serves as the foundation for concrete animation types such as `FadeAnimation`, `SlideAnimation`, and `ScaleAnimation`.

---

## Class Hierarchy

```
Animation
  ├── FadeAnimation
  ├── SlideAnimation
  └── ScaleAnimation
```

Python alias: `nebula_shell.animation.animation.Animation`

---

## Constructor

### `Animation(name="animation")`

| Parameter | Type   | Default      | Description                          |
|-----------|--------|--------------|--------------------------------------|
| `name`    | `str`  | `"animation"` | A human-readable identifier for the animation instance. |

---

## Properties

| Property     | Type    | Default      | Access | Description                                      |
|--------------|---------|--------------|--------|--------------------------------------------------|
| `name`       | `str`   | `"animation"`| rw     | Human-readable identifier for this animation.    |
| `duration`   | `float` | `300.0`      | rw     | Animation duration in milliseconds.              |
| `is_running` | `bool`  | `False`      | ro     | Whether the animation is currently in progress.  |

---

## Methods

| Method    | Parameters                                   | Returns | Description                                                      |
|-----------|----------------------------------------------|---------|------------------------------------------------------------------|
| `start()` | —                                            | `None`  | Begins the animation. Emits `started`. No-op if already running. |
| `stop()`  | —                                            | `None`  | Stops the animation immediately. Emits `completed`.              |
| `cancel()`| —                                            | `None`  | Cancels the animation without completing. Does **not** emit `completed`. |
| `complete()` | —                                         | `None`  | Marks the animation as finished. Emits `completed`.              |
| `connect()`| `signal: str, callback: callable`           | `int`   | Connects a callback to a named signal. Returns a handler ID for later disconnection. |

---

## Signals

| Signal      | Parameters | Description                                               |
|-------------|------------|-----------------------------------------------------------|
| `started`   | —          | Emitted when the animation begins via `start()`.          |
| `completed` | —          | Emitted when the animation finishes via `stop()` or `complete()`. |

---

## Python Example

```python
from nebula_shell.animation.animation import Animation

# Create a basic animation
anim = Animation(name="my-animation")
anim.duration = 500.0  # 500 ms

# Connect to lifecycle signals
def on_started():
    print("Animation started")

def on_completed():
    print("Animation completed")

anim.connect("started", on_started)
anim.connect("completed", on_completed)

# Run the animation lifecycle
anim.start()     # emits "started"
anim.complete()  # emits "completed"

# Stop early (also emits "completed")
anim.stop()

# Cancel mid-flight (does NOT emit "completed")
anim.cancel()

print(f"Is running? {anim.is_running}")  # False
```

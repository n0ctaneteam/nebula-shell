# Application

Entry point for a Nebula Shell process. Manages the main event loop,
lifetime, and configuration lifecycle for shell components. Every
Nebula Shell process creates exactly one `Application` instance.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Application
```

- **Vala**: `NebulaShell.Application : NebulaShell.Object`
- **Python**: `nebula_shell.app` — wraps GI `NebulaShell.Application`

---

## Constructor

### `Application()`

| Parameter | Type | Default | Description                           |
|-----------|------|---------|---------------------------------------|
| —         | —    | —       | Creates the singleton application.    |

The constructor initialises the GTK event loop, connects to the Wayland
compositor via the layer-shell protocol, and sets up the Nebula Shell
runtime. Only one instance should be created per process.

---

## Properties

| Property     | Type   | Default | Access | Description                              |
|--------------|--------|---------|--------|------------------------------------------|
| `is_running` | `bool` | —       | **ro** | Whether the main loop is currently active. |

---

## Methods

| Method   | Parameters | Returns  | Description                                                     |
|----------|------------|----------|-----------------------------------------------------------------|
| `run()`  | —          | `None`   | Start the main event loop. Blocks until `quit()` is called.     |
| `quit()` | —          | `None`   | Gracefully stop the main event loop and exit.                   |
| `reload()`| —         | `None`   | Trigger a hot-reload of configuration and theme at runtime.     |

### `run()`

Starts the GTK main loop. This call **blocks** until `quit()` is invoked
from a signal handler, timeout, or external event. All window management
and signal processing happens inside this call.

### `quit()`

Requests a graceful shutdown. Any remaining `destroyed` signals are
emitted before the loop exits.

### `reload()`

Triggers a runtime reload without restarting the process. This re-reads
configuration files, reloads the active theme, and emits a notification
to all connected services. The event loop continues running.

---

## Signals

This class does not emit any application-level signals.

---

## Python Example

### Basic usage

```python
from nebula_shell.app import Application
from nebula_shell.ui.panel import Panel
from nebula_shell.ui.widgets import Label

app = Application()

panel = Panel(name="status-bar")
label = Label("Nebula Shell is running")
panel.append(label)
panel.show()

app.run()  # blocks until app.quit() is called
```

### Graceful shutdown with SIGINT

```python
import signal
from nebula_shell.app import Application

app = Application()

def handle_sigint(sig, frame):
    print("Shutting down...")
    app.quit()

signal.signal(signal.SIGINT, handle_sigint)

app.run()
```

### Configuration reload listener

```python
from nebula_shell.app import Application

app = Application()

# Schedule a reload after 60 seconds
GLib.timeout_add_seconds(60, app.reload)

app.run()
```

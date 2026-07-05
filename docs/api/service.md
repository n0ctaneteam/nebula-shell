# Service

Base class for all Nebula Shell system services. `Service` provides a standard lifecycle — initialize, shutdown, reload — and enforces the singleton pattern for built-in services.

Services own state. Widgets observe services. This separation ensures a clean, event-driven architecture: services emit signals when state changes, and widgets react accordingly without polling.

---

## Class Hierarchy

```
Service
  ├── BatteryService
  ├── AudioService
  ├── BluetoothService
  ├── MediaService
  ├── NetworkService
  └── WorkspaceService
```

Python alias: `nebula_shell.services.service.Service`

---

## Constructor

### `Service(name: str)`

| Parameter | Type   | Description                                            |
|-----------|--------|--------------------------------------------------------|
| `name`    | `str`  | Unique name identifying this service instance.          |

> **Note:** Built-in services use the `default()` singleton factory rather than direct instantiation.

---

## Properties

### Own properties

| Property         | Type   | Default | Access | Description                                           |
|------------------|--------|---------|--------|-------------------------------------------------------|
| `name`           | `str`  | —       | ro     | Unique name identifying this service.                 |
| `is_initialized` | `bool` | `False` | ro     | Whether the service has been fully initialized.       |

---

## Methods

### Public API

| Method         | Parameters                        | Returns | Description                                              |
|----------------|-----------------------------------|---------|----------------------------------------------------------|
| `initialize()` | —                                 | `None`  | Initializes the service. Calls the `on_initialize()` hook and sets `is_initialized = True`. |
| `shutdown()`   | —                                 | `None`  | Shuts down the service. Calls the `on_shutdown()` hook and sets `is_initialized = False`.   |
| `reload()`     | —                                 | `None`  | Reloads the service configuration. Calls the `on_reload()` hook.                            |
| `connect()`    | `signal: str, callback: callable` | `int`   | Connects a callback to a named signal. Returns a handler ID for later disconnection.        |

### Lifecycle hooks (override in subclasses)

| Method           | Parameters | Returns | Description                                                |
|------------------|------------|---------|------------------------------------------------------------|
| `on_initialize()`| —          | `None`  | Called during `initialize()`. Override to set up resources. |
| `on_shutdown()`  | —          | `None`  | Called during `shutdown()`. Override to tear down resources.|
| `on_reload()`    | —          | `None`  | Called during `reload()`. Override to apply config changes.  |

---

## Built-in Services

All built-in services follow the `default()` singleton pattern and inherit the full `Service` lifecycle.

### `BatteryService`

| Property     | Type   | Default | Description                                        |
|--------------|--------|---------|----------------------------------------------------|
| `percentage` | `int`  | `0`     | Battery charge percentage (`0`–`100`).             |
| `charging`   | `bool` | `False` | Whether the battery is currently charging.         |

### `AudioService`

| Property | Type   | Default | Description                                         |
|----------|--------|---------|-----------------------------------------------------|
| `volume` | `int`  | `50`    | Audio volume level (`0`–`100`).                     |
| `muted`  | `bool` | `False` | Whether the audio output is muted.                  |

### `BluetoothService`

| Property  | Type   | Default | Description                              |
|-----------|--------|---------|------------------------------------------|
| `enabled` | `bool` | `False` | Whether Bluetooth is currently enabled.  |

### `MediaService`

| Property  | Type   | Default | Description                                   |
|-----------|--------|---------|-----------------------------------------------|
| `title`   | `str`  | `""`    | Title of the currently playing media.         |
| `artist`  | `str`  | `""`    | Artist of the currently playing media.        |
| `playing` | `bool` | `False` | Whether media is currently playing.           |

### `NetworkService`

| Property   | Type   | Default | Description                                |
|------------|--------|---------|--------------------------------------------|
| `connected`| `bool` | `False` | Whether the device has network connectivity.|
| `ssid`     | `str`  | `""`    | The SSID of the connected Wi-Fi network.   |

### `WorkspaceService`

| Property  | Type  | Default | Description                           |
|-----------|-------|---------|---------------------------------------|
| `current` | `int` | `1`     | The currently active workspace index. |

---

## Signals

| Signal       | Parameters   | Description                                            |
|--------------|--------------|--------------------------------------------------------|
| `initialized`| —            | Emitted after `initialize()` completes successfully.   |
| `shutdown`   | —            | Emitted after `shutdown()` completes.                  |

Built-in services may emit additional signals when their properties change. Check each service's documentation for details.

---

## Python Example

```python
from nebula_shell.services.service import Service
from nebula_shell.services.battery import BatteryService
from nebula_shell.services.audio import AudioService
from nebula_shell.services.media import MediaService
from nebula_shell.services.network import NetworkService
from nebula_shell.services.workspace import WorkspaceService

# --- Custom service ---
class MyService(Service):
    def __init__(self):
        super().__init__(name="my-service")

    def on_initialize(self):
        print("MyService: initializing resources")

    def on_shutdown(self):
        print("MyService: cleaning up resources")

    def on_reload(self):
        print("MyService: reloading configuration")

svc = MyService()
svc.initialize()
svc.reload()
svc.shutdown()

# --- Built-in services (singleton pattern) ---
battery = BatteryService.default()
print(f"Battery: {battery.percentage}% {'(charging)' if battery.charging else ''}")

audio = AudioService.default()
print(f"Volume: {audio.volume}% {'(muted)' if audio.muted else ''}")

media = MediaService.default()
print(f"Now playing: {media.title} by {media.artist}")

network = NetworkService.default()
print(f"Network: {'connected' if network.connected else 'disconnected'} (SSID: {network.ssid})")

ws = WorkspaceService.default()
print(f"Current workspace: {ws.current}")

# --- React to service changes via signals ---
def on_battery_changed():
    print(f"Battery changed: {battery.percentage}%")

battery.connect("notify::percentage", on_battery_changed)
```

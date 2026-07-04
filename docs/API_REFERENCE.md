# Nebula Shell API Reference

Version: 0.1.0

Complete reference for the Nebula Shell public API.

All APIs documented here are public. Everything else is internal.

---

# Table of Contents

- [Application](#application)
- [Windows](#windows)
- [Widgets](#widgets)
- [Containers](#containers)
- [Services](#services)
- [Reactive System](#reactive-system)
- [Animation](#animation)
- [Theme](#theme)
- [Configuration](#configuration)
- [Plugin](#plugin)
- [IPC](#ipc)
- [Logging](#logging)
- [Enums](#enums)

---

# Application

**File:** `core/nebula-shell/application.vala`

**Namespace:** `NebulaShell`

**Purpose:** Owns the application lifecycle. Initializes runtime, GTK, loads configuration, starts event loop.

**Lifecycle:**
1. Constructor creates Application instance
2. `run()` starts the event loop
3. `shutdown()` cleans up resources

**Properties:**
- `config` — Current configuration
- `runtime` — Internal runtime (not for public use)

**Methods:**
- `run()` — Start the application event loop
- `quit()` — Stop the application
- `reload()` — Reload configuration

**Signals:**
- `started` — Emitted when application starts
- `stopping` — Emitted before shutdown
- `reloaded` — Emitted after configuration reload

**Example:**
```python
import nebula_shell

app = nebula_shell.Application()
app.run()
```

**Notes:**
- Always create exactly one Application per process
- Application is a singleton

---

# Windows

## Window

**File:** `core/nebula-shell/window.vala`

**Namespace:** `NebulaShell`

**Purpose:** Abstract base class for all layer shell windows. Wraps GTK window and layer shell while exposing only NebulaShell concepts.

**Lifecycle:**
1. Create subclass (Panel, Popup, Overlay)
2. Configure properties (anchor, layer, size)
3. Call `show()` to display
4. Call `hide()` to hide, `destroy()` to remove

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `visible` | bool | false | Whether window is visible |
| `width` | int | 800 | Width in logical pixels |
| `height` | int | 600 | Height in logical pixels |
| `monitor` | Monitor? | null | Target monitor |
| `anchor` | Anchor | NONE | Screen edge anchors |
| `layer` | Layer | TOP | Layer shell layer |
| `exclusive` | bool | false | Reserves screen space |
| `keyboard_mode` | KeyboardMode | NONE | Keyboard interaction |
| `margin_top` | int | 0 | Top margin |
| `margin_bottom` | int | 0 | Bottom margin |
| `margin_left` | int | 0 | Left margin |
| `margin_right` | int | 0 | Right margin |

**Methods:**
- `show()` — Display the window
- `hide()` — Hide without destroying
- `toggle()` — Toggle visibility
- `close()` — Hide and emit closed signal
- `destroy()` — Remove window permanently
- `set_size(width, height)` — Set both dimensions

**Signals:**
- `shown` — Window became visible
- `hidden` — Window became hidden
- `closed` — Window was closed
- `destroyed` — Window was destroyed

**Example:**
```python
from nebula_shell.ui import Window
from nebula_shell import Anchor, Layer

win = Window()
win.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT
win.layer = Layer.TOP
win.height = 32
win.show()
```

---

## Panel

**File:** `core/nebula-shell/panel.vala` (planned)

**Purpose:** Dock/panel windows. Reserves screen space.

**Example:**
```python
from nebula_shell.ui import Panel
from nebula_shell import Anchor

panel = Panel()
panel.anchor = Anchor.TOP
panel.height = 32
panel.exclusive = True
panel.show()
```

---

## Popup

**Purpose:** Temporary floating windows. Used for launchers, menus.

**Methods:**
- `open()` — Show the popup
- `close()` — Hide the popup
- `toggle()` — Toggle visibility

**Signals:**
- `opened` — Popup was opened
- `closed` — Popup was closed

---

## Overlay

**Purpose:** Non-interactive floating windows. Used for notifications, OSD.

---

# Widgets

## Widget

**File:** `core/nebula-shell/widget.vala`

**Namespace:** `NebulaShell`

**Purpose:** Base class for all visual components. Widgets display information but never fetch it.

**Lifecycle:**
1. Create widget instance
2. Configure properties
3. Add to container
4. Call `destroy()` when done

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `visible` | bool | Widget visibility |
| `parent` | Widget? | Parent widget |
| `tooltip` | string | Hover tooltip |
| `style_context` | StyleContext | CSS styling |
| `style_classes` | string[] | CSS classes |

**Methods:**
- `show()` — Make visible
- `hide()` — Make invisible
- `destroy()` — Remove widget
- `add_style_class(css_class)` — Add CSS class
- `remove_style_class(css_class)` — Remove CSS class
- `has_style_class(css_class)` — Check CSS class
- `set_id(id)` — Set CSS ID
- `get_id()` — Get CSS ID
- `set_inline_css(css)` — Set inline CSS
- `get_inline_css()` — Get inline CSS
- `set_pseudo_class(pseudo_class, active)` — Set pseudo-class
- `has_pseudo_class(pseudo_class)` — Check pseudo-class
- `toggle_style_class(css_class)` — Toggle CSS class

**Signals:**
- `shown` — Widget became visible
- `hidden` — Widget became invisible
- `destroyed` — Widget was destroyed
- `event_received(event)` — User interaction event

**Example:**
```python
from nebula_shell.ui import Label

label = Label("Hello")
label.visible = True
label.tooltip = "A greeting"
label.add_style_class("primary")
label.set_id("status-label")
```

---

## Label

**File:** `core/nebula-shell/label.vala`

**Purpose:** Display single or multi-line text.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | "" | Text content |
| `wrap` | bool | false | Enable word wrap |
| `max_width` | int | -1 | Max width before wrap |
| `xalign` | string | "start" | Horizontal alignment |

**Signals:**
- `text_changed(new_text)` — Text was updated

**Constructors:**
- `Label()` — Empty label
- `Label.with_text(text)` — Label with text
- `Label.with_name_and_text(name, text)` — Named label with text

**Example:**
```python
from nebula_shell.ui import Label

label = Label.with_text("Hello, World!")
label.text = "Updated"
label.wrap = True
label.xalign = "center"
```

---

## Button

**File:** `core/nebula-shell/button.vala`

**Purpose:** Clickable element with child widget.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | Widget? | null | Child widget |
| `enabled` | bool | true | Clickable state |
| `label_text` | string | "" | Convenience label |

**Signals:**
- `clicked` — Button was pressed

**Methods:**
- `press()` — Emit clicked signal

**Constructors:**
- `Button()` — Empty button
- `Button.with_label(text)` — Button with label
- `Button.with_name_and_label(name, text)` — Named button with label

**Example:**
```python
from nebula_shell.ui import Button

button = Button.with_label("Click me")
button.clicked.connect(lambda: print("Pressed!"))
```

---

## Icon

**File:** `core/nebula-shell/icon.vala`

**Purpose:** Display themed icons.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon_name` | string | "" | Icon theme name |
| `pixel_size` | int | -1 | Rendered size |

**Signals:**
- `icon_name_changed(new_name)` — Icon name updated

**Constructors:**
- `Icon()` — Empty icon
- `Icon.with_name(icon_name)` — Icon with name
- `Icon.with_name_and_size(icon_name, pixel_size)` — Icon with name and size

**Example:**
```python
from nebula_shell.ui import Icon

icon = Icon.with_name("weather-clear")
icon.pixel_size = 32
```

---

## Image

**File:** `core/nebula-shell/image.vala`

**Purpose:** Display images from file paths.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `path` | string | "" | Image file path |
| `pixel_size` | int | -1 | Rendered size |
| `keep_aspect` | bool | true | Preserve aspect ratio |

**Signals:**
- `path_changed(new_path)` — Path was updated

**Constructors:**
- `Image()` — Empty image
- `Image.with_path(path)` — Image from path
- `Image.with_path_and_size(path, pixel_size)` — Image with size

**Example:**
```python
from nebula_shell.ui import Image

image = Image.with_path("/usr/share/icons/hicolor/48x48/apps/firefox.png")
image.pixel_size = 48
```

---

## Entry

**File:** `core/nebula-shell/entry.vala`

**Purpose:** Single-line text input.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | "" | Current text |
| `placeholder` | string | "" | Placeholder text |
| `editable` | bool | true | User can edit |
| `max_length` | int | -1 | Max characters |

**Signals:**
- `text_changed(new_text)` — Text was updated
- `activated(text)` — Enter was pressed

**Constructors:**
- `Entry()` — Empty entry
- `Entry.with_text(text)` — Entry with text
- `Entry.with_text_and_placeholder(text, placeholder)` — Entry with placeholder

**Example:**
```python
from nebula_shell.ui import Entry

entry = Entry.with_text_and_placeholder("", "Type here...")
entry.activated.connect(lambda text: print(f"Submitted: {text}"))
```

---

## Separator

**File:** `core/nebula-shell/separator.vala`

**Purpose:** Visual line divider.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `orientation` | Orientation | HORIZONTAL | Line direction |
| `thickness` | int | 1 | Line thickness |

**Constructors:**
- `Separator()` — Horizontal separator
- `Separator.with_orientation(orientation)` — Custom orientation
- `Separator.with_orientation_and_thickness(orientation, thickness)` — Custom thickness

**Example:**
```python
from nebula_shell.ui import Separator
from nebula_shell import Orientation

sep = Separator.with_orientation(Orientation.VERTICAL)
sep.thickness = 2
```

---

## Spacer

**File:** `core/nebula-shell/spacer.vala`

**Purpose:** Flexible spacing between widgets.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `min_size` | int | 0 | Minimum size |
| `expand` | bool | true | Fill available space |

**Constructors:**
- `Spacer()` — Expanding spacer
- `Spacer.with_min_size(min_size)` — Fixed minimum
- `Spacer.with_min_size_and_expand(min_size, expand)` — Custom expand

**Example:**
```python
from nebula_shell.ui import Spacer

spacer = Spacer()
```

---

# Containers

## Container

**File:** `core/nebula-shell/container.vala`

**Purpose:** Base class for widgets that contain children. Manages child lifecycle.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `child_count` | int | Number of children |

**Methods:**
- `append(child)` — Add child at end
- `prepend(child)` — Add child at start
- `remove(child)` — Remove child
- `clear()` — Remove all children
- `get_children()` — Get all children
- `get_child_at(index)` — Get child by index
- `index_of(child)` — Find child index

**Signals:**
- `child_added(child)` — Child was added
- `child_removed(child)` — Child was removed
- `children_cleared()` — All children removed

**Example:**
```python
from nebula_shell.ui import Container, Label

container = Container()
container.append(Label("First"))
container.append(Label("Second"))
container.remove(container.get_child_at(0))
```

---

## Box

**File:** `core/nebula-shell/box.vala`

**Purpose:** Single-line layout container. Arranges children horizontally or vertically.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `orientation` | Orientation | HORIZONTAL | Layout direction |
| `spacing` | int | 0 | Gap between children |
| `alignment` | Alignment | START | Cross-axis alignment |
| `homogeneous` | int | 0 | Equal child size |

**Constructors:**
- `Box()` — Horizontal box
- `Box.with_orientation(orientation)` — Custom orientation
- `Box.with_name_and_orientation(name, orientation)` — Named box

**Example:**
```python
from nebula_shell.ui import Box, Label, Orientation

hbox = Box(Orientation.HORIZONTAL)
hbox.spacing = 8
hbox.append(Label("Left"))
hbox.append(Label("Right"))

vbox = Box(Orientation.VERTICAL)
vbox.spacing = 4
vbox.append(Label("Top"))
vbox.append(Label("Bottom"))
```

---

## Grid

**File:** `core/nebula-shell/grid.vala`

**Purpose:** Two-dimensional layout container.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `rows` | int | 1 | Number of rows |
| `columns` | int | 1 | Number of columns |
| `row_spacing` | int | 0 | Gap between rows |
| `column_spacing` | int | 0 | Gap between columns |
| `row_alignment` | GridAlignment | START | Row alignment |
| `column_alignment` | GridAlignment | START | Column alignment |

**Methods:**
- `attach(child, column, row)` — Place child at position

**Constructors:**
- `Grid()` — Empty grid
- `Grid.with_name(name)` — Named grid

**Example:**
```python
from nebula_shell.ui import Grid, Label

grid = Grid()
grid.rows = 2
grid.columns = 2
grid.row_spacing = 8
grid.column_spacing = 8
grid.attach(Label("0,0"), 0, 0)
grid.attach(Label("1,0"), 1, 0)
grid.attach(Label("0,1"), 0, 1)
grid.attach(Label("1,1"), 1, 1)
```

---

## Stack

**File:** `core/nebula-shell/stack.vala`

**Purpose:** Shows one child at a time. Pages switcher.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `visible_child_index` | int | 0 | Current page |
| `visible_child_name` | string | "" | Current page by name |
| `animate_transitions` | bool | true | Animate switches |

**Methods:**
- `get_visible_child()` — Get current child
- `set_visible_child(child)` — Set by widget
- `add_named(name, child)` — Add named child

**Signals:**
- `visible_child_changed(index)` — Page changed

**Constructors:**
- `Stack()` — Empty stack
- `Stack.with_name(name)` — Named stack

**Example:**
```python
from nebula_shell.ui import Stack, Label

stack = Stack()
stack.append(Label("Page 1"))
stack.append(Label("Page 2"))
stack.visible_child_index = 0

# Or by name
stack.add_named("page1", Label("Page 1"))
stack.visible_child_name = "page1"
```

---

## Overlay

**File:** `core/nebula-shell/overlay.vala`

**Purpose:** Floating layers with alignment positioning.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `default_alignment` | OverlayAlignment | CENTER | Default position |
| `default_child` | Widget? | null | Main child |

**Methods:**
- `set_child_alignment(child, alignment)` — Set child position
- `get_child_alignment(child)` — Get child position

**Signals:**
- `default_child_changed(child)` — Default child updated

**Constructors:**
- `Overlay()` — Empty overlay
- `Overlay.with_name(name)` — Named overlay

**Example:**
```python
from nebula_shell.ui import Overlay, Label
from nebula_shell import OverlayAlignment

overlay = Overlay()
overlay.append(Label("Background"))
overlay.append(Label("Content"))
badge = Label("NEW")
overlay.set_child_alignment(badge, OverlayAlignment.TOP_RIGHT)
overlay.append(badge)
```

---

# Services

## Service

**File:** `core/nebula-shell/service.vala`

**Purpose:** Base class for system state services. Services own state, widgets observe.

**Lifecycle:**
1. Create service instance
2. Call `initialize()` to start
3. Use properties and signals
4. Call `shutdown()` to stop

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `service_name` | string | Service identifier |
| `is_initialized` | bool | Initialization state |

**Methods:**
- `initialize()` — Start the service
- `shutdown()` — Stop the service
- `reload()` — Refresh state

**Signals:**
- `service_initialized` — Service started
- `service_shutdown` — Service stopped
- `service_reloaded` — Service reloaded

**Example:**
```python
from nebula_shell.services import Service

class MyService(Service):
    def on_initialize(self):
        # Connect to backend
        pass

    def on_shutdown(self):
        # Disconnect from backend
        pass
```

---

## BatteryService

**File:** `core/nebula-shell/battery.vala` (planned)

**Purpose:** Battery state monitoring.

**Properties:**
- `percentage` — Battery level (0-100)
- `charging` — Whether charging

**Signals:**
- `changed` — Battery state updated

**Example:**
```python
from nebula_shell.services import BatteryService

battery = BatteryService.default()
print(f"Battery: {battery.percentage}%")

def on_battery_changed():
    print(f"Level: {battery.percentage}%")

battery.connect("changed", on_battery_changed)
```

---

## AudioService

**Purpose:** Audio volume control.

**Properties:**
- `volume` — Current volume
- `muted` — Mute state

**Signals:**
- `changed` — Volume updated

**Example:**
```python
from nebula_shell.services import AudioService

audio = AudioService.default()
audio.volume = 75
```

---

## Other Services

- **BluetoothService** — Bluetooth state
- **MediaService** — Media player info
- **WorkspaceService** — Workspace management
- **NetworkService** — Network status

All follow the same pattern: `ServiceName.default()` for singleton access.

---

# Reactive System

## Property

**File:** `core/nebula-shell/property.vala`

**Purpose:** Reactive value container. Emits change notifications.

**Generic Type:** `Property<T>` where T is the value type.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Property identifier |
| `value` | T | Current value |

**Methods:**
- `bind_to(target)` — One-way binding
- `bind_to_with_transform(target, transform)` — One-way with transform
- `bind_two_way(other)` — Two-way binding

**Signals:**
- `value_changed(name, value)` — Value was updated

**Example:**
```python
from nebula_shell import Property

volume = Property("volume", 50)
volume.value = 75

# One-way binding
label.bind(volume.value, lambda v: f"Volume: {v}")

# Two-way binding
other = Property("mirror", 0)
volume.bind_two_way(other)
```

---

## Binding

**File:** `core/nebula-shell/binding.vala`

**Purpose:** Synchronizes properties automatically.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `source` | Observable? | Observed property |
| `target` | Observable? | Updated property |
| `is_two_way` | bool | Bidirectional sync |

**Methods:**
- `unbind()` — Stop synchronization

**Signals:**
- `synchronized` — Sync occurred

---

## Observable

**File:** `core/nebula-shell/observable.vala`

**Purpose:** Base class for reactive state containers.

**Methods:**
- `freeze()` — Suppress notifications
- `thaw()` — Resume notifications

**Signals:**
- `changed(property_name)` — Property changed
- `state_changed()` — Any property changed

---

# Animation

## Animation

**File:** `core/nebula-shell/animation.vala`

**Purpose:** Abstract base for property animations.

**Properties:**
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `duration` | double | 300 | Duration in ms |
| `easing` | EasingFunc | linear | Easing function |
| `is_running` | bool | false | Running state |

**Methods:**
- `start()` — Begin animation
- `stop()` — Pause animation
- `cancel()` — Cancel and reset
- `complete()` — Jump to end

**Signals:**
- `started` — Animation started
- `completed` — Animation finished
- `cancelled` — Animation cancelled

---

## FadeAnimation

**File:** `core/nebula-shell/fade_animation.vala`

**Purpose:** Animate opacity between values.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `from` | double | Start opacity |
| `to` | double | End opacity |
| `current` | double | Current opacity |

**Constructors:**
- `FadeAnimation(name, from, to)` — Custom range
- `FadeAnimation.fade_in(name)` — 0.0 to 1.0
- `FadeAnimation.fade_out(name)` — 1.0 to 0.0

**Example:**
```python
from nebula_shell.animation import FadeAnimation

fade = FadeAnimation.fade_in("show")
fade.duration = 300
fade.start()
```

---

## Easing Functions

Available in `Easing` module:
- `linear`
- `ease_in`
- `ease_out`
- `ease_in_out`

---

# Theme

## Theme

**File:** `core/nebula-shell/theme.vala`

**Purpose:** GTK CSS theme container.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Theme name |
| `file_path` | string | CSS file path |
| `loaded` | bool | Load state |
| `last_modified` | int64 | Last modification |

**Methods:**
- `get_css_content()` — Get CSS string
- `set_css_content(content)` — Set CSS string
- `get_include_paths()` — Get include paths
- `add_include_path(path)` — Add include path
- `copy()` — Clone theme

**Signals:**
- `updated` — CSS content changed

---

# Configuration

## Config

**File:** `core/nebula-shell/config.vala`

**Purpose:** Immutable configuration snapshot.

**Properties:**
| Property | Type | Description |
|----------|------|-------------|
| `size` | int | Number of values |
| `has_errors` | bool | Validation errors exist |

**Methods:**
- `get_string(key)` — Get string value
- `get_int(key)` — Get integer value
- `get_bool(key)` — Get boolean value
- `get_double(key)` — Get double value
- `get(key)` — Get raw value
- `set(key, value)` — Set value
- `has(key)` — Check key exists
- `get_keys()` — Get all keys
- `get_errors()` — Get validation errors
- `add_error(key, message)` — Add error

**Example:**
```python
config = config_manager.get_config()
theme = config.get_string("general/theme")
```

---

# Plugin

## Plugin Interface

**File:** `core/nebula-shell/plugin.vala`

**Purpose:** Plugin contract. Plugins extend framework via public APIs.

**Lifecycle:**
1. `load()` — Initialize plugin
2. `enable()` — Activate plugin
3. `disable()` — Deactivate plugin
4. `unload()` — Clean up

**Properties:**
- `info` — Plugin metadata

**Methods:**
- `load()` — Initialize
- `enable()` — Activate
- `disable()` — Deactivate
- `unload()` — Clean up

**Example:**
```python
class MyPlugin:
    @property
    def info(self):
        return PluginInfo(
            id="my-plugin",
            name="My Plugin",
            version="1.0.0",
            author="Author",
            description="Description",
            api_version=1
        )

    def load(self):
        pass

    def enable(self):
        pass

    def disable(self):
        pass

    def unload(self):
        pass
```

---

## PluginInfo

**Purpose:** Immutable plugin metadata.

**Properties:**
- `id` — Unique identifier
- `name` — Human-readable name
- `version` — Semantic version
- `author` — Author name
- `description` — Short description
- `api_version` — Required API version
- `dependencies` — Required plugins

---

# IPC

## Ipc Interface

**File:** `core/nebula-shell/ipc.vala`

**Purpose:** Transport-independent IPC abstraction.

**Methods:**
- `start()` — Start transport
- `stop()` — Stop transport
- `register_handler(method, handler)` — Handle requests
- `unregister_handler(method)` — Remove handler
- `register_event_handler(event_name, handler)` — Handle events
- `unregister_event_handler(event_name)` — Remove handler
- `send_request(method, payload)` — Send request
- `broadcast_event(event_name, payload)` — Broadcast event

**Properties:**
- `is_running` — Transport state

**Example:**
```python
server = IpcServer()
server.register_handler("get-volume", lambda m, p: '{"volume": 75}')
server.start()
```

---

# Logging

## Logger

**File:** `core/nebula-shell/logger.vala`

**Purpose:** Framework-wide logging with colored output.

**Levels:**
- TRACE
- DEBUG
- INFO
- WARNING
- ERROR
- FATAL

**Methods (static):**
- `trace(message)`
- `debug(message)`
- `info(message)`
- `warning(message)`
- `error(message)`
- `fatal(message)`

**Properties:**
- `min_level` — Minimum log level
- `debug_mode` — Enable debug output
- `color_enabled` — Colored output

**Example:**
```python
from nebula_shell import Logger

Logger.info("Application started")
Logger.set_debug_mode(True)
Logger.debug("Loading plugins")
```

---

# Enums

## Anchor

Flags for screen edge anchoring.

| Value | Description |
|-------|-------------|
| NONE | Floating |
| TOP | Top edge |
| BOTTOM | Bottom edge |
| LEFT | Left edge |
| RIGHT | Right edge |
| ALL | All edges |

---

## Layer

Layer shell stacking order.

| Value | Description |
|-------|-------------|
| BACKGROUND | Below all |
| BOTTOM | Below top |
| TOP | Above bottom |
| OVERLAY | Above all |

---

## Orientation

Layout direction.

| Value | Description |
|-------|-------------|
| HORIZONTAL | Left to right |
| VERTICAL | Top to bottom |

---

## Alignment

Child positioning.

| Value | Description |
|-------|-------------|
| START | Pack at start |
| CENTER | Center |
| END | Pack at end |
| FILL | Fill space |

---

## KeyboardMode

Window keyboard interaction.

| Value | Description |
|-------|-------------|
| NONE | No keyboard |
| EXCLUSIVE | Exclusive focus |
| ON_DEMAND | On-demand focus |

---

## LogLevel

Logging levels.

| Value | Description |
|-------|-------------|
| TRACE | Most verbose |
| DEBUG | Debug info |
| INFO | General info |
| WARNING | Warnings |
| ERROR | Errors |
| FATAL | Critical errors |

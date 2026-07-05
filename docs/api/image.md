# Image

A widget that renders a raster image from a file path. `Image` supports common formats such as PNG and JPEG and provides control over scaling behaviour through pixel size and aspect ratio preservation.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
       └── NebulaShell.Image
```

Python alias: `nebula_shell.ui.image.Image`

---

## Constructor

### `Image(path="", name=None)`

| Parameter | Type   | Default | Description                                               |
|-----------|--------|---------|-----------------------------------------------------------|
| `path`    | `str`  | `""`    | Initial file path to the image to display.                |
| `name`    | `str`  | `None`  | Optional widget name for CSS styling and identification.  |

Creates an image widget. If `path` is empty the widget renders blank until `path` is set.

---

## Properties

| Property      | Type   | Default | Description                                                     |
|---------------|--------|---------|-----------------------------------------------------------------|
| `path`        | `str`  | `""`    | File path to the image. Setting this loads the new image and emits `path_changed`. |
| `pixel_size`  | `int`  | `-1`    | Desired width and height in pixels. `-1` means use the image's intrinsic size. When `keep_aspect` is `True`, this sets the bounding square. |
| `keep_aspect` | `bool` | `True`  | Whether to preserve the image's original aspect ratio when `pixel_size` is set. |
| `visible`     | `bool` | `True`  | Inherited from `Widget`.                                        |
| `tooltip`     | `str`  | `""`    | Inherited from `Widget`.                                        |
| `name`        | `str`  | `""`    | Inherited from `Widget`.                                        |

---

## Methods

This widget inherits all methods from `NebulaShell.Widget`:

| Method      | Parameters | Returns  | Description                               |
|-------------|------------|----------|-------------------------------------------|
| `show()`    | —          | `None`   | Makes the image visible.                  |
| `hide()`    | —          | `None`   | Hides the image.                          |
| `destroy()` | —          | `None`   | Destroys the image widget.                |

---

## Signals

| Signal         | Parameters            | Description                                              |
|----------------|-----------------------|----------------------------------------------------------|
| `path_changed` | `new_path: str`       | Emitted when the `path` property changes. The new file path is passed as the argument. |

Inherited from `Widget`:

| Signal      | Parameters | Description                                      |
|-------------|------------|--------------------------------------------------|
| `shown`     | —          | Emitted when the image becomes visible.          |
| `hidden`    | —          | Emitted when the image is hidden.                |
| `destroyed` | —          | Emitted just before the image is destroyed.      |

---

## Example

```python
from nebula_shell.ui.image import Image

# Create an image from a file
avatar = Image(path="/usr/share/icons/hicolor/48x48/apps/user-avatar.png")
avatar.pixel_size = 48
avatar.keep_aspect = True

# React to path changes
def on_path_changed(new_path):
    print(f"Image source changed to: {new_path}")

avatar.connect("path_changed", on_path_changed)

# Swap the image at runtime
avatar.path = "/usr/share/icons/hicolor/48x48/apps/user-avatar-offline.png"

# Display at intrinsic size
banner = Image(path="/usr/share/wallpapers/default.png")
banner.pixel_size = -1  # use intrinsic dimensions

print(banner.path)       # "/usr/share/wallpapers/default.png"
print(banner.pixel_size) # -1
print(banner.keep_aspect)  # True
```


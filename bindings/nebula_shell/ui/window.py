"""
Window class for Nebula Shell.

Window provides a GTK-independent abstraction for desktop shell windows.
It wraps an internal GtkWindow and layer shell surface while exposing
only NebulaShell concepts to users.

Window is abstract. Concrete subclasses are Panel, Popup, and Overlay.
"""

from enum import IntFlag, IntEnum
from typing import Optional

from nebula_shell._gi import Window as _GIWindow
from nebula_shell.ui.widget import Widget


class Anchor(IntFlag):
    """Screen edge anchor positions.

    Multiple anchors can be combined for corners or edge fills.
    """
    NONE = 0
    TOP = 1 << 0
    BOTTOM = 1 << 1
    LEFT = 1 << 2
    RIGHT = 1 << 3
    ALL = TOP | BOTTOM | LEFT | RIGHT


class Layer(IntEnum):
    """Layer shell surface layers.

    Determines the stacking order of windows on screen.
    Higher layers are rendered above lower layers.
    """
    BACKGROUND = 0
    BOTTOM = 1
    TOP = 2
    OVERLAY = 3


class KeyboardMode(IntEnum):
    """Keyboard interaction modes for layer shell surfaces.

    Controls how a window handles keyboard input and focus.
    """
    NONE = 0
    EXCLUSIVE = 1
    ON_DEMAND = 2


class Monitor:
    """Represents a display monitor.

    Monitor provides an abstraction over display outputs.
    Each monitor has a unique identifier, position, size, and scale factor.

    Example:
        primary = Monitor.get_primary()
        window.monitor = primary
    """

    def __init__(
        self,
        monitor_id: int,
        name: str,
        x: int,
        y: int,
        width: int,
        height: int,
        scale: float = 1.0,
    ) -> None:
        self._monitor_id = monitor_id
        self._name = name
        self._x = x
        self._y = y
        self._width = width
        self._height = height
        self._scale = scale

    @property
    def id(self) -> int:
        """Unique identifier for this monitor."""
        return self._monitor_id

    @property
    def name(self) -> str:
        """Human-readable name for this monitor."""
        return self._name

    @property
    def x(self) -> int:
        """X coordinate in the global coordinate space."""
        return self._x

    @property
    def y(self) -> int:
        """Y coordinate in the global coordinate space."""
        return self._y

    @property
    def width(self) -> int:
        """Width in logical pixels."""
        return self._width

    @property
    def height(self) -> int:
        """Height in logical pixels."""
        return self._height

    @property
    def scale(self) -> float:
        """Scale factor of the monitor."""
        return self._scale

    def contains_point(self, px: int, py: int) -> bool:
        """Check if a point lies within this monitor.

        Args:
            px: X coordinate of the point.
            py: Y coordinate of the point.

        Returns:
            True if the point is within the monitor bounds.
        """
        return (
            px >= self._x
            and px < self._x + self._width
            and py >= self._y
            and py < self._y + self._height
        )

    @staticmethod
    def get_primary() -> Optional["Monitor"]:
        """Get the primary monitor.

        Returns:
            The primary monitor, or None if no monitors exist.
        """
        try:
            from gi.repository import Gdk
        except ImportError:
            return None

        display = Gdk.Display.get_default()
        if display is None:
            return None

        model = display.get_monitors()
        n_items = model.get_n_items()
        if n_items == 0:
            return None

        gdk_monitor = model.get_item(0)
        if gdk_monitor is None:
            return None

        return Monitor._from_gdk_monitor(gdk_monitor, 0)

    @staticmethod
    def get_all() -> list["Monitor"]:
        """Get all available monitors.

        Returns:
            List of all monitors.
        """
        try:
            from gi.repository import Gdk
        except ImportError:
            return []

        display = Gdk.Display.get_default()
        if display is None:
            return []

        monitors = []
        model = display.get_monitors()
        n_items = model.get_n_items()

        for i in range(n_items):
            gdk_monitor = model.get_item(i)
            if gdk_monitor is not None:
                monitors.append(Monitor._from_gdk_monitor(gdk_monitor, i))

        return monitors

    @staticmethod
    def find_by_id(monitor_id: int) -> Optional["Monitor"]:
        """Find a monitor by its identifier.

        Args:
            monitor_id: The monitor id to find.

        Returns:
            The monitor, or None if not found.
        """
        for monitor in Monitor.get_all():
            if monitor.id == monitor_id:
                return monitor
        return None

    @staticmethod
    def find_by_name(name: str) -> Optional["Monitor"]:
        """Find a monitor by name.

        Args:
            name: The monitor name to find.

        Returns:
            The monitor, or None if not found.
        """
        for monitor in Monitor.get_all():
            if monitor.name == name:
                return monitor
        return None

    @staticmethod
    def _from_gdk_monitor(gdk_monitor, monitor_id: int) -> "Monitor":
        """Create a Monitor from a GDK monitor."""
        geometry = gdk_monitor.get_geometry()
        name = gdk_monitor.get_model() or "Unknown"
        return Monitor(
            monitor_id=monitor_id,
            name=name,
            x=geometry.x,
            y=geometry.y,
            width=geometry.width,
            height=geometry.height,
            scale=gdk_monitor.get_scale_factor(),
        )


class Window(Widget):
    """Base class for all windows in NebulaShell.

    Window provides a GTK-independent abstraction for desktop shell
    windows. It wraps an internal GtkWindow and layer shell surface
    while exposing only NebulaShell concepts to users.

    Window is abstract. Concrete subclasses are Panel, Popup, and Overlay.

    Example:
        window = Window("my-window")
        window.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT
        window.layer = Layer.TOP
        window.height = 32
        window.show()
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new window.

        Args:
            name: Optional human-readable identifier for this window.
        """
        super().__init__(name)
        self._gi_window = _GIWindow()
        self._visible = False
        self._width = 800
        self._height = 600
        self._monitor: Optional[Monitor] = None
        self._anchor = Anchor.NONE
        self._layer = Layer.TOP
        self._exclusive = False
        self._keyboard_mode = KeyboardMode.NONE
        self._margin_top = 0
        self._margin_bottom = 0
        self._margin_left = 0
        self._margin_right = 0
        self._children: list = []

    @property
    def visible(self) -> bool:
        """Whether the window is currently visible on screen."""
        return self._visible

    @property
    def width(self) -> int:
        """Width of the window in logical pixels."""
        return self._width

    @width.setter
    def width(self, value: int) -> None:
        if value <= 0:
            return
        self._width = value
        if self._visible:
            self._gi_window.set_default_size(self._width, self._height)

    @property
    def height(self) -> int:
        """Height of the window in logical pixels."""
        return self._height

    @height.setter
    def height(self, value: int) -> None:
        if value <= 0:
            return
        self._height = value
        if self._visible:
            self._gi_window.set_default_size(self._width, self._height)

    @property
    def monitor(self) -> Optional[Monitor]:
        """The monitor this window is displayed on."""
        return self._monitor

    @monitor.setter
    def monitor(self, value: Optional[Monitor]) -> None:
        self._monitor = value

    @property
    def anchor(self) -> Anchor:
        """Screen edge anchor for this window."""
        return self._anchor

    @anchor.setter
    def anchor(self, value: Anchor) -> None:
        self._anchor = value

    @property
    def layer(self) -> Layer:
        """Layer shell layer for this window."""
        return self._layer

    @layer.setter
    def layer(self, value: Layer) -> None:
        self._layer = value

    @property
    def exclusive(self) -> bool:
        """Whether this window reserves exclusive screen space."""
        return self._exclusive

    @exclusive.setter
    def exclusive(self, value: bool) -> None:
        self._exclusive = value

    @property
    def keyboard_mode(self) -> KeyboardMode:
        """Keyboard interaction mode for this window."""
        return self._keyboard_mode

    @keyboard_mode.setter
    def keyboard_mode(self, value: KeyboardMode) -> None:
        self._keyboard_mode = value

    @property
    def margin_top(self) -> int:
        """Margin from the top screen edge in logical pixels."""
        return self._margin_top

    @margin_top.setter
    def margin_top(self, value: int) -> None:
        self._margin_top = value

    @property
    def margin_bottom(self) -> int:
        """Margin from the bottom screen edge in logical pixels."""
        return self._margin_bottom

    @margin_bottom.setter
    def margin_bottom(self, value: int) -> None:
        self._margin_bottom = value

    @property
    def margin_left(self) -> int:
        """Margin from the left screen edge in logical pixels."""
        return self._margin_left

    @margin_left.setter
    def margin_left(self, value: int) -> None:
        self._margin_left = value

    @property
    def margin_right(self) -> int:
        """Margin from the right screen edge in logical pixels."""
        return self._margin_right

    @margin_right.setter
    def margin_right(self, value: int) -> None:
        self._margin_right = value

    def show(self) -> None:
        """Show the window on screen.

        Emits the shown signal.
        """
        if self._visible:
            return
        self._visible = True

    def hide(self) -> None:
        """Hide the window without destroying it.

        Emits the hidden signal.
        """
        if not self._visible:
            return
        self._visible = False

    def toggle(self) -> None:
        """Toggle the window visibility.

        If visible, hides the window.
        If hidden, shows the window.
        """
        if self._visible:
            self.hide()
        else:
            self.show()

    def close(self) -> None:
        """Close the window.

        Hides the window and emits the closed signal.
        The window can be shown again with show().
        """
        if not self._visible:
            return
        self.hide()

    def destroy(self) -> None:
        """Destroy the window and release all resources.

        After destruction, the window cannot be shown again.
        """
        self._gi_window = None
        self._visible = False

    def set_size(self, width: int, height: int) -> None:
        """Set the window size.

        Convenience method to set both width and height at once.

        Args:
            width: The new width in logical pixels.
            height: The new height in logical pixels.
        """
        if width <= 0 or height <= 0:
            return
        self._width = width
        self._height = height
        self._gi_window.set_default_size(self._width, self._height)

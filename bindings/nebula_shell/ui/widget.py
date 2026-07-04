"""
Base widget class for Nebula Shell.

Widget provides the foundation for all visual components.
Widgets display information but never fetch it.
"""

from typing import Optional, Callable, Any

from nebula_shell._gi import Widget as _GIWidget


class Widget:
    """Base class for all Nebula Shell widgets.

    Widgets display information but never fetch it. Data fetching
    belongs inside services.

    Properties describe widget state.
    Methods perform actions on the widget.
    Signals describe widget events.

    Example:
        widget = Widget()
        widget.visible = True
        widget.tooltip = "A helpful tip"
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new widget.

        Args:
            name: Optional human-readable identifier for this widget.
        """
        self._widget = _GIWidget()
        self._name = name
        self._signal_handlers: dict[str, list[Callable]] = {}

    @property
    def visible(self) -> bool:
        """Whether the widget is currently visible."""
        return self._widget.get_property("visible")

    @visible.setter
    def visible(self, value: bool) -> None:
        self._widget.set_property("visible", value)

    @property
    def tooltip(self) -> str:
        """Tooltip text displayed on hover."""
        return self._widget.get_property("tooltip") or ""

    @tooltip.setter
    def tooltip(self, value: str) -> None:
        self._widget.set_property("tooltip", value)

    @property
    def name(self) -> Optional[str]:
        """Human-readable identifier for this widget."""
        return self._name

    def show(self) -> None:
        """Show the widget."""
        self._widget.show()

    def hide(self) -> None:
        """Hide the widget."""
        self._widget.hide()

    def destroy(self) -> None:
        """Destroy the widget and release all resources."""
        self._widget.destroy()

    def add_style_class(self, css_class: str) -> None:
        """Add a CSS style class to this widget.

        Args:
            css_class: The CSS class name to add.
        """
        self._widget.add_style_class(css_class)

    def remove_style_class(self, css_class: str) -> None:
        """Remove a CSS style class from this widget.

        Args:
            css_class: The CSS class name to remove.
        """
        self._widget.remove_style_class(css_class)

    def has_style_class(self, css_class: str) -> bool:
        """Check if this widget has a specific CSS style class.

        Args:
            css_class: The CSS class name to check.

        Returns:
            True if the class is present.
        """
        return self._widget.has_style_class(css_class)

    def connect(self, signal: str, callback: Callable) -> int:
        """Connect a signal handler.

        Args:
            signal: The signal name to connect to.
            callback: The function to call when the signal is emitted.

        Returns:
            The handler ID.
        """
        return self._widget.connect(signal, callback)

    def disconnect(self, handler_id: int) -> None:
        """Disconnect a signal handler.

        Args:
            handler_id: The handler ID returned by connect().
        """
        self._widget.disconnect(handler_id)

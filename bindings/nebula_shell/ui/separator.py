"""
Separator widget class for Nebula Shell.

Separator draws a horizontal or vertical line to separate content.
"""

from typing import Optional

from nebula_shell._gi import Separator as _GISeparator
from nebula_shell._gi import Orientation as _GIOrientation
from nebula_shell.ui.widget import Widget
from nebula_shell.ui.box import Orientation


class Separator(Widget):
    """A widget that draws a line to separate content.

    Separator can be horizontal or vertical.

    Example:
        separator = Separator()
        separator.orientation = Orientation.HORIZONTAL
    """

    def __init__(self, name: Optional[str] = None, orientation: Orientation = Orientation.HORIZONTAL) -> None:
        """Create a new separator.

        Args:
            name: Optional human-readable identifier.
            orientation: The orientation of the separator.
        """
        super().__init__()
        self._widget = _GISeparator()
        gi_orientation = _GIOrientation.HORIZONTAL if orientation == Orientation.HORIZONTAL else _GIOrientation.VERTICAL
        self._widget.set_orientation(gi_orientation)
        if name is not None:
            self._widget.set_name(name)

    @property
    def orientation(self) -> Orientation:
        """The orientation of the separator."""
        return Orientation(self._widget.get_orientation())

    @orientation.setter
    def orientation(self, value: Orientation) -> None:
        gi_orientation = _GIOrientation.HORIZONTAL if value == Orientation.HORIZONTAL else _GIOrientation.VERTICAL
        self._widget.set_orientation(gi_orientation)

    @property
    def thickness(self) -> int:
        """The thickness of the separator line in logical pixels."""
        return self._widget.get_thickness()

    @thickness.setter
    def thickness(self, value: int) -> None:
        self._widget.set_thickness(value)

"""
Separator widget class for Nebula Shell.

Separator draws a horizontal or vertical line to separate content.
"""

from typing import Optional

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
        super().__init__(name)
        self._orientation = orientation
        self._thickness = 1

    @property
    def orientation(self) -> Orientation:
        """The orientation of the separator."""
        return self._orientation

    @orientation.setter
    def orientation(self, value: Orientation) -> None:
        self._orientation = value

    @property
    def thickness(self) -> int:
        """The thickness of the separator line in logical pixels."""
        return self._thickness

    @thickness.setter
    def thickness(self, value: int) -> None:
        self._thickness = value

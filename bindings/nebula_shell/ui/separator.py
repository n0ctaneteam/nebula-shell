"""
Separator widget class for Nebula Shell.

Separator draws a horizontal or vertical line to separate content.
"""

from typing import Optional

from nebula_shell.ui.widget import Widget


class Separator(Widget):
    """A widget that draws a line to separate content.

    Separator can be horizontal or vertical.

    Example:
        separator = Separator()
        separator.orientation = Orientation.HORIZONTAL
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new separator.

        Args:
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._orientation = "horizontal"

    @property
    def orientation(self) -> str:
        """The orientation of the separator.

        Valid values: "horizontal", "vertical".
        """
        return self._orientation

    @orientation.setter
    def orientation(self, value: str) -> None:
        if value not in ("horizontal", "vertical"):
            raise ValueError(f"Invalid orientation: {value}")
        self._orientation = value

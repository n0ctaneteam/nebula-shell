"""
Box widget class for Nebula Shell.

Box lays out children horizontally or vertically.
Use orientation to control the layout direction.
Use spacing to add gaps between children.
"""

from enum import Enum
from typing import Optional

from nebula_shell.ui.container import Container


class Orientation(Enum):
    """Orientation for box layout direction."""
    HORIZONTAL = 0
    VERTICAL = 1


class Alignment(Enum):
    """Alignment for child widgets within a box."""
    START = 0
    CENTER = 1
    END = 2
    FILL = 3


class Box(Container):
    """A container that arranges children in a single line.

    Box lays out children horizontally or vertically.
    Use orientation to control the layout direction.
    Use spacing to add gaps between children.

    Example:
        hbox = Box()
        hbox.orientation = Orientation.HORIZONTAL
        hbox.spacing = 8
        hbox.append(Label("Left"))
        hbox.append(Label("Right"))

    Example:
        vbox = Box(Orientation.VERTICAL)
        vbox.spacing = 4
        vbox.append(Label("Top"))
        vbox.append(Label("Bottom"))
    """

    def __init__(
        self,
        orientation: Orientation = Orientation.HORIZONTAL,
        name: Optional[str] = None,
    ) -> None:
        """Create a new box.

        Args:
            orientation: The layout direction. Default is HORIZONTAL.
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._orientation = orientation
        self._spacing = 0
        self._alignment = Alignment.START

    @property
    def orientation(self) -> Orientation:
        """The layout direction of this box."""
        return self._orientation

    @orientation.setter
    def orientation(self, value: Orientation) -> None:
        self._orientation = value

    @property
    def spacing(self) -> int:
        """Spacing between children in logical pixels."""
        return self._spacing

    @spacing.setter
    def spacing(self, value: int) -> None:
        self._spacing = value

    @property
    def alignment(self) -> Alignment:
        """Alignment of children within the box."""
        return self._alignment

    @alignment.setter
    def alignment(self, value: Alignment) -> None:
        self._alignment = value

"""
Overlay widget class for Nebula Shell.

Overlay is a container that stacks children with floating positioning.
Children are layered in order: later children appear on top.
"""

from enum import Enum
from typing import Optional

from nebula_shell.ui.container import Container


class OverlayAlignment(Enum):
    """Alignment for overlay children."""
    TOP_LEFT = 0
    TOP_CENTER = 1
    TOP_RIGHT = 2
    MIDDLE_LEFT = 3
    CENTER = 4
    MIDDLE_RIGHT = 5
    BOTTOM_LEFT = 6
    BOTTOM_CENTER = 7
    BOTTOM_RIGHT = 8


class Overlay(Container):
    """A container that stacks children with floating positioning.

    Overlay places children on top of each other, each at a
    specific alignment position. Unlike Stack which shows one
    child at a time, Overlay can show multiple children at once.

    Children are layered in order: later children appear on top.

    Example:
        overlay = Overlay()
        overlay.append(background)
        overlay.append(content)
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new overlay.

        Args:
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._default_alignment = OverlayAlignment.CENTER
        self._child_alignments: dict[int, OverlayAlignment] = {}

    @property
    def default_alignment(self) -> OverlayAlignment:
        """Default alignment for new children."""
        return self._default_alignment

    @default_alignment.setter
    def default_alignment(self, value: OverlayAlignment) -> None:
        self._default_alignment = value

    def set_child_alignment(self, child, alignment: OverlayAlignment) -> None:
        """Set the alignment for a specific child.

        Args:
            child: The widget to align.
            alignment: The alignment position.
        """
        child_id = id(child)
        self._child_alignments[child_id] = alignment

    def get_child_alignment(self, child) -> OverlayAlignment:
        """Get the alignment for a specific child.

        Args:
            child: The widget to query.

        Returns:
            The alignment, or the default alignment.
        """
        child_id = id(child)
        return self._child_alignments.get(child_id, self._default_alignment)

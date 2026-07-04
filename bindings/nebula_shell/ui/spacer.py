"""
Spacer widget class for Nebula Shell.

Spacer adds empty space between widgets.
"""

from typing import Optional

from nebula_shell.ui.widget import Widget


class Spacer(Widget):
    """A widget that adds empty space between other widgets.

    Spacer is used to create gaps or push widgets apart
    in a Box layout.

    Example:
        box = Box()
        box.append(Label("Left"))
        box.append(Spacer())
        box.append(Label("Right"))
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new spacer.

        Args:
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._hexpand = True
        self._vexpand = True

    @property
    def hexpand(self) -> bool:
        """Whether the spacer expands horizontally."""
        return self._hexpand

    @hexpand.setter
    def hexpand(self, value: bool) -> None:
        self._hexpand = value

    @property
    def vexpand(self) -> bool:
        """Whether the spacer expands vertically."""
        return self._vexpand

    @vexpand.setter
    def vexpand(self, value: bool) -> None:
        self._vexpand = value

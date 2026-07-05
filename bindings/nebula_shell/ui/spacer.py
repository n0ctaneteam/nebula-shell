"""
Spacer widget class for Nebula Shell.

Spacer adds empty space between widgets.
"""

from typing import Optional

from nebula_shell._gi import Spacer as _GISpacer
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

    def __init__(self, name: Optional[str] = None, min_size: int = 0, expand: bool = False) -> None:
        """Create a new spacer.

        Args:
            name: Optional human-readable identifier.
            min_size: The minimum size in logical pixels.
            expand: Whether to expand to fill available space.
        """
        super().__init__()
        self._widget = _GISpacer()
        if name is not None:
            self._widget.set_name(name)
        if min_size != 0 or expand:
            self._widget.set_min_size(min_size)
            self._widget.set_expand(expand)

    @property
    def min_size(self) -> int:
        """The minimum size in logical pixels."""
        return self._widget.get_min_size()

    @min_size.setter
    def min_size(self, value: int) -> None:
        self._widget.set_min_size(value)

    @property
    def expand(self) -> bool:
        """Whether this spacer expands to fill available space."""
        return self._widget.get_expand()

    @expand.setter
    def expand(self, value: bool) -> None:
        self._widget.set_expand(value)

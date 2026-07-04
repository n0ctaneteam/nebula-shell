"""
Slide animation class for Nebula Shell.

SlideAnimation animates a widget sliding in or out of view.
"""

from typing import Optional

from nebula_shell.animation.animation import Animation


class SlideAnimation(Animation):
    """Animation that slides a widget in or out of view.

    SlideAnimation smoothly transitions a widget's position
    from a start point to an end point.

    Example:
        slide = SlideAnimation(widget, from_x=0, to_x=100)
        slide.duration = 300
        slide.start()
    """

    def __init__(
        self,
        widget=None,
        from_x: float = 0.0,
        from_y: float = 0.0,
        to_x: float = 0.0,
        to_y: float = 0.0,
        name: str = "slide",
    ) -> None:
        """Create a new slide animation.

        Args:
            widget: The widget to animate.
            from_x: Starting X position.
            from_y: Starting Y position.
            to_x: Ending X position.
            to_y: Ending Y position.
            name: Human-readable identifier.
        """
        super().__init__(name)
        self._widget = widget
        self._from_x = from_x
        self._from_y = from_y
        self._to_x = to_x
        self._to_y = to_y

    @property
    def from_x(self) -> float:
        """Starting X position."""
        return self._from_x

    @from_x.setter
    def from_x(self, value: float) -> None:
        self._from_x = value

    @property
    def from_y(self) -> float:
        """Starting Y position."""
        return self._from_y

    @from_y.setter
    def from_y(self, value: float) -> None:
        self._from_y = value

    @property
    def to_x(self) -> float:
        """Ending X position."""
        return self._to_x

    @to_x.setter
    def to_x(self, value: float) -> None:
        self._to_x = value

    @property
    def to_y(self) -> float:
        """Ending Y position."""
        return self._to_y

    @to_y.setter
    def to_y(self, value: float) -> None:
        self._to_y = value

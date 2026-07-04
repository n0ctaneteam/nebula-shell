"""
Fade animation class for Nebula Shell.

FadeAnimation animates the opacity of a widget from one value to another.
"""

from typing import Optional

from nebula_shell.animation.animation import Animation


class FadeAnimation(Animation):
    """Animation that fades a widget's opacity.

    FadeAnimation smoothly transitions a widget's opacity
    from a start value to an end value over a specified duration.

    Example:
        fade = FadeAnimation(widget, 0.0, 1.0)
        fade.duration = 300
        fade.start()
    """

    def __init__(
        self,
        widget=None,
        from_value: float = 0.0,
        to_value: float = 1.0,
        name: str = "fade",
    ) -> None:
        """Create a new fade animation.

        Args:
            widget: The widget to animate.
            from_value: Starting opacity (0.0 to 1.0).
            to_value: Ending opacity (0.0 to 1.0).
            name: Human-readable identifier.
        """
        super().__init__(name)
        self._widget = widget
        self._from_value = from_value
        self._to_value = to_value

    @property
    def from_value(self) -> float:
        """Starting opacity value."""
        return self._from_value

    @from_value.setter
    def from_value(self, value: float) -> None:
        self._from_value = value

    @property
    def to_value(self) -> float:
        """Ending opacity value."""
        return self._to_value

    @to_value.setter
    def to_value(self, value: float) -> None:
        self._to_value = value

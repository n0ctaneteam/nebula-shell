"""
Scale animation class for Nebula Shell.

ScaleAnimation animates a widget scaling up or down.
"""

from typing import Optional

from nebula_shell.animation.animation import Animation


class ScaleAnimation(Animation):
    """Animation that scales a widget up or down.

    ScaleAnimation smoothly transitions a widget's scale
    from a start factor to an end factor.

    Example:
        scale = ScaleAnimation(widget, from_scale=0.5, to_scale=1.0)
        scale.duration = 200
        scale.start()
    """

    def __init__(
        self,
        widget=None,
        from_scale: float = 0.0,
        to_scale: float = 1.0,
        name: str = "scale",
    ) -> None:
        """Create a new scale animation.

        Args:
            widget: The widget to animate.
            from_scale: Starting scale factor.
            to_scale: Ending scale factor.
            name: Human-readable identifier.
        """
        super().__init__(name)
        self._widget = widget
        self._from_scale = from_scale
        self._to_scale = to_scale

    @property
    def from_scale(self) -> float:
        """Starting scale factor."""
        return self._from_scale

    @from_scale.setter
    def from_scale(self, value: float) -> None:
        self._from_scale = value

    @property
    def to_scale(self) -> float:
        """Ending scale factor."""
        return self._to_scale

    @to_scale.setter
    def to_scale(self, value: float) -> None:
        self._to_scale = value

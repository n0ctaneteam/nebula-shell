"""
Scale animation class for Nebula Shell.

ScaleAnimation animates a widget scaling up or down.
"""

from typing import Optional

from nebula_shell.animation.animation import Animation


class ScaleAnimation(Animation):
    """Animation that scales a widget up or down.

    ScaleAnimation smoothly transitions a widget's scale
    from a start factor to an end factor. Supports uniform
    scaling (same factor for both axes) or independent x/y scaling.

    Example:
        scale = ScaleAnimation(widget, from_scale=0.5, to_scale=1.0)
        scale.duration = 200
        scale.start()

    Example:
        scale = ScaleAnimation(widget, from_x=0.0, from_y=0.5, to_x=1.0, to_y=1.0)
        scale.duration = 200
        scale.start()
    """

    def __init__(
        self,
        widget=None,
        from_scale: float = 0.0,
        to_scale: float = 1.0,
        from_x: Optional[float] = None,
        from_y: Optional[float] = None,
        to_x: Optional[float] = None,
        to_y: Optional[float] = None,
        name: str = "scale",
    ) -> None:
        """Create a new scale animation.

        Args:
            widget: The widget to animate.
            from_scale: Starting scale factor (uniform).
            to_scale: Ending scale factor (uniform).
            from_x: Starting X scale factor.
            from_y: Starting Y scale factor.
            to_x: Ending X scale factor.
            to_y: Ending Y scale factor.
            name: Human-readable identifier.
        """
        super().__init__(name)
        self._widget = widget
        if from_x is not None:
            self._from_x = from_x
        else:
            self._from_x = from_scale
        if from_y is not None:
            self._from_y = from_y
        else:
            self._from_y = from_scale
        if to_x is not None:
            self._to_x = to_x
        else:
            self._to_x = to_scale
        if to_y is not None:
            self._to_y = to_y
        else:
            self._to_y = to_scale

    @property
    def from_x(self) -> float:
        """Starting scale factor for X axis."""
        return self._from_x

    @property
    def from_y(self) -> float:
        """Starting scale factor for Y axis."""
        return self._from_y

    @property
    def to_x(self) -> float:
        """Ending scale factor for X axis."""
        return self._to_x

    @property
    def to_y(self) -> float:
        """Ending scale factor for Y axis."""
        return self._to_y

    @property
    def from_scale(self) -> float:
        """Starting scale factor (uniform, uses from_x value)."""
        return self._from_x

    @from_scale.setter
    def from_scale(self, value: float) -> None:
        self._from_x = value
        self._from_y = value

    @property
    def to_scale(self) -> float:
        """Ending scale factor (uniform, uses to_x value)."""
        return self._to_x

    @to_scale.setter
    def to_scale(self, value: float) -> None:
        self._to_x = value
        self._to_y = value

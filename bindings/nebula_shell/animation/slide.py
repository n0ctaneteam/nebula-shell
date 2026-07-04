"""
Slide animation class for Nebula Shell.

SlideAnimation animates a widget sliding in or out of view.
"""

from enum import Enum
from typing import Optional

from nebula_shell.animation.animation import Animation


class SlideDirection(Enum):
    """Direction for slide animations."""
    LEFT = 0
    RIGHT = 1
    UP = 2
    DOWN = 3


class SlideAnimation(Animation):
    """Animation that slides a widget in or out of view.

    SlideAnimation smoothly transitions a widget's position
    from a start point to an end point.

    Example:
        slide = SlideAnimation(widget, from_x=0, to_x=100)
        slide.duration = 300
        slide.start()

    Example:
        slide = SlideAnimation(widget, SlideDirection.LEFT)
        slide.set_offset(100)
        slide.start()
    """

    def __init__(
        self,
        widget=None,
        from_x: float = 0.0,
        from_y: float = 0.0,
        to_x: float = 0.0,
        to_y: float = 0.0,
        direction: Optional[SlideDirection] = None,
        name: str = "slide",
    ) -> None:
        """Create a new slide animation.

        Args:
            widget: The widget to animate.
            from_x: Starting X position.
            from_y: Starting Y position.
            to_x: Ending X position.
            to_y: Ending Y position.
            direction: The slide direction. When provided, from_x/from_y
                are set automatically based on direction.
            name: Human-readable identifier.
        """
        super().__init__(name)
        self._widget = widget
        self._direction = direction
        if direction is not None:
            self._from_x, self._from_y = self._get_direction_offsets(direction)
        else:
            self._from_x = from_x
            self._from_y = from_y
        self._to_x = to_x
        self._to_y = to_y

    @staticmethod
    def _get_direction_offsets(direction: SlideDirection):
        """Get default offsets for a slide direction."""
        if direction == SlideDirection.LEFT:
            return (-100.0, 0.0)
        elif direction == SlideDirection.RIGHT:
            return (100.0, 0.0)
        elif direction == SlideDirection.UP:
            return (0.0, -100.0)
        elif direction == SlideDirection.DOWN:
            return (0.0, 100.0)
        return (0.0, 0.0)

    @property
    def direction(self) -> Optional[SlideDirection]:
        """The slide direction."""
        return self._direction

    @property
    def from_x(self) -> float:
        """Starting X position."""
        return self._from_x

    @property
    def from_y(self) -> float:
        """Starting Y position."""
        return self._from_y

    @property
    def to_x(self) -> float:
        """Ending X position."""
        return self._to_x

    @property
    def to_y(self) -> float:
        """Ending Y position."""
        return self._to_y

    def set_offset(self, offset: float) -> None:
        """Set the slide offset for directional animations.

        Args:
            offset: The distance to slide in pixels.
        """
        if self._direction is None:
            return
        if self._direction == SlideDirection.LEFT:
            self._from_x = -offset
        elif self._direction == SlideDirection.RIGHT:
            self._from_x = offset
        elif self._direction == SlideDirection.UP:
            self._from_y = -offset
        elif self._direction == SlideDirection.DOWN:
            self._from_y = offset

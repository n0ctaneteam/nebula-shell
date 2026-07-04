"""
Base animation class for Nebula Shell.

Animation provides a declarative, GTK-independent abstraction
for animating properties over time.
"""

from typing import Optional, Callable


class Animation:
    """Base class for all animations.

    Animation provides a declarative, GTK-independent abstraction
    for animating properties over time. Animations describe WHAT
    to animate, not HOW to render it.

    The animation engine details remain private. Widgets and services
    interact only with this public API.

    Example:
        fade = FadeAnimation(widget, 0.0, 1.0)
        fade.duration = 300
        fade.start()
    """

    def __init__(self, name: str = "animation") -> None:
        """Create a new animation.

        Args:
            name: Human-readable identifier for this animation.
        """
        self._name = name
        self._duration = 300.0
        self._running = False
        self._started_callbacks: list[Callable] = []
        self._completed_callbacks: list[Callable] = []

    @property
    def name(self) -> str:
        """Human-readable identifier for this animation."""
        return self._name

    @property
    def duration(self) -> float:
        """Duration of the animation in milliseconds."""
        return self._duration

    @duration.setter
    def duration(self, value: float) -> None:
        if value <= 0:
            raise ValueError("Duration must be positive")
        self._duration = value

    @property
    def is_running(self) -> bool:
        """Whether this animation is currently running."""
        return self._running

    def start(self) -> None:
        """Start the animation from the beginning.

        If already running, this method has no effect.
        """
        if self._running:
            return
        self._running = True
        for callback in self._started_callbacks:
            callback()

    def stop(self) -> None:
        """Stop the animation at its current position."""
        if not self._running:
            return
        self._running = False

    def cancel(self) -> None:
        """Cancel the animation and reset progress."""
        self._running = False

    def complete(self) -> None:
        """Complete the animation immediately."""
        self._running = False
        for callback in self._completed_callbacks:
            callback()

    def connect(self, signal: str, callback: Callable) -> int:
        """Connect a signal handler.

        Args:
            signal: The signal name ("started", "completed", "cancelled").
            callback: The function to call.

        Returns:
            The handler ID.
        """
        if signal == "started":
            self._started_callbacks.append(callback)
            return len(self._started_callbacks) - 1
        elif signal == "completed":
            self._completed_callbacks.append(callback)
            return len(self._completed_callbacks) - 1
        return 0

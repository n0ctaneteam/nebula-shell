"""
Base service class for Nebula Shell.

Services own system state and expose it through properties,
signals, and methods. Widgets observe services but never
own system state themselves.
"""

from typing import Optional, Callable


class Service:
    """Base class for framework services.

    Services own system state and expose it through properties,
    signals, and methods. Widgets observe services but never
    own system state themselves.

    Properties represent state, signals represent changes, methods
    perform actions. Never confuse these responsibilities.

    Services must never:
    - Poll for state changes
    - Perform rendering
    - Own GTK objects
    - Spawn processes directly

    Example:
        battery = BatteryService.default()
        battery.percentage
        battery.charging
    """

    def __init__(self, name: str) -> None:
        """Create a new service.

        Args:
            name: Unique identifier for this service.
        """
        self._name = name
        self._initialized = False

    @property
    def name(self) -> str:
        """Unique name for this service."""
        return self._name

    @property
    def is_initialized(self) -> bool:
        """Whether this service has been initialized."""
        return self._initialized

    def initialize(self) -> None:
        """Initialize the service.

        Heavy initialization belongs here, not in constructors.
        """
        if self._initialized:
            return
        self.on_initialize()
        self._initialized = True

    def shutdown(self) -> None:
        """Shut down the service.

        Must mirror initialize() in reverse order.
        """
        if not self._initialized:
            return
        self.on_shutdown()
        self._initialized = False

    def reload(self) -> None:
        """Reload the service's state without full restart."""
        if not self._initialized:
            return
        self.on_reload()

    def on_initialize(self) -> None:
        """Called during initialization.

        Subclasses override this to set up their resources.
        """

    def on_shutdown(self) -> None:
        """Called during shutdown.

        Subclasses override this to release their resources.
        """

    def on_reload(self) -> None:
        """Called during reload.

        Subclasses override this to refresh their state.
        """

    def connect(self, signal: str, callback: Callable) -> int:
        """Connect a signal handler.

        Args:
            signal: The signal name to connect to.
            callback: The function to call when the signal is emitted.

        Returns:
            The handler ID.
        """
        return 0

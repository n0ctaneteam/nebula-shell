"""
Battery service for Nebula Shell.

Provides battery state information including percentage, charging status,
and time remaining.
"""

from typing import Optional

from nebula_shell.services.service import Service


class BatteryService(Service):
    """Service providing battery state information.

    Example:
        battery = BatteryService.default()
        print(f"Battery: {battery.percentage}%")
        print(f"Charging: {battery.charging}")
    """

    _instance: Optional["BatteryService"] = None

    def __init__(self) -> None:
        """Create a new battery service."""
        super().__init__("battery")
        self._percentage = 0
        self._charging = False

    @classmethod
    def default(cls) -> "BatteryService":
        """Get the default battery service instance.

        Returns:
            The singleton battery service.
        """
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    @property
    def percentage(self) -> int:
        """Battery charge percentage (0-100)."""
        return self._percentage

    @property
    def charging(self) -> bool:
        """Whether the battery is currently charging."""
        return self._charging

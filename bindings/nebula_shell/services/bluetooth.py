"""
Bluetooth service for Nebula Shell.

Provides bluetooth state information including adapter status
and connected devices.
"""

from typing import Optional

from nebula_shell.services.service import Service


class BluetoothService(Service):
    """Service providing bluetooth state information.

    Example:
        bt = BluetoothService.default()
        print(f"Enabled: {bt.enabled}")
    """

    _instance: Optional["BluetoothService"] = None

    def __init__(self) -> None:
        """Create a new bluetooth service."""
        super().__init__("bluetooth")
        self._enabled = False

    @classmethod
    def default(cls) -> "BluetoothService":
        """Get the default bluetooth service instance.

        Returns:
            The singleton bluetooth service.
        """
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    @property
    def enabled(self) -> bool:
        """Whether bluetooth is enabled."""
        return self._enabled

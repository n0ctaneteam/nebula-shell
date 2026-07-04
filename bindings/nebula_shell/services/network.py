"""
Network service for Nebula Shell.

Provides network state information including connection status,
SSID, and signal strength.
"""

from typing import Optional

from nebula_shell.services.service import Service


class NetworkService(Service):
    """Service providing network state information.

    Example:
        net = NetworkService.default()
        print(f"Connected: {net.connected}")
        print(f"SSID: {net.ssid}")
    """

    _instance: Optional["NetworkService"] = None

    def __init__(self) -> None:
        """Create a new network service."""
        super().__init__("network")
        self._connected = False
        self._ssid = ""

    @classmethod
    def default(cls) -> "NetworkService":
        """Get the default network service instance.

        Returns:
            The singleton network service.
        """
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    @property
    def connected(self) -> bool:
        """Whether the network is connected."""
        return self._connected

    @property
    def ssid(self) -> str:
        """Current network SSID."""
        return self._ssid

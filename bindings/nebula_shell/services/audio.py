"""
Audio service for Nebula Shell.

Provides audio state information including volume, mute status,
and available sinks.
"""

from typing import Optional

from nebula_shell.services.service import Service


class AudioService(Service):
    """Service providing audio state information.

    Example:
        audio = AudioService.default()
        print(f"Volume: {audio.volume}%")
        print(f"Muted: {audio.muted}")
    """

    _instance: Optional["AudioService"] = None

    def __init__(self) -> None:
        """Create a new audio service."""
        super().__init__("audio")
        self._volume = 50
        self._muted = False

    @classmethod
    def default(cls) -> "AudioService":
        """Get the default audio service instance.

        Returns:
            The singleton audio service.
        """
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    @property
    def volume(self) -> int:
        """Audio volume level (0-100)."""
        return self._volume

    @volume.setter
    def volume(self, value: int) -> None:
        if 0 <= value <= 100:
            self._volume = value

    @property
    def muted(self) -> bool:
        """Whether audio is muted."""
        return self._muted

    @muted.setter
    def muted(self, value: bool) -> None:
        self._muted = value

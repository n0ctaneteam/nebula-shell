"""
Media service for Nebula Shell.

Provides media player state information including current track,
playback status, and player controls.
"""

from typing import Optional

from nebula_shell.services.service import Service


class MediaService(Service):
    """Service providing media player state information.

    Example:
        media = MediaService.default()
        print(f"Now playing: {media.title}")
        print(f"Artist: {media.artist}")
    """

    _instance: Optional["MediaService"] = None

    def __init__(self) -> None:
        """Create a new media service."""
        super().__init__("media")
        self._title = ""
        self._artist = ""
        self._playing = False

    @classmethod
    def default(cls) -> "MediaService":
        """Get the default media service instance.

        Returns:
            The singleton media service.
        """
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    @property
    def title(self) -> str:
        """Title of the currently playing track."""
        return self._title

    @property
    def artist(self) -> str:
        """Artist of the currently playing track."""
        return self._artist

    @property
    def playing(self) -> bool:
        """Whether media is currently playing."""
        return self._playing

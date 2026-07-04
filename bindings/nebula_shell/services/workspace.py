"""
Workspace service for Nebula Shell.

Provides workspace state information for Wayland compositors.
"""

from typing import Optional

from nebula_shell.services.service import Service


class WorkspaceService(Service):
    """Service providing workspace state information.

    Example:
        ws = WorkspaceService.default()
        print(f"Current workspace: {ws.current}")
    """

    _instance: Optional["WorkspaceService"] = None

    def __init__(self) -> None:
        """Create a new workspace service."""
        super().__init__("workspace")
        self._current = 1

    @classmethod
    def default(cls) -> "WorkspaceService":
        """Get the default workspace service instance.

        Returns:
            The singleton workspace service.
        """
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    @property
    def current(self) -> int:
        """Current workspace index."""
        return self._current

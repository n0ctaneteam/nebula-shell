"""
Plugin API for Nebula Shell.

Plugins extend the framework through public APIs only.
Plugins cannot modify internal runtime state directly.
"""

from enum import Enum
from typing import Optional


class PluginState(Enum):
    """Plugin lifecycle states."""
    LOADING = 0
    LOADED = 1
    ENABLED = 2
    DISABLED = 3
    UNLOADED = 4


class PluginInfo:
    """Metadata describing a plugin.

    PluginInfo is immutable and holds the static metadata
    declared by a plugin in its manifest.

    Example:
        info = PluginInfo(
            id="my-plugin",
            name="My Plugin",
            version="1.0.0",
            author="Author",
            description="A plugin",
            api_version=1,
        )
    """

    def __init__(
        self,
        id: str,
        name: str,
        version: str,
        author: str,
        description: str,
        api_version: int,
        dependencies: Optional[list[str]] = None,
    ) -> None:
        """Create plugin info from a set of metadata values.

        Args:
            id: Unique plugin identifier.
            name: Human-readable name.
            version: Semantic version string.
            author: Plugin author.
            description: Short description.
            api_version: Required API version.
            dependencies: List of required plugin IDs.
        """
        self._id = id
        self._name = name
        self._version = version
        self._author = author
        self._description = description
        self._api_version = api_version
        self._dependencies = dependencies or []

    @property
    def id(self) -> str:
        """Unique identifier for the plugin."""
        return self._id

    @property
    def name(self) -> str:
        """Human-readable name."""
        return self._name

    @property
    def version(self) -> str:
        """Semantic version string."""
        return self._version

    @property
    def author(self) -> str:
        """Plugin author or organization."""
        return self._author

    @property
    def description(self) -> str:
        """Short description of the plugin."""
        return self._description

    @property
    def api_version(self) -> int:
        """Required NebulaShell plugin API version."""
        return self._api_version

    @property
    def dependencies(self) -> list[str]:
        """List of plugin IDs this plugin depends on."""
        return list(self._dependencies)


class Plugin:
    """Interface for all NebulaShell plugins.

    Plugins extend the framework through public APIs only.
    Plugins cannot modify internal runtime state directly.

    Lifecycle:
        load() -> enable() -> disable() -> unload()

    Example:
        class MyPlugin(Plugin):
            def __init__(self):
                self._info = PluginInfo(
                    id="my-plugin",
                    name="My Plugin",
                    version="1.0.0",
                    author="Author",
                    description="A plugin",
                    api_version=1,
                )

            @property
            def info(self):
                return self._info

            def load(self):
                pass

            def enable(self):
                pass

            def disable(self):
                pass

            def unload(self):
                pass
    """

    def __init__(self) -> None:
        """Create a new plugin."""
        self._state = PluginState.UNLOADED
        self._info: Optional[PluginInfo] = None

    @property
    def info(self) -> Optional[PluginInfo]:
        """Metadata describing this plugin."""
        return self._info

    @property
    def state(self) -> PluginState:
        """Current plugin lifecycle state."""
        return self._state

    def load(self) -> None:
        """Initialize the plugin.

        Called when the plugin module is loaded.
        """
        self._state = PluginState.LOADED

    def enable(self) -> None:
        """Activate the plugin.

        Called after load() or when re-enabling a disabled plugin.
        """
        self._state = PluginState.ENABLED

    def disable(self) -> None:
        """Deactivate the plugin.

        Called before unload() or when temporarily disabling.
        """
        self._state = PluginState.DISABLED

    def unload(self) -> None:
        """Clean up and release all resources.

        Called when the plugin is being removed from memory.
        """
        self._state = PluginState.UNLOADED

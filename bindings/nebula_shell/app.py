"""
Application module for Nebula Shell.

Provides the Application class that owns the application lifecycle,
initializes the runtime, loads configuration and plugins, and starts
the event loop.
"""

from typing import Optional

from nebula_shell._gi import Application as _Application


class Application:
    """Main application class for Nebula Shell.

    Manages the application lifecycle including runtime initialization,
    configuration loading, plugin loading, and event loop startup.

    Example:
        app = Application()
        app.run()
    """

    def __init__(self) -> None:
        """Create a new Nebula Shell application."""
        self._app = _Application()

    def run(self, args: Optional[list] = None) -> int:
        """Start the application event loop.

        This initializes the runtime, loads configuration and plugins,
        creates windows, and enters the main GTK event loop.

        Args:
            args: Optional command line arguments. If None, uses sys.argv.

        Returns:
            Exit code from the application.
        """
        return self._app.run(args)

    def quit(self) -> None:
        """Quit the application immediately."""
        self._app.quit()

    def reload(self) -> None:
        """Reload the application configuration and plugins."""
        self._app.reload()

    @property
    def is_running(self) -> bool:
        """Whether the application is currently running."""
        return self._app.get_is_running()

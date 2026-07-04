"""
Logger utility for Nebula Shell.

Framework-wide logger with colored console output.
"""

from enum import Enum
from typing import Optional


class LogLevel(Enum):
    """Log levels for NebulaShell logging."""
    TRACE = 0
    DEBUG = 1
    INFO = 2
    WARNING = 3
    ERROR = 4
    FATAL = 5


class Logger:
    """Framework-wide logger with colored console output.

    Logger is a singleton that provides structured logging
    for NebulaShell internals and extensions.

    Logging is for developers. Users should not see debug logs.
    Use debug_mode to control visibility of trace and debug messages.

    Example:
        Logger.info("Application started")
        Logger.set_debug_mode(True)
        Logger.debug("Loading plugins")
    """

    _instance: Optional["Logger"] = None

    def __init__(self) -> None:
        """Create a new logger."""
        self._min_level = LogLevel.INFO
        self._debug_mode = False
        self._color_enabled = True

    @classmethod
    def default(cls) -> "Logger":
        """Get the default logger instance.

        Returns:
            The singleton logger.
        """
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    @property
    def min_level(self) -> LogLevel:
        """Minimum log level to display."""
        return self._min_level

    @min_level.setter
    def min_level(self, value: LogLevel) -> None:
        self._min_level = value

    @property
    def debug_mode(self) -> bool:
        """Debug mode toggle."""
        return self._debug_mode

    @debug_mode.setter
    def debug_mode(self, value: bool) -> None:
        self._debug_mode = value
        if value:
            self._min_level = LogLevel.TRACE
        else:
            self._min_level = LogLevel.INFO

    @property
    def color_enabled(self) -> bool:
        """Whether colored output is enabled."""
        return self._color_enabled

    @color_enabled.setter
    def color_enabled(self, value: bool) -> None:
        self._color_enabled = value

    def trace(self, message: str) -> None:
        """Log a trace message.

        Args:
            message: The message to log.
        """
        self._log(LogLevel.TRACE, message)

    def debug(self, message: str) -> None:
        """Log a debug message.

        Args:
            message: The message to log.
        """
        self._log(LogLevel.DEBUG, message)

    def info(self, message: str) -> None:
        """Log an info message.

        Args:
            message: The message to log.
        """
        self._log(LogLevel.INFO, message)

    def warning(self, message: str) -> None:
        """Log a warning message.

        Args:
            message: The message to log.
        """
        self._log(LogLevel.WARNING, message)

    def error(self, message: str) -> None:
        """Log an error message.

        Args:
            message: The message to log.
        """
        self._log(LogLevel.ERROR, message)

    def fatal(self, message: str) -> None:
        """Log a fatal message.

        Args:
            message: The message to log.
        """
        self._log(LogLevel.FATAL, message)

    def _log(self, level: LogLevel, message: str) -> None:
        if level.value < self._min_level.value:
            return
        print(f"[{level.name}] {message}")

    @staticmethod
    def trace_static(message: str) -> None:
        """Log a trace message using the default logger."""
        Logger.default().trace(message)

    @staticmethod
    def debug_static(message: str) -> None:
        """Log a debug message using the default logger."""
        Logger.default().debug(message)

    @staticmethod
    def info_static(message: str) -> None:
        """Log an info message using the default logger."""
        Logger.default().info(message)

    @staticmethod
    def warning_static(message: str) -> None:
        """Log a warning message using the default logger."""
        Logger.default().warning(message)

    @staticmethod
    def error_static(message: str) -> None:
        """Log an error message using the default logger."""
        Logger.default().error(message)

    @staticmethod
    def fatal_static(message: str) -> None:
        """Log a fatal message using the default logger."""
        Logger.default().fatal(message)

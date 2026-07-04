"""
Configuration class for Nebula Shell.

Config is an immutable snapshot of configuration values.
Configuration is Python-based. Users write Python scripts
that define their shell configuration.
"""

from typing import Any, Optional


class Config:
    """Configuration data class holding all loaded configuration values.

    Config is an immutable snapshot of the configuration state at a point
    in time. ConfigManager creates new Config instances when configuration
    is loaded or reloaded.

    Configuration is Python-based. Users write Python scripts that define
    their shell configuration. ConfigManager loads and executes these
    scripts, then stores the resulting values here.

    Example:
        config = Config()
        config.set("theme", "dark")
        theme = config.get_string("theme")
    """

    def __init__(self) -> None:
        """Create a new empty configuration."""
        self._values: dict[str, Any] = {}
        self._errors: dict[str, str] = {}

    def get_string(self, key: str) -> Optional[str]:
        """Get a string value by key path.

        Args:
            key: Dot-separated path to the value.

        Returns:
            The string value, or None if not found.
        """
        value = self._values.get(key)
        if isinstance(value, str):
            return value
        return None

    def get_int(self, key: str) -> int:
        """Get an integer value by key path.

        Args:
            key: Dot-separated path to the value.

        Returns:
            The integer value, or 0 if not found.
        """
        value = self._values.get(key)
        if isinstance(value, int):
            return value
        return 0

    def get_bool(self, key: str) -> bool:
        """Get a boolean value by key path.

        Args:
            key: Dot-separated path to the value.

        Returns:
            The boolean value, or False if not found.
        """
        value = self._values.get(key)
        if isinstance(value, bool):
            return value
        return False

    def get_double(self, key: str) -> float:
        """Get a double value by key path.

        Args:
            key: Dot-separated path to the value.

        Returns:
            The double value, or 0.0 if not found.
        """
        value = self._values.get(key)
        if isinstance(value, (int, float)):
            return float(value)
        return 0.0

    def get(self, key: str, default: Any = None) -> Any:
        """Get a value by key path.

        Args:
            key: Dot-separated path to the value.
            default: Default value if not found.

        Returns:
            The value, or default if not found.
        """
        return self._values.get(key, default)

    def set(self, key: str, value: Any) -> None:
        """Set a value by key path.

        Args:
            key: Dot-separated path to the value.
            value: The value to store.
        """
        self._values[key] = value

    def has(self, key: str) -> bool:
        """Check if a key exists in the configuration.

        Args:
            key: The key to check.

        Returns:
            True if the key exists.
        """
        return key in self._values

    @property
    def keys(self) -> list[str]:
        """Get all configuration keys."""
        return list(self._values.keys())

    @property
    def size(self) -> int:
        """Get the number of configuration values."""
        return len(self._values)

    @property
    def has_errors(self) -> bool:
        """Check if the configuration has any errors."""
        return len(self._errors) > 0

    def add_error(self, key: str, message: str) -> None:
        """Add a validation error.

        Args:
            key: The key that caused the error.
            message: The error description.
        """
        self._errors[key] = message

    def get_errors(self) -> dict[str, str]:
        """Get all validation errors.

        Returns:
            A dictionary of key-error pairs.
        """
        return dict(self._errors)

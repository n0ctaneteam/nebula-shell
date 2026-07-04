"""
Icon widget class for Nebula Shell.

Icon displays an icon from a named icon or file.
"""

from typing import Optional

from nebula_shell._gi import Widget as _GIWidget
from nebula_shell.ui.widget import Widget


class Icon(Widget):
    """A widget that displays an icon.

    Icon can display icons from named icons or image files.

    Example:
        icon = Icon("network-wireless")
        icon.pixel_size = 24
    """

    def __init__(self, icon_name: str = "", name: Optional[str] = None) -> None:
        """Create a new icon.

        Args:
            icon_name: The icon name or path to display.
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._widget = _GIWidget()
        self._icon_name = icon_name
        self._pixel_size = 16

    @property
    def icon_name(self) -> str:
        """The icon name displayed."""
        return self._icon_name

    @icon_name.setter
    def icon_name(self, value: str) -> None:
        self._icon_name = value

    @property
    def pixel_size(self) -> int:
        """The size of the icon in pixels."""
        return self._pixel_size

    @pixel_size.setter
    def pixel_size(self, value: int) -> None:
        self._pixel_size = value

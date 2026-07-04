"""
Image widget class for Nebula Shell.

Image displays an image from a file or resource.
"""

from typing import Optional

from nebula_shell._gi import Widget as _GIWidget
from nebula_shell.ui.widget import Widget


class Image(Widget):
    """A widget that displays an image.

    Image can display images from files or resources.

    Example:
        image = Image("/path/to/image.png")
        image.pixel_size = 64
    """

    def __init__(self, path: str = "", name: Optional[str] = None) -> None:
        """Create a new image.

        Args:
            path: The file path or resource path of the image.
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._widget = _GIWidget()
        self._path = path
        self._pixel_size = -1

    @property
    def path(self) -> str:
        """The path of the displayed image."""
        return self._path

    @path.setter
    def path(self, value: str) -> None:
        self._path = value

    @property
    def pixel_size(self) -> int:
        """The size of the image in pixels. -1 means natural size."""
        return self._pixel_size

    @pixel_size.setter
    def pixel_size(self, value: int) -> None:
        self._pixel_size = value

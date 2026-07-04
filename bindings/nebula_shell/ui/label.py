"""
Label widget class for Nebula Shell.

Label renders a single line or multi-line text string.
It supports text content, font styling, alignment, and wrapping.
"""

from typing import Optional

from nebula_shell.ui.widget import Widget


class Label(Widget):
    """Label widget for displaying text.

    Label renders a single line or multi-line text string.
    It supports text content, font styling, alignment, and wrapping.

    Label is a leaf widget and does not accept children.

    Example:
        label = Label("Hello, World!")
        label.text = "Updated text"
        label.wrap = True
    """

    def __init__(self, text: str = "", name: Optional[str] = None) -> None:
        """Create a new label.

        Args:
            text: The initial text content. Default is empty.
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._text = text
        self._wrap = False
        self._max_width = -1
        self._xalign = "start"

    @property
    def text(self) -> str:
        """The text content displayed by this label."""
        return self._text

    @text.setter
    def text(self, value: str) -> None:
        if self._text == value:
            return
        self._text = value
        if self._widget is not None:
            self._widget.set_property("text", value)

    @property
    def wrap(self) -> bool:
        """Whether the label text wraps to multiple lines."""
        return self._wrap

    @wrap.setter
    def wrap(self, value: bool) -> None:
        self._wrap = value

    @property
    def max_width(self) -> int:
        """Maximum width in pixels before text wraps.

        Only effective when wrap is True.
        A value of -1 means no limit.
        """
        return self._max_width

    @max_width.setter
    def max_width(self, value: int) -> None:
        self._max_width = value

    @property
    def xalign(self) -> str:
        """Horizontal alignment of the label text.

        Valid values: "start", "center", "end".
        """
        return self._xalign

    @xalign.setter
    def xalign(self, value: str) -> None:
        if value not in ("start", "center", "end"):
            raise ValueError(f"Invalid xalign value: {value}")
        self._xalign = value

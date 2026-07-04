"""
Label widget class for Nebula Shell.

Label renders a single line or multi-line text string.
It supports text content, font styling, alignment, and wrapping.
"""

from typing import Optional

from nebula_shell._gi import Label as _GILabel
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
        self._widget = _GILabel(text=text)
        self._text = text

    @property
    def text(self) -> str:
        """The text content displayed by this label."""
        return self._widget.get_property("text")

    @text.setter
    def text(self, value: str) -> None:
        if self._text == value:
            return
        self._text = value
        self._widget.set_property("text", value)

    @property
    def wrap(self) -> bool:
        """Whether the label text wraps to multiple lines."""
        return self._widget.get_wrap()

    @wrap.setter
    def wrap(self, value: bool) -> None:
        self._widget.set_wrap(value)

    @property
    def max_width(self) -> int:
        """Maximum width in pixels before text wraps.

        Only effective when wrap is True.
        A value of -1 means no limit.
        """
        return self._widget.get_max_width_chars()

    @max_width.setter
    def max_width(self, value: int) -> None:
        self._widget.set_max_width_chars(value)

    @property
    def xalign(self) -> str:
        """Horizontal alignment of the label text.

        Valid values: "start", "center", "end".
        """
        align = self._widget.get_xalign()
        if align <= 0.25:
            return "start"
        elif align <= 0.75:
            return "center"
        else:
            return "end"

    @xalign.setter
    def xalign(self, value: str) -> None:
        if value not in ("start", "center", "end"):
            raise ValueError(f"Invalid xalign value: {value}")
        align_map = {"start": 0.0, "center": 0.5, "end": 1.0}
        self._widget.set_xalign(align_map[value])

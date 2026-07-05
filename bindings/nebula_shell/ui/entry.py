"""
Entry widget class for Nebula Shell.

Entry is a single-line text input field.
"""

from typing import Optional

from nebula_shell._gi import Entry as _GIEntry
from nebula_shell.ui.widget import Widget


class Entry(Widget):
    """A single-line text input widget.

    Entry allows users to input and edit text.

    Example:
        entry = Entry()
        entry.text = "Hello"
        entry.placeholder = "Type here..."
    """

    def __init__(self, text: str = "", name: Optional[str] = None) -> None:
        """Create a new entry.

        Args:
            text: The initial text content.
            name: Optional human-readable identifier.
        """
        super().__init__()
        self._widget = _GIEntry()
        self._widget.set_text(text)
        if name is not None:
            self._widget.set_name(name)

    @property
    def text(self) -> str:
        """The current text content."""
        return self._widget.get_text()

    @text.setter
    def text(self, value: str) -> None:
        self._widget.set_text(value)

    @property
    def placeholder(self) -> str:
        """Placeholder text shown when entry is empty."""
        return self._widget.get_placeholder()

    @placeholder.setter
    def placeholder(self, value: str) -> None:
        self._widget.set_placeholder(value)


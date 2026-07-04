"""
Entry widget class for Nebula Shell.

Entry is a single-line text input field.
"""

from typing import Optional, Callable

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
        super().__init__(name)
        self._widget = _GIEntry(text=text)
        self._text = text
        self._placeholder = ""

    @property
    def text(self) -> str:
        """The current text content."""
        return self._widget.get_text()

    @text.setter
    def text(self, value: str) -> None:
        self._text = value
        self._widget.set_text(value)

    @property
    def placeholder(self) -> str:
        """Placeholder text shown when entry is empty."""
        return self._placeholder

    @placeholder.setter
    def placeholder(self, value: str) -> None:
        self._placeholder = value

    def select_all(self) -> None:
        """Select all text in the entry."""
        self._widget.select_region(0, -1)

    def delete_selection(self) -> None:
        """Delete the selected text."""
        self._widget.delete_selection()

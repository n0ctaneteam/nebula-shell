"""
Button widget class for Nebula Shell.

Button renders a clickable element that can contain a child widget.
It emits a signal when pressed, enabling user interaction.
"""

from typing import Optional

from nebula_shell._gi import Button as _GIButton
from nebula_shell.ui.widget import Widget


class Button(Widget):
    """Button widget with click handling.

    Button renders a clickable element that can contain a child widget.
    It emits a signal when pressed, enabling user interaction.

    Button is a container widget that accepts a single child.

    Example:
        button = Button("Click me")
        button.clicked.connect(lambda: print("Pressed!"))
    """

    def __init__(self, label: str = "", name: Optional[str] = None) -> None:
        """Create a new button.

        Args:
            label: Optional text label for the button.
            name: Optional human-readable identifier.
        """
        super().__init__()
        self._widget = _GIButton()
        self._widget.set_label_text(label)
        if name is not None:
            self._widget.set_name(name)
        self._label_text = label

    @property
    def label_text(self) -> str:
        """Convenience text label for the button."""
        return self._widget.get_label_text()

    @label_text.setter
    def label_text(self, value: str) -> None:
        self._label_text = value
        self._widget.set_label_text(value)

    @property
    def enabled(self) -> bool:
        """Whether the button is enabled and can be clicked."""
        return self._widget.get_enabled()

    @enabled.setter
    def enabled(self, value: bool) -> None:
        self._widget.set_enabled(value)

    def press(self) -> None:
        """Emit the clicked signal.

        Only emits if the button is enabled.
        """
        if not self.enabled:
            return
        self._widget.emit("clicked")

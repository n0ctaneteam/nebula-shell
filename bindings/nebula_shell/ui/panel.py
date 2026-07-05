"""
Panel widget class for Nebula Shell.

Panel is a concrete Window subclass for dock and panel windows.
It provides sensible defaults for panel use: anchored to top,
top layer, exclusive zone, no keyboard interaction.

Example:
    panel = Panel("top-bar")
    panel.height = 32
    panel.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT
    panel.append(Label("My Panel"))
    panel.show()
"""

from typing import Optional

from nebula_shell.ui.window import Window, Anchor, Layer, KeyboardMode, Monitor


class Panel(Window):
    """A panel window for docks, bars, and taskbars.

    Panel provides sensible defaults for panel use:
    - Anchored to the top edge
    - Uses the TOP layer
    - Has an exclusive zone
    - No keyboard interaction

    Example:
        panel = Panel("top-bar")
        panel.height = 32
        panel.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT
        panel.append(Label("My Panel"))
        panel.show()
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new panel.

        Args:
            name: Optional human-readable identifier for this panel.
        """
        super().__init__(name)
        self.anchor = Anchor.TOP
        self.layer = Layer.TOP
        self.exclusive = True
        self.height = 32
        self.keyboard_mode = KeyboardMode.NONE

    @property
    def children(self) -> list:
        """List of child widgets in this panel."""
        return list(self._children)

    def append(self, child) -> None:
        """Append a child widget to the panel.

        Args:
            child: The widget to append.
        """
        self._children.append(child)

    def prepend(self, child) -> None:
        """Prepend a child widget to the panel.

        Args:
            child: The widget to prepend.
        """
        self._children.insert(0, child)

    def remove(self, child) -> None:
        """Remove a child widget from the panel.

        Args:
            child: The widget to remove.
        """
        if child in self._children:
            self._children.remove(child)

    def clear(self) -> None:
        """Remove all children from the panel."""
        self._children.clear()

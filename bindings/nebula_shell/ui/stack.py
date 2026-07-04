"""
Stack widget class for Nebula Shell.

Stack shows one child at a time, switching between them.
"""

from typing import Optional

from nebula_shell.ui.container import Container


class Stack(Container):
    """A container that shows one child at a time.

    Stack manages a collection of children but only displays
    one at a time. Use visible_child to switch which child
    is currently shown.

    Example:
        stack = Stack()
        stack.append(page1)
        stack.append(page2)
        stack.visible_child = page2
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new stack.

        Args:
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._visible_child_index = 0

    @property
    def visible_child_index(self) -> int:
        """Index of the currently visible child."""
        return self._visible_child_index

    @visible_child_index.setter
    def visible_child_index(self, value: int) -> None:
        self._visible_child_index = value

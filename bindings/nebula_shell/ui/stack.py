"""
Stack widget class for Nebula Shell.

Stack shows one child at a time, switching between them.
"""

from typing import Optional

from nebula_shell._gi import Stack as _GIStack
from nebula_shell.ui.container import Container


class Stack(Container):
    """A container that shows one child at a time.

    Stack manages a collection of children but only displays
    one at a time. Use visible_child_index or visible_child_name
    to switch which child is currently shown.

    Example:
        stack = Stack()
        stack.append(page1)
        stack.append(page2)
        stack.visible_child_index = 1
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new stack.

        Args:
            name: Optional human-readable identifier.
        """
        super().__init__()
        self._widget = _GIStack()
        if name is not None:
            self._widget.set_name(name)

    @property
    def visible_child_index(self) -> int:
        """Index of the currently visible child."""
        return self._widget.get_visible_child_index()

    @visible_child_index.setter
    def visible_child_index(self, value: int) -> None:
        self._widget.set_visible_child_index(value)

    @property
    def visible_child_name(self) -> str:
        """Name of the currently visible child."""
        return self._widget.get_visible_child_name()

    @visible_child_name.setter
    def visible_child_name(self, value: str) -> None:
        self._widget.set_visible_child_name(value)

    @property
    def animate_transitions(self) -> bool:
        """Whether transitions between children are animated."""
        return self._widget.get_animate_transitions()

    @animate_transitions.setter
    def animate_transitions(self, value: bool) -> None:
        self._widget.set_animate_transitions(value)

    def get_visible_child(self) -> Optional['Widget']:
        """Get the currently visible child widget.

        Returns:
            The visible child, or None if empty.
        """
        from nebula_shell.ui.container import _wrap_widget
        child = self._widget.get_visible_child()
        if child is not None:
            return _wrap_widget(child)
        return None

    def set_visible_child(self, child) -> None:
        """Set the visible child by widget reference.

        Args:
            child: The widget to make visible.
        """
        self._widget.set_visible_child(child._widget)

    def add_named(self, name: str, child) -> None:
        """Add a named child to the stack.

        Convenience method that sets the child name
        before appending.

        Args:
            name: The name to assign to the child.
            child: The widget to add.
        """
        self._widget.add_named(name, child._widget)
        child.name = name

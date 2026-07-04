"""
Stack widget class for Nebula Shell.

Stack shows one child at a time, switching between them.
"""

from typing import Optional

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
        super().__init__(name)
        self._visible_child_index = 0
        self._visible_child_name = ""
        self._animate_transitions = True

    @property
    def visible_child_index(self) -> int:
        """Index of the currently visible child."""
        return self._visible_child_index

    @visible_child_index.setter
    def visible_child_index(self, value: int) -> None:
        if value < 0 or value >= self.child_count:
            return
        if self._visible_child_index == value:
            return
        self._visible_child_index = value

    @property
    def visible_child_name(self) -> str:
        """Name of the currently visible child."""
        return self._visible_child_name

    @visible_child_name.setter
    def visible_child_name(self, value: str) -> None:
        self._visible_child_name = value
        for i, child in enumerate(self):
            if child.name == value:
                self.visible_child_index = i
                return

    @property
    def animate_transitions(self) -> bool:
        """Whether transitions between children are animated."""
        return self._animate_transitions

    @animate_transitions.setter
    def animate_transitions(self, value: bool) -> None:
        self._animate_transitions = value

    def get_visible_child(self):
        """Get the currently visible child widget.

        Returns:
            The visible child, or None if empty.
        """
        if self._visible_child_index < self.child_count:
            children = list(self)
            return children[self._visible_child_index]
        return None

    def set_visible_child(self, child) -> None:
        """Set the visible child by widget reference.

        Args:
            child: The widget to make visible.
        """
        for i, c in enumerate(self):
            if c is child:
                self.visible_child_index = i
                return

    def add_named(self, name: str, child) -> None:
        """Add a named child to the stack.

        Convenience method that sets the child name
        before appending.

        Args:
            name: The name to assign to the child.
            child: The widget to add.
        """
        child._name = name
        self.append(child)

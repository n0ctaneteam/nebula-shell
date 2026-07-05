"""
Container widget class for Nebula Shell.

Container extends Widget to provide child management.
It manages the lifecycle of child widgets: append, prepend, remove, and clear.
"""

from typing import Optional, Iterator

from nebula_shell._gi import Container as _GIContainer
from nebula_shell.ui.widget import Widget


class Container(Widget):
    """A widget that contains child widgets.

    Container extends Widget to provide child management.
    It manages the lifecycle of child widgets: append, prepend,
    remove, and clear.

    Containers own their children. When a container is destroyed,
    all its children are destroyed as well.

    Example:
        container = Container()
        container.append(Label("First"))
        container.append(Label("Second"))
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new container.

        Args:
            name: Optional human-readable identifier for this container.
        """
        self._widget = _GIContainer()
        self._name: Optional[str] = name
        if name is not None:
            self._widget.set_name(name)

    def append(self, child: Widget) -> None:
        """Append a child widget to the end.

        The child is added after all existing children.
        If the child already has a parent, it is removed first.

        Args:
            child: The widget to append.
        """
        self._widget.append(child._widget)

    def prepend(self, child: Widget) -> None:
        """Prepend a child widget to the beginning.

        The child is added before all existing children.
        If the child already has a parent, it is removed first.

        Args:
            child: The widget to prepend.
        """
        self._widget.prepend(child._widget)

    def remove(self, child: Widget) -> None:
        """Remove a child widget from this container.

        The child is detached and its parent is cleared.
        Does nothing if the child is not in this container.

        Args:
            child: The widget to remove.
        """
        self._widget.remove(child._widget)

    def clear(self) -> None:
        """Remove all children from this container.

        Each child's parent is cleared.
        """
        self._widget.clear()

    @property
    def child_count(self) -> int:
        """The number of children in this container."""
        return self._widget.get_child_count()

    def __iter__(self) -> Iterator[Widget]:
        """Iterate over children.

        Yields:
            Child widgets in order.
        """
        children = self._widget.get_children()
        for child in children:
            yield _wrap_widget(child)

    def __len__(self) -> int:
        """Get the number of children."""
        return self.child_count


_TYPE_MAP = None

def _get_type_map():
    global _TYPE_MAP
    if _TYPE_MAP is not None:
        return _TYPE_MAP
    from nebula_shell.ui.label import Label
    from nebula_shell.ui.button import Button
    from nebula_shell.ui.box import Box
    from nebula_shell.ui.overlay import Overlay
    from nebula_shell.ui.stack import Stack
    from nebula_shell.ui.grid import Grid
    from nebula_shell.ui.separator import Separator
    from nebula_shell.ui.spacer import Spacer
    from nebula_shell.ui.icon import Icon
    from nebula_shell.ui.image import Image
    from nebula_shell.ui.entry import Entry
    _TYPE_MAP = {
        "NebulaShellLabel": Label,
        "NebulaShellButton": Button,
        "NebulaShellBox": Box,
        "NebulaShellOverlay": Overlay,
        "NebulaShellStack": Stack,
        "NebulaShellGrid": Grid,
        "NebulaShellSeparator": Separator,
        "NebulaShellSpacer": Spacer,
        "NebulaShellIcon": Icon,
        "NebulaShellImage": Image,
        "NebulaShellEntry": Entry,
        "NebulaShellContainer": Container,
        "NebulaShellWidget": Widget,
    }
    return _TYPE_MAP


def _wrap_widget(gi_widget) -> Widget:
    """Wrap a GI widget object in the appropriate Python wrapper.

    Args:
        gi_widget: The GI widget object.

    Returns:
        The wrapped widget.
    """
    type_name = gi_widget.get_type().name
    type_map = _get_type_map()
    wrapper_class = type_map.get(type_name, Widget)
    wrapper = wrapper_class.__new__(wrapper_class)
    wrapper._widget = gi_widget
    return wrapper

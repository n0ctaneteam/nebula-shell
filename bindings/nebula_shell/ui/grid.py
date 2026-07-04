"""
Grid widget class for Nebula Shell.

Grid arranges children in a two-dimensional grid.
"""

from typing import Optional

from nebula_shell.ui.container import Container


class Grid(Container):
    """A container that arranges children in a two-dimensional grid.

    Grid places children in rows and columns.

    Example:
        grid = Grid()
        grid.append(label1)
        grid.append(label2)
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new grid.

        Args:
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._column_spacing = 0
        self._row_spacing = 0

    @property
    def column_spacing(self) -> int:
        """Spacing between columns in logical pixels."""
        return self._column_spacing

    @column_spacing.setter
    def column_spacing(self, value: int) -> None:
        self._column_spacing = value

    @property
    def row_spacing(self) -> int:
        """Spacing between rows in logical pixels."""
        return self._row_spacing

    @row_spacing.setter
    def row_spacing(self, value: int) -> None:
        self._row_spacing = value

"""
Grid widget class for Nebula Shell.

Grid arranges children in a two-dimensional grid.
"""

from enum import Enum
from typing import Optional

from nebula_shell.ui.container import Container


class GridAlignment(Enum):
    """Alignment for grid children."""
    START = 0
    CENTER = 1
    END = 2
    FILL = 3


class Grid(Container):
    """A container that arranges children in a two-dimensional grid.

    Grid places children in rows and columns.

    Example:
        grid = Grid()
        grid.rows = 2
        grid.columns = 2
        grid.attach(label1, 0, 0)
        grid.attach(label2, 1, 0)
    """

    def __init__(self, name: Optional[str] = None) -> None:
        """Create a new grid.

        Args:
            name: Optional human-readable identifier.
        """
        super().__init__(name)
        self._rows = 1
        self._columns = 1
        self._row_spacing = 0
        self._column_spacing = 0
        self._row_alignment = GridAlignment.START
        self._column_alignment = GridAlignment.START

    @property
    def rows(self) -> int:
        """Number of rows in the grid."""
        return self._rows

    @rows.setter
    def rows(self, value: int) -> None:
        self._rows = value

    @property
    def columns(self) -> int:
        """Number of columns in the grid."""
        return self._columns

    @columns.setter
    def columns(self, value: int) -> None:
        self._columns = value

    @property
    def row_spacing(self) -> int:
        """Spacing between rows in logical pixels."""
        return self._row_spacing

    @row_spacing.setter
    def row_spacing(self, value: int) -> None:
        self._row_spacing = value

    @property
    def column_spacing(self) -> int:
        """Spacing between columns in logical pixels."""
        return self._column_spacing

    @column_spacing.setter
    def column_spacing(self, value: int) -> None:
        self._column_spacing = value

    @property
    def row_alignment(self) -> GridAlignment:
        """Vertical alignment of children within their cells."""
        return self._row_alignment

    @row_alignment.setter
    def row_alignment(self, value: GridAlignment) -> None:
        self._row_alignment = value

    @property
    def column_alignment(self) -> GridAlignment:
        """Horizontal alignment of children within their cells."""
        return self._column_alignment

    @column_alignment.setter
    def column_alignment(self, value: GridAlignment) -> None:
        self._column_alignment = value

    def attach(self, child, column: int, row: int) -> None:
        """Attach a child widget to a specific cell.

        The widget is placed at the given column and row.

        Args:
            child: The widget to place.
            column: The column index (0-based).
            row: The row index (0-based).
        """
        self.append(child)

"""
Grid widget class for Nebula Shell.

Grid arranges children in a two-dimensional grid.
"""

from enum import Enum
from typing import Optional

from nebula_shell._gi import Grid as _GIGrid
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
        super().__init__()
        self._widget = _GIGrid()
        if name is not None:
            self._widget.set_name(name)

    @property
    def rows(self) -> int:
        """Number of rows in the grid."""
        return self._widget.get_rows()

    @rows.setter
    def rows(self, value: int) -> None:
        self._widget.set_rows(value)

    @property
    def columns(self) -> int:
        """Number of columns in the grid."""
        return self._widget.get_columns()

    @columns.setter
    def columns(self, value: int) -> None:
        self._widget.set_columns(value)

    @property
    def row_spacing(self) -> int:
        """Spacing between rows in logical pixels."""
        return self._widget.get_row_spacing()

    @row_spacing.setter
    def row_spacing(self, value: int) -> None:
        self._widget.set_row_spacing(value)

    @property
    def column_spacing(self) -> int:
        """Spacing between columns in logical pixels."""
        return self._widget.get_column_spacing()

    @column_spacing.setter
    def column_spacing(self, value: int) -> None:
        self._widget.set_column_spacing(value)

    @property
    def row_alignment(self) -> GridAlignment:
        """Vertical alignment of children within their cells."""
        return GridAlignment(self._widget.get_row_alignment())

    @row_alignment.setter
    def row_alignment(self, value: GridAlignment) -> None:
        self._widget.set_row_alignment(value.value)

    @property
    def column_alignment(self) -> GridAlignment:
        """Horizontal alignment of children within their cells."""
        return GridAlignment(self._widget.get_column_alignment())

    @column_alignment.setter
    def column_alignment(self, value: GridAlignment) -> None:
        self._widget.set_column_alignment(value.value)

    def attach(self, child, column: int, row: int) -> None:
        """Attach a child widget to a specific cell.

        The widget is placed at the given column and row.

        Args:
            child: The widget to place.
            column: The column index (0-based).
            row: The row index (0-based).
        """
        self._widget.attach(child._widget, column, row)

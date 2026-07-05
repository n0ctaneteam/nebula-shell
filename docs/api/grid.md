# Grid

A container that arranges its child widgets in a rectangular grid with a configurable number of rows and columns. `Grid` allows precise placement of children at specific cell coordinates and is ideal for form layouts, dashboards, and tabular arrangements.

---

## Class Hierarchy

```
NebulaShell.Object
  └── NebulaShell.Widget
       └── NebulaShell.Container
            └── NebulaShell.Grid
```

Python alias: `nebula_shell.ui.grid.Grid`

---

## Enums

### `GridAlignment`

Controls how children are positioned within their grid cell along a given axis.

| Value    | Integer | Description                                        |
|----------|---------|----------------------------------------------------|
| `START`  | `0`     | Children are aligned to the start edge of the cell. |
| `CENTER` | `1`     | Children are centered within the cell.              |
| `END`    | `2`     | Children are aligned to the end edge of the cell.   |
| `FILL`   | `3`     | Children are stretched to fill the cell.            |

---

## Constructor

### `Grid(name=None)`

| Parameter | Type  | Default | Description                                               |
|-----------|-------|---------|-----------------------------------------------------------|
| `name`    | `str` | `None`  | Optional widget name for CSS styling and identification.  |

Creates an empty grid with a single row and a single column.

---

## Properties

| Property           | Type            | Default                | Description                                                  |
|--------------------|-----------------|------------------------|--------------------------------------------------------------|
| `rows`             | `int`           | `1`                    | Number of rows in the grid. Changing this reflows children.  |
| `columns`          | `int`           | `1`                    | Number of columns in the grid. Changing this reflows children. |
| `row_spacing`      | `int`           | `0`                    | Vertical spacing in pixels between rows.                     |
| `column_spacing`   | `int`           | `0`                    | Horizontal spacing in pixels between columns.                |
| `row_alignment`    | `GridAlignment` | `GridAlignment.START`  | Default alignment of children along the row axis.            |
| `column_alignment` | `GridAlignment` | `GridAlignment.START`  | Default alignment of children along the column axis.         |
| `child_count`      | `int`           | `0`                    | Read-only. Inherited from `Container`. Number of children.   |
| `visible`          | `bool`          | `True`                 | Inherited from `Widget`.                                     |
| `tooltip`          | `str`           | `""`                   | Inherited from `Widget`.                                     |
| `name`             | `str`           | `""`                   | Inherited from `Widget`.                                     |

---

## Methods

`Grid` defines one additional method beyond `Container`:

| Method     | Parameters                          | Returns  | Description                                           |
|------------|-------------------------------------|----------|-------------------------------------------------------|
| `attach()` | `child: Widget, column: int, row: int` | `None` | Places a child at the specified grid column and row.  |

Inherited from `Container`:

| Method      | Parameters               | Returns          | Description                                    |
|-------------|--------------------------|------------------|------------------------------------------------|
| `append()`  | `child: Widget`          | `None`           | Appends a child to the end of the grid.        |
| `prepend()` | `child: Widget`          | `None`           | Prepends a child to the beginning of the grid. |
| `remove()`  | `child: Widget`          | `None`           | Removes a child from the grid.                 |
| `clear()`   | —                        | `None`           | Removes all children from the grid.            |
| `__iter__()`| —                        | `Iterator[Widget]` | Iterates over all children.                  |
| `__len__()` | —                        | `int`            | Returns the number of children.                |

Inherited from `Widget`:

| Method      | Parameters | Returns  | Description                               |
|-------------|------------|----------|-------------------------------------------|
| `show()`    | —          | `None`   | Makes the grid visible.                   |
| `hide()`    | —          | `None`   | Hides the grid.                           |
| `destroy()` | —          | `None`   | Destroys the grid and its children.       |

---

## Signals

`Grid` inherits all signals from `Container` and `Widget`:

| Signal             | Parameters       | Description                                    |
|--------------------|------------------|------------------------------------------------|
| `child_added`      | `child: Widget`  | Emitted when a child is added.                 |
| `child_removed`    | `child: Widget`  | Emitted when a child is removed.               |
| `children_cleared` | —                | Emitted when all children are cleared.         |
| `shown`            | —                | Emitted when the grid becomes visible.         |
| `hidden`           | —                | Emitted when the grid is hidden.               |
| `destroyed`        | —                | Emitted just before the grid is destroyed.     |

---

## Example

```python
from nebula_shell.ui.grid import Grid, GridAlignment
from nebula_shell.ui.label import Label

# Create a 3x3 grid for a dashboard layout
grid = Grid(name="dashboard")
grid.rows = 3
grid.columns = 3
grid.row_spacing = 12
grid.column_spacing = 12
grid.row_alignment = GridAlignment.CENTER
grid.column_alignment = GridAlignment.FILL

# Place labels at specific positions
header = Label(text="Header")
grid.attach(header, column=0, row=0)

sidebar = Label(text="Sidebar")
grid.attach(sidebar, column=0, row=1)

content = Label(text="Main Content")
grid.attach(content, column=1, row=1)

footer = Label(text="Footer")
grid.attach(footer, column=0, row=2)

print(len(grid))  # 4

# Append adds to the next available cell
extra = Label(text="Extra")
grid.append(extra)

# Remove a widget and clear
grid.remove(sidebar)
grid.clear()
print(grid.child_count)  # 0
```


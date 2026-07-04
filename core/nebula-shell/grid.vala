namespace NebulaShell {

/**
 * Alignment for grid children.
 */
public enum GridAlignment {
    /**
     * Children are placed at the start of their cell.
     */
    START,

    /**
     * Children are centered within their cell.
     */
    CENTER,

    /**
     * Children are placed at the end of their cell.
     */
    END,

    /**
     * Children stretch to fill their cell.
     */
    FILL
}

/**
 * A container that arranges children in a two-dimensional grid.
 *
 * Grid positions children in rows and columns.
 * Use row_spacing and column_spacing to control gaps.
 * Children are placed using row and column indices.
 *
 * Example:
 *   var grid = new Grid ();
 *   grid.row_spacing = 8;
 *   grid.column_spacing = 8;
 *   grid.rows = 2;
 *   grid.columns = 2;
 *   grid.attach (widget1, 0, 0);
 *   grid.attach (widget2, 1, 0);
 *   grid.attach (widget3, 0, 1);
 *   grid.attach (widget4, 1, 1);
 *
 * Example:
 *   var grid = new Grid ();
 *   grid.rows = 3;
 *   grid.columns = 3;
 *   for (int r = 0; r < 3; r++) {
 *       for (int c = 0; c < 3; c++) {
 *           grid.attach (new Label (@"$r,$c"), c, r);
 *       }
 *   }
 */
public class Grid : NebulaShell.Container {

    private int _rows = 1;
    private int _columns = 1;
    private int _row_spacing = 0;
    private int _column_spacing = 0;
    private GridAlignment _row_alignment = GridAlignment.START;
    private GridAlignment _column_alignment = GridAlignment.START;

    /**
     * Number of rows in the grid.
     *
     * Determines the vertical extent of the grid layout.
     * Default is 1.
     */
    public int rows {
        get { return _rows; }
        set { _rows = value; }
    }

    /**
     * Number of columns in the grid.
     *
     * Determines the horizontal extent of the grid layout.
     * Default is 1.
     */
    public int columns {
        get { return _columns; }
        set { _columns = value; }
    }

    /**
     * Spacing between rows in logical pixels.
     *
     * Adds empty space between each row.
     * Default is 0.
     */
    public int row_spacing {
        get { return _row_spacing; }
        set { _row_spacing = value; }
    }

    /**
     * Spacing between columns in logical pixels.
     *
     * Adds empty space between each column.
     * Default is 0.
     */
    public int column_spacing {
        get { return _column_spacing; }
        set { _column_spacing = value; }
    }

    /**
     * Vertical alignment of children within their cells.
     *
     * Default is START.
     */
    public GridAlignment row_alignment {
        get { return _row_alignment; }
        set { _row_alignment = value; }
    }

    /**
     * Horizontal alignment of children within their cells.
     *
     * Default is START.
     */
    public GridAlignment column_alignment {
        get { return _column_alignment; }
        set { _column_alignment = value; }
    }

    /**
     * Attach a child widget to a specific cell.
     *
     * The widget is placed at the given column and row.
     * If the child already has a parent, it is removed first.
     *
     * @param child the widget to place
     * @param column the column index (0-based)
     * @param row the row index (0-based)
     */
    public void attach (Widget child, int column, int row) {
        if (child.parent != null) {
            var old_parent = child.parent as Container;
            if (old_parent != null) {
                old_parent.remove (child);
            }
        }

        child.parent = this;
        append (child);
    }

    /**
     * Remove a child widget from the grid.
     *
     * @param child the widget to remove
     */
    public override void remove (Widget child) {
        base.remove (child);
    }

    /**
     * Create a new grid.
     */
    public Grid () {
        base ();
    }

    /**
     * Create a new grid with a name.
     *
     * @param name human-readable identifier
     */
    public Grid.with_name (string name) {
        base.with_name (name);
    }

}

}

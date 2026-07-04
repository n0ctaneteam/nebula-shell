namespace NebulaShell {

/**
 * Separator widget for visual separation.
 *
 * Separator renders a line to visually divide UI sections.
 * It supports horizontal and vertical orientations.
 *
 * Separator is a leaf widget and does not accept children.
 *
 * Example:
 *   var sep = new Separator ();
 *   sep.orientation = Orientation.HORIZONTAL;
 *   sep.thickness = 1;
 */
public class Separator : NebulaShell.Widget {

    private Orientation _orientation = Orientation.HORIZONTAL;
    private int _thickness = 1;

    /**
     * The orientation of the separator line.
     *
     * HORIZONTAL draws a horizontal line.
     * VERTICAL draws a vertical line.
     * Default is HORIZONTAL.
     */
    public Orientation orientation {
        get { return _orientation; }
        set { _orientation = value; }
    }

    /**
     * The thickness of the separator line in logical pixels.
     *
     * Default is 1.
     */
    public int thickness {
        get { return _thickness; }
        set { _thickness = value; }
    }

    /**
     * Create a new horizontal separator.
     */
    public Separator () {
        base ();
    }

    /**
     * Create a new separator with a specific orientation.
     *
     * @param orientation the line direction
     */
    public Separator.with_orientation (Orientation orientation) {
        base ();
        _orientation = orientation;
    }

    /**
     * Create a new separator with orientation and thickness.
     *
     * @param orientation the line direction
     * @param thickness the line thickness in pixels
     */
    public Separator.with_orientation_and_thickness (Orientation orientation, int thickness) {
        base ();
        _orientation = orientation;
        _thickness = thickness;
    }

}

}

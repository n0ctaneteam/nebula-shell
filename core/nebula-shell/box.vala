namespace NebulaShell {

/**
 * Orientation for box layout direction.
 */
public enum Orientation {
    /**
     * Children are arranged horizontally (left to right).
     */
    HORIZONTAL,

    /**
     * Children are arranged vertically (top to bottom).
     */
    VERTICAL
}

/**
 * Alignment for child widgets within a box.
 */
public enum Alignment {
    /**
     * Children are packed at the start of the box.
     */
    START,

    /**
     * Children are centered within the box.
     */
    CENTER,

    /**
     * Children are packed at the end of the box.
     */
    END,

    /**
     * Children are stretched to fill available space.
     */
    FILL
}

/**
 * A container that arranges children in a single line.
 *
 * Box lays out children horizontally or vertically.
 * Use orientation to control the layout direction.
 * Use spacing to add gaps between children.
 * Use alignment to control how children are positioned.
 *
 * Example:
 *   var hbox = new Box ();
 *   hbox.orientation = Orientation.HORIZONTAL;
 *   hbox.spacing = 8;
 *   hbox.append (new Label ("Left"));
 *   hbox.append (new Label ("Right"));
 *
 * Example:
 *   var vbox = new Box ();
 *   vbox.orientation = Orientation.VERTICAL;
 *   vbox.spacing = 4;
 *   vbox.append (new Label ("Top"));
 *   vbox.append (new Label ("Bottom"));
 */
public class Box : NebulaShell.Container {

    private Orientation _orientation = Orientation.HORIZONTAL;
    private int _spacing = 0;
    private Alignment _alignment = Alignment.START;
    private int _homogeneous = 0;

    /**
     * The layout direction of this box.
     *
     * Determines whether children are arranged horizontally
     * or vertically. Default is HORIZONTAL.
     */
    public Orientation orientation {
        get { return _orientation; }
        set { _orientation = value; }
    }

    /**
     * Spacing between children in logical pixels.
     *
     * Adds empty space between each child widget.
     * Default is 0 (no spacing).
     */
    public int spacing {
        get { return _spacing; }
        set { _spacing = value; }
    }

    /**
     * Alignment of children within the box.
     *
     * Controls how children are positioned along the
     * cross axis. Default is START.
     */
    public Alignment alignment {
        get { return _alignment; }
        set { _alignment = value; }
    }

    /**
     * Whether children should have equal size.
     *
     * When non-zero, all children are given this fixed size
     * along the main axis. When 0, children use their natural size.
     * Default is 0.
     */
    public int homogeneous {
        get { return _homogeneous; }
        set { _homogeneous = value; }
    }

    /**
     * Create a new box with horizontal orientation.
     */
    public Box () {
        base ();
    }

    /**
     * Create a new box with specified orientation.
     *
     * @param orientation the layout direction
     */
    public Box.with_orientation (Orientation orientation) {
        base ();
        _orientation = orientation;
    }

    /**
     * Create a new box with a name and orientation.
     *
     * @param name human-readable identifier
     * @param orientation the layout direction
     */
    public Box.with_name_and_orientation (string name, Orientation orientation) {
        base.with_name (name);
        _orientation = orientation;
    }

}

}

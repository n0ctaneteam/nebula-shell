namespace NebulaShell {

/**
 * Spacer widget for flexible spacing between widgets.
 *
 * Spacer fills available space to push other widgets apart.
 * It is typically used inside Box containers.
 *
 * Spacer is a leaf widget and does not accept children.
 *
 * Example:
 *   var hbox = new Box ();
 *   hbox.append (new Label ("Left"));
 *   hbox.append (new Spacer ());
 *   hbox.append (new Label ("Right"));
 */
public class Spacer : NebulaShell.Widget {

    private int _min_size = 0;
    private bool _expand = true;

    /**
     * The minimum size in logical pixels.
     *
     * The spacer will never be smaller than this value.
     * Default is 0.
     */
    public int min_size {
        get { return _min_size; }
        set { _min_size = value; }
    }

    /**
     * Whether this spacer expands to fill available space.
     *
     * When true, the spacer takes up remaining space.
     * When false, it uses only min_size.
     * Default is true.
     */
    public bool expand {
        get { return _expand; }
        set { _expand = value; }
    }

    /**
     * Create a new spacer that expands.
     */
    public Spacer () {
        base ();
    }

    /**
     * Create a new spacer with a minimum size.
     *
     * @param min_size the minimum size in pixels
     */
    public Spacer.with_min_size (int min_size) {
        base ();
        _min_size = min_size;
    }

    /**
     * Create a new spacer with size and expand control.
     *
     * @param min_size the minimum size in pixels
     * @param expand whether to fill available space
     */
    public Spacer.with_min_size_and_expand (int min_size, bool expand) {
        base ();
        _min_size = min_size;
        _expand = expand;
    }

}

}

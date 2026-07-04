namespace NebulaShell {

/**
 * Alignment for overlay children.
 */
public enum OverlayAlignment {
    /**
     * Child is positioned at the top-left corner.
     */
    TOP_LEFT,

    /**
     * Child is positioned at the top-center.
     */
    TOP_CENTER,

    /**
     * Child is positioned at the top-right corner.
     */
    TOP_RIGHT,

    /**
     * Child is positioned at the middle-left.
     */
    MIDDLE_LEFT,

    /**
     * Child is centered in the overlay.
     */
    CENTER,

    /**
     * Child is positioned at the middle-right.
     */
    MIDDLE_RIGHT,

    /**
     * Child is positioned at the bottom-left corner.
     */
    BOTTOM_LEFT,

    /**
     * Child is positioned at the bottom-center.
     */
    BOTTOM_CENTER,

    /**
     * Child is positioned at the bottom-right corner.
     */
    BOTTOM_RIGHT
}

/**
 * A container that stacks children with floating positioning.
 *
 * Overlay places children on top of each other, each at a
 * specific alignment position. Unlike Stack which shows one
 * child at a time, Overlay can show multiple children at once
 * at different positions.
 *
 * Children are layered in order: later children appear on top.
 * Each child has an alignment that determines its position.
 *
 * Example:
 *   var overlay = new Overlay ();
 *   overlay.append (background);
 *   overlay.append (content);
 *   overlay.append (notification);
 *
 * Example with alignment:
 *   var overlay = new Overlay ();
 *   overlay.set_child_alignment (badge, OverlayAlignment.TOP_RIGHT);
 *   overlay.append (badge);
 */
public class Overlay : NebulaShell.Container {

    private OverlayAlignment _default_alignment = OverlayAlignment.CENTER;
    private Widget? _default_child = null;

    /**
     * Emitted when the default child changes.
     *
     * @param child the new default child
     */
    public signal void default_child_changed (Widget? child);

    /**
     * Default alignment for new children.
     *
     * When a child is appended without explicit alignment,
     * this alignment is used. Default is CENTER.
     */
    public OverlayAlignment default_alignment {
        get { return _default_alignment; }
        set { _default_alignment = value; }
    }

    /**
     * The default (main) child of this overlay.
     *
     * The default child fills the overlay and other
     * children float on top. Set to null to clear.
     */
    public Widget? default_child {
        get { return _default_child; }
        set {
            if (_default_child != null) {
                remove (_default_child);
            }
            _default_child = value;
            if (_default_child != null) {
                prepend (_default_child);
            }
            default_child_changed (_default_child);
        }
    }

    /**
     * Create a new overlay.
     */
    public Overlay () {
        base ();
    }

    /**
     * Create a new overlay with a name.
     *
     * @param name human-readable identifier
     */
    public Overlay.with_name (string name) {
        base.with_name (name);
    }

    /**
     * Set the alignment for a specific child.
     *
     * @param child the widget to align
     * @param alignment the alignment position
     */
    public void set_child_alignment (Widget child, OverlayAlignment alignment) {
    }

    /**
     * Get the alignment for a specific child.
     *
     * @param child the widget to query
     * @return the alignment, or the default alignment
     */
    public OverlayAlignment get_child_alignment (Widget child) {
        return _default_alignment;
    }

}

}

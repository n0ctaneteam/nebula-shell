namespace NebulaShell {

/**
 * Defines screen edge anchor positions.
 *
 * Anchors determine where a window is attached to the screen edges.
 * Multiple anchors can be combined to anchor to corners or fill edges.
 *
 * Example:
 *   panel.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT;
 */
[Flags]
public enum Anchor {

    /**
     * No anchor. Window is floating.
     */
    NONE = 0,

    /**
     * Anchor to the top edge of the screen.
     */
    TOP = 1 << 0,

    /**
     * Anchor to the bottom edge of the screen.
     */
    BOTTOM = 1 << 1,

    /**
     * Anchor to the left edge of the screen.
     */
    LEFT = 1 << 2,

    /**
     * Anchor to the right edge of the screen.
     */
    RIGHT = 1 << 3,

    /**
     * Anchor to all four edges. Window fills the screen.
     */
    ALL = TOP | BOTTOM | LEFT | RIGHT;

}

}

namespace NebulaShell {

/**
 * A desktop panel window.
 *
 * Panel is a concrete Window subclass designed for dock and panel
 * windows that reserve screen space and anchor to screen edges.
 *
 * Panel defaults to:
 * - Anchored to the top edge
 * - Layer TOP
 * - Exclusive screen space
 * - Height 32px
 *
 * Example:
 *   var panel = new Panel ();
 *   panel.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT;
 *   panel.height = 32;
 *   panel.show ();
 */
public class Panel : NebulaShell.Window {

    /**
     * Create a new panel.
     *
     * Defaults to top-anchored with exclusive zone.
     */
    public Panel () {
        base ("panel");
        this.anchor = Anchor.TOP;
        this.layer = Layer.TOP;
        this.exclusive = true;
        this.height = 32;
    }

    /**
     * Create a new panel with a name.
     *
     * @param name human-readable identifier
     */
    public Panel.with_name (string name) {
        base.with_name (name);
        this.anchor = Anchor.TOP;
        this.layer = Layer.TOP;
        this.exclusive = true;
        this.height = 32;
    }

}

}

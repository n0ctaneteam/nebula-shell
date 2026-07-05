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
     * Panel defaults applied during GObject construction.
     *
     * These values are stored in the Vala instance and applied
     * when show() is called (which triggers ensure_gtk_window + apply_layer_shell_config).
     */
    construct {
        this.anchor = Anchor.TOP;
        this.layer = Layer.TOP;
        this.exclusive = true;
        this.height = 32;
    }

}

}

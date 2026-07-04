namespace NebulaShell {

/**
 * Internal helper wrapping gtk4-layer-shell API.
 *
 * LayerShell encapsulates all layer shell configuration calls,
 * keeping gtk4-layer-shell as an internal implementation detail.
 * Users never interact with this class directly.
 *
 * This class is not public and may change at any time.
 */
internal class LayerShell {

    /**
     * Initialize layer shell for a window.
     *
     * Must be called before any other layer shell operations
     * on this window.
     *
     * @param window the GTK window to initialize
     */
    public static void init_for_window (Gtk.Window window) {
        GtkLayerShell.init_for_window (window);
    }

    /**
     * Set the layer shell layer for a window.
     *
     * @param window the GTK window
     * @param layer the NebulaShell layer to set
     */
    public static void set_layer (Gtk.Window window, Layer layer) {
        GtkLayerShell.set_layer (window, (GtkLayerShell.Layer) layer);
    }

    /**
     * Set anchor state for a single edge.
     *
     * @param window the GTK window
     * @param edge a single Anchor flag (TOP, BOTTOM, LEFT, or RIGHT)
     * @param anchored true to anchor to this edge
     */
    public static void set_anchor (Gtk.Window window, Anchor edge, bool anchored) {
        GtkLayerShell.Edge gtk_edge = anchor_to_edge (edge);
        GtkLayerShell.set_anchor (window, gtk_edge, anchored);
    }

    /**
     * Set exclusive zone size for a window.
     *
     * A positive value reserves that many pixels of screen space.
     * -1 means the zone is automatically calculated from window size.
     * 0 means no exclusive zone.
     *
     * @param window the GTK window
     * @param zone the exclusive zone size in pixels
     */
    public static void set_exclusive_zone (Gtk.Window window, int zone) {
        GtkLayerShell.set_exclusive_zone (window, zone);
    }

    /**
     * Set the keyboard interaction mode.
     *
     * @param window the GTK window
     * @param mode the keyboard mode to set
     */
    public static void set_keyboard_mode (Gtk.Window window, KeyboardMode mode) {
        GtkLayerShell.set_keyboard_mode (window, (GtkLayerShell.KeyboardMode) mode);
    }

    /**
     * Set the output monitor for a window.
     *
     * @param window the GTK window
     * @param monitor the GDK monitor to display on
     */
    public static void set_monitor (Gtk.Window window, Gdk.Monitor monitor) {
        GtkLayerShell.set_monitor (window, monitor);
    }

    /**
     * Set margin for a specific edge.
     *
     * @param window the GTK window
     * @param edge a single Anchor flag (TOP, BOTTOM, LEFT, or RIGHT)
     * @param margin margin size in logical pixels
     */
    public static void set_margin (Gtk.Window window, Anchor edge, int margin) {
        GtkLayerShell.Edge gtk_edge = anchor_to_edge (edge);
        GtkLayerShell.set_margin (window, gtk_edge, margin);
    }

    /**
     * Convert a single Anchor flag to a GtkLayerShell.Edge.
     *
     * @param edge a single Anchor flag
     * @return the corresponding GTK layer shell edge
     */
    private static GtkLayerShell.Edge anchor_to_edge (Anchor edge) {
        if ((edge & Anchor.TOP) != 0) return GtkLayerShell.Edge.TOP;
        if ((edge & Anchor.BOTTOM) != 0) return GtkLayerShell.Edge.BOTTOM;
        if ((edge & Anchor.LEFT) != 0) return GtkLayerShell.Edge.LEFT;
        if ((edge & Anchor.RIGHT) != 0) return GtkLayerShell.Edge.RIGHT;
        return GtkLayerShell.Edge.TOP;
    }

}

}

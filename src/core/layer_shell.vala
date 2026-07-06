namespace NebulaShell {
    public class LayerShell : Object {
        public static void init_window(Gtk.Window window, string anchor, bool exclusive = true) {
            GtkLayerShell.init_for_window(window);
            GtkLayerShell.set_namespace(window, "nebula-shell");

            switch (anchor.down()) {
                case "top":
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, true);
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.LEFT, true);
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.RIGHT, true);
                    GtkLayerShell.set_layer(window, GtkLayerShell.Layer.TOP);
                    break;
                case "bottom":
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.BOTTOM, true);
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.LEFT, true);
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.RIGHT, true);
                    GtkLayerShell.set_layer(window, GtkLayerShell.Layer.TOP);
                    break;
                case "left":
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.LEFT, true);
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, true);
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.BOTTOM, true);
                    GtkLayerShell.set_layer(window, GtkLayerShell.Layer.TOP);
                    break;
                case "right":
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.RIGHT, true);
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, true);
                    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.BOTTOM, true);
                    GtkLayerShell.set_layer(window, GtkLayerShell.Layer.TOP);
                    break;
            }

            if (exclusive) {
                GtkLayerShell.auto_exclusive_zone_enable(window);
            }
        }

        public static void set_exclusive(Gtk.Window window, bool enable) {
            if (enable) {
                GtkLayerShell.auto_exclusive_zone_enable(window);
            } else {
                GtkLayerShell.set_exclusive_zone(window, 0);
            }
        }
    }
}

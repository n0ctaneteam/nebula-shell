namespace NebulaShell {
    public class LayerShell : Object {
        public static bool init_window(Gtk.Window window, string[] anchors, bool exclusive = true,
            GtkLayerShell.Layer layer = GtkLayerShell.Layer.TOP) {
            if (!GtkLayerShell.is_supported()) {
                Logger.warning("Layer Shell protocol not supported by compositor. Widgets will not use layer-shell.");
                return false;
            }
            GtkLayerShell.init_for_window(window);
            GtkLayerShell.set_namespace(window, "nebula-shell");
            GtkLayerShell.set_layer(window, layer);

            bool any_anchor = false;
            foreach (var a in anchors) {
                switch (a.down()) {
                    case "top":
                        GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, true);
                        any_anchor = true;
                        break;
                    case "bottom":
                        GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.BOTTOM, true);
                        any_anchor = true;
                        break;
                    case "left":
                        GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.LEFT, true);
                        any_anchor = true;
                        break;
                    case "right":
                        GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.RIGHT, true);
                        any_anchor = true;
                        break;
                    case "center":
                        // No anchors — window floats centered
                        break;
                }
            }

            if (any_anchor && exclusive) {
                GtkLayerShell.auto_exclusive_zone_enable(window);
            } else if (any_anchor && !exclusive) {
                GtkLayerShell.set_exclusive_zone(window, 0);
            }

            return true;
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

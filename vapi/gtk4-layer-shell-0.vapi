[CCode (cprefix = "gtk_layer_", cheader_filename = "gtk4-layer-shell.h")]
namespace GtkLayerShell {
    [CCode (cname = "GtkLayerShellEdge")]
    public enum Edge {
        [CCode (cname = "GTK_LAYER_SHELL_EDGE_LEFT")]
        LEFT,
        [CCode (cname = "GTK_LAYER_SHELL_EDGE_RIGHT")]
        RIGHT,
        [CCode (cname = "GTK_LAYER_SHELL_EDGE_TOP")]
        TOP,
        [CCode (cname = "GTK_LAYER_SHELL_EDGE_BOTTOM")]
        BOTTOM
    }

    [CCode (cname = "GtkLayerShellLayer")]
    public enum Layer {
        [CCode (cname = "GTK_LAYER_SHELL_LAYER_BACKGROUND")]
        BACKGROUND,
        [CCode (cname = "GTK_LAYER_SHELL_LAYER_BOTTOM")]
        BOTTOM,
        [CCode (cname = "GTK_LAYER_SHELL_LAYER_TOP")]
        TOP,
        [CCode (cname = "GTK_LAYER_SHELL_LAYER_OVERLAY")]
        OVERLAY
    }

    [CCode (cname = "gtk_layer_is_supported")]
    public bool is_supported();

    [CCode (cname = "gtk_layer_init_for_window")]
    public void init_for_window(Gtk.Window window);

    [CCode (cname = "gtk_layer_set_anchor")]
    public void set_anchor(Gtk.Window window, Edge edge, bool anchor_to_edge);

    [CCode (cname = "gtk_layer_set_margin")]
    public void set_margin(Gtk.Window window, Edge edge, int margin);

    [CCode (cname = "gtk_layer_set_namespace")]
    public void set_namespace(Gtk.Window window, string ns);

    [CCode (cname = "gtk_layer_set_layer")]
    public void set_layer(Gtk.Window window, Layer layer);

    [CCode (cname = "gtk_layer_auto_exclusive_zone_enable")]
    public void auto_exclusive_zone_enable(Gtk.Window window);

    [CCode (cname = "gtk_layer_set_exclusive_zone")]
    public void set_exclusive_zone(Gtk.Window window, int zone);

    [CCode (cname = "gtk_layer_is_layer_window")]
    public bool is_layer_window(Gtk.Window window);
}

namespace NebulaShell {

/**
 * Provides widget inspection for development.
 *
 * WidgetInspector allows developers to examine the widget tree,
 * view widget properties, and debug layout issues. It traverses
 * the widget hierarchy and provides structured information
 * about each widget.
 *
 * WidgetInspector follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * Example:
 *   var inspector = WidgetInspector.get_default();
 *   inspector.initialize();
 *   var tree = inspector.inspect_root();
 *   inspector.print_tree(tree);
 */
public class WidgetInspector : GLib.Object, Manager {

    private static WidgetInspector? _instance = null;

    private bool _initialized;
    private Gee.ArrayList<Widget?> _inspected_widgets;

    /**
     * Signal emitted when a widget is inspected.
     *
     * @param widget the widget being inspected
     */
    public signal void widget_inspected (Widget widget);

    /**
     * Get the default WidgetInspector instance.
     *
     * @return the singleton widget inspector
     */
    public static WidgetInspector get_default () {
        if (_instance == null)
            _instance = new WidgetInspector ();

        return _instance;
    }

    /**
     * Create a new WidgetInspector instance.
     */
    public WidgetInspector () {
        _initialized = false;
        _inspected_widgets = new Gee.ArrayList<Widget?> ();
    }

    /**
     * Initialize the widget inspector.
     */
    public void initialize () {
        if (_initialized)
            return;

        Logger.info ("WidgetInspector: initializing");
        _initialized = true;
        Logger.info ("WidgetInspector: initialized");
    }

    /**
     * Shut down the widget inspector.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("WidgetInspector: shutting down");
        _inspected_widgets.clear ();
        _initialized = false;
        Logger.info ("WidgetInspector: shut down");
    }

    /**
     * Reload the widget inspector state.
     */
    public void reload () {
        if (!_initialized)
            return;

        Logger.info ("WidgetInspector: reloading");
        _inspected_widgets.clear ();
    }

    /**
     * Inspect a widget and collect its information.
     *
     * @param widget the widget to inspect
     * @return a string representation of the widget info
     */
    public string inspect_widget (Widget widget) {
        if (widget == null)
            return "(null)";

        widget_inspected (widget);

        var builder = new GLib.StringBuilder ();
        builder.append (get_widget_type_name (widget));
        builder.append (" {");

        string name = widget.name;
        if (name.length > 0) {
            builder.append (" name=\"");
            builder.append (name);
            builder.append ("\"");
        }

        string id = widget.get_id ();
        if (id.length > 0) {
            builder.append (" id=\"");
            builder.append (id);
            builder.append ("\"");
        }

        builder.append (" visible=");
        builder.append (widget.visible ? "true" : "false");

        string[] classes = widget.style_classes;
        if (classes.length > 0) {
            builder.append (" classes=[");
            for (int i = 0; i < classes.length; i++) {
                if (i > 0) builder.append (", ");
                builder.append (classes[i]);
            }
            builder.append ("]");
        }

        string inline_css = widget.get_inline_css ();
        if (inline_css.length > 0) {
            builder.append (" inline_css=\"");
            builder.append (inline_css);
            builder.append ("\"");
        }

        builder.append ("}");
        return builder.str;
    }

    /**
     * Inspect the widget tree starting from a root widget.
     *
     * @param root the root widget
     * @return the tree representation as a string
     */
    public string inspect_tree (Widget root) {
        if (root == null)
            return "(null)";

        var builder = new GLib.StringBuilder ();
        build_tree_string (root, builder, 0, true);
        return builder.str;
    }

    /**
     * Build a tree string representation recursively.
     *
     * @param widget the current widget
     * @param builder the string builder
     * @param depth the current depth
     * @param is_last whether this is the last child
     */
    private void build_tree_string (Widget widget, GLib.StringBuilder builder, int depth, bool is_last) {
        for (int i = 0; i < depth; i++) {
            builder.append (i == depth - 1 ? (is_last ? "└── " : "├── ") : "    ");
        }

        builder.append (inspect_widget (widget));
        builder.append ("\n");

        if (widget is Container) {
            var container = (Container) widget;
            var children = container.get_children ();
            for (int i = 0; i < children.length; i++) {
                var child = children[i];
                if (child != null) {
                    build_tree_string (child, builder, depth + 1, i == (int) children.length - 1);
                }
            }
        }
    }

    /**
     * Get a human-readable type name for a widget.
     *
     * @param widget the widget
     * @return the type name
     */
    private string get_widget_type_name (Widget widget) {
        var type = widget.get_type ();
        return type.name ();
    }

    /**
     * Find widgets matching a CSS class.
     *
     * @param root the root widget to search from
     * @param css_class the CSS class to match
     * @return a list of matching widgets
     */
    public Gee.List<Widget> find_by_class (Widget root, string css_class) {
        var results = new Gee.ArrayList<Widget> ();
        find_by_class_recursive (root, css_class, results);
        return results;
    }

    /**
     * Recursively find widgets matching a CSS class.
     *
     * @param widget the current widget
     * @param css_class the CSS class to match
     * @param results the results list
     */
    private void find_by_class_recursive (Widget widget, string css_class, Gee.ArrayList<Widget> results) {
        if (widget.has_style_class (css_class)) {
            results.add (widget);
        }

        if (widget is Container) {
            var container = (Container) widget;
            var children = container.get_children ();
            for (int i = 0; i < children.length; i++) {
                var child = children[i];
                if (child != null) {
                    find_by_class_recursive (child, css_class, results);
                }
            }
        }
    }

    /**
     * Find widgets matching a CSS ID.
     *
     * @param root the root widget to search from
     * @param id the CSS ID to match
     * @return the matching widget, or null if not found
     */
    public Widget? find_by_id (Widget root, string id) {
        if (root.get_id () == id)
            return root;

        if (root is Container) {
            var container = (Container) root;
            var children = container.get_children ();
            for (int i = 0; i < children.length; i++) {
                var child = children[i];
                if (child != null) {
                    var found = find_by_id (child, id);
                    if (found != null)
                        return found;
                }
            }
        }

        return null;
    }

}

}

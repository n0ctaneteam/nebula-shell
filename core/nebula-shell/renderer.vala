namespace NebulaShell {

/**
 * Converts NebulaShell widget trees to GTK widgets for display.
 *
 * Renderer walks the abstract NebulaShell widget hierarchy and
 * creates corresponding GTK4 widgets. Each NebulaShell widget
 * type maps to a specific GTK widget type:
 *
 *   Box     → GtkBox
 *   Label   → GtkLabel
 *   Button  → GtkButton
 *   Entry   → GtkEntry
 *   Icon    → GtkImage (from icon name)
 *   Image   → GtkImage (from file path)
 *   Separator → GtkSeparator
 *   Spacer  → GtkBox (expanding)
 *   Grid    → GtkGrid
 *   Stack   → GtkStack
 *   Overlay → GtkOverlay
 *
 * The renderer caches the mapping so that repeated calls
 * for the same widget return the same GTK widget.
 *
 * This is a render-once renderer. After initial render,
 * changes to NebulaShell properties do NOT automatically
 * update the GTK widgets. To reflect changes, call
 * clear_cache() and re-render the tree.
 *
 * Example:
 *   var renderer = new WidgetRenderer ();
 *   var gtk_widget = renderer.render (my_box);
 *   gtk_window.set_child (gtk_widget);
 */
public class WidgetRenderer : NebulaShell.Object {

    private Gee.HashMap<void*, Gtk.Widget> _widget_cache;
    private Gee.HashMap<string, Gtk.CssProvider> _css_cache;
    private Gee.HashMap<Gtk.Entry, bool> _syncing_entries;

    /**
     * Create a new widget renderer.
     */
    public WidgetRenderer () {
        base.with_name ("widget-renderer");
        _widget_cache = new Gee.HashMap<void*, Gtk.Widget> ();
        _css_cache = new Gee.HashMap<string, Gtk.CssProvider> ();
        _syncing_entries = new Gee.HashMap<Gtk.Entry, bool> ();
    }

    /**
     * Render a NebulaShell widget tree into a GTK widget.
     *
     * Walks the widget tree recursively and creates the
     * corresponding GTK widget for each NebulaShell widget.
     *
     * @param widget the root NebulaShell widget to render
     * @return the corresponding GTK widget
     */
    public Gtk.Widget render (Widget widget) {
        if (_widget_cache.has_key (widget)) {
            return _widget_cache.get (widget);
        }

        Gtk.Widget gtk_widget = create_gtk_widget (widget);
        _widget_cache.set (widget, gtk_widget);

        apply_styles (widget, gtk_widget);

        if (widget is Container) {
            render_children ((Container) widget, gtk_widget);
        }

        return gtk_widget;
    }

    /**
     * Clear the widget and CSS caches.
     *
     * Call this when the widget tree has been modified
     * and needs to be re-rendered.
     */
    public void clear_cache () {
        _widget_cache.clear ();
        _css_cache.clear ();
        _syncing_entries.clear ();
    }

    /**
     * Create a GTK widget for a NebulaShell widget.
     */
    private Gtk.Widget create_gtk_widget (Widget widget) {
        if (widget is Box) {
            return create_box ((Box) widget);
        }
        if (widget is Label) {
            return create_label ((Label) widget);
        }
        if (widget is Button) {
            return create_button ((Button) widget);
        }
        if (widget is Entry) {
            return create_entry ((Entry) widget);
        }
        if (widget is Icon) {
            return create_icon ((Icon) widget);
        }
        if (widget is Image) {
            return create_image ((Image) widget);
        }
        if (widget is Separator) {
            return create_separator ((Separator) widget);
        }
        if (widget is Spacer) {
            return create_spacer ((Spacer) widget);
        }
        if (widget is Grid) {
            return create_grid ((Grid) widget);
        }
        if (widget is Stack) {
            return create_stack ((Stack) widget);
        }
        if (widget is Overlay) {
            return create_overlay ((Overlay) widget);
        }

        // Unknown widget type — fallback GtkBox
        return new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    }

    /**
     * Render children of a container into a GTK widget.
     */
    private void render_children (Container container, Gtk.Widget gtk_widget) {
        var children = container.get_children ();

        if (container is Box) {
            var gtk_box = (Gtk.Box) gtk_widget;
            foreach (var child in children) {
                gtk_box.append (render (child));
            }
        } else if (container is Grid) {
            var gtk_grid = (Gtk.Grid) gtk_widget;
            var grid = (Grid) container;
            int index = 0;
            int cols = grid.columns;
            if (cols <= 0) cols = 1;
            foreach (var child in children) {
                int col = index % cols;
                int row = index / cols;
                gtk_grid.attach (render (child), col, row);
                index++;
            }
        } else if (container is Stack) {
            var gtk_stack = (Gtk.Stack) gtk_widget;
            var stack = (Stack) container;
            foreach (var child in children) {
                gtk_stack.add_named (render (child), child.name);
            }
            if (stack.visible_child_name != "") {
                gtk_stack.set_visible_child_name (stack.visible_child_name);
            } else if (stack.visible_child_index >= 0 && stack.visible_child_index < children.length) {
                gtk_stack.set_visible_child (render (children[stack.visible_child_index]));
            }
        } else if (container is Overlay) {
            var gtk_overlay = (Gtk.Overlay) gtk_widget;
            bool first = true;
            foreach (var child in children) {
                var gtk_child = render (child);
                if (first) {
                    gtk_overlay.set_child (gtk_child);
                    first = false;
                } else {
                    gtk_overlay.add_overlay (gtk_child);
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // Widget creation methods
    // ------------------------------------------------------------------

    private Gtk.Widget create_box (Box box) {
        Gtk.Orientation orient;
        if (box.orientation == Orientation.VERTICAL) {
            orient = Gtk.Orientation.VERTICAL;
        } else {
            orient = Gtk.Orientation.HORIZONTAL;
        }
        var gtk_box = new Gtk.Box (orient, box.spacing);
        gtk_box.set_homogeneous (box.homogeneous != 0);
        return gtk_box;
    }

    private Gtk.Widget create_label (Label label) {
        var gtk_label = new Gtk.Label (label.text);
        gtk_label.set_wrap (label.wrap);
        gtk_label.set_ellipsize (Pango.EllipsizeMode.END);

        if (label.max_width > 0) {
            gtk_label.set_max_width_chars (label.max_width / 6);
        }

        if (label.xalign == "center") {
            gtk_label.set_halign (Gtk.Align.CENTER);
        } else if (label.xalign == "end") {
            gtk_label.set_halign (Gtk.Align.END);
        } else {
            gtk_label.set_halign (Gtk.Align.START);
        }
        gtk_label.set_valign (Gtk.Align.CENTER);

        return gtk_label;
    }

    private Gtk.Widget create_button (Button button) {
        var gtk_button = new Gtk.Button ();
        gtk_button.set_sensitive (button.enabled);

        if (button.child != null) {
            gtk_button.set_child (render (button.child));
        } else if (button.label_text != "") {
            gtk_button.set_label (button.label_text);
        }

        // Strong ref: prevent GC of NebulaShell.Button while GtkButton is alive
        button.ref ();
        gtk_button.clicked.connect (() => {
            button.press ();
        });
        gtk_button.destroy.connect (() => {
            button.unref ();
        });

        return gtk_button;
    }

    private Gtk.Widget create_entry (Entry entry) {
        var gtk_entry = new Gtk.Entry ();
        gtk_entry.set_text (entry.text);
        gtk_entry.set_placeholder_text (entry.placeholder);
        gtk_entry.set_editable (entry.editable);

        if (entry.max_length > 0) {
            gtk_entry.set_max_length (entry.max_length);
        }

        // GTK → NebulaShell sync with per-entry reentrancy guard
        _syncing_entries.set (gtk_entry, false);

        // Strong ref: prevent GC of NebulaShell.Entry while GtkEntry is alive
        entry.ref ();
        gtk_entry.changed.connect (() => {
            if (_syncing_entries.get (gtk_entry)) return;
            _syncing_entries.set (gtk_entry, true);
            entry.text = gtk_entry.get_text ();
            _syncing_entries.set (gtk_entry, false);
        });

        gtk_entry.activate.connect (() => {
            entry.activated (gtk_entry.get_text ());
        });
        gtk_entry.destroy.connect (() => {
            _syncing_entries.unset (gtk_entry);
            entry.unref ();
        });

        return gtk_entry;
    }

    private Gtk.Widget create_icon (Icon icon) {
        var gtk_image = new Gtk.Image ();

        if (icon.icon_name != "") {
            gtk_image.set_from_icon_name (icon.icon_name);
        }

        if (icon.pixel_size > 0) {
            gtk_image.set_pixel_size (icon.pixel_size);
        }

        return gtk_image;
    }

    private Gtk.Widget create_image (Image image) {
        var gtk_image = new Gtk.Image ();

        if (image.path != "") {
            gtk_image.set_from_file (image.path);
        }

        if (image.pixel_size > 0) {
            gtk_image.set_pixel_size (image.pixel_size);
        }

        return gtk_image;
    }

    private Gtk.Widget create_separator (Separator separator) {
        Gtk.Orientation orient;
        if (separator.orientation == Orientation.VERTICAL) {
            orient = Gtk.Orientation.VERTICAL;
        } else {
            orient = Gtk.Orientation.HORIZONTAL;
        }
        var gtk_separator = new Gtk.Separator (orient);
        gtk_separator.set_size_request (-1, separator.thickness);
        return gtk_separator;
    }

    private Gtk.Widget create_spacer (Spacer spacer) {
        var gtk_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        gtk_box.set_hexpand (spacer.expand);
        gtk_box.set_vexpand (spacer.expand);

        if (spacer.min_size > 0) {
            gtk_box.set_size_request (spacer.min_size, spacer.min_size);
        }

        return gtk_box;
    }

    private Gtk.Widget create_grid (Grid grid) {
        var gtk_grid = new Gtk.Grid ();
        gtk_grid.set_row_spacing ((uint) grid.row_spacing);
        gtk_grid.set_column_spacing ((uint) grid.column_spacing);
        return gtk_grid;
    }

    private Gtk.Widget create_stack (Stack stack) {
        var gtk_stack = new Gtk.Stack ();

        if (stack.animate_transitions) {
            gtk_stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            gtk_stack.set_transition_duration (300);
        } else {
            gtk_stack.set_transition_type (Gtk.StackTransitionType.NONE);
        }

        return gtk_stack;
    }

    private Gtk.Widget create_overlay (Overlay overlay) {
        return new Gtk.Overlay ();
    }

    // ------------------------------------------------------------------
    // CSS styling
    // ------------------------------------------------------------------

    /**
     * Apply CSS styles from the NebulaShell widget to the GTK widget.
     *
     * Copies CSS classes, the widget ID, and inline CSS.
     */
    private void apply_styles (Widget widget, Gtk.Widget gtk_widget) {
        // CSS ID from StyleContext (not widget.name)
        string css_id = widget.style_context.get_id ();
        if (css_id != "") {
            gtk_widget.set_name (css_id);
        }

        // CSS classes
        var classes = widget.style_context.get_classes ();
        foreach (string cls in classes) {
            gtk_widget.add_css_class (cls);
        }

        // Inline CSS — cached per content string
        string inline_css = widget.style_context.get_inline_css ();
        if (inline_css != "") {
            Gtk.CssProvider? provider = null;

            if (_css_cache.has_key (inline_css)) {
                provider = _css_cache.get (inline_css);
            } else {
                try {
                    provider = new Gtk.CssProvider ();
                    provider.load_from_data (inline_css.data);
                    _css_cache.set (inline_css, provider);
                } catch (Error e) {
                    warning ("Failed to parse inline CSS: %s", e.message);
                    return;
                }
            }

            gtk_widget.get_style_context ().add_provider (
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }
    }

}

}

namespace NebulaShell {

/**
 * Manages the visual styling of a widget.
 *
 * StyleContext owns the CSS state for a single widget, including:
 * - Style classes (CSS class selectors)
 * - Inline CSS (per-widget style overrides)
 * - Widget IDs (unique CSS selectors)
 * - Pseudo-classes (state-based selectors like :hover, :active)
 *
 * StyleContext is owned by a Widget and should not be shared.
 * Each widget creates its own StyleContext during construction.
 *
 * GTK CSS is the official theme language. Widgets expose style classes,
 * not hardcoded colors. StyleContext is the bridge between widget state
 * and the GTK CSS system.
 *
 * Example:
 *   var ctx = widget.get_style_context();
 *   ctx.add_class("primary");
 *   ctx.set_id("status-bar");
 *   ctx.set_inline_css("background-color: rgba(0,0,0,0.5);");
 */
public class StyleContext : GLib.Object {

    private unowned Gtk.Widget? _gtk_widget;
    private string _id;
    private Gee.HashSet<string> _classes;
    private Gee.HashMap<string, string> _pseudo_classes;
    private string _inline_css;
    private string _css_name;
    private bool _dirty;

    /**
     * Emitted when the style context changes.
     *
     * Connected widgets should re-apply their styling.
     */
    public signal void changed ();

    /**
     * Emitted when a style class is added.
     *
     * @param css_class the class that was added
     */
    public signal void class_added (string css_class);

    /**
     * Emitted when a style class is removed.
     *
     * @param css_class the class that was removed
     */
    public signal void class_removed (string css_class);

    /**
     * Emitted when a pseudo-class state changes.
     *
     * @param pseudo_class the pseudo-class name
     * @param active whether the pseudo-class is now active
     */
    public signal void pseudo_class_changed (string pseudo_class, bool active);

    /**
     * Emitted when the inline CSS is updated.
     */
    public signal void inline_css_changed ();

    /**
     * Create a new StyleContext for a GTK widget.
     *
     * @param gtk_widget the underlying GTK widget, or null
     */
    public StyleContext (Gtk.Widget? gtk_widget) {
        _gtk_widget = gtk_widget;
        _id = "";
        _classes = new Gee.HashSet<string> ();
        _pseudo_classes = new Gee.HashMap<string, string> ();
        _inline_css = "";
        _css_name = "";
        _dirty = false;
    }

    /**
     * The GTK widget this context is attached to.
     */
    public Gtk.Widget? gtk_widget {
        get { return _gtk_widget; }
    }

    /**
     * Whether the context has pending changes.
     */
    public bool dirty {
        get { return _dirty; }
    }

    /**
     * Set the CSS ID of this widget.
     *
     * Widget IDs enable targeted CSS styling using the #id selector.
     * Each widget should have a unique ID within its hierarchy.
     *
     * @param id the CSS ID, or empty to clear
     */
    public void set_id (string id) {
        if (_id == id)
            return;

        _id = id;
        _dirty = true;

        if (_gtk_widget != null) {
            _gtk_widget.set_name (id);
        }

        changed ();
    }

    /**
     * Get the CSS ID of this widget.
     *
     * @return the CSS ID, or empty if not set
     */
    public string get_id () {
        return _id;
    }

    /**
     * Add a CSS style class to this widget.
     *
     * Style classes allow theming without modifying widget code.
     * Classes are applied as CSS selectors: .classname
     *
     * @param css_class the CSS class name to add
     */
    public void add_class (string css_class) {
        if (css_class.length == 0)
            return;

        if (_classes.add (css_class)) {
            _dirty = true;

            if (_gtk_widget != null) {
                _gtk_widget.add_css_class (css_class);
            }

            class_added (css_class);
            changed ();
        }
    }

    /**
     * Remove a CSS style class from this widget.
     *
     * @param css_class the CSS class name to remove
     */
    public void remove_class (string css_class) {
        if (_classes.remove (css_class)) {
            _dirty = true;

            if (_gtk_widget != null) {
                _gtk_widget.remove_css_class (css_class);
            }

            class_removed (css_class);
            changed ();
        }
    }

    /**
     * Check if this widget has a specific CSS style class.
     *
     * @param css_class the CSS class name to check
     * @return true if the class is present
     */
    public bool has_class (string css_class) {
        return _classes.contains (css_class);
    }

    /**
     * Get all CSS style classes on this widget.
     *
     * @return a read-only set of class names
     */
    public Gee.Set<string> get_classes () {
        return _classes.read_only_view;
    }

    /**
     * Toggle a CSS style class.
     *
     * If the class is present, it is removed.
     * If the class is absent, it is added.
     *
     * @param css_class the CSS class name to toggle
     * @return true if the class is now active
     */
    public bool toggle_class (string css_class) {
        if (_classes.contains (css_class)) {
            remove_class (css_class);
            return false;
        } else {
            add_class (css_class);
            return true;
        }
    }

    /**
     * Clear all CSS style classes.
     */
    public void clear_classes () {
        if (_classes.size == 0)
            return;

        var removed = new Gee.ArrayList<string> ();
        removed.add_all (_classes);

        if (_gtk_widget != null) {
            foreach (string cls in removed) {
                _gtk_widget.remove_css_class (cls);
            }
        }

        _classes.clear ();
        _dirty = true;

        foreach (string cls in removed) {
            class_removed (cls);
        }

        changed ();
    }

    /**
     * Set a pseudo-class state.
     *
     * Pseudo-classes provide state-based styling using :state selectors.
     * Common pseudo-classes: hover, active, focus, selected, checked.
     *
     * @param pseudo_class the pseudo-class name
     * @param active whether the state is active
     */
    public void set_pseudo_class (string pseudo_class, bool active) {
        if (active) {
            if (!_pseudo_classes.has_key (pseudo_class)) {
                _pseudo_classes.set (pseudo_class, pseudo_class);
                _dirty = true;

                if (_gtk_widget != null) {
                    _gtk_widget.set_state_flags (pseudo_class_to_flag (pseudo_class), true);
                }

                pseudo_class_changed (pseudo_class, true);
                changed ();
            }
        } else {
            if (_pseudo_classes.has_key (pseudo_class)) {
                _pseudo_classes.unset (pseudo_class);
                _dirty = true;

                if (_gtk_widget != null) {
                    _gtk_widget.unset_state_flags (pseudo_class_to_flag (pseudo_class));
                }

                pseudo_class_changed (pseudo_class, false);
                changed ();
            }
        }
    }

    /**
     * Check if a pseudo-class is active.
     *
     * @param pseudo_class the pseudo-class name
     * @return true if the pseudo-class is active
     */
    public bool has_pseudo_class (string pseudo_class) {
        return _pseudo_classes.has_key (pseudo_class);
    }

    /**
     * Get all active pseudo-classes.
     *
     * @return a read-only map of pseudo-class names
     */
    public Gee.Map<string, string> get_pseudo_classes () {
        return _pseudo_classes.read_only_view;
    }

    /**
     * Clear all pseudo-class states.
     */
    public void clear_pseudo_classes () {
        if (_pseudo_classes.size == 0)
            return;

        if (_gtk_widget != null) {
            _gtk_widget.set_state_flags (Gtk.StateFlags.NORMAL, true);
        }

        _pseudo_classes.clear ();
        _dirty = true;
        changed ();
    }

    /**
     * Set inline CSS for this widget.
     *
     * Inline CSS overrides theme CSS for this specific widget.
     * Useful for per-widget styling without modifying the theme.
     *
     * @param css the CSS string, or empty to clear
     */
    public void set_inline_css (string css) {
        if (_inline_css == css)
            return;

        _inline_css = css;
        _dirty = true;
        inline_css_changed ();
        changed ();
    }

    /**
     * Get the inline CSS for this widget.
     *
     * @return the inline CSS string, or empty if not set
     */
    public string get_inline_css () {
        return _inline_css;
    }

    /**
     * Set the CSS node name for this widget.
     *
     * The CSS name determines how the widget is targeted in CSS selectors.
     * For example, setting name to "button" makes it targetable as button {}.
     *
     * @param name the CSS node name
     */
    public void set_css_name (string name) {
        if (_css_name == name)
            return;

        _css_name = name;
        _dirty = true;

        if (_gtk_widget != null) {
            _gtk_widget.set_css_name (name);
        }

        changed ();
    }

    /**
     * Get the CSS node name for this widget.
     *
     * @return the CSS node name, or empty if not set
     */
    public string get_css_name () {
        return _css_name;
    }

    /**
     * Apply all pending style changes to the GTK widget.
     *
     * This is called by the widget when it needs to synchronize
     * its visual state with the style context.
     */
    public void apply () {
        if (_gtk_widget == null || !_dirty)
            return;

        foreach (string cls in _classes) {
            _gtk_widget.add_css_class (cls);
        }

        if (_id.length > 0) {
            _gtk_widget.set_name (_id);
        }

        if (_css_name.length > 0) {
            _gtk_widget.set_css_name (_css_name);
        }

        _dirty = false;
    }

    /**
     * Check if a pseudo-class name maps to a valid GTK state flag.
     *
     * @param pseudo_class the pseudo-class name
     * @return the corresponding GTK state flags
     */
    private Gtk.StateFlags pseudo_class_to_flag (string pseudo_class) {
        switch (pseudo_class) {
            case "hover":
                return Gtk.StateFlags.PRELIGHT;
            case "active":
                return Gtk.StateFlags.ACTIVE;
            case "focus":
                return Gtk.StateFlags.FOCUSED;
            case "selected":
                return Gtk.StateFlags.SELECTED;
            case "checked":
                return Gtk.StateFlags.CHECKED;
            case "indeterminate":
                return Gtk.StateFlags.INCONSISTENT;
            case "disabled":
                return Gtk.StateFlags.INSENSITIVE;
            case "backdrop":
                return Gtk.StateFlags.BACKDROP;
            default:
                return Gtk.StateFlags.NORMAL;
        }
    }

    /**
     * Reset the dirty flag without applying changes.
     *
     * Useful when changes have been applied externally.
     */
    public void mark_clean () {
        _dirty = false;
    }

}

}

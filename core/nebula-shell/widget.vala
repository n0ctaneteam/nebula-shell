namespace NebulaShell {

/**
 * Base class for all widgets in NebulaShell.
 *
 * Widget provides the foundation for all visual components.
 * Widgets display information but never fetch it.
 * Data fetching belongs inside services.
 *
 * Widgets may contain children, but child management
 * is handled by the Container subclass.
 *
 * Properties describe widget state.
 * Methods perform actions on the widget.
 * Signals describe widget events.
 *
 * Widgets use StyleContext for visual styling. StyleContext manages
 * CSS classes, inline CSS, widget IDs, and pseudo-classes. This keeps
 * styling logic separate from widget logic.
 *
 * Example:
 *   var label = new Label ("Hello");
 *   label.visible = true;
 *   label.tooltip = "A greeting";
 *   label.style_context.add_class ("primary");
 *   label.style_context.set_id ("status-label");
 */
public class Widget : NebulaShell.Object {

    private bool _visible = true;
    private Widget? _parent = null;
    private string _tooltip = "";
    private StyleContext? _style_context;
    private EventHandler? _event_handler;

    /**
     * Emitted when the widget is shown.
     */
    public signal void shown ();

    /**
     * Emitted when the widget is hidden.
     */
    public signal void hidden ();

    /**
     * Emitted when the widget is destroyed.
     */
    public signal void destroyed ();

    /**
     * Emitted when any user interaction event occurs on this widget.
     *
     * Connect to this signal to handle user input events.
     * Use `is` checks to determine the event type:
     *
     *   widget.event_received.connect ((event) => {
     *       if (event is ClickEvent) {
     *           var click = (ClickEvent) event;
     *           // handle click
     *       }
     *   });
     */
    public signal void event_received (Event event);

    /**
     * Whether the widget is currently visible.
     *
     * Setting this property shows or hides the widget.
     */
    public bool visible {
        get { return _visible; }
        set {
            if (_visible == value) return;
            _visible = value;
            if (_visible) {
                shown ();
            } else {
                hidden ();
            }
        }
    }

    /**
     * The parent widget of this widget.
     *
     * Null when the widget is not attached to a parent.
     * Managed internally by the parent container.
     */
    public Widget? parent {
        get { return _parent; }
        internal set { _parent = value; }
    }

    /**
     * Tooltip text displayed on hover.
     */
    public string tooltip {
        get { return _tooltip; }
        set { _tooltip = value; }
    }

    /**
     * The style context for this widget.
     *
     * Provides access to CSS classes, inline CSS, widget IDs,
     * and pseudo-classes. Each widget owns its own StyleContext.
     */
    public StyleContext style_context {
        get {
            if (_style_context == null) {
                _style_context = create_style_context ();
            }
            return _style_context;
        }
    }

    /**
     * CSS style classes applied to this widget.
     *
     * Convenience accessor that delegates to StyleContext.
     * Prefer using style_context directly for new code.
     */
    public string[] style_classes {
        owned get {
            var classes = style_context.get_classes ();
            string[] result = {};
            foreach (string cls in classes) {
                result += cls;
            }
            return result;
        }
        set {
            style_context.clear_classes ();
            foreach (string cls in value) {
                style_context.add_class (cls);
            }
        }
    }

    /**
     * Create a new widget.
     */
    public Widget () {
        base ();
    }

    /**
     * Create a new widget with a name.
     *
     * @param name human-readable identifier
     */
    public Widget.with_name (string name) {
        base.with_name (name);
    }

    /**
     * Show the widget.
     *
     * Makes the widget visible if it has been hidden.
     * Emits the `shown` signal.
     */
    public virtual void show () {
        visible = true;
    }

    /**
     * Hide the widget without destroying it.
     *
     * The widget can be shown again with show().
     * Emits the `hidden` signal.
     */
    public virtual void hide () {
        visible = false;
    }

    /**
     * Destroy the widget and release all resources.
     *
     * After destruction, the widget cannot be reused.
     * Emits the `destroyed` signal.
     */
    public virtual void destroy () {
        _visible = false;
        _parent = null;
        _style_context = null;
        destroyed ();
    }

    /**
     * Add a CSS style class to this widget.
     *
     * @param css_class the CSS class name to add
     */
    public void add_style_class (string css_class) {
        style_context.add_class (css_class);
    }

    /**
     * Remove a CSS style class from this widget.
     *
     * @param css_class the CSS class name to remove
     */
    public void remove_style_class (string css_class) {
        style_context.remove_class (css_class);
    }

    /**
     * Check if this widget has a specific CSS style class.
     *
     * @param css_class the CSS class name to check
     * @return true if the class is present
     */
    public bool has_style_class (string css_class) {
        return style_context.has_class (css_class);
    }

    /**
     * Set the widget's CSS ID.
     *
     * Widget IDs enable targeted CSS styling using the #id selector.
     *
     * @param id the CSS ID, or empty to clear
     */
    public void set_id (string id) {
        style_context.set_id (id);
    }

    /**
     * Get the widget's CSS ID.
     *
     * @return the CSS ID, or empty if not set
     */
    public string get_id () {
        return style_context.get_id ();
    }

    /**
     * Set inline CSS for this widget.
     *
     * Inline CSS overrides theme CSS for this specific widget.
     *
     * @param css the CSS string, or empty to clear
     */
    public void set_inline_css (string css) {
        style_context.set_inline_css (css);
    }

    /**
     * Get the inline CSS for this widget.
     *
     * @return the inline CSS string, or empty if not set
     */
    public string get_inline_css () {
        return style_context.get_inline_css ();
    }

    /**
     * Set a pseudo-class state on this widget.
     *
     * Pseudo-classes provide state-based styling using :state selectors.
     *
     * @param pseudo_class the pseudo-class name
     * @param active whether the state is active
     */
    public void set_pseudo_class (string pseudo_class, bool active) {
        style_context.set_pseudo_class (pseudo_class, active);
    }

    /**
     * Check if a pseudo-class is active.
     *
     * @param pseudo_class the pseudo-class name
     * @return true if the pseudo-class is active
     */
    public bool has_pseudo_class (string pseudo_class) {
        return style_context.has_pseudo_class (pseudo_class);
    }

    /**
     * Toggle a CSS style class.
     *
     * @param css_class the CSS class name to toggle
     * @return true if the class is now active
     */
    public bool toggle_style_class (string css_class) {
        return style_context.toggle_class (css_class);
    }

    /**
     * Create the style context for this widget.
     *
     * Subclasses can override this to provide a custom StyleContext.
     *
     * @return a new StyleContext instance
     */
    protected virtual StyleContext create_style_context () {
        return new StyleContext (null);
    }

    /**
     * The internal event handler for this widget.
     *
     * Lazily created when event handling is needed.
     * This property is internal and should not be used by consumers.
     */
    internal EventHandler event_handler {
        get {
            if (_event_handler == null) {
                _event_handler = new EventHandler (this);
            }
            return _event_handler;
        }
    }

    /**
     * Handle a click event.
     *
     * Called by the EventHandler when a click occurs.
     * Emits the `event_received` signal with the click event.
     * Subclasses can override to perform custom handling.
     *
     * @param event the click event
     */
    internal virtual void on_click (ClickEvent event) {
        if (!event.handled) {
            event_received (event);
        }
    }

    /**
     * Handle a hover enter event.
     *
     * Called by the EventHandler when the pointer enters the widget.
     * Emits the `event_received` signal with the hover event.
     * Subclasses can override to perform custom handling.
     *
     * @param event the hover event
     */
    internal virtual void on_hover_enter (HoverEvent event) {
        if (!event.handled) {
            event_received (event);
        }
    }

    /**
     * Handle a hover leave event.
     *
     * Called by the EventHandler when the pointer leaves the widget.
     * Emits the `event_received` signal with the hover event.
     * Subclasses can override to perform custom handling.
     *
     * @param event the hover event
     */
    internal virtual void on_hover_leave (HoverEvent event) {
        if (!event.handled) {
            event_received (event);
        }
    }

    /**
     * Handle a keyboard event.
     *
     * Called by the EventHandler when a key is pressed or released.
     * Emits the `event_received` signal with the keyboard event.
     * Subclasses can override to perform custom handling.
     *
     * @param event the keyboard event
     */
    internal virtual void on_keyboard (KeyboardEvent event) {
        if (!event.handled) {
            event_received (event);
        }
    }

    /**
     * Handle a scroll event.
     *
     * Called by the EventHandler when a scroll occurs.
     * Emits the `event_received` signal with the scroll event.
     * Subclasses can override to perform custom handling.
     *
     * @param event the scroll event
     */
    internal virtual void on_scroll (ScrollEvent event) {
        if (!event.handled) {
            event_received (event);
        }
    }

    /**
     * Handle a drag event.
     *
     * Called by the EventHandler during drag operations.
     * Emits the `event_received` signal with the drag event.
     * Subclasses can override to perform custom handling.
     *
     * @param event the drag event
     */
    internal virtual void on_drag (DragEvent event) {
        if (!event.handled) {
            event_received (event);
        }
    }

    /**
     * Handle a focus event.
     *
     * Called by the EventHandler when focus changes.
     * Emits the `event_received` signal with the focus event.
     * Subclasses can override to perform custom handling.
     *
     * @param event the focus event
     */
    internal virtual void on_focus (FocusEvent event) {
        if (!event.handled) {
            event_received (event);
        }
    }

}

}
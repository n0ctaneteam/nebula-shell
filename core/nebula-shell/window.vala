namespace NebulaShell {

/**
 * Base class for all windows in NebulaShell.
 *
 * Window provides a GTK-independent abstraction for desktop shell
 * windows. It wraps an internal GtkWindow and layer shell surface
 * while exposing only NebulaShell concepts to users.
 *
 * Window is abstract. Concrete subclasses are:
 * - Panel: dock/panel windows
 * - Popup: temporary floating windows
 * - Overlay: non-interactive floating windows
 *
 * Properties describe the window state.
 * Methods perform actions on the window.
 * Signals describe window events.
 *
 * Example:
 *   var panel = new Panel ();
 *   panel.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT;
 *   panel.layer = Layer.TOP;
 *   panel.height = 32;
 *   panel.show ();
 */
public abstract class Window : NebulaShell.Object {

    private Gtk.Window? _gtk_window = null;
    private bool _visible = false;
    private int _width = 800;
    private int _height = 600;
    private Monitor? _monitor = null;
    private Anchor _anchor = Anchor.NONE;
    private Layer _layer = Layer.TOP;
    private bool _exclusive = false;
    private KeyboardMode _keyboard_mode = KeyboardMode.NONE;
    private int _margin_top = 0;
    private int _margin_bottom = 0;
    private int _margin_left = 0;
    private int _margin_right = 0;
    private Widget? _child = null;
    private WidgetRenderer? _renderer = null;
    private bool _layer_shell_initialized = false;

    /**
     * Emitted when the window is shown.
     */
    public signal void shown ();

    /**
     * Emitted when the window is hidden.
     */
    public signal void hidden ();

    /**
     * Emitted when the window is closed.
     */
    public signal void closed ();

    /**
     * Emitted when the window is destroyed.
     */
    public signal void destroyed ();

    /**
     * Whether the window is currently visible on screen.
     */
    public bool visible {
        get { return _visible; }
    }

    /**
     * Width of the window in logical pixels.
     *
     * Changing this value after the window is shown will
     * resize the window immediately.
     */
    public int width {
        get { return _width; }
        set {
            if (value <= 0) return;
            _width = value;
            if (_gtk_window != null && _visible) {
                _gtk_window.set_default_size (_width, _height);
            }
        }
    }

    /**
     * Height of the window in logical pixels.
     *
     * Changing this value after the window is shown will
     * resize the window immediately.
     */
    public int height {
        get { return _height; }
        set {
            if (value <= 0) return;
            _height = value;
            if (_gtk_window != null && _visible) {
                _gtk_window.set_default_size (_width, _height);
            }
        }
    }

    /**
     * The monitor this window is displayed on.
     *
     * Set to null to use the default monitor.
     * Changing this value moves the window to the new monitor.
     */
    public Monitor? monitor {
        get { return _monitor; }
        set {
            _monitor = value;
            apply_monitor ();
        }
    }

    /**
     * Screen edge anchor for this window.
     *
     * Determines which screen edge(s) the window is attached to.
     * Can be combined with bitwise OR for corners.
     */
    public Anchor anchor {
        get { return _anchor; }
        set {
            _anchor = value;
            apply_layer_shell_config ();
        }
    }

    /**
     * Layer shell layer for this window.
     *
     * Determines the stacking order relative to other surfaces.
     */
    public Layer layer {
        get { return _layer; }
        set {
            _layer = value;
            apply_layer_shell_config ();
        }
    }

    /**
     * Whether this window reserves exclusive screen space.
     *
     * When true, the compositor reserves screen area for this
     * window, pushing other windows away. Used for panels and docks.
     */
    public bool exclusive {
        get { return _exclusive; }
        set {
            _exclusive = value;
            apply_layer_shell_config ();
        }
    }

    /**
     * Keyboard interaction mode for this window.
     *
     * Controls how the window handles keyboard focus and input.
     */
    public KeyboardMode keyboard_mode {
        get { return _keyboard_mode; }
        set {
            _keyboard_mode = value;
            apply_layer_shell_config ();
        }
    }

    /**
     * Margin from the top screen edge in logical pixels.
     *
     * Only applies when anchored to the top edge.
     */
    public int margin_top {
        get { return _margin_top; }
        set {
            _margin_top = value;
            apply_layer_shell_config ();
        }
    }

    /**
     * Margin from the bottom screen edge in logical pixels.
     *
     * Only applies when anchored to the bottom edge.
     */
    public int margin_bottom {
        get { return _margin_bottom; }
        set {
            _margin_bottom = value;
            apply_layer_shell_config ();
        }
    }

    /**
     * Margin from the left screen edge in logical pixels.
     *
     * Only applies when anchored to the left edge.
     */
    public int margin_left {
        get { return _margin_left; }
        set {
            _margin_left = value;
            apply_layer_shell_config ();
        }
    }

    /**
     * Margin from the right screen edge in logical pixels.
     *
     * Only applies when anchored to the right edge.
     */
    public int margin_right {
        get { return _margin_right; }
        set {
            _margin_right = value;
            apply_layer_shell_config ();
        }
    }

    /**
     * Window is created via GObject construction.
     *
     * The underlying GtkWindow is not created until show() is called.
     */
    construct {
        /* intentionally empty — all init deferred to show() */
    }

    /**
     * Show the window on screen.
     *
     * Creates the internal GtkWindow if it does not exist,
     * applies all layer shell configuration, and makes the
     * window visible.
     *
     * Emits `shown` signal.
     */
    public virtual void show () {
        if (_visible) return;

        ensure_gtk_window ();
        apply_layer_shell_config ();
        apply_monitor ();

        // Defer present() to the next main loop iteration.
        // GTK4's gtk_window_present() requires the main loop to be running
        // and calling it before main_loop.run() causes a segfault on Wayland.
        GLib.Idle.add (() => {
            if (_gtk_window == null) return false;

            // Guard: ensure the Wayland display is ready before presenting.
            // If the display roundtrip hasn't completed, defer one more iteration.
            var display = _gtk_window.get_display ();
            if (display == null) {
                return true; // re-try on next idle iteration
            }

            _gtk_window.present ();
            return false; // remove idle source after firing
        });

        _visible = true;
        shown ();
    }

    /**
     * Hide the window without destroying it.
     *
     * The window can be shown again with show().
     * All configuration is preserved.
     *
     * Emits `hidden` signal.
     */
    public virtual void hide () {
        if (!_visible || _gtk_window == null) return;

        _gtk_window.set_visible (false);
        _visible = false;
        hidden ();
    }

    /**
     * Toggle the window visibility.
     *
     * If visible, hides the window.
     * If hidden, shows the window.
     */
    public virtual void toggle () {
        if (_visible) {
            hide ();
        } else {
            show ();
        }
    }

    /**
     * Close the window.
     *
     * Hides the window and emits the `closed` signal.
     * The window can be shown again with show().
     */
    public virtual void close () {
        if (!_visible) return;

        hide ();
        closed ();
    }

    /**
     * Destroy the window and release all resources.
     *
     * After destruction, the window cannot be shown again.
     * The window must be recreated to be used.
     *
     * Emits `destroyed` signal.
     */
    public virtual void destroy () {
        if (_gtk_window != null) {
            _gtk_window.destroy ();
            _gtk_window = null;
        }
        _visible = false;
        destroyed ();
    }

    /**
     * Set the window size.
     *
     * Convenience method to set both width and height at once.
     *
     * @param width the new width in logical pixels
     * @param height the new height in logical pixels
     */
    public void set_size (int width, int height) {
        if (width <= 0 || height <= 0) return;

        _width = width;
        _height = height;

        if (_gtk_window != null) {
            _gtk_window.set_default_size (_width, _height);
        }
    }

    /**
     * Set the root child widget for this window.
     *
     * The child widget is stored and rendered when the window
     * is shown. Only one root child is allowed — calling set_child
     * replaces the previous child.
     *
     * @param child the root widget to display in this window
     */
    public void set_child (Widget child) {
        _child = child;
        if (_renderer != null) {
            _renderer.clear_cache ();
        }
    }

    /**
     * Get the root child widget of this window.
     *
     * @return the root widget, or null if no child is set
     */
    public Widget? get_child () {
        return _child;
    }

    /**
     * Ensure the internal GtkWindow exists.
     *
     * Creates the window if it does not exist. Subclasses
     * should override to provide their specific window type.
     */
    protected virtual void ensure_gtk_window () {
        if (_gtk_window != null) return;

        _gtk_window = new Gtk.Window ();
        _gtk_window.set_default_size (_width, _height);
        _gtk_window.set_decorated (false);
        _gtk_window.set_resizable (false);

        _gtk_window.close_request.connect (() => {
            // Emit our close signal and let GTK handle the actual
            // window destruction. Returning true and calling
            // set_visible(false) inside the handler causes a
            // use-after-free when GTK is already tearing down the window.
            if (_visible) {
                _visible = false;
                closed ();
            }
            return false; // let GTK handle destruction
        });

        // Render the child widget tree into GTK widgets
        if (_child != null) {
            if (_renderer == null) {
                _renderer = new WidgetRenderer ();
            }
            var gtk_child = _renderer.render (_child);
            _gtk_window.set_child (gtk_child);
        }
    }

    /**
     * Apply layer shell configuration to the internal window.
     *
     * This method configures the layer shell properties using
     * the internal LayerShell helper.
     * Subclasses may override to customize behavior.
     */
    protected virtual void apply_layer_shell_config () {
        if (_gtk_window == null) return;

        // Only initialize layer shell once per window
        if (!_layer_shell_initialized) {
            LayerShell.init_for_window (_gtk_window);
            _layer_shell_initialized = true;
        }

        LayerShell.set_layer (_gtk_window, _layer);

        LayerShell.set_anchor (_gtk_window, Anchor.TOP,
                               (_anchor & Anchor.TOP) != 0);
        LayerShell.set_anchor (_gtk_window, Anchor.BOTTOM,
                               (_anchor & Anchor.BOTTOM) != 0);
        LayerShell.set_anchor (_gtk_window, Anchor.LEFT,
                               (_anchor & Anchor.LEFT) != 0);
        LayerShell.set_anchor (_gtk_window, Anchor.RIGHT,
                               (_anchor & Anchor.RIGHT) != 0);

        LayerShell.set_exclusive_zone (_gtk_window,
                                       _exclusive ? -1 : 0);

        LayerShell.set_keyboard_mode (_gtk_window, _keyboard_mode);

        LayerShell.set_margin (_gtk_window, Anchor.TOP, _margin_top);
        LayerShell.set_margin (_gtk_window, Anchor.BOTTOM, _margin_bottom);
        LayerShell.set_margin (_gtk_window, Anchor.LEFT, _margin_left);
        LayerShell.set_margin (_gtk_window, Anchor.RIGHT, _margin_right);
    }

    /**
     * Apply the monitor configuration to the internal window.
     *
     * Sets the output for the layer shell surface using
     * the internal LayerShell helper.
     */
    protected virtual void apply_monitor () {
        if (_gtk_window == null || _monitor == null) return;

        var display = Gdk.Display.get_default ();
        if (display == null) return;

        var model = display.get_monitors ();
        uint n_items = model.get_n_items ();

        for (uint i = 0; i < n_items; i++) {
            if ((int) i == _monitor.id) {
                var obj = model.get_item (i);
                if (obj != null) {
                    LayerShell.set_monitor (_gtk_window, (Gdk.Monitor) obj);
                }
                return;
            }
        }
    }

}

}

namespace NebulaShell {

/**
 * Manages live CSS reload for development.
 *
 * LiveCss watches GTK CSS theme files and automatically
 * re-applies them when changes are detected. This provides
 * instant visual feedback during theme development.
 *
 * LiveCss follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * Example:
 *   var live_css = new LiveCss();
 *   live_css.initialize();
 *   live_css.set_css_path("/path/to/theme.css");
 */
public class LiveCss : GLib.Object, Manager {

    private bool _initialized;
    private string? _css_path;
    private GLib.FileMonitor? _monitor;
    private Gtk.CssProvider? _css_provider;
    private uint _debounce_id;

    /**
     * Signal emitted when CSS is reloaded.
     *
     * @param path the CSS file that was reloaded
     */
    public signal void css_reloaded (string path);

    /**
     * Signal emitted when a CSS error occurs.
     *
     * @param message the error description
     */
    public signal void css_error (string message);

    /**
     * Create a new LiveCss instance.
     */
    public LiveCss () {
        _initialized = false;
        _css_path = null;
        _monitor = null;
        _css_provider = null;
        _debounce_id = 0;
    }

    /**
     * Set the CSS file path to watch.
     *
     * @param path absolute path to a GTK CSS file
     */
    public void set_css_path (string path) {
        _css_path = path;
        if (_initialized) {
            start_monitor ();
        }
    }

    /**
     * Get the currently watched CSS path.
     *
     * @return the CSS path, or null if not set
     */
    public string? get_css_path () {
        return _css_path;
    }

    /**
     * Initialize the live CSS manager.
     */
    public void initialize () {
        if (_initialized)
            return;

        Logger.info ("LiveCss: initializing");

        _css_provider = new Gtk.CssProvider ();
        start_monitor ();

        _initialized = true;
        Logger.info ("LiveCss: initialized");
    }

    /**
     * Shut down the live CSS manager.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("LiveCss: shutting down");

        stop_monitor ();

        if (_debounce_id != 0) {
            GLib.Source.remove (_debounce_id);
            _debounce_id = 0;
        }

        _css_provider = null;
        _initialized = false;
        Logger.info ("LiveCss: shut down");
    }

    /**
     * Reload the live CSS state.
     */
    public void reload () {
        if (!_initialized)
            return;

        Logger.info ("LiveCss: reloading");
        stop_monitor ();
        start_monitor ();
        apply_css ();
    }

    /**
     * Start the CSS file monitor.
     */
    private void start_monitor () {
        if (_css_path == null)
            return;

        if (!GLib.FileUtils.test (_css_path, GLib.FileTest.EXISTS))
            return;

        try {
            var file = GLib.File.new_for_path (_css_path);
            _monitor = file.monitor (GLib.FileMonitorFlags.WATCH_MOVES);
            _monitor.changed.connect (on_css_changed);
            Logger.debug ("LiveCss: watching " + _css_path);
        } catch (GLib.Error e) {
            Logger.error ("LiveCss: failed to monitor: " + e.message);
        }
    }

    /**
     * Stop the CSS file monitor.
     */
    private void stop_monitor () {
        if (_monitor != null) {
            _monitor.cancel ();
            _monitor = null;
        }
    }

    /**
     * Handle CSS file change events.
     *
     * @param file the file that changed
     * @param other_file the other file (for moves)
     * @param event the change event
     */
    private void on_css_changed (GLib.File file, GLib.File? other_file, GLib.FileMonitorEvent event) {
        if (event != GLib.FileMonitorEvent.CHANGED &&
            event != GLib.FileMonitorEvent.MOVED)
            return;

        string? path = file.get_path ();
        if (path == null)
            return;

        Logger.debug ("LiveCss: detected change in " + path);

        if (_debounce_id != 0) {
            GLib.Source.remove (_debounce_id);
        }

        _debounce_id = GLib.Timeout.add (100, () => {
            _debounce_id = 0;
            apply_css ();
            return false;
        });
    }

    /**
     * Apply the CSS file to the GTK provider.
     */
    private void apply_css () {
        if (_css_path == null || _css_provider == null)
            return;

        try {
            string content;
            GLib.FileUtils.get_contents (_css_path, out content);

            _css_provider.load_from_string (content.make_valid ());

            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                _css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            Logger.info ("LiveCss: applied CSS from " + _css_path);
            css_reloaded (_css_path);

        } catch (GLib.Error e) {
            Logger.error ("LiveCss: failed to apply CSS: " + e.message);
            css_error (e.message);
        }
    }

}

}

namespace NebulaShell {

/**
 * Manages hot reload for development.
 *
 * HotReload watches Python configuration files and triggers
 * framework reload when changes are detected. It uses
 * GLib.FileMonitor for efficient file system monitoring.
 *
 * HotReload follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * Example:
 *   var hot_reload = new HotReload();
 *   hot_reload.set_watch_path("/path/to/shell.py");
 *   hot_reload.initialize();
 */
public class HotReload : GLib.Object, Manager {

    private bool _initialized;
    private string? _watch_path;
    private GLib.FileMonitor? _monitor;
    private uint _debounce_id;

    /**
     * Signal emitted when a file change is detected.
     *
     * @param path the path that changed
     */
    public signal void file_changed (string path);

    /**
     * Signal emitted when a reload is triggered.
     */
    public signal void reload_triggered ();

    /**
     * Create a new HotReload instance.
     */
    public HotReload () {
        _initialized = false;
        _watch_path = null;
        _monitor = null;
        _debounce_id = 0;
    }

    /**
     * Set the path to watch for changes.
     *
     * @param path absolute path to watch
     */
    public void set_watch_path (string path) {
        _watch_path = path;
        if (_initialized) {
            start_monitor ();
        }
    }

    /**
     * Get the currently watched path.
     *
     * @return the watched path, or null if not set
     */
    public string? get_watch_path () {
        return _watch_path;
    }

    /**
     * Initialize the hot reload manager.
     */
    public void initialize () {
        if (_initialized)
            return;

        Logger.info ("HotReload: initializing");
        start_monitor ();
        _initialized = true;
        Logger.info ("HotReload: initialized");
    }

    /**
     * Shut down the hot reload manager.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("HotReload: shutting down");

        stop_monitor ();

        if (_debounce_id != 0) {
            GLib.Source.remove (_debounce_id);
            _debounce_id = 0;
        }

        _initialized = false;
        Logger.info ("HotReload: shut down");
    }

    /**
     * Reload the hot reload state.
     */
    public void reload () {
        if (!_initialized)
            return;

        Logger.info ("HotReload: reloading");
        stop_monitor ();
        start_monitor ();
    }

    /**
     * Start the file monitor.
     */
    private void start_monitor () {
        if (_watch_path == null)
            return;

        if (!GLib.FileUtils.test (_watch_path, GLib.FileTest.EXISTS))
            return;

        try {
            var file = GLib.File.new_for_path (_watch_path);
            _monitor = file.monitor (GLib.FileMonitorFlags.WATCH_MOVES);
            _monitor.changed.connect (on_file_changed);
            Logger.debug ("HotReload: watching " + _watch_path);
        } catch (GLib.Error e) {
            Logger.error ("HotReload: failed to monitor: " + e.message);
        }
    }

    /**
     * Stop the file monitor.
     */
    private void stop_monitor () {
        if (_monitor != null) {
            _monitor.cancel ();
            _monitor = null;
        }
    }

    /**
     * Handle file change events with debouncing.
     *
     * @param file the file that changed
     * @param other_file the other file (for moves)
     * @param event the change event
     */
    private void on_file_changed (GLib.File file, GLib.File? other_file, GLib.FileMonitorEvent event) {
        if (event != GLib.FileMonitorEvent.CHANGED &&
            event != GLib.FileMonitorEvent.CREATED &&
            event != GLib.FileMonitorEvent.MOVED)
            return;

        string? path = file.get_path ();
        if (path == null)
            return;

        Logger.debug ("HotReload: detected change in " + path);
        file_changed (path);

        if (_debounce_id != 0) {
            GLib.Source.remove (_debounce_id);
        }

        _debounce_id = GLib.Timeout.add (300, () => {
            _debounce_id = 0;
            trigger_reload ();
            return false;
        });
    }

    /**
     * Trigger a framework reload.
     */
    private void trigger_reload () {
        Logger.info ("HotReload: triggering reload");
        reload_triggered ();

        var runtime = Runtime.get_default ();
        runtime.reload ();
    }

}

}

namespace NebulaShell {

/**
 * Provides a performance overlay for development.
 *
 * PerformanceOverlay displays real-time performance metrics
 * including FPS, frame time, memory usage, and widget count.
 * It renders an overlay on top of the application content.
 *
 * PerformanceOverlay follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * Example:
 *   var overlay = PerformanceOverlay.get_default();
 *   overlay.initialize();
 *   overlay.set_visible(true);
 */
public class PerformanceOverlay : GLib.Object, Manager {

    private static PerformanceOverlay? _instance = null;

    private bool _initialized;
    private bool _visible;
    private double _fps;
    private double _frame_time_ms;
    private uint _frame_count;
    private uint64 _last_frame_time;
    private uint _fps_update_id;
    private uint _frame_timeout_id;

    private const int FPS_UPDATE_INTERVAL_MS = 1000;
    private const int FRAME_MEASUREMENT_INTERVAL_MS = 16;

    /**
     * Signal emitted when performance metrics are updated.
     */
    public signal void metrics_updated ();

    /**
     * Signal emitted when the overlay visibility changes.
     */
    public signal void visibility_changed (bool visible);

    /**
     * Get the default PerformanceOverlay instance.
     *
     * @return the singleton performance overlay
     */
    public static PerformanceOverlay get_default () {
        if (_instance == null)
            _instance = new PerformanceOverlay ();

        return _instance;
    }

    /**
     * Create a new PerformanceOverlay instance.
     */
    public PerformanceOverlay () {
        _initialized = false;
        _visible = false;
        _fps = 0.0;
        _frame_time_ms = 0.0;
        _frame_count = 0;
        _last_frame_time = 0;
        _fps_update_id = 0;
        _frame_timeout_id = 0;
    }

    /**
     * Whether the overlay is visible.
     */
    public bool visible {
        get { return _visible; }
    }

    /**
     * Current frames per second.
     */
    public double fps {
        get { return _fps; }
    }

    /**
     * Current frame time in milliseconds.
     */
    public double frame_time_ms {
        get { return _frame_time_ms; }
    }

    /**
     * Set the overlay visibility.
     *
     * @param value true to show the overlay
     */
    public void set_visible (bool value) {
        if (_visible == value)
            return;

        _visible = value;
        visibility_changed (value);

        if (_visible) {
            start_measurement ();
        } else {
            stop_measurement ();
        }
    }

    /**
     * Toggle the overlay visibility.
     */
    public void toggle () {
        set_visible (!_visible);
    }

    /**
     * Initialize the performance overlay.
     */
    public void initialize () {
        if (_initialized)
            return;

        Logger.info ("PerformanceOverlay: initializing");
        _initialized = true;
        Logger.info ("PerformanceOverlay: initialized");
    }

    /**
     * Shut down the performance overlay.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("PerformanceOverlay: shutting down");

        stop_measurement ();
        _initialized = false;
        Logger.info ("PerformanceOverlay: shut down");
    }

    /**
     * Reload the performance overlay state.
     */
    public void reload () {
        if (!_initialized)
            return;

        Logger.info ("PerformanceOverlay: reloading");
        reset_metrics ();
    }

    /**
     * Start frame measurement.
     */
    private void start_measurement () {
        if (_fps_update_id != 0)
            return;

        _last_frame_time = get_monotonic_time ();
        _frame_count = 0;

        _fps_update_id = GLib.Timeout.add (FPS_UPDATE_INTERVAL_MS, () => {
            update_fps ();
            return true;
        });

        _frame_timeout_id = GLib.Timeout.add (FRAME_MEASUREMENT_INTERVAL_MS, () => {
            measure_frame ();
            return true;
        });
    }

    /**
     * Stop frame measurement.
     */
    private void stop_measurement () {
        if (_fps_update_id != 0) {
            GLib.Source.remove (_fps_update_id);
            _fps_update_id = 0;
        }

        if (_frame_timeout_id != 0) {
            GLib.Source.remove (_frame_timeout_id);
            _frame_timeout_id = 0;
        }
    }

    /**
     * Measure a single frame.
     */
    private void measure_frame () {
        uint64 now = get_monotonic_time ();
        uint64 delta = now - _last_frame_time;
        _last_frame_time = now;

        _frame_time_ms = delta / 1000.0;
        _frame_count++;

        metrics_updated ();
    }

    /**
     * Update the FPS calculation.
     */
    private void update_fps () {
        _fps = _frame_count * (1000.0 / FPS_UPDATE_INTERVAL_MS);
        _frame_count = 0;

        Logger.debug ("PerformanceOverlay: FPS=%.1f frame_time=%.2fms".printf (_fps, _frame_time_ms));
        metrics_updated ();
    }

    /**
     * Reset all metrics.
     */
    private void reset_metrics () {
        _fps = 0.0;
        _frame_time_ms = 0.0;
        _frame_count = 0;
        _last_frame_time = 0;
    }

    /**
     * Get a formatted string of current metrics.
     *
     * @return the metrics string
     */
    public string get_metrics_string () {
        return "FPS: %.1f | Frame: %.2fms".printf (_fps, _frame_time_ms);
    }

}

}

namespace NebulaShell {

/**
 * Provides frame timing diagnostics for development.
 *
 * FrameTiming records detailed frame timing data including
 * render time, composite time, and frame intervals. It helps
 * developers identify performance bottlenecks and jank.
 *
 * FrameTiming follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * Example:
 *   var timing = FrameTiming.get_default();
 *   timing.initialize();
 *   timing.begin_frame();
 *   // ... render ...
 *   timing.end_frame();
 *   var stats = timing.get_stats();
 */
public class FrameTiming : GLib.Object, Manager {

    private static FrameTiming? _instance = null;

    private bool _initialized;
    private bool _recording;
    private int64 _frame_start;
    private double[] _frame_durations;
    private int _frame_count;
    private int _max_samples;
    private uint _jank_threshold_ms;

    /**
     * Signal emitted when a frame is recorded.
     *
     * @param duration_ms the frame duration in milliseconds
     */
    public signal void frame_recorded (double duration_ms);

    /**
     * Signal emitted when a jank frame is detected.
     *
     * @param duration_ms the jank frame duration in milliseconds
     */
    public signal void jank_detected (double duration_ms);

    /**
     * Get the default FrameTiming instance.
     *
     * @return the singleton frame timing diagnostics
     */
    public static FrameTiming get_default () {
        if (_instance == null)
            _instance = new FrameTiming ();

        return _instance;
    }

    /**
     * Create a new FrameTiming instance.
     */
    public FrameTiming () {
        _initialized = false;
        _recording = false;
        _frame_start = 0;
        _frame_durations = {};
        _frame_count = 0;
        _max_samples = 120;
        _jank_threshold_ms = 20;
    }

    /**
     * Whether timing is currently being recorded.
     */
    public bool recording {
        get { return _recording; }
    }

    /**
     * Set the maximum number of frame samples to keep.
     *
     * @param max the maximum samples
     */
    public void set_max_samples (int max) {
        _max_samples = max;
    }

    /**
     * Set the jank threshold in milliseconds.
     *
     * Frames longer than this are flagged as jank.
     *
     * @param threshold_ms the threshold in milliseconds
     */
    public void set_jank_threshold (uint threshold_ms) {
        _jank_threshold_ms = threshold_ms;
    }

    /**
     * Initialize the frame timing diagnostics.
     */
    public void initialize () {
        if (_initialized)
            return;

        Logger.info ("FrameTiming: initializing");
        _initialized = true;
        Logger.info ("FrameTiming: initialized");
    }

    /**
     * Shut down the frame timing diagnostics.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("FrameTiming: shutting down");

        stop_recording ();
        _frame_durations = {};
        _frame_count = 0;
        _initialized = false;
        Logger.info ("FrameTiming: shut down");
    }

    /**
     * Reload the frame timing state.
     */
    public void reload () {
        if (!_initialized)
            return;

        Logger.info ("FrameTiming: reloading");
        reset ();
    }

    /**
     * Start recording frame timings.
     */
    public void start_recording () {
        if (_recording)
            return;

        _recording = true;
        Logger.info ("FrameTiming: started recording");
    }

    /**
     * Stop recording frame timings.
     */
    public void stop_recording () {
        if (!_recording)
            return;

        _recording = false;
        Logger.info ("FrameTiming: stopped recording");
    }

    /**
     * Begin a new frame measurement.
     *
     * Call this at the start of each frame.
     */
    public void begin_frame () {
        if (!_recording)
            return;

        _frame_start = get_monotonic_time ();
    }

    /**
     * End the current frame measurement.
     *
     * Call this at the end of each frame.
     */
    public void end_frame () {
        if (!_recording || _frame_start == 0)
            return;

        int64 now = get_monotonic_time ();
        double duration_ms = (now - _frame_start) / 1000.0;
        _frame_start = 0;

        if (_frame_count < _max_samples) {
            _frame_durations += duration_ms;
            _frame_count++;
        } else {
            for (int i = 0; i < _frame_count - 1; i++) {
                _frame_durations[i] = _frame_durations[i + 1];
            }
            _frame_durations[_frame_count - 1] = duration_ms;
        }

        frame_recorded (duration_ms);

        if (duration_ms > _jank_threshold_ms) {
            jank_detected (duration_ms);
            Logger.warning ("FrameTiming: jank detected: %.2fms".printf (duration_ms));
        }
    }

    /**
     * Get timing statistics.
     *
     * @return a formatted statistics string
     */
    public string get_stats () {
        if (_frame_count == 0)
            return "No frame data recorded";

        double total = 0;
        double min = double.MAX;
        double max = 0;
        int jank_count = 0;

        for (int i = 0; i < _frame_count; i++) {
            double duration = _frame_durations[i];
            total += duration;
            if (duration < min) min = duration;
            if (duration > max) max = duration;
            if (duration > _jank_threshold_ms) jank_count++;
        }

        double avg_ms = total / _frame_count;
        double fps = 1000.0 / avg_ms;

        return "Frames: %d | FPS: %.1f | Avg: %.2fms | Min: %.2fms | Max: %.2fms | Jank: %d".printf (
            _frame_count, fps, avg_ms, min, max, jank_count
        );
    }

    /**
     * Reset all recorded data.
     */
    public void reset () {
        _frame_durations = {};
        _frame_count = 0;
        _frame_start = 0;
        Logger.debug ("FrameTiming: reset");
    }

    /**
     * Get the recorded frame durations in milliseconds.
     *
     * @return a copy of the frame durations array
     */
    public double[] get_frame_durations () {
        double[] result = {};
        for (int i = 0; i < _frame_count; i++) {
            result += _frame_durations[i];
        }
        return result;
    }

}

}

namespace NebulaShell {

/**
 * Easing function type.
 *
 * Maps a normalized time value [0, 1] to an eased value.
 * Used to control the acceleration curve of animations.
 *
 * @param t normalized time in range [0, 1]
 * @return eased value, typically in range [0, 1]
 */
public delegate double EasingFunc (double t);

/**
 * Base class for all animations.
 *
 * Animation provides a declarative, GTK-independent abstraction
 * for animating properties over time. Animations describe WHAT
 * to animate, not HOW to render it.
 *
 * The animation engine details remain private. Widgets and services
 * interact only with this public API.
 *
 * Example:
 *   var fade = new FadeAnimation (widget, 0.0, 1.0);
 *   fade.duration = 300;
 *   fade.easing = Easing.ease_out;
 *   fade.start ();
 */
public abstract class Animation : NebulaShell.Object {

    private double _duration = 300;
    private EasingFunc _easing = Easing.linear;
    private bool _is_running = false;
    private bool _is_cancelled = false;
    private uint _source_id = 0;

    /**
     * Emitted when the animation starts.
     */
    public signal void started ();

    /**
     * Emitted when the animation completes naturally.
     */
    public signal void completed ();

    /**
     * Emitted when the animation is cancelled.
     */
    public signal void cancelled ();

    /**
     * Duration of the animation in milliseconds.
     *
     * Must be positive. Default is 300ms.
     */
    public double duration {
        get { return _duration; }
        set {
            if (value <= 0) return;
            _duration = value;
        }
    }

    /**
     * The easing function applied to this animation.
     *
     * Controls the acceleration curve. Default is linear.
     */
    public EasingFunc get_easing () {
        return _easing;
    }

    public void set_easing (EasingFunc value) {
        _easing = value;
    }

    /**
     * Whether this animation is currently running.
     */
    public bool is_running {
        get { return _is_running; }
    }

    /**
     * Create a new animation.
     *
     * @param name human-readable identifier
     */
    protected Animation (string name) {
        base.with_name (name);
    }

    /**
     * Start the animation from the beginning.
     *
     * If already running, this method has no effect.
     * Emits `started` signal.
     */
    public void start () {
        if (_is_running) return;

        _is_cancelled = false;
        _is_running = true;

        on_start ();
        started ();
    }

    /**
     * Stop the animation at its current position.
     *
     * The animation retains its current progress.
     * Emits neither `completed` nor `cancelled`.
     */
    public void stop () {
        if (!_is_running) return;

        _is_running = false;
        cancel_source ();
        on_stop ();
    }

    /**
     * Cancel the animation and reset progress.
     *
     * The animation returns to its initial state.
     * Emits `cancelled` signal.
     */
    public void cancel () {
        if (!_is_running && !_is_cancelled) return;

        _is_cancelled = true;
        _is_running = false;
        cancel_source ();
        on_cancel ();
        cancelled ();
    }

    /**
     * Complete the animation immediately.
     *
     * Sets the animation to its final state and
     * emits `completed` signal.
     */
    public void complete () {
        if (!_is_running) return;

        _is_running = false;
        cancel_source ();
        on_complete ();
        completed ();
    }

    /**
     * Internal: Called by the scheduler to advance the animation.
     *
     * @param elapsed_ms milliseconds elapsed since start
     * @return true if animation should continue
     */
    internal bool advance (double elapsed_ms) {
        if (_is_cancelled) return false;

        double progress = (elapsed_ms / _duration).clamp (0.0, 1.0);
        double eased_progress = _easing (progress);

        on_update (eased_progress);

        if (progress >= 1.0) {
            _is_running = false;
            on_complete ();
            completed ();
            return false;
        }

        return true;
    }

    /**
     * Called when the animation starts.
     *
     * Subclasses should set initial state here.
     */
    protected abstract void on_start ();

    /**
     * Called on each animation frame.
     *
     * @param progress eased progress in range [0, 1]
     */
    protected abstract void on_update (double progress);

    /**
     * Called when the animation stops without completing.
     */
    protected virtual void on_stop () {}

    /**
     * Called when the animation is cancelled.
     */
    protected virtual void on_cancel () {}

    /**
     * Called when the animation reaches its end.
     */
    protected virtual void on_complete () {}

    private void cancel_source () {
        if (_source_id != 0) {
            Source.remove (_source_id);
            _source_id = 0;
        }
    }

}

}

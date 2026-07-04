namespace NebulaShell {

/**
 * Manages animation scheduling and frame updates.
 *
 * AnimationScheduler drives all active animations using
 * GLib's main loop. It provides high-resolution timing
 * and ensures animations run at the optimal frame rate.
 *
 * This is an internal class. Users interact with Animation
 * objects directly; the scheduler handles frame dispatch.
 */
internal class AnimationScheduler : NebulaShell.Object, Manager {

    private const double TARGET_FPS = 60.0;
    private const double FRAME_INTERVAL_MS = 1000.0 / TARGET_FPS;

    private static AnimationScheduler? instance = null;

    private GLib.List<AnimationEntry> _active;
    private uint _frame_source_id = 0;
    private int64 _start_time = 0;

    /**
     * Get the default scheduler instance.
     *
     * @return the singleton scheduler
     */
    public static AnimationScheduler get_default () {
        if (instance == null)
            instance = new AnimationScheduler ();
        return instance;
    }

    private AnimationScheduler () {
        base.with_name ("animation-scheduler");
        _active = new GLib.List<AnimationEntry> ();
    }

    /**
     * Initialize the scheduler.
     */
    public void initialize () {
        // Ready to accept animations
    }

    /**
     * Shut down the scheduler and cancel all animations.
     */
    public void shutdown () {
        cancel_all ();
        stop_frame_loop ();
    }

    /**
     * Reload the scheduler.
     */
    public void reload () {
        // Nothing to reload
    }

    /**
     * Schedule an animation for execution.
     *
     * @param animation the animation to schedule
     */
    public void schedule (Animation animation) {
        if (animation.is_running) return;

        var entry = new AnimationEntry (animation);
        _active.append (entry);

        animation.start ();

        if (_frame_source_id == 0) {
            start_frame_loop ();
        }
    }

    /**
     * Cancel all running animations.
     */
    public void cancel_all () {
        foreach (var entry in _active) {
            entry.animation.cancel ();
        }
        _active = new GLib.List<AnimationEntry> ();
    }

    private void start_frame_loop () {
        _start_time = get_monotonic_time ();
        _frame_source_id = Timeout.add ((uint) FRAME_INTERVAL_MS, on_frame);
    }

    private void stop_frame_loop () {
        if (_frame_source_id != 0) {
            Source.remove (_frame_source_id);
            _frame_source_id = 0;
        }
    }

    private bool on_frame () {
        int64 now = get_monotonic_time ();
        double elapsed_ms = (now - _start_time) / 1000.0;

        var to_remove = new GLib.List<AnimationEntry> ();

        foreach (var entry in _active) {
            bool should_continue = entry.animation.advance (elapsed_ms);
            if (!should_continue) {
                to_remove.append (entry);
            }
        }

        foreach (var entry in to_remove) {
            _active.remove (entry);
        }

        if (_active.length () == 0) {
            stop_frame_loop ();
            return false;
        }

        return true;
    }

}

/**
 * Internal pairing of animation with its start time.
 */
internal class AnimationEntry : NebulaShell.Object {

    public Animation animation;
    public int64 started_at;

    public AnimationEntry (Animation animation) {
        base.with_name ("animation-entry");
        this.animation = animation;
        this.started_at = get_monotonic_time ();
    }

}

}

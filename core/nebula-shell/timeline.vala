namespace NebulaShell {

/**
 * Sequences multiple animations with relative timing.
 *
 * Timeline allows composing several animations into a sequence.
 * Animations can run in parallel, sequentially, or with custom
 * delays. The timeline manages the lifecycle of all child
 * animations as a single unit.
 *
 * Example:
 *   var timeline = new Timeline ("fade-in-slide");
 *   timeline.append (fade_animation);
 *   timeline.append (slide_animation);
 *   timeline.start ();
 */
public class Timeline : NebulaShell.Object {

    private GLib.List<TimelineEntry> _entries;
    private bool _is_running = false;
    private bool _is_cancelled = false;
    private uint _source_id = 0;
    private int64 _start_time = 0;

    /**
     * Emitted when the timeline starts.
     */
    public signal void started ();

    /**
     * Emitted when all animations in the timeline complete.
     */
    public signal void completed ();

    /**
     * Emitted when the timeline is cancelled.
     */
    public signal void cancelled ();

    /**
     * Whether the timeline is currently running.
     */
    public bool is_running {
        get { return _is_running; }
    }

    /**
     * Total duration of the timeline in milliseconds.
     *
     * Calculated from the latest ending animation.
     */
    public double duration {
        get {
            double max_end = 0;
            foreach (var entry in _entries) {
                double end = entry.delay + entry.animation.duration;
                if (end > max_end) max_end = end;
            }
            return max_end;
        }
    }

    /**
     * Create a new timeline.
     *
     * @param name human-readable identifier
     */
    public Timeline (string name) {
        base.with_name (name);
        _entries = new GLib.List<TimelineEntry> ();
    }

    /**
     * Add an animation to the end of the timeline.
     *
     * @param animation the animation to append
     */
    public void append (Animation animation) {
        double offset = duration;
        var entry = new TimelineEntry (animation, offset);
        _entries.append (entry);
    }

    /**
     * Add an animation with a specific delay.
     *
     * @param animation the animation to add
     * @param delay_ms delay before animation starts in milliseconds
     */
    public void add (Animation animation, double delay_ms) {
        var entry = new TimelineEntry (animation, delay_ms);
        _entries.append (entry);
    }

    /**
     * Add an animation to start at a specific time.
     *
     * @param animation the animation to add
     * @param at_ms absolute time in milliseconds from timeline start
     */
    public void at (Animation animation, double at_ms) {
        var entry = new TimelineEntry (animation, at_ms);
        _entries.append (entry);
    }

    /**
     * Start all animations in the timeline.
     *
     * If already running, this method has no effect.
     */
    public void start () {
        if (_is_running) return;

        _is_cancelled = false;
        _is_running = true;
        _start_time = get_monotonic_time ();

        foreach (var entry in _entries) {
            entry.started = false;
            entry.completed = false;
        }

        started ();
    }

    /**
     * Stop the timeline at its current position.
     */
    public void stop () {
        if (!_is_running) return;

        _is_running = false;
        cancel_source ();

        foreach (var entry in _entries) {
            if (entry.started && !entry.completed) {
                entry.animation.stop ();
            }
        }
    }

    /**
     * Cancel the timeline and reset all animations.
     */
    public void cancel () {
        if (!_is_running && !_is_cancelled) return;

        _is_cancelled = true;
        _is_running = false;
        cancel_source ();

        foreach (var entry in _entries) {
            if (entry.started) {
                entry.animation.cancel ();
            }
            entry.started = false;
            entry.completed = false;
        }

        cancelled ();
    }

    /**
     * Complete the timeline immediately.
     */
    public void complete () {
        if (!_is_running) return;

        _is_running = false;
        cancel_source ();

        foreach (var entry in _entries) {
            if (!entry.completed) {
                entry.animation.complete ();
            }
            entry.started = false;
            entry.completed = false;
        }

        completed ();
    }

    /**
     * Internal: Called by the scheduler to advance the timeline.
     *
     * @return true if timeline should continue
     */
    internal bool advance (double elapsed_ms) {
        if (_is_cancelled) return false;

        bool any_running = false;

        foreach (var entry in _entries) {
            if (entry.completed) continue;

            if (!entry.started) {
                if (elapsed_ms >= entry.delay) {
                    entry.animation.start ();
                    entry.started = true;
                } else {
                    any_running = true;
                    continue;
                }
            }

            if (entry.started && !entry.completed) {
                double local_elapsed = elapsed_ms - entry.delay;
                bool should_continue = entry.animation.advance (local_elapsed);
                if (!should_continue) {
                    entry.completed = true;
                } else {
                    any_running = true;
                }
            }
        }

        if (!any_running) {
            _is_running = false;
            completed ();
            return false;
        }

        return true;
    }

    private void cancel_source () {
        if (_source_id != 0) {
            Source.remove (_source_id);
            _source_id = 0;
        }
    }

}

/**
 * Internal entry pairing an animation with its timeline offset.
 */
internal class TimelineEntry : NebulaShell.Object {

    public Animation animation;
    public double delay;
    public bool started;
    public bool completed;

    public TimelineEntry (Animation animation, double delay) {
        base.with_name ("timeline-entry");
        this.animation = animation;
        this.delay = delay;
        this.started = false;
        this.completed = false;
    }

}

}

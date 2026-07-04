namespace NebulaShell {

/**
 * A reactive value derived from other properties.
 *
 * Computed watches one or more source properties and
 * automatically recalculates its value when any source
 * changes. The result is cached and only recomputed when
 * dependencies change.
 *
 * Computed values are lazy by default: they recalculate
 * on the next read after a dependency changes. This avoids
 * unnecessary work when the computed value is not observed.
 *
 * @param T the type of the computed value
 *
 * Example:
 *   var width = new Property<int> ("width", 100);
 *   var height = new Property<int> ("height", 50);
 *   var area = new Computed<int> (() => {
 *       return width.value * height.value;
 *   });
 *   area.watch (width);
 *   area.watch (height);
 *   area.computed_changed.connect ((val) => {
 *       print (@"Area: $(val)\n");
 *   });
 */
public class Computed<T> : Observable {

    /**
     * Emitted when the computed value changes.
     */
    public signal void computed_changed (T value);

    private owned ComputeFunc<T> _compute;
    private T _cached_value;
    private bool _dirty = true;

    /**
     * The current computed value.
     *
     * Recalculates lazily if any dependency has changed
     * since the last read.
     */
    public T value {
        get {
            if (_dirty) {
                recompute ();
            }
            return _cached_value;
        }
    }

    /**
     * Create a computed value from a computation function.
     *
     * The function is called once immediately to set the
     * initial value. Use watch() to add dependencies.
     *
     * @param compute the function that produces the value
     */
    public Computed (owned ComputeFunc<T> compute) {
        _compute = (owned) compute;
        recompute ();
    }

    /**
     * Add a dependency to watch.
     *
     * When the source's `changed` signal fires, the
     * computed value is marked dirty and will recalculate
     * on next read.
     *
     * @param source an observable to watch
     */
    public void watch (Observable source) {
        source.changed.connect (on_dependency_changed);
        mark_dirty ();
    }

    /**
     * Remove a dependency.
     *
     * @param source the observable to stop watching
     */
    public void unwatch (Observable source) {
        source.changed.disconnect (on_dependency_changed);
        mark_dirty ();
    }

    /**
     * Force an immediate recalculation.
     *
     * Bypasses lazy evaluation and recomputes the value
     * right now. Useful when you need to ensure the cached
     * value is up to date before reading it.
     */
    public void recompute () {
        T new_value = _compute ();
        bool changed = !is_equal (new_value, _cached_value);
        _cached_value = new_value;
        _dirty = false;

        if (changed) {
            notify_changed ("computed");
            computed_changed (new_value);
        }
    }

    /**
     * Mark this computed value as stale.
     *
     * The next read of `.value` will trigger recompute.
     */
    private void mark_dirty () {
        _dirty = true;
        notify_changed ("computed");
    }

    /**
     * Handle a dependency property changing.
     */
    private void on_dependency_changed (string property_name) {
        mark_dirty ();
    }

    /**
     * Compare two values for equality.
     */
    private bool is_equal (T a, T b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a == b;
    }

}

/**
 * Function type for computing derived values.
 *
 * @return the computed value
 */
public delegate T ComputeFunc<T> ();

}

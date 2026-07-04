namespace NebulaShell {

/**
 * Base class for reactive state containers.
 *
 * Provides a signal-based change notification mechanism that
 * forms the foundation of the NebulaShell reactive system.
 *
 * Observable objects emit a `changed` signal whenever their
 * internal state is modified. Downstream consumers (bindings,
 * widgets, computed values) subscribe to this signal to
 * propagate state automatically.
 *
 * Example:
 *   class BatteryService : Observable {
 *       private int _percentage = 100;
 *       public int percentage {
 *           get { return _percentage; }
 *           set { _set(ref _percentage, value); }
 *       }
 *   }
 */
public class Observable : GLib.Object {

    /**
     * Emitted whenever observable state changes.
     *
     * Connect to this signal to react to state modifications.
     * The signal carries the name of the property that changed.
     */
    public signal void changed (string property_name);

    /**
     * Emitted when any property on this object changes.
     *
     * This is a convenience signal for listeners that do not
     * care which specific property changed.
     */
    public signal void state_changed ();

    /**
     * Whether change notifications are currently suppressed.
     *
     * When true, property changes will not emit signals.
     * Used for batch updates to avoid redundant notifications.
     */
    private bool _frozen = false;

    /**
     * Suppress change notifications for the duration of a block.
     *
     * Multiple calls nest; signals resume when the outermost
     * freeze ends.
     */
    public void freeze () {
        _frozen = true;
    }

    /**
     * Resume change notifications after a freeze.
     *
     * Emits a single `state_changed` signal if any properties
     * were modified during the frozen period.
     */
    public void thaw () {
        if (!_frozen) return;
        _frozen = false;
        state_changed ();
    }

    /**
     * Emit change signals for a property modification.
     *
     * Intended for use inside property setters to emit both
     * the specific `changed` signal and the general
     * `state_changed` signal. Respects the frozen state.
     *
     * @param property_name the name of the property that changed
     */
    protected void notify_changed (string property_name) {
        if (_frozen) return;
        changed (property_name);
        state_changed ();
    }

}

}

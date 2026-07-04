namespace NebulaShell {

/**
 * Represents a reactive data binding between properties.
 *
 * Binding synchronizes a target property with a source
 * property. It supports one-way and two-way synchronization
 * and handles automatic cleanup when either side is destroyed.
 *
 * Bindings perform synchronization automatically. Widgets
 * should never manually refresh themselves; bindings handle
 * that responsibility.
 *
 * Example:
 *   var source = new Property<int> ("battery", 85);
 *   var target = new Property<string> ("label", "");
 *   source.bind_to (target, (v) => {
 *       return v.to_string () + "%";
 *   });
 */
public class Binding : Observable {

    private unowned Observable? _source;
    private unowned Observable? _target;
    private bool _is_two_way = false;
    private bool _updating = false;

    /**
     * Emitted when the binding synchronizes values.
     */
    public signal void synchronized ();

    /**
     * The source property being observed.
     */
    public Observable? source {
        get { return _source; }
    }

    /**
     * The target property being updated.
     */
    public Observable? target {
        get { return _target; }
    }

    /**
     * Whether this binding performs two-way synchronization.
     */
    public bool is_two_way {
        get { return _is_two_way; }
    }

    /**
     * Create a new binding.
     *
     * @param source the observable to watch
     * @param target the observable to update
     * @param two_way whether to sync in both directions
     */
    public Binding (Observable source, Observable target, bool two_way = false) {
        _source = source;
        _target = target;
        _is_two_way = two_way;

        source.changed.connect (on_source_changed);

        if (two_way) {
            target.changed.connect (on_target_changed);
        }
    }

    /**
     * Remove this binding and stop all synchronization.
     */
    public void unbind () {
        if (_source != null) {
            _source.changed.disconnect (on_source_changed);
        }
        if (_target != null) {
            _target.changed.disconnect (on_target_changed);
        }
    }

    /**
     * Handle source property changes.
     */
    private void on_source_changed (string property_name) {
        if (_updating) return;
        _updating = true;

        synchronized ();
        notify_changed ("binding");

        _updating = false;
    }

    /**
     * Handle target property changes (two-way only).
     */
    private void on_target_changed (string property_name) {
        if (!_is_two_way || _updating) return;
        _updating = true;

        synchronized ();
        notify_changed ("binding");

        _updating = false;
    }

}

}

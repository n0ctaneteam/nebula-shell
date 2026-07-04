namespace NebulaShell {

/**
 * A reactive property that notifies listeners on value changes.
 *
 * Property<T> wraps a value and emits change notifications
 * whenever the value is updated. It is the primary building
 * block of the NebulaShell reactive system.
 *
 * Properties represent state. They do not perform actions.
 * When a property value changes, all connected bindings and
 * observers are notified automatically.
 *
 * @param T the type of the held value
 *
 * Example:
 *   var volume = new Property<int> ("volume", 50);
 *   volume.changed.connect ((name) => {
 *       print (@"Volume changed\n");
 *   });
 *   volume.value = 75;
 */
public class Property<T> : Observable {

    /**
     * Emitted when the property value changes.
     *
     * @param name the name of this property
     * @param value the new value
     */
    public signal void value_changed (string name, T value);

    private string _name;
    private T _value;

    /**
     * The name of this property.
     *
     * Used for identification in signals, bindings, and
     * debug output. Immutable after construction.
     */
    public string name {
        get { return _name; }
    }

    /**
     * The current value of this property.
     *
     * Setting this property emits `value_changed` and
     * `changed` signals if the new value differs from
     * the current one.
     */
    public T value {
        get { return _value; }
        set {
            if (is_equal (value, _value)) return;
            _value = value;
            notify_changed (_name);
            value_changed (_name, value);
        }
    }

    /**
     * Create a new reactive property.
     *
     * @param name human-readable identifier
     * @param initial the starting value
     */
    public Property (string name, T initial) {
        _name = name;
        _value = initial;
    }

    /**
     * Create a one-way binding from this property to a target.
     *
     * When this property changes, the target is updated
     * with the same value.
     *
     * @param target the property to update
     * @return the active binding
     */
    public Binding bind_to (Property<T> target) {
        var binding = new Binding (this, target, false);

        this.value_changed.connect ((name, val) => {
            target.value = val;
        });

        return binding;
    }

    /**
     * Create a one-way binding with a value transform.
     *
     * When this property changes, the transform function
     * is applied and the result is written to the target.
     *
     * @param target the property to update
     * @param transform the value transformation function
     * @return the active binding
     */
    public Binding bind_to_with_transform (Property<T> target,
                                           owned TransformFunc transform) {
        var binding = new Binding (this, target, false);

        this.value_changed.connect ((name, val) => {
            target.value = transform (val);
        });

        return binding;
    }

    /**
     * Create a two-way binding between this property and another.
     *
     * Changes to either property propagate to the other.
     * A guard prevents infinite loops from circular updates.
     *
     * @param other the property to bind with
     * @return the active binding
     */
    public Binding bind_two_way (Property<T> other) {
        var binding = new Binding (this, other, true);

        bool updating = false;

        this.value_changed.connect ((name, val) => {
            if (updating) return;
            updating = true;
            other.value = val;
            updating = false;
        });

        other.value_changed.connect ((name, val) => {
            if (updating) return;
            updating = true;
            this.value = val;
            updating = false;
        });

        return binding;
    }

    /**
     * Compare two values for equality.
     *
     * Uses GLib's direct equality check which covers
     * basic types and boxed values.
     */
    private bool is_equal (T a, T b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a == b;
    }

}

/**
 * Function type for transforming property values.
 *
 * @param input the original value
 * @return the transformed value
 */
public delegate T TransformFunc<T> (T input);

}

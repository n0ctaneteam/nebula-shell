namespace NebulaShell {

/**
 * Configuration data class holding all loaded configuration values.
 *
 * Config is an immutable snapshot of the configuration state at a point
 * in time. ConfigManager creates new Config instances when configuration
 * is loaded or reloaded.
 *
 * Configuration is Python-based. Users write Python scripts that define
 * their shell configuration. ConfigManager loads and executes these
 * scripts, then stores the resulting values here.
 *
 * Example:
 *   var config = config_manager.get_config();
 *   var value = config.get_string("general/theme");
 */
public class Config : GLib.Object {

    private Gee.HashMap<string, GLib.Value?> _values;
    private Gee.HashMap<string, string> _errors;

    /**
     * Create a new empty configuration.
     */
    public Config () {
        _values = new Gee.HashMap<string, GLib.Value?> ();
        _errors = new Gee.HashMap<string, string> ();
    }

    /**
     * Get a string value by key path.
     *
     * @param key dot-separated path to the value
     * @return the string value, or null if not found
     */
    public string? get_string (string key) {
        var value = _values.get (key);
        if (value != null && value.holds (typeof (string)))
            return value.get_string ();
        return null;
    }

    /**
     * Get an integer value by key path.
     *
     * @param key dot-separated path to the value
     * @return the integer value, or 0 if not found
     */
    public int get_int (string key) {
        var value = _values.get (key);
        if (value != null && value.holds (typeof (int)))
            return value.get_int ();
        return 0;
    }

    /**
     * Get a boolean value by key path.
     *
     * @param key dot-separated path to the value
     * @return the boolean value, or false if not found
     */
    public bool get_bool (string key) {
        var value = _values.get (key);
        if (value != null && value.holds (typeof (bool)))
            return value.get_boolean ();
        return false;
    }

    /**
     * Get a double value by key path.
     *
     * @param key dot-separated path to the value
     * @return the double value, or 0.0 if not found
     */
    public double get_double (string key) {
        var value = _values.get (key);
        if (value != null && value.holds (typeof (double)))
            return value.get_double ();
        return 0.0;
    }

    /**
     * Get a raw GLib.Value by key path.
     *
     * @param key dot-separated path to the value
     * @return the value, or null if not found
     */
    public new GLib.Value? @get (string key) {
        return _values.get (key);
    }

    /**
     * Set a value by key path.
     *
     * @param key dot-separated path to the value
     * @param value the value to store
     */
    public new void @set (string key, owned GLib.Value? value) {
        _values.set (key, (owned) value);
    }

    /**
     * Check if a key exists in the configuration.
     *
     * @param key the key to check
     * @return true if the key exists
     */
    public bool has (string key) {
        return _values.has_key (key);
    }

    /**
     * Get all configuration keys.
     *
     * @return a read-only view of all keys
     */
    public Gee.Set<string> get_keys () {
        return _values.keys.read_only_view;
    }

    /**
     * Get the number of configuration values.
     */
    public int size {
        get { return _values.size; }
    }

    /**
     * Get all validation errors.
     *
     * @return a read-only view of errors
     */
    public Gee.Map<string, string> get_errors () {
        return _errors.read_only_view;
    }

    /**
     * Add a validation error.
     *
     * @param key the key that caused the error
     * @param message the error description
     */
    public void add_error (string key, string message) {
        _errors.set (key, message);
    }

    /**
     * Check if the configuration has any errors.
     */
    public bool has_errors {
        get { return _errors.size > 0; }
    }

}

}

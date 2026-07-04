namespace NebulaShell {

/**
 * Singleton registry for framework-wide systems.
 *
 * SingletonRegistry ensures only one instance of each system type
 * is created and registered. Useful for services that must be
 * globally accessible but should not pollute public APIs.
 *
 * Singletons are allowed ONLY for framework-wide systems:
 * ThemeManager, PluginManager, ConfigManager, Logger, etc.
 *
 * Never create singleton widgets.
 *
 * Example:
 *   var registry = SingletonRegistry.get_default();
 *   registry.register("theme", theme_manager);
 *   var theme = registry.get("theme");
 */
public class SingletonRegistry : GLib.Object {

    private static SingletonRegistry? _instance = null;

    private Gee.HashMap<string, GLib.Object> _singletons;

    /**
     * Get the default singleton registry instance.
     *
     * @return the singleton registry
     */
    public static SingletonRegistry get_default () {
        if (_instance == null)
            _instance = new SingletonRegistry ();

        return _instance;
    }

    private SingletonRegistry () {
        _singletons = new Gee.HashMap<string, GLib.Object> ();
    }

    /**
     * Register a singleton instance with the given name.
     *
     * If an instance with the same name already exists,
     * it is replaced. The old instance is unreffed.
     *
     * @param name unique identifier for the singleton
     * @param instance the singleton instance
     */
    public void register (string name, owned GLib.Object instance) {
        if (_singletons.has_key (name)) {
            _singletons.unset (name);
        }
        _singletons.set (name, instance);
    }

    /**
     * Retrieve a registered singleton by name.
     *
     * @param name the name used during registration
     * @return the singleton instance, or null if not found
     */
    public GLib.Object? @get (string name) {
        return _singletons.get (name);
    }

    /**
     * Retrieve a registered singleton cast to a specific type.
     *
     * @param name the name used during registration
     * @return the singleton instance, or null if not found
     */
    public T? get_typed<T> (string name) {
        var obj = _singletons.get (name);
        if (obj != null && obj is T)
            return (T) obj;
        return null;
    }

    /**
     * Check whether a singleton with the given name is registered.
     *
     * @param name the name to check
     * @return true if registered
     */
    public bool has (string name) {
        return _singletons.has_key (name);
    }

    /**
     * Remove a registered singleton by name.
     *
     * @param name the name to remove
     */
    public void unregister (string name) {
        _singletons.unset (name);
    }

    /**
     * Remove all registered singletons.
     */
    public void clear () {
        _singletons.clear ();
    }

    /**
     * Get the number of registered singletons.
     */
    public int size {
        get { return _singletons.size; }
    }

}

}

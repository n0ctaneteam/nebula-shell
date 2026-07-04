namespace NebulaShell {

/**
 * Generic registry for registering and discovering framework objects.
 *
 * ObjectRegistry provides a central lookup mechanism for objects
 * managed by the framework. Objects are registered by name and
 * can be retrieved later for use by other components.
 *
 * ObjectRegistry does NOT own registered objects. Ownership
 * remains with whoever registered them.
 *
 * Example:
 *   var registry = new ObjectRegistry<Manager>();
 *   registry.register("audio", audio_manager);
 *   var manager = registry.get("audio");
 */
public class ObjectRegistry<T> : GLib.Object {

    private Gee.HashMap<string, T> _items;

    public ObjectRegistry () {
        _items = new Gee.HashMap<string, T> ();
    }

    /**
     * Register an object with the given name.
     *
     * If an object with the same name already exists,
     * it is replaced.
     *
     * @param name unique identifier for the object
     * @param item the object to register
     */
    public void register (string name, owned T item) {
        _items.set (name, item);
    }

    /**
     * Retrieve a registered object by name.
     *
     * @param name the name used during registration
     * @return the registered object, or null if not found
     */
    public T? @get (string name) {
        return _items.get (name);
    }

    /**
     * Check whether an object with the given name is registered.
     *
     * @param name the name to check
     * @return true if registered
     */
    public bool has (string name) {
        return _items.has_key (name);
    }

    /**
     * Remove a registered object by name.
     *
     * @param name the name to remove
     */
    public void unregister (string name) {
        _items.unset (name);
    }

    /**
     * Remove all registered objects.
     */
    public void clear () {
        _items.clear ();
    }

    /**
     * Get the number of registered objects.
     */
    public int size {
        get { return _items.size; }
    }

}

}

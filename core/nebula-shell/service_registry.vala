namespace NebulaShell {

/**
 * Central registry for managing framework service instances.
 *
 * ServiceRegistry manages the lifecycle of all services in the framework.
 * Services are registered by name and can be retrieved for use by widgets
 * and other framework components.
 *
 * ServiceRegistry is a singleton. Services are singleton objects.
 * Widgets observe services but never own system state.
 *
 * Features:
 * - Singleton service management
 * - Service lookup by name
 * - Lazy initialization support
 * - Shutdown ordering by dependency
 *
 * Shutdown mirrors initialization in reverse order.
 * Services are initialized in registration order.
 * Services are shut down in reverse registration order.
 *
 * Example:
 *   var registry = ServiceRegistry.get_default();
 *   registry.register("audio", new AudioService());
 *   registry.register("battery", new BatteryService());
 *   registry.initialize_all();
 *
 *   var audio = registry.get<AudioService>("audio");
 *   audio.volume = 80;
 *
 *   registry.shutdown_all();
 */
public class ServiceRegistry : GLib.Object {

    private static ServiceRegistry? _instance = null;

    private Gee.HashMap<string, Service> _services;
    private Gee.ArrayList<string> _load_order;
    private bool _initialized;

    /**
     * Emitted when a service is registered.
     *
     * @param service_name the name of the registered service
     */
    public signal void service_registered (string service_name);

    /**
     * Emitted when a service is unregistered.
     *
     * @param service_name the name of the unregistered service
     */
    public signal void service_unregistered (string service_name);

    /**
     * Get the default ServiceRegistry instance.
     *
     * @return the singleton service registry
     */
    public static ServiceRegistry get_default () {
        if (_instance == null)
            _instance = new ServiceRegistry ();

        return _instance;
    }

    private ServiceRegistry () {
        _services = new Gee.HashMap<string, Service> ();
        _load_order = new Gee.ArrayList<string> ();
        _initialized = false;
    }

    /**
     * Register a service with the given name.
     *
     * If a service with the same name already exists,
     * it is replaced. The old service is shut down first.
     *
     * Services are initialized in registration order.
     *
     * @param name unique identifier for the service
     * @param service the service instance
     */
    public void register (string name, owned Service service) {
        if (_services.has_key (name)) {
            var existing = _services.get (name);
            if (existing.is_initialized) {
                existing.shutdown ();
            }
            _services.unset (name);
            _load_order.remove (name);
        }

        service.service_name = name;
        _services.set (name, service);
        _load_order.add (name);

        Logger.info ("ServiceRegistry: registered service " + name);
        service_registered (name);
    }

    /**
     * Unregister a service by name.
     *
     * The service is shut down if initialized, then removed.
     *
     * @param name the service name to remove
     */
    public void unregister (string name) {
        var service = _services.get (name);
        if (service == null)
            return;

        if (service.is_initialized) {
            service.shutdown ();
        }

        _services.unset (name);
        _load_order.remove (name);

        Logger.info ("ServiceRegistry: unregistered service " + name);
        service_unregistered (name);
    }

    /**
     * Retrieve a service by name.
     *
     * @param name the name used during registration
     * @return the service, or null if not found
     */
    public Service? get (string name) {
        return _services.get (name);
    }

    /**
     * Retrieve a service cast to a specific type.
     *
     * @param name the name used during registration
     * @return the service instance cast to T, or null if not found or wrong type
     */
    public T? get_typed<T> (string name) {
        var service = _services.get (name);
        if (service != null && service is T)
            return (T) service;
        return null;
    }

    /**
     * Check whether a service with the given name is registered.
     *
     * @param name the name to check
     * @return true if registered
     */
    public bool has (string name) {
        return _services.has_key (name);
    }

    /**
     * Initialize all registered services in registration order.
     *
     * Services are initialized in the order they were registered.
     */
    public void initialize_all () {
        if (_initialized)
            return;

        Logger.info ("ServiceRegistry: initializing all services");

        foreach (string name in _load_order) {
            var service = _services.get (name);
            if (service != null && !service.is_initialized) {
                service.initialize ();
            }
        }

        _initialized = true;
        Logger.info ("ServiceRegistry: initialized %d services".printf (_services.size));
    }

    /**
     * Shut down all registered services in reverse registration order.
     *
     * Mirrors initialize_all() in reverse order.
     * Clears the registry after shutdown.
     */
    public void shutdown_all () {
        if (!_initialized)
            return;

        Logger.info ("ServiceRegistry: shutting down all services");

        for (int i = _load_order.size - 1; i >= 0; i--) {
            string name = _load_order[i];
            var service = _services.get (name);
            if (service != null && service.is_initialized) {
                service.shutdown ();
            }
        }

        _services.clear ();
        _load_order.clear ();
        _initialized = false;

        Logger.info ("ServiceRegistry: shut down");
    }

    /**
     * Reload all registered services.
     *
     * Services are reloaded in registration order.
     */
    public void reload_all () {
        if (!_initialized)
            return;

        Logger.info ("ServiceRegistry: reloading all services");

        foreach (string name in _load_order) {
            var service = _services.get (name);
            if (service != null && service.is_initialized) {
                service.reload ();
            }
        }

        Logger.info ("ServiceRegistry: reloaded %d services".printf (_services.size));
    }

    /**
     * Initialize a specific service by name.
     *
     * @param name the service name to initialize
     * @return true if the service was found and initialized
     */
    public bool initialize_service (string name) {
        var service = _services.get (name);
        if (service == null)
            return false;

        if (!service.is_initialized) {
            service.initialize ();
        }

        return true;
    }

    /**
     * Shut down a specific service by name.
     *
     * @param name the service name to shut down
     * @return true if the service was found and shut down
     */
    public bool shutdown_service (string name) {
        var service = _services.get (name);
        if (service == null)
            return false;

        if (service.is_initialized) {
            service.shutdown ();
        }

        return true;
    }

    /**
     * Get all registered service names.
     *
     * @return a read-only view of service names
     */
    public Gee.Set<string> get_service_names () {
        return _services.keys.read_only_view;
    }

    /**
     * Get the number of registered services.
     */
    public int service_count {
        get { return _services.size; }
    }

    /**
     * Whether all services have been initialized.
     */
    public bool is_initialized {
        get { return _initialized; }
    }

}

}

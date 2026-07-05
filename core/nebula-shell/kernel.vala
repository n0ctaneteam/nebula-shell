namespace NebulaShell {

/**
 * Orchestrates framework startup and shutdown.
 *
 * Kernel owns the initialization sequence.
 * Managers are initialized in registration order.
 * Managers are shut down in reverse order.
 *
 * Kernel maintains a registry of managers for discovery
 * by other framework components.
 *
 * Kernel integrates with ServiceRegistry to manage service
 * lifecycle. Services are initialized after managers and
 * shut down before managers, following the dependency order:
 *   managers → services → widgets
 */
public class Kernel : NebulaShell.Object {

    private Gee.ArrayList<Manager> managers;
    private ObjectRegistry<Manager> manager_registry;
    private ServiceRegistry service_registry;
    private bool _booting = false;

    public Kernel () {
        base.with_name ("kernel");
        managers = new Gee.ArrayList<Manager> ();
        manager_registry = new ObjectRegistry<Manager> ();
        service_registry = ServiceRegistry.get_default ();
    }

    /**
     * Register a manager to be initialized and shut down by the kernel.
     *
     * Managers are initialized in registration order.
     * Managers are shut down in reverse registration order.
     *
     * @param name unique name for discovery
     * @param manager the manager to register
     */
    public void register (string name, Manager manager) {
        managers.add (manager);
        manager_registry.register (name, manager);
    }

    /**
     * Retrieve a registered manager by name.
     *
     * @param name the name used during registration
     * @return the manager, or null if not found
     */
    public Manager? get_manager (string name) {
        return manager_registry.get (name);
    }

    /**
     * Check whether a manager with the given name is registered.
     *
     * @param name the name to check
     * @return true if registered
     */
    public bool has_manager (string name) {
        return manager_registry.has (name);
    }

    /**
     * Register a service with the service registry.
     *
     * Services are managed by the ServiceRegistry and are
     * initialized after managers during boot.
     *
     * @param name unique name for the service
     * @param service the service to register
     */
    public void register_service (string name, Service service) {
        service_registry.register (name, service);
    }

    /**
     * Retrieve a registered service by name.
     *
     * @param name the service name
     * @return the service, or null if not found
     */
    public Service? get_service (string name) {
        return service_registry.get (name);
    }

    /**
     * Retrieve a registered service cast to a specific type.
     *
     * @param name the service name
     * @return the service instance cast to T, or null if not found or wrong type
     */
    public T? get_service_typed<T> (string name) {
        return service_registry.get_typed<T> (name);
    }

    /**
     * Check whether a service with the given name is registered.
     *
     * @param name the name to check
     * @return true if registered
     */
    public bool has_service (string name) {
        return service_registry.has (name);
    }

    /**
     * Get the service registry.
     *
     * @return the service registry instance
     */
    public ServiceRegistry get_service_registry () {
        return service_registry;
    }

    /**
     * Initialize all registered managers and services.
     *
     * Managers are initialized first (in registration order),
     * then services are initialized (in registration order).
     */
    public void boot () {
        if (_booting) return;
        _booting = true;
        foreach (var manager in managers) {
            manager.initialize ();
        }
        service_registry.initialize_all ();
        _booting = false;
    }

    /**
     * Shut down all registered services and managers.
     *
     * Services are shut down first (in reverse registration order),
     * then managers are shut down (in reverse registration order).
     *
     * This mirrors boot() in reverse order:
     *   boot:    managers → services
     *   halt:    services → managers
     */
    public void halt () {
        service_registry.shutdown_all ();
        for (int i = managers.size - 1; i >= 0; i--) {
            managers[i].shutdown ();
        }
        manager_registry.clear ();
    }

    /**
     * Reload all registered managers and services.
     */
    public void reload_all () {
        foreach (var manager in managers) {
            manager.reload ();
        }
        service_registry.reload_all ();
    }

}

}

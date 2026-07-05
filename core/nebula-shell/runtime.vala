namespace NebulaShell {

/**
 * Owns all framework managers.
 *
 * Runtime is the central coordinator that Kernel uses
 * to manage the lifecycle of the framework.
 */
internal class Runtime : NebulaShell.Object, Manager {

    private static Runtime? instance = null;

    private Kernel kernel;

    /**
     * Get the default runtime instance.
     *
     * @return the singleton runtime
     */
    public static Runtime get_default () {

        if (instance == null)
            instance = new Runtime ();

        return instance;
    }

    private Runtime () {
        base.with_name ("runtime");
        kernel = new Kernel ();
        // NOTE: Runtime is the coordinator, NOT a managed component.
        // Registering itself as a Manager caused kernel.boot() → runtime.initialize()
        // → kernel.boot() infinite recursion → stack overflow → segfault.
    }

    /**
     * Register a manager with the kernel.
     *
     * @param name unique name for discovery
     * @param manager the manager to register
     */
    public void register_manager (string name, Manager manager) {
        kernel.register (name, manager);
    }

    /**
     * Initialize the runtime and all registered managers.
     */
    public void initialize () {
        kernel.boot ();
    }

    /**
     * Shut down the runtime and all registered managers.
     *
     * Mirrors initialize() in reverse order.
     */
    public void shutdown () {
        kernel.halt ();
    }

    /**
     * Reload all registered managers.
     */
    public void reload () {
        kernel.reload_all ();
    }

}

}

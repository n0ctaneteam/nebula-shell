namespace NebulaShell {

/**
 * Interface for framework managers.
 *
 * Every manager follows the same lifecycle:
 * initialize() → run → shutdown()
 *
 * Shutdown must mirror initialization in reverse order.
 */
public interface Manager : GLib.Object {

    /**
     * Initialize the manager and allocate resources.
     *
     * Heavy initialization belongs here, not in constructors.
     */
    public abstract void initialize ();

    /**
     * Shut down the manager and release resources.
     *
     * Must mirror initialize() in reverse order.
     */
    public abstract void shutdown ();

    /**
     * Reload the manager's state without full restart.
     */
    public abstract void reload ();

}

}

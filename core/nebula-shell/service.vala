namespace NebulaShell {

/**
 * Base class for framework services.
 *
 * Services own system state and expose it through properties,
 * signals, and methods. Widgets observe services but never
 * own system state themselves.
 *
 * Service extends Observable to provide reactive state notifications,
 * and implements the Manager lifecycle pattern (initialize/shutdown/reload)
 * for consistent framework integration.
 *
 * Concrete services must override initialize(), shutdown(), and reload()
 * to manage their specific resources.
 *
 * Properties represent state, signals represent changes, methods perform
 * actions. Never confuse these responsibilities.
 *
 * Services must never:
 * - Poll for state changes
 * - Perform rendering
 * - Own GTK objects
 * - Spawn processes directly
 *
 * Example:
 *   public class AudioService : Service {
 *       private int _volume = 50;
 *       public int volume {
 *           get { return _volume; }
 *           set { _set(ref _volume, value); }
 *       }
 *
 *       protected override void initialize () {
 *           // Connect to audio backend
 *       }
 *
 *       protected override void shutdown () {
 *           // Disconnect from audio backend
 *       }
 *   }
 */
public class Service : Observable, Manager {

    private string _service_name;
    private bool _initialized;

    /**
     * Emitted when the service is initialized.
     */
    public signal void service_initialized ();

    /**
     * Emitted when the service is shut down.
     */
    public signal void service_shutdown ();

    /**
     * Emitted when the service is reloaded.
     */
    public signal void service_reloaded ();

    /**
     * Unique name for this service.
     *
     * Used for lookup in the ServiceRegistry.
     */
    public string service_name {
        get { return _service_name; }
        set { _service_name = value; }
    }

    /**
     * Whether this service has been initialized.
     */
    public bool is_initialized {
        get { return _initialized; }
    }

    /**
     * Create a new service with the given name.
     *
     * @param name unique identifier for this service
     */
    public Service (string name) {
        _service_name = name;
        _initialized = false;
    }

    /**
     * Initialize the service.
     *
     * Heavy initialization belongs here, not in constructors.
     * Subclasses must override this to set up their resources.
     */
    public virtual void initialize () {
        if (_initialized)
            return;

        Logger.info ("Service: initializing " + _service_name);
        on_initialize ();
        _initialized = true;
        service_initialized ();
    }

    /**
     * Shut down the service.
     *
     * Must mirror initialize() in reverse order.
     * Subclasses must override this to release their resources.
     */
    public virtual void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("Service: shutting down " + _service_name);
        on_shutdown ();
        _initialized = false;
        service_shutdown ();
    }

    /**
     * Reload the service's state without full restart.
     *
     * Subclasses should override this to refresh their state.
     */
    public virtual void reload () {
        if (!_initialized)
            return;

        Logger.info ("Service: reloading " + _service_name);
        on_reload ();
        service_reloaded ();
    }

    /**
     * Called during initialization.
     *
     * Subclasses override this to set up their resources.
     */
    protected virtual void on_initialize () {
    }

    /**
     * Called during shutdown.
     *
     * Subclasses override this to release their resources.
     */
    protected virtual void on_shutdown () {
    }

    /**
     * Called during reload.
     *
     * Subclasses override this to refresh their state.
     */
    protected virtual void on_reload () {
    }

}

}

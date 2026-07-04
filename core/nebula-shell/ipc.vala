namespace NebulaShell {

/**
 * Delegate for handling incoming IPC requests.
 *
 * Implementations should process the request and return
 * a response payload, or null if no response is needed.
 *
 * @param method the request method name
 * @param payload the request payload (JSON)
 * @return response payload (JSON), or null
 */
public delegate string? IpcRequestHandler (string method, string? payload);

/**
 * Delegate for handling incoming IPC events.
 *
 * Implementations should process the event.
 * Events are fire-and-forget — no response is expected.
 *
 * @param event_name the event name
 * @param payload the event payload (JSON)
 */
public delegate void IpcEventHandler (string event_name, string? payload);

/**
 * Transport-independent IPC abstraction.
 *
 * Ipc defines the interface for inter-process communication
 * independent of the underlying transport (Unix sockets, TCP, etc.).
 *
 * Implementations provide concrete transport backends.
 *
 * Example:
 *   Ipc server = new IpcServer();
 *   server.register_handler("get-volume", handle_volume);
 *   server.start();
 */
public interface Ipc : GLib.Object {

    /**
     * Start the IPC transport.
     */
    public abstract void start ();

    /**
     * Stop the IPC transport and release resources.
     */
    public abstract void stop ();

    /**
     * Register a request handler for a given method.
     *
     * @param method the method name to handle
     * @param handler the handler to call
     */
    public abstract void register_handler (string method, owned IpcRequestHandler handler);

    /**
     * Unregister a previously registered request handler.
     *
     * @param method the method name to unregister
     */
    public abstract void unregister_handler (string method);

    /**
     * Register an event handler for a given event name.
     *
     * @param event_name the event name to listen for
     * @param handler the handler to call
     */
    public abstract void register_event_handler (string event_name, owned IpcEventHandler handler);

    /**
     * Unregister a previously registered event handler.
     *
     * @param event_name the event name to unregister
     */
    public abstract void unregister_event_handler (string event_name);

    /**
     * Send a request and wait for a response.
     *
     * @param method the method to call
     * @param payload the request payload (JSON), or null
     * @return the response payload (JSON), or null on failure
     */
    public abstract string? send_request (string method, string? payload);

    /**
     * Broadcast an event to all connected clients.
     *
     * @param event_name the event name
     * @param payload the event payload (JSON), or null
     */
    public abstract void broadcast_event (string event_name, string? payload);

    /**
     * Whether the IPC transport is currently running.
     */
    public abstract bool is_running { get; }

}

}

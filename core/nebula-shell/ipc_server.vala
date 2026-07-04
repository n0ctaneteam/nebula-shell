namespace NebulaShell {

/**
 * Container for a registered IPC request handler.
 */
internal class IpcHandlerHolder : GLib.Object {
    public IpcRequestHandler handler;
    public IpcHandlerHolder (owned IpcRequestHandler h) {
        handler = (owned) h;
    }
}

/**
 * Container for a registered IPC event handler.
 */
internal class IpcEventHandlerHolder : GLib.Object {
    public IpcEventHandler handler;
    public IpcEventHandlerHolder (owned IpcEventHandler h) {
        handler = (owned) h;
    }
}

/**
 * IPC server using Unix domain sockets.
 *
 * IpcServer provides a local IPC server backed by Unix sockets.
 * It handles incoming client connections, processes request/response
 * messages, and broadcasts events.
 *
 * The server uses GLib.UnixSocketAddress for local communication,
 * which is fast and does not require network configuration.
 *
 * Example:
 *   var server = new IpcServer("/tmp/nebula-shell.sock");
 *   server.register_handler("get-volume", (method, payload) => {
 *       return "{\"volume\":80}";
 *   });
 *   server.start();
 */
public class IpcServer : Ipc, GLib.Object {

    private string _socket_path;
    private GLib.SocketService? _service;
    private GLib.HashTable<string, IpcHandlerHolder> _handlers;
    private GLib.HashTable<string, IpcEventHandlerHolder> _event_handlers;
    private Gee.ArrayList<GLib.SocketConnection> _clients;
    private bool _running;

    /**
     * Create a new IPC server.
     *
     * @param socket_path the path for the Unix socket
     */
    public IpcServer (string socket_path) {
        _socket_path = socket_path;
        _handlers = new GLib.HashTable<string, IpcHandlerHolder> (GLib.str_hash, GLib.str_equal);
        _event_handlers = new GLib.HashTable<string, IpcEventHandlerHolder> (GLib.str_hash, GLib.str_equal);
        _clients = new Gee.ArrayList<GLib.SocketConnection> ();
        _running = false;
        _service = null;
    }

    /**
     * The socket path used by this server.
     */
    public string socket_path {
        get { return _socket_path; }
    }

    /**
     * Whether the server is currently running.
     */
    public bool is_running {
        get { return _running; }
    }

    /**
     * Start the IPC server.
     *
     * Creates the Unix socket and begins listening for connections.
     * Removes any existing socket file before binding.
     */
    public void start () {
        if (_running)
            return;

        try {
            var socket_file = GLib.File.new_for_path (_socket_path);
            if (socket_file.query_exists ())
                socket_file.delete (null);

            _service = new GLib.SocketService ();
            var address = new GLib.UnixSocketAddress (_socket_path);
            GLib.SocketAddress? effective = null;
            _service.add_address (address, GLib.SocketType.STREAM, GLib.SocketProtocol.DEFAULT, null, out effective);

            _service.incoming.connect (on_incoming_connection);

            _running = true;
            Logger.info ("IPC server started on " + _socket_path);
        } catch (Error e) {
            Logger.error ("IPC server failed to start: " + e.message);
        }
    }

    /**
     * Stop the IPC server and close all connections.
     */
    public void stop () {
        if (!_running)
            return;

        _running = false;

        if (_service != null) {
            _service.stop ();
            _service = null;
        }

        foreach (var client in _clients) {
            try {
                client.close (null);
            } catch (Error e) {
                Logger.warning ("IPC: failed to close client: " + e.message);
            }
        }
        _clients.clear ();

        try {
            var socket_file = GLib.File.new_for_path (_socket_path);
            if (socket_file.query_exists ())
                socket_file.delete (null);
        } catch (Error e) {
            Logger.warning ("IPC: failed to remove socket file: " + e.message);
        }

        Logger.info ("IPC server stopped");
    }

    /**
     * Register a request handler for a given method.
     *
     * @param method the method name to handle
     * @param handler the handler to call
     */
    public void register_handler (string method, owned IpcRequestHandler handler) {
        _handlers.set (method, new IpcHandlerHolder ((owned) handler));
    }

    /**
     * Unregister a previously registered request handler.
     *
     * @param method the method name to unregister
     */
    public void unregister_handler (string method) {
        _handlers.remove (method);
    }

    /**
     * Register an event handler for a given event name.
     *
     * @param event_name the event name to listen for
     * @param handler the handler to call
     */
    public void register_event_handler (string event_name, owned IpcEventHandler handler) {
        _event_handlers.set (event_name, new IpcEventHandlerHolder ((owned) handler));
    }

    /**
     * Unregister a previously registered event handler.
     *
     * @param event_name the event name to unregister
     */
    public void unregister_event_handler (string event_name) {
        _event_handlers.remove (event_name);
    }

    /**
     * Send a request and wait for a response.
     *
     * This is primarily for client-side usage.
     * Server-side request handling is done via registered handlers.
     *
     * @param method the method to call
     * @param payload the request payload (JSON), or null
     * @return the response payload (JSON), or null on failure
     */
    public string? send_request (string method, string? payload) {
        Logger.warning ("IPC: send_request not supported on server side");
        return null;
    }

    /**
     * Broadcast an event to all connected clients.
     *
     * @param event_name the event name
     * @param payload the event payload (JSON), or null
     */
    public void broadcast_event (string event_name, string? payload) {
        if (!_running)
            return;

        var id = generate_id ();
        var msg = new IpcMessage (IpcMessageType.EVENT, id, event_name, payload);
        var json = msg.to_json () + "\n";

        var stale = new Gee.ArrayList<GLib.SocketConnection> ();

        foreach (var client in _clients) {
            try {
                var output = client.get_output_stream ();
                output.write (json.data);
            } catch (Error e) {
                Logger.warning ("IPC: failed to broadcast to client: " + e.message);
                stale.add (client);
            }
        }

        foreach (var client in stale) {
            _clients.remove (client);
        }
    }

    private bool on_incoming_connection (GLib.SocketConnection connection, GLib.Object? source_object) {
        _clients.add (connection);

        var input = connection.get_input_stream ();
        var buf = new uint8[4096];

        read_loop.begin (connection, input, buf);
        return true;
    }

    private async void read_loop (GLib.SocketConnection connection, GLib.InputStream input, uint8[] buf) {
        while (_running) {
            try {
                ssize_t bytes_read = yield input.read_async (buf, GLib.Priority.DEFAULT);

                if (bytes_read <= 0) {
                    _clients.remove (connection);
                    break;
                }

                string raw = (string) buf[0:bytes_read];
                handle_raw_message (raw);
            } catch (Error e) {
                Logger.warning ("IPC: read error: " + e.message);
                _clients.remove (connection);
                break;
            }
        }
    }

    private void handle_raw_message (string raw) {
        string[] lines = raw.split ("\n");

        foreach (unowned string line in lines) {
            if (line.strip ().length == 0)
                continue;

            var msg = IpcMessage.from_json (line);
            if (msg == null)
                continue;

            if (msg.message_type == IpcMessageType.REQUEST) {
                handle_request (msg);
            } else if (msg.message_type == IpcMessageType.EVENT) {
                handle_event_message (msg);
            }
        }
    }

    private void handle_request (IpcMessage request) {
        if (request.method == null)
            return;

        if (!_handlers.contains (request.method)) {
            var response = new IpcMessage (
                IpcMessageType.RESPONSE, request.id, null, null
            );
            response.status = 404;
            send_to_all (response);
            return;
        }

        try {
            var holder = _handlers.get (request.method);
            string? result = holder.handler (request.method, request.payload);
            var response = new IpcMessage (
                IpcMessageType.RESPONSE, request.id, null, result
            );
            response.status = 0;
            send_to_all (response);
        } catch (Error e) {
            var response = new IpcMessage (
                IpcMessageType.ERROR, request.id, null, null
            );
            response.status = 500;
            send_to_all (response);
        }
    }

    private void handle_event_message (IpcMessage event) {
        if (event.method == null)
            return;

        if (_event_handlers.contains (event.method)) {
            try {
                var holder = _event_handlers.get (event.method);
                holder.handler (event.method, event.payload);
            } catch (Error e) {
                Logger.warning ("IPC: event handler error: " + e.message);
            }
        }
    }

    private void send_to_all (IpcMessage msg) {
        var json = msg.to_json () + "\n";
        var stale = new Gee.ArrayList<GLib.SocketConnection> ();

        foreach (var client in _clients) {
            try {
                var output = client.get_output_stream ();
                output.write (json.data);
            } catch (Error e) {
                stale.add (client);
            }
        }

        foreach (var client in stale) {
            _clients.remove (client);
        }
    }

    private static uint _id_counter = 0;

    private static string generate_id () {
        _id_counter++;
        int64 now = GLib.get_real_time () / 1000;
        return "msg-%lld-%u".printf (now, _id_counter);
    }

}

}

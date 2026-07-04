namespace NebulaShell {

/**
 * IPC client for connecting to an IPC server.
 *
 * IpcClient provides a client-side IPC transport backed by Unix sockets.
 * It can send requests and receive responses, as well as listen for
 * broadcast events from the server.
 *
 * Example:
 *   var client = new IpcClient("/tmp/nebula-shell.sock");
 *   client.start();
 *   string? result = client.send_request("get-volume", null);
 *   client.stop();
 */
public class IpcClient : Ipc, GLib.Object {

    private string _socket_path;
    private GLib.SocketConnection? _connection;
    private GLib.HashTable<string, IpcEventHandlerHolder> _event_handlers;
    private bool _running;

    /**
     * Create a new IPC client.
     *
     * @param socket_path the path of the Unix socket to connect to
     */
    public IpcClient (string socket_path) {
        _socket_path = socket_path;
        _event_handlers = new GLib.HashTable<string, IpcEventHandlerHolder> (GLib.str_hash, GLib.str_equal);
        _running = false;
        _connection = null;
    }

    /**
     * The socket path this client connects to.
     */
    public string socket_path {
        get { return _socket_path; }
    }

    /**
     * Whether the client is currently connected.
     */
    public bool is_running {
        get { return _running; }
    }

    /**
     * Connect to the IPC server.
     *
     * Establishes the Unix socket connection and begins
     * listening for incoming messages.
     */
    public void start () {
        if (_running)
            return;

        try {
            var client = new GLib.SocketClient ();
            var address = new GLib.UnixSocketAddress (_socket_path);
            _connection = client.connect (address, null);

            _running = true;
            listen_for_messages ();
            Logger.info ("IPC client connected to " + _socket_path);
        } catch (Error e) {
            Logger.error ("IPC client failed to connect: " + e.message);
        }
    }

    /**
     * Disconnect from the IPC server.
     */
    public void stop () {
        if (!_running)
            return;

        _running = false;

        if (_connection != null) {
            try {
                _connection.close (null);
            } catch (Error e) {
                Logger.warning ("IPC: failed to close connection: " + e.message);
            }
            _connection = null;
        }

        Logger.info ("IPC client disconnected");
    }

    /**
     * Register a handler for incoming requests (client-side).
     *
     * @param method the method name to handle
     * @param handler the handler to call
     */
    public void register_handler (string method, owned IpcRequestHandler handler) {
    }

    /**
     * Unregister a previously registered handler.
     *
     * @param method the method name to unregister
     */
    public void unregister_handler (string method) {
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
     * Send a request to the server and wait for a response.
     *
     * @param method the method to call
     * @param payload the request payload (JSON), or null
     * @return the response payload (JSON), or null on failure
     */
    public string? send_request (string method, string? payload) {
        if (!_running || _connection == null)
            return null;

        var id = generate_id ();
        var msg = new IpcMessage (IpcMessageType.REQUEST, id, method, payload);
        var json = msg.to_json () + "\n";

        try {
            var output = _connection.get_output_stream ();
            output.write (json.data);

            var input = _connection.get_input_stream ();
            var buf = new uint8[4096];
            ssize_t bytes_read = input.read (buf);

            if (bytes_read <= 0)
                return null;

            string raw = (string) buf[0:bytes_read];
            string[] lines = raw.split ("\n");

            foreach (unowned string line in lines) {
                if (line.strip ().length == 0)
                    continue;

                var response = IpcMessage.from_json (line);
                if (response != null && response.id == id) {
                    return response.payload;
                }
            }

            return null;
        } catch (Error e) {
            Logger.error ("IPC: send_request failed: " + e.message);
            return null;
        }
    }

    /**
     * Broadcast an event to the server.
     *
     * @param event_name the event name
     * @param payload the event payload (JSON), or null
     */
    public void broadcast_event (string event_name, string? payload) {
        if (!_running || _connection == null)
            return;

        var id = generate_id ();
        var msg = new IpcMessage (IpcMessageType.EVENT, id, event_name, payload);
        var json = msg.to_json () + "\n";

        try {
            var output = _connection.get_output_stream ();
            output.write (json.data);
        } catch (Error e) {
            Logger.error ("IPC: broadcast_event failed: " + e.message);
        }
    }

    private void listen_for_messages () {
        if (_connection == null)
            return;

        var input = _connection.get_input_stream ();
        var buf = new uint8[4096];

        read_loop.begin (input, buf);
    }

    private async void read_loop (GLib.InputStream input, uint8[] buf) {
        while (_running) {
            try {
                ssize_t bytes_read = yield input.read_async (buf, GLib.Priority.DEFAULT);

                if (bytes_read <= 0) {
                    _running = false;
                    Logger.warning ("IPC: server disconnected");
                    break;
                }

                string raw = (string) buf[0:bytes_read];
                handle_raw_message (raw);
            } catch (Error e) {
                Logger.warning ("IPC: read error: " + e.message);
                _running = false;
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

            if (msg.message_type == IpcMessageType.RESPONSE) {
                Logger.debug ("IPC: received response for " + msg.id);
            } else if (msg.message_type == IpcMessageType.EVENT) {
                handle_event (msg);
            } else if (msg.message_type == IpcMessageType.ERROR) {
                Logger.warning ("IPC: received error for " + msg.id);
            }
        }
    }

    private void handle_event (IpcMessage event) {
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

    private static uint _id_counter = 0;

    private static string generate_id () {
        _id_counter++;
        int64 now = GLib.get_real_time () / 1000;
        return "msg-%lld-%u".printf (now, _id_counter);
    }

}

}

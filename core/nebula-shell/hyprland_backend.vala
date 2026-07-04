namespace NebulaShell {

/**
 * Hyprland compositor backend.
 *
 * HyprlandBackend provides a Compositor implementation for the Hyprland
 * compositor. It communicates with Hyprland through its Unix socket IPC
 * interface to receive real-time state updates and dispatch commands.
 *
 * Hyprland receives first-class support in NebulaShell. This backend
 * uses Hyprland's event system to provide reactive workspace, window,
 * and monitor tracking without polling.
 *
 * Features:
 * - Workspace events (create, destroy, focus, change)
 * - Window events (create, destroy, focus, change)
 * - Monitor events (add, remove, change)
 * - Focused workspace tracking
 * - Focused window tracking
 * - Real-time state synchronization via IPC
 *
 * Example:
 *   var backend = new HyprlandBackend ();
 *   backend.initialize ();
 *   var workspaces = backend.get_workspaces ();
 *   backend.shutdown ();
 */
public class HyprlandBackend : Service, Compositor {

    private IpcClient? _ipc_client;
    private string _socket_path;
    private Gee.HashMap<int, Workspace> _workspaces;
    private Gee.HashMap<string, WindowInfo> _windows;
    private Gee.HashMap<int, MonitorInfo> _monitors;
    private Workspace? _focused_workspace;
    private WindowInfo? _focused_window;
    private MonitorInfo? _focused_monitor;

    /**
     * Whether the Hyprland backend is currently connected.
     */
    public bool is_connected {
        get { return _ipc_client != null && _ipc_client.is_running; }
    }

    /**
     * Create a new HyprlandBackend.
     *
     * The socket path is determined from the HYPRLAND_INSTANCE_SIGNATURE
     * environment variable.
     */
    public HyprlandBackend () {
        base ("hyprland");
        _workspaces = new Gee.HashMap<int, Workspace> ();
        _windows = new Gee.HashMap<string, WindowInfo> ();
        _monitors = new Gee.HashMap<int, MonitorInfo> ();
        _focused_workspace = null;
        _focused_window = null;
        _focused_monitor = null;
        _ipc_client = null;

        _socket_path = resolve_socket_path ();
    }

    /**
     * Initialize the Hyprland backend.
     *
     * Connects to the Hyprland IPC socket and subscribes to events.
     */
    public override void initialize () {
        base.initialize ();

        Logger.info ("HyprlandBackend: connecting to " + _socket_path);

        _ipc_client = new IpcClient (_socket_path);
        _ipc_client.start ();

        if (!_ipc_client.is_running) {
            Logger.error ("HyprlandBackend: failed to connect to Hyprland IPC");
            return;
        }

        register_event_handlers ();
        fetch_initial_state ();

        Logger.info ("HyprlandBackend: connected successfully");
    }

    /**
     * Shut down the Hyprland backend.
     *
     * Disconnects from the Hyprland IPC socket and clears state.
     */
    public override void shutdown () {
        if (_ipc_client != null) {
            _ipc_client.stop ();
            _ipc_client = null;
        }

        _workspaces.clear ();
        _windows.clear ();
        _monitors.clear ();
        _focused_workspace = null;
        _focused_window = null;
        _focused_monitor = null;

        Logger.info ("HyprlandBackend: disconnected");

        base.shutdown ();
    }

    /**
     * Reload the Hyprland backend state.
     *
     * Re-fetches all state from the compositor.
     */
    public override void reload () {
        if (!is_connected) return;

        _workspaces.clear ();
        _windows.clear ();
        _monitors.clear ();

        fetch_initial_state ();

        Logger.info ("HyprlandBackend: reloaded");

        base.reload ();
    }

    /**
     * Get the name of this compositor backend.
     *
     * @return "hyprland"
     */
    public string get_compositor_name () {
        return "hyprland";
    }

    /**
     * Get all workspaces.
     *
     * @return list of all workspaces
     */
    public Workspace[] get_workspaces () {
        var result = new Workspace[0];
        foreach (var workspace in _workspaces.values) {
            result += workspace;
        }
        return result;
    }

    /**
     * Get the currently focused workspace.
     *
     * @return the focused workspace, or null if none
     */
    public Workspace? get_focused_workspace () {
        return _focused_workspace;
    }

    /**
     * Get all windows.
     *
     * @return list of all windows
     */
    public WindowInfo[] get_windows () {
        var result = new WindowInfo[0];
        foreach (var window in _windows.values) {
            result += window;
        }
        return result;
    }

    /**
     * Get the currently focused window.
     *
     * @return the focused window, or null if none
     */
    public WindowInfo? get_focused_window () {
        return _focused_window;
    }

    /**
     * Get all monitors.
     *
     * @return list of all monitors
     */
    public MonitorInfo[] get_monitors () {
        var result = new MonitorInfo[0];
        foreach (var monitor in _monitors.values) {
            result += monitor;
        }
        return result;
    }

    /**
     * Get the currently focused monitor.
     *
     * @return the focused monitor, or null if none
     */
    public MonitorInfo? get_focused_monitor () {
        return _focused_monitor;
    }

    /**
     * Dispatch a request to Hyprland.
     *
     * @param method the request method
     * @param payload the request payload, or null
     * @return the response payload, or null
     */
    public string? dispatch (string method, string? payload) {
        if (!is_connected) return null;
        return _ipc_client.send_request (method, payload);
    }

    private string resolve_socket_path () {
        string instance = GLib.Environment.get_variable ("HYPRLAND_INSTANCE_SIGNATURE");
        if (instance == null || instance.length == 0) {
            Logger.warning ("HyprlandBackend: HYPRLAND_INSTANCE_SIGNATURE not set");
            return "/tmp/hyprland-ipc.sock";
        }

        string runtime_dir = GLib.Environment.get_variable ("XDG_RUNTIME_DIR");
        if (runtime_dir == null || runtime_dir.length == 0) {
            Logger.warning ("HyprlandBackend: XDG_RUNTIME_DIR not set");
            return "/tmp/hyprland-ipc.sock";
        }

        return runtime_dir + "/hypr/" + instance + "/.socket.sock";
    }

    private void register_event_handlers () {
        _ipc_client.register_event_handler ("workspace", handle_workspace_event);
        _ipc_client.register_event_handler ("createworkspace", handle_workspace_create_event);
        _ipc_client.register_event_handler ("destroyworkspace", handle_workspace_destroy_event);
        _ipc_client.register_event_handler ("urgent", handle_urgent_event);
        _ipc_client.register_event_handler ("moveworkspace", handle_workspace_move_event);
        _ipc_client.register_event_handler ("renameworkspace", handle_workspace_rename_event);
        _ipc_client.register_event_handler ("openwindow", handle_window_open_event);
        _ipc_client.register_event_handler ("closewindow", handle_window_close_event);
        _ipc_client.register_event_handler ("focuswindow", handle_window_focus_event);
        _ipc_client.register_event_handler ("activewindow", handle_window_active_event);
        _ipc_client.register_event_handler ("monitoradded", handle_monitor_add_event);
        _ipc_client.register_event_handler ("monitorremoved", handle_monitor_remove_event);
        _ipc_client.register_event_handler ("focusedmon", handle_monitor_focus_event);
        _ipc_client.register_event_handler ("activespecial", handle_special_event);
    }

    private void fetch_initial_state () {
        fetch_workspaces ();
        fetch_windows ();
        fetch_monitors ();
    }

    private void fetch_workspaces () {
        string? response = dispatch ("j/workspaces", null);
        if (response == null) return;

        try {
            var parser = new Json.Parser ();
            parser.load_from_data (response);
            var root = parser.get_root ();
            if (root.get_node_type () != Json.NodeType.ARRAY) return;

            var array = root.get_array ();
            foreach (var element in array.get_elements ()) {
                if (element.get_node_type () != Json.NodeType.OBJECT) continue;
                var obj = element.get_object ();
                var workspace = Workspace.from_json (obj);
                _workspaces.set (workspace.id, workspace);

                if (workspace.focused) {
                    _focused_workspace = workspace;
                }
            }
        } catch (Error e) {
            Logger.error ("HyprlandBackend: failed to parse workspaces: " + e.message);
        }
    }

    private void fetch_windows () {
        string? response = dispatch ("j/clients", null);
        if (response == null) return;

        try {
            var parser = new Json.Parser ();
            parser.load_from_data (response);
            var root = parser.get_root ();
            if (root.get_node_type () != Json.NodeType.ARRAY) return;

            var array = root.get_array ();
            foreach (var element in array.get_elements ()) {
                if (element.get_node_type () != Json.NodeType.OBJECT) continue;
                var obj = element.get_object ();
                var window = WindowInfo.from_json (obj);
                _windows.set (window.address, window);

                if (window.focused) {
                    _focused_window = window;
                }
            }
        } catch (Error e) {
            Logger.error ("HyprlandBackend: failed to parse windows: " + e.message);
        }
    }

    private void fetch_monitors () {
        string? response = dispatch ("j/monitors", null);
        if (response == null) return;

        try {
            var parser = new Json.Parser ();
            parser.load_from_data (response);
            var root = parser.get_root ();
            if (root.get_node_type () != Json.NodeType.ARRAY) return;

            var array = root.get_array ();
            foreach (var element in array.get_elements ()) {
                if (element.get_node_type () != Json.NodeType.OBJECT) continue;
                var obj = element.get_object ();
                var monitor = MonitorInfo.from_json (obj);
                _monitors.set (monitor.id, monitor);

                if (monitor.focused) {
                    _focused_monitor = monitor;
                }
            }
        } catch (Error e) {
            Logger.error ("HyprlandBackend: failed to parse monitors: " + e.message);
        }
    }

    private void handle_workspace_event (string event_name, string? payload) {
        if (payload == null) return;

        int workspace_id = int.parse (payload);
        Workspace? ws = _workspaces.get (workspace_id);

        if (ws != null) {
            _focused_workspace = ws;
            workspace_focused (ws);
            focused_workspace_changed (ws);
        }
    }

    private void handle_workspace_create_event (string event_name, string? payload) {
        if (payload == null) return;

        string name = payload;
        int id = int.parse (name);
        var workspace = new Workspace (id, name, 0, "", false, true, 0);
        _workspaces.set (id, workspace);
        workspace_created (workspace);
    }

    private void handle_workspace_destroy_event (string event_name, string? payload) {
        if (payload == null) return;

        int workspace_id = int.parse (payload);
        Workspace? workspace = null;
        _workspaces.unset (workspace_id, out workspace);

        if (workspace != null) {
            workspace_destroyed (workspace);
        }
    }

    private void handle_workspace_move_event (string event_name, string? payload) {
        if (payload == null) return;

        string[] parts = payload.split (",", 2);
        if (parts.length < 2) return;

        int workspace_id = int.parse (parts[0]);
        Workspace? workspace = _workspaces.get (workspace_id);

        if (workspace != null) {
            workspace_changed (workspace);
        }
    }

    private void handle_workspace_rename_event (string event_name, string? payload) {
        if (payload == null) return;

        string[] parts = payload.split (",", 2);
        if (parts.length < 2) return;

        int workspace_id = int.parse (parts[0]);
        Workspace? workspace = _workspaces.get (workspace_id);

        if (workspace != null) {
            workspace_changed (workspace);
        }
    }

    private void handle_window_open_event (string event_name, string? payload) {
        if (payload == null) return;

        string[] parts = payload.split (",", 5);
        if (parts.length < 5) return;

        string address = parts[0];
        string window_class = parts[1];
        string title = parts[2];
        int workspace_id = int.parse (parts[3]);
        bool floating = parts[4] == "1";

        string workspace_name = workspace_id.to_string ();
        Workspace? ws = _workspaces.get (workspace_id);
        if (ws != null) {
            workspace_name = ws.workspace_name;
        }

        var window = new WindowInfo (
            address, title, window_class, "",
            workspace_id, workspace_name, false, floating,
            false, false, 0, "", 0, "", 0, 0, 0, 0
        );

        _windows.set (address, window);
        window_created (window);
    }

    private void handle_window_close_event (string event_name, string? payload) {
        if (payload == null) return;

        WindowInfo? window = null;
        _windows.unset (payload, out window);

        if (window != null) {
            window_destroyed (window);
        }
    }

    private void handle_window_focus_event (string event_name, string? payload) {
        if (payload == null) return;

        string address = payload;
        WindowInfo? window = _windows.get (address);

        if (window != null) {
            _focused_window = window;
            window_focused (window);
            focused_window_changed (window);
        }
    }

    private void handle_window_active_event (string event_name, string? payload) {
        if (payload == null) return;

        string address = payload;
        WindowInfo? window = _windows.get (address);

        if (window != null) {
            _focused_window = window;
            window_focused (window);
            focused_window_changed (window);
        }
    }

    private void handle_monitor_add_event (string event_name, string? payload) {
        if (payload == null) return;

        fetch_monitors ();

        string monitor_name = payload;
        foreach (var monitor in _monitors.values) {
            if (monitor.monitor_name == monitor_name) {
                monitor_added (monitor);
                return;
            }
        }
    }

    private void handle_monitor_remove_event (string event_name, string? payload) {
        if (payload == null) return;

        string monitor_name = payload;
        MonitorInfo? removed = null;

        foreach (var entry in _monitors.entries) {
            if (entry.value.monitor_name == monitor_name) {
                removed = entry.value;
                _monitors.unset (entry.key);
                break;
            }
        }

        if (removed != null) {
            monitor_removed (removed);
        }
    }

    private void handle_monitor_focus_event (string event_name, string? payload) {
        if (payload == null) return;

        string monitor_name = payload;
        foreach (var monitor in _monitors.values) {
            if (monitor.monitor_name == monitor_name) {
                _focused_monitor = monitor;
                monitor_changed (monitor);
                return;
            }
        }
    }

    private void handle_special_event (string event_name, string? payload) {
        if (payload == null) return;

        string[] parts = payload.split (",", 2);
        if (parts.length < 2) return;

        string workspace_name = parts[0];

        foreach (var workspace in _workspaces.values) {
            if (workspace.workspace_name == workspace_name) {
                _focused_workspace = workspace;
                workspace_focused (workspace);
                focused_workspace_changed (workspace);
                return;
            }
        }
    }

    private void handle_urgent_event (string event_name, string? payload) {
        if (payload == null) return;

        string address = payload;
        WindowInfo? window = _windows.get (address);

        if (window != null) {
            window_changed (window);
        }
    }

}

}

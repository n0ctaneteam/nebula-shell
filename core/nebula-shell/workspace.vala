namespace NebulaShell {

/**
 * Represents a compositor workspace.
 *
 * Workspace is a data class that holds information about a compositor
 * workspace. It is used by compositor backends to expose workspace
 * state to the framework.
 *
 * Workspace objects are created by compositor backends and should
 * not be created directly by widgets or applications.
 *
 * Example:
 *   var workspaces = compositor.get_workspaces ();
 *   foreach (var ws in workspaces) {
 *       Logger.info (ws.name + " on " + ws.monitor_name);
 *   }
 */
public class Workspace : GLib.Object {

    private int _id;
    private string _name;
    private int _monitor_id;
    private string _monitor_name;
    private bool _focused;
    private bool _active;
    private int _windows;

    /**
     * Unique identifier for this workspace.
     */
    public int id {
        get { return _id; }
    }

    /**
     * Human-readable name for this workspace.
     *
     * Typically a number or label assigned by the compositor.
     */
    public string workspace_name {
        get { return _name; }
    }

    /**
     * Identifier of the monitor this workspace is on.
     */
    public int monitor_id {
        get { return _monitor_id; }
    }

    /**
     * Name of the monitor this workspace is on.
     */
    public string monitor_name {
        get { return _monitor_name; }
    }

    /**
     * Whether this workspace is currently focused.
     */
    public bool focused {
        get { return _focused; }
    }

    /**
     * Whether this workspace is currently active (visible).
     */
    public bool active {
        get { return _active; }
    }

    /**
     * Number of windows on this workspace.
     */
    public int windows {
        get { return _windows; }
    }

    /**
     * Create a new workspace instance.
     *
     * @param id unique identifier
     * @param name human-readable name
     * @param monitor_id monitor identifier
     * @param monitor_name monitor name
     * @param focused whether this workspace is focused
     * @param active whether this workspace is active
     * @param windows number of windows
     */
    public Workspace (int id, string name, int monitor_id,
                      string monitor_name, bool focused,
                      bool active, int windows) {
        _id = id;
        _name = name;
        _monitor_id = monitor_id;
        _monitor_name = monitor_name;
        _focused = focused;
        _active = active;
        _windows = windows;
    }

    /**
     * Create a workspace from a JSON object.
     *
     * @param json the JSON object to parse
     * @return a new Workspace instance
     */
    internal static Workspace from_json (Json.Object json) {
        int id = (int) json.get_int_member ("id");
        string name = json.get_string_member ("name");
        int monitor_id = (int) json.get_int_member ("monitorId");
        string monitor_name = json.get_string_member ("monitor");
        bool focused = json.get_boolean_member ("focused");
        bool active = json.get_boolean_member ("active");
        int windows = (int) json.get_int_member ("windows");

        return new Workspace (id, name, monitor_id, monitor_name,
                              focused, active, windows);
    }

    /**
     * Convert this workspace to a JSON object.
     *
     * @return a new JSON object representing this workspace
     */
    public Json.Object to_json () {
        var obj = new Json.Object ();
        obj.set_int_member ("id", _id);
        obj.set_string_member ("name", _name);
        obj.set_int_member ("monitorId", _monitor_id);
        obj.set_string_member ("monitor", _monitor_name);
        obj.set_boolean_member ("focused", _focused);
        obj.set_boolean_member ("active", _active);
        obj.set_int_member ("windows", _windows);
        return obj;
    }

    /**
     * Get a string representation of this workspace.
     *
     * @return a human-readable string
     */
    public string to_string () {
        return "Workspace(%d, %s, monitor=%s, focused=%s, windows=%d)"
            .printf (_id, _name, _monitor_name,
                     _focused ? "true" : "false", _windows);
    }

}

}

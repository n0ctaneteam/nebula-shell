namespace NebulaShell {

/**
 * Represents information about a compositor monitor.
 *
 * MonitorInfo is a data class that holds information about a monitor
 * managed by the compositor. It is used by compositor backends to
 * expose monitor state to the framework.
 *
 * MonitorInfo objects are created by compositor backends and should
 * not be created directly by widgets or applications.
 *
 * Example:
 *   var monitors = compositor.get_monitors ();
 *   foreach (var mon in monitors) {
 *       Logger.info (mon.name + " at " + mon.x.to_string () + "," + mon.y.to_string ());
 *   }
 */
public class MonitorInfo : GLib.Object {

    private int _id;
    private string _name;
    private int _x;
    private int _y;
    private int _width;
    private int _height;
    private double _scale;
    private int _refresh_rate;
    private bool _focused;
    private string _active_workspace_name;
    private int _active_workspace_id;

    /**
     * Unique identifier for this monitor.
     */
    public int id {
        get { return _id; }
    }

    /**
     * Human-readable name for this monitor.
     */
    public string monitor_name {
        get { return _name; }
    }

    /**
     * X coordinate of the monitor in the global coordinate space.
     */
    public int x {
        get { return _x; }
    }

    /**
     * Y coordinate of the monitor in the global coordinate space.
     */
    public int y {
        get { return _y; }
    }

    /**
     * Width of the monitor in logical pixels.
     */
    public int width {
        get { return _width; }
    }

    /**
     * Height of the monitor in logical pixels.
     */
    public int height {
        get { return _height; }
    }

    /**
     * Scale factor of the monitor.
     */
    public double scale {
        get { return _scale; }
    }

    /**
     * Refresh rate of the monitor in Hz.
     */
    public int refresh_rate {
        get { return _refresh_rate; }
    }

    /**
     * Whether this monitor is currently focused.
     */
    public bool focused {
        get { return _focused; }
    }

    /**
     * Name of the active workspace on this monitor.
     */
    public string active_workspace_name {
        get { return _active_workspace_name; }
    }

    /**
     * Identifier of the active workspace on this monitor.
     */
    public int active_workspace_id {
        get { return _active_workspace_id; }
    }

    /**
     * Create a new monitor info instance.
     */
    public MonitorInfo (int id, string name, int x, int y,
                        int width, int height, double scale,
                        int refresh_rate, bool focused,
                        string active_workspace_name,
                        int active_workspace_id) {
        _id = id;
        _name = name;
        _x = x;
        _y = y;
        _width = width;
        _height = height;
        _scale = scale;
        _refresh_rate = refresh_rate;
        _focused = focused;
        _active_workspace_name = active_workspace_name;
        _active_workspace_id = active_workspace_id;
    }

    /**
     * Create a MonitorInfo from a JSON object.
     *
     * @param json the JSON object to parse
     * @return a new MonitorInfo instance
     */
    internal static MonitorInfo from_json (Json.Object json) {
        int id = (int) json.get_int_member ("id");
        string name = json.get_string_member ("name");

        var x = json.get_int_member ("x");
        var y = json.get_int_member ("y");
        int width = (int) json.get_int_member ("width");
        int height = (int) json.get_int_member ("height");
        double scale = json.get_double_member ("scale");
        int refresh_rate = (int) json.get_int_member ("refreshRate");
        bool focused = json.get_boolean_member ("focused");

        var active_workspace = json.get_object_member ("activeWorkspace");
        int active_workspace_id = (int) active_workspace.get_int_member ("id");
        string active_workspace_name = active_workspace.get_string_member ("name");

        return new MonitorInfo (id, name, (int) x, (int) y,
                                width, height, scale, refresh_rate,
                                focused, active_workspace_name,
                                active_workspace_id);
    }

    /**
     * Get a string representation of this monitor info.
     *
     * @return a human-readable string
     */
    public string to_string () {
        return "MonitorInfo(%d, %s, %dx%d, scale=%.1f, focused=%s)"
            .printf (_id, _name, _width, _height, _scale,
                     _focused ? "true" : "false");
    }

}

}

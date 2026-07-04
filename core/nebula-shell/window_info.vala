namespace NebulaShell {

/**
 * Represents information about a compositor window.
 *
 * WindowInfo is a data class that holds information about a window
 * managed by the compositor. It is used by compositor backends to
 * expose window state to the framework.
 *
 * WindowInfo objects are created by compositor backends and should
 * not be created directly by widgets or applications.
 *
 * Example:
 *   var windows = compositor.get_windows ();
 *   foreach (var win in windows) {
 *       Logger.info (win.title + " on workspace " + win.workspace_id.to_string ());
 *   }
 */
public class WindowInfo : GLib.Object {

    private string _address;
    private string _title;
    private string _class;
    private string _instance;
    private int _workspace_id;
    private string _workspace_name;
    private bool _focused;
    private bool _floating;
    private bool _fullscreen;
    private bool _maximized;
    private int _pid;
    private string _owner;
    private int _monitor_id;
    private string _monitor_name;
    private int _at_x;
    private int _at_y;
    private int _size_w;
    private int _size_h;

    /**
     * Unique address for this window (compositor-specific).
     */
    public string address {
        get { return _address; }
    }

    /**
     * Window title.
     */
    public string title {
        get { return _title; }
    }

    /**
     * Window class (WM_CLASS).
     */
    public string window_class {
        get { return _class; }
    }

    /**
     * Window instance (WM_CLASS instance).
     */
    public string instance {
        get { return _instance; }
    }

    /**
     * Identifier of the workspace this window is on.
     */
    public int workspace_id {
        get { return _workspace_id; }
    }

    /**
     * Name of the workspace this window is on.
     */
    public string workspace_name {
        get { return _workspace_name; }
    }

    /**
     * Whether this window is currently focused.
     */
    public bool focused {
        get { return _focused; }
    }

    /**
     * Whether this window is floating (not tiled).
     */
    public bool floating {
        get { return _floating; }
    }

    /**
     * Whether this window is fullscreen.
     */
    public bool fullscreen {
        get { return _fullscreen; }
    }

    /**
     * Whether this window is maximized.
     */
    public bool maximized {
        get { return _maximized; }
    }

    /**
     * Process ID of the window owner.
     */
    public int pid {
        get { return _pid; }
    }

    /**
     * Name of the process owning this window.
     */
    public string owner {
        get { return _owner; }
    }

    /**
     * Identifier of the monitor this window is on.
     */
    public int monitor_id {
        get { return _monitor_id; }
    }

    /**
     * Name of the monitor this window is on.
     */
    public string monitor_name {
        get { return _monitor_name; }
    }

    /**
     * X position of the window.
     */
    public int at_x {
        get { return _at_x; }
    }

    /**
     * Y position of the window.
     */
    public int at_y {
        get { return _at_y; }
    }

    /**
     * Width of the window.
     */
    public int size_w {
        get { return _size_w; }
    }

    /**
     * Height of the window.
     */
    public int size_h {
        get { return _size_h; }
    }

    /**
     * Create a new window info instance.
     */
    public WindowInfo (string address, string title, string window_class,
                       string instance, int workspace_id, string workspace_name,
                       bool focused, bool floating, bool fullscreen,
                       bool maximized, int pid, string owner,
                       int monitor_id, string monitor_name,
                       int at_x, int at_y, int size_w, int size_h) {
        _address = address;
        _title = title;
        _class = window_class;
        _instance = instance;
        _workspace_id = workspace_id;
        _workspace_name = workspace_name;
        _focused = focused;
        _floating = floating;
        _fullscreen = fullscreen;
        _maximized = maximized;
        _pid = pid;
        _owner = owner;
        _monitor_id = monitor_id;
        _monitor_name = monitor_name;
        _at_x = at_x;
        _at_y = at_y;
        _size_w = size_w;
        _size_h = size_h;
    }

    /**
     * Create a WindowInfo from a JSON object.
     *
     * @param json the JSON object to parse
     * @return a new WindowInfo instance
     */
    internal static WindowInfo from_json (Json.Object json) {
        string address = json.get_string_member ("address");
        string title = json.get_string_member ("title");
        string window_class = json.get_string_member ("class");
        string instance = json.get_string_member ("initialClass");

        var workspace = json.get_object_member ("workspace");
        int workspace_id = (int) workspace.get_int_member ("id");
        string workspace_name = workspace.get_string_member ("name");

        bool focused = json.get_boolean_member ("focused");
        bool floating = json.get_boolean_member ("floating");
        bool fullscreen = json.get_boolean_member ("fullscreen");
        bool maximized = json.get_boolean_member ("maximized");

        int pid = (int) json.get_int_member ("pid");
        string owner = json.get_string_member ("owner");

        var monitor = json.get_object_member ("monitor");
        int monitor_id = (int) monitor.get_int_member ("id");
        string monitor_name = monitor.get_string_member ("name");

        var at = json.get_object_member ("at");
        int at_x = (int) at.get_int_member ("x");
        int at_y = (int) at.get_int_member ("y");

        var size = json.get_object_member ("size");
        int size_w = (int) size.get_int_member ("x");
        int size_h = (int) size.get_int_member ("y");

        return new WindowInfo (address, title, window_class, instance,
                               workspace_id, workspace_name, focused,
                               floating, fullscreen, maximized, pid,
                               owner, monitor_id, monitor_name,
                               at_x, at_y, size_w, size_h);
    }

    /**
     * Get a string representation of this window info.
     *
     * @return a human-readable string
     */
    public string to_string () {
        return "WindowInfo(%s, class=%s, focused=%s, floating=%s)"
            .printf (_address, _class,
                     _focused ? "true" : "false",
                     _floating ? "true" : "false");
    }

}

}

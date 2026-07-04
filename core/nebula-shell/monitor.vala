namespace NebulaShell {

/**
 * Represents a display monitor.
 *
 * Monitor provides an abstraction over display outputs, hiding
 * GDK/GTK monitor details from the public API. Each monitor
 * has a unique identifier, position, size, and scale factor.
 *
 * Monitor objects are obtained from the monitor manager and
 * should not be created directly.
 *
 * Example:
 *   var monitors = Monitor.get_all ();
 *   var primary = Monitor.get_primary ();
 *   window.monitor = primary;
 */
public class Monitor : NebulaShell.Object {

    private int _id;
    private string _name;
    private int _x;
    private int _y;
    private int _width;
    private int _height;
    private double _scale;

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
     *
     * A scale factor of 2.0 means the monitor uses 2x pixels
     * per logical pixel (HiDPI).
     */
    public double scale {
        get { return _scale; }
    }

    /**
     * Create a new monitor instance.
     *
     * @param id unique identifier
     * @param name human-readable name
     * @param x x position
     * @param y y position
     * @param width width in logical pixels
     * @param height height in logical pixels
     * @param scale display scale factor
     */
    public Monitor (int id, string name, int x, int y,
                    int width, int height, double scale) {
        base.with_name (name);
        _id = id;
        _name = name;
        _x = x;
        _y = y;
        _width = width;
        _height = height;
        _scale = scale;
    }

    /**
     * Get the primary monitor.
     *
     * Returns the first available monitor. The primary monitor
     * is typically the one containing the taskbar or system tray.
     *
     * @return the primary monitor, or null if no monitors exist
     */
    public static Monitor? get_primary () {
        var display = Gdk.Display.get_default ();
        if (display == null) return null;

        var model = display.get_monitors ();
        uint n_items = model.get_n_items ();

        if (n_items == 0) return null;

        var obj = model.get_item (0);
        if (obj == null) return null;

        return from_gdk_monitor ((Gdk.Monitor) obj, 0);
    }

    /**
     * Get all available monitors.
     *
     * @return list of all monitors
     */
    public static Monitor[] get_all () {
        var display = Gdk.Display.get_default ();
        if (display == null) return new Monitor[0];

        var monitors = new Monitor[0];
        var model = display.get_monitors ();
        uint n_items = model.get_n_items ();

        for (uint i = 0; i < n_items; i++) {
            var obj = model.get_item (i);
            if (obj == null) continue;

            var gdk_monitor = (Gdk.Monitor) obj;
            monitors += from_gdk_monitor (gdk_monitor, (int) i);
        }

        return monitors;
    }

    /**
     * Find a monitor by its identifier.
     *
     * @param id the monitor id to find
     * @return the monitor, or null if not found
     */
    public static Monitor? find_by_id (int id) {
        var monitors = get_all ();
        foreach (var monitor in monitors) {
            if (monitor.id == id) return monitor;
        }
        return null;
    }

    /**
     * Find a monitor by name.
     *
     * @param name the monitor name to find
     * @return the monitor, or null if not found
     */
    public static Monitor? find_by_name (string name) {
        var monitors = get_all ();
        foreach (var monitor in monitors) {
            if (monitor.monitor_name == name) return monitor;
        }
        return null;
    }

    /**
     * Check if a point lies within this monitor.
     *
     * @param px x coordinate of the point
     * @param py y coordinate of the point
     * @return true if the point is within the monitor bounds
     */
    public bool contains_point (int px, int py) {
        return px >= _x && px < _x + _width &&
               py >= _y && py < _y + _height;
    }

    /**
     * Create a Monitor from a GDK monitor.
     *
     * @param gdk_monitor the GDK monitor to wrap
     * @param id the monitor identifier
     * @return a new Monitor instance
     */
    internal static Monitor from_gdk_monitor (Gdk.Monitor gdk_monitor,
                                               int id) {
        var geometry = gdk_monitor.get_geometry ();
        var name = gdk_monitor.get_model () ?? "Unknown";

        return new Monitor (
            id,
            name,
            geometry.x,
            geometry.y,
            geometry.width,
            geometry.height,
            gdk_monitor.get_scale_factor ()
        );
    }

}

}

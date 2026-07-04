namespace NebulaShell {

/**
 * Base class for all framework objects.
 *
 * Provides common identity, naming, and lifecycle hooks
 * for objects managed by NebulaShell.
 */
public class Object : GLib.Object {

    private string _name;

    /**
     * Human-readable name for this object.
     */
    public string name {
        get { return _name; }
        set { _name = value; }
    }

    public Object () {
        _name = "";
    }

    public Object.with_name (string name) {
        _name = name;
    }

}

}

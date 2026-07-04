namespace NebulaShell {

/**
 * Theme data class holding theme information.
 *
 * Theme represents a loaded GTK CSS theme. It contains the CSS content,
 * file path, and metadata about the theme. Theme instances are created
 * by ThemeManager and are immutable once created.
 *
 * GTK CSS is the official theme language. Widgets expose style classes,
 * not hardcoded colors. The theme engine is independent of widgets.
 *
 * Example:
 *   var theme = new Theme("my-theme", "/path/to/theme.css");
 *   var css = theme.get_css_content();
 */
public class Theme : GLib.Object {

    private string _name;
    private string _file_path;
    private string _css_content;
    private Gee.ArrayList<string> _include_paths;
    private bool _loaded;
    private int64 _last_modified;

    /**
     * Signal emitted when theme CSS content is updated.
     */
    public signal void updated ();

    /**
     * Create a new theme with a name and file path.
     *
     * @param name the theme name
     * @param file_path path to the CSS file
     */
    public Theme (string name, string file_path) {
        _name = name;
        _file_path = file_path;
        _css_content = "";
        _include_paths = new Gee.ArrayList<string> ();
        _loaded = false;
        _last_modified = 0;
    }

    /**
     * The theme name.
     */
    public string name {
        get { return _name; }
    }

    /**
     * Path to the CSS file.
     */
    public string file_path {
        get { return _file_path; }
    }

    /**
     * Whether the theme has been loaded.
     */
    public bool loaded {
        get { return _loaded; }
    }

    /**
     * Timestamp of last file modification.
     */
    public int64 last_modified {
        get { return _last_modified; }
    }

    /**
     * Get the CSS content of the theme.
     *
     * @return the CSS string, or empty if not loaded
     */
    public string get_css_content () {
        return _css_content;
    }

    /**
     * Set the CSS content.
     *
     * @param content the CSS string to set
     */
    public void set_css_content (owned string content) {
        _css_content = (owned) content;
        _loaded = true;
        updated ();
    }

    /**
     * Get all include paths for this theme.
     *
     * @return a read-only view of include paths
     */
    public Gee.List<string> get_include_paths () {
        return _include_paths.read_only_view;
    }

    /**
     * Add an include path for this theme.
     *
     * @param path path to include
     */
    public void add_include_path (string path) {
        _include_paths.add (path);
    }

    /**
     * Update the last modified timestamp.
     *
     * @param timestamp the new timestamp
     */
    public void set_last_modified (int64 timestamp) {
        _last_modified = timestamp;
    }

    /**
     * Create a copy of this theme with updated CSS content.
     *
     * @return a new Theme instance
     */
    public Theme copy () {
        var theme = new Theme (_name, _file_path);
        theme.set_css_content (_css_content);
        theme.set_last_modified (_last_modified);
        foreach (string path in _include_paths) {
            theme.add_include_path (path);
        }
        return theme;
    }

}

}

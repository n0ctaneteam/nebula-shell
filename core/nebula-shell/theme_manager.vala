namespace NebulaShell {

/**
 * Manages GTK CSS themes for the framework.
 *
 * ThemeManager is a singleton manager that owns the theme lifecycle.
 * It searches for GTK CSS theme files in standard locations, loads them
 * via Gtk.CssProvider, and provides the resulting Theme objects to the
 * rest of the framework.
 *
 * GTK CSS is the official theme language. Widgets expose style classes,
 * not hardcoded colors. The theme engine is independent of widgets.
 *
 * ThemeManager follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * It is registered with the Kernel as "theme".
 *
 * Example:
 *   var theme_manager = ThemeManager.get_default();
 *   runtime.register_manager("theme", theme_manager);
 *   runtime.initialize();
 *
 *   var theme = theme_manager.get_current_theme();
 *   theme_manager.set_theme_name("dark");
 *   theme_manager.reload();
 */
public class ThemeManager : GLib.Object, Manager {

    private static ThemeManager? _instance = null;

    private Gee.ArrayList<string> _theme_directories;
    private Gee.HashMap<string, Theme> _themes;
    private Theme? _current_theme;
    private string? _current_theme_name;
    private Gtk.CssProvider? _css_provider;
    private bool _initialized;
    private bool _auto_reload;
    private Gee.ArrayList<GLib.FileMonitor> _monitors;

    /**
     * Signal emitted when the current theme changes.
     *
     * @param theme_name the name of the new theme
     */
    public signal void theme_changed (string theme_name);

    /**
     * Signal emitted when a theme is loaded.
     *
     * @param theme_name the name of the loaded theme
     */
    public signal void theme_loaded (string theme_name);

    /**
     * Signal emitted when a theme reload occurs.
     *
     * @param theme_name the name of the reloaded theme
     */
    public signal void theme_reloaded (string theme_name);

    /**
     * Signal emitted when a theme error occurs.
     *
     * @param theme_name the theme that caused the error
     * @param message the error description
     */
    public signal void theme_error (string theme_name, string message);

    /**
     * Get the default ThemeManager instance.
     *
     * @return the singleton theme manager
     */
    public static ThemeManager get_default () {
        if (_instance == null)
            _instance = new ThemeManager ();

        return _instance;
    }

    private ThemeManager () {
        _theme_directories = new Gee.ArrayList<string> ();
        _themes = new Gee.HashMap<string, Theme> ();
        _current_theme = null;
        _current_theme_name = null;
        _css_provider = null;
        _initialized = false;
        _auto_reload = false;
        _monitors = new Gee.ArrayList<GLib.FileMonitor> ();

        initialize_theme_directories ();
    }

    /**
     * Initialize default theme search directories.
     *
     * Search order:
     * 1. ~/.config/nebula-shell/themes/
     * 2. $XDG_CONFIG_HOME/nebula-shell/themes/
     * 3. /usr/share/nebula-shell/themes/
     * 4. /usr/local/share/nebula-shell/themes/
     */
    private void initialize_theme_directories () {
        string home = GLib.Environment.get_variable ("HOME") ?? "";
        string xdg_config = GLib.Environment.get_variable ("XDG_CONFIG_HOME") ?? "";

        if (home.length > 0) {
            _theme_directories.add (
                GLib.Path.build_filename (home, ".config", "nebula-shell", "themes")
            );
        }

        if (xdg_config.length > 0) {
            _theme_directories.add (
                GLib.Path.build_filename (xdg_config, "nebula-shell", "themes")
            );
        }

        _theme_directories.add (
            GLib.Path.build_filename ("/usr", "share", "nebula-shell", "themes")
        );

        _theme_directories.add (
            GLib.Path.build_filename ("/usr", "local", "share", "nebula-shell", "themes")
        );
    }

    /**
     * Add a custom theme directory.
     *
     * Custom directories are prepended to the search list,
     * giving them higher priority.
     *
     * @param path absolute path to a theme directory
     */
    public void add_theme_directory (string path) {
        _theme_directories.insert (0, path);
    }

    /**
     * Get all configured theme directories.
     *
     * @return a read-only view of theme directories
     */
    public Gee.List<string> get_theme_directories () {
        return _theme_directories.read_only_view;
    }

    /**
     * Get the current theme.
     *
     * @return the current theme, or null if not loaded
     */
    public Theme? get_current_theme () {
        return _current_theme;
    }

    /**
     * Get the current theme name.
     *
     * @return the theme name, or null if no theme loaded
     */
    public string? get_current_theme_name () {
        return _current_theme_name;
    }

    /**
     * Set the current theme by name.
     *
     * Loads the theme from the first matching file found
     * in the theme directories.
     *
     * @param theme_name the theme name to load
     */
    public void set_theme_name (string theme_name) {
        if (_current_theme_name == theme_name)
            return;

        load_theme (theme_name);
    }

    /**
     * Get a loaded theme by name.
     *
     * @param theme_name the theme name
     * @return the theme, or null if not loaded
     */
    public Theme? get_theme (string theme_name) {
        return _themes.get (theme_name);
    }

    /**
     * Get all available theme names.
     *
     * @return a read-only set of theme names
     */
    public Gee.Set<string> get_available_themes () {
        return _themes.keys.read_only_view;
    }

    /**
     * Enable or disable automatic theme reload during development.
     *
     * When enabled, monitors theme directories for changes and
     * automatically reloads the current theme.
     *
     * @param enabled true to enable auto-reload
     */
    public void set_auto_reload (bool enabled) {
        _auto_reload = enabled;
        if (_initialized) {
            update_monitors ();
        }
    }

    /**
     * Whether auto-reload is enabled.
     */
    public bool auto_reload {
        get { return _auto_reload; }
    }

    /**
     * Initialize the theme manager.
     *
     * Loads available themes from configured directories.
     * This is called by the Kernel during framework startup.
     */
    public void initialize () {
        if (_initialized)
            return;

        Logger.info ("ThemeManager: initializing");

        _css_provider = new Gtk.CssProvider ();
        discover_themes ();
        load_default_theme ();

        _initialized = true;
        Logger.info ("ThemeManager: initialized");
    }

    /**
     * Shut down the theme manager.
     *
     * Releases the current theme and stops file monitors.
     * This is called by the Kernel during framework shutdown.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("ThemeManager: shutting down");

        stop_monitors ();
        _css_provider = null;
        _current_theme = null;
        _current_theme_name = null;
        _themes.clear ();
        _initialized = false;

        Logger.info ("ThemeManager: shut down");
    }

    /**
     * Reload the current theme from disk.
     *
     * Re-reads the CSS file and updates the provider.
     * Emits theme_reloaded signal when complete.
     * This is called by the Kernel during framework reload.
     */
    public void reload () {
        if (!_initialized)
            return;

        if (_current_theme_name == null) {
            Logger.warning ("ThemeManager: no theme to reload");
            return;
        }

        Logger.info ("ThemeManager: reloading theme " + _current_theme_name);

        var theme_name = _current_theme_name;
        load_theme (theme_name);

        Logger.info ("ThemeManager: theme reloaded");
        theme_reloaded (theme_name);
    }

    /**
     * Discover available themes in all theme directories.
     *
     * Scans each directory for CSS files and registers them as themes.
     */
    private void discover_themes () {
        _themes.clear ();

        foreach (string dir_path in _theme_directories) {
            if (!GLib.FileUtils.test (dir_path, GLib.FileTest.IS_DIR))
                continue;

            try {
                var dir = GLib.Dir.open (dir_path);
                string? file_name;

                while ((file_name = dir.read_name ()) != null) {
                    if (file_name.has_suffix (".css")) {
                        string theme_name = file_name.substring (0, file_name.length - 4);
                        string file_path = GLib.Path.build_filename (dir_path, file_name);

                        var theme = new Theme (theme_name, file_path);
                        _themes.set (theme_name, theme);
                        Logger.debug ("ThemeManager: discovered theme " + theme_name);
                    }
                }
            } catch (GLib.Error e) {
                Logger.warning ("ThemeManager: failed to scan " + dir_path + ": " + e.message);
            }
        }
    }

    /**
     * Load the default theme.
     *
     * Tries to load "default" theme, or falls back to the first available theme.
     */
    private void load_default_theme () {
        if (_themes.has_key ("default")) {
            load_theme ("default");
            return;
        }

        if (_themes.size > 0) {
            var iter = _themes.keys.iterator ();
            if (iter.next ()) {
                load_theme (iter.get ());
            }
            return;
        }

        Logger.info ("ThemeManager: no themes found");
    }

    /**
     * Load a theme by name.
     *
     * @param theme_name the theme to load
     */
    private void load_theme (string theme_name) {
        var theme = _themes.get (theme_name);
        if (theme == null) {
            Logger.error ("ThemeManager: theme not found: " + theme_name);
            theme_error (theme_name, "Theme not found");
            return;
        }

        string css_content = read_css_file (theme.file_path);
        if (css_content == null) {
            Logger.error ("ThemeManager: failed to read theme: " + theme_name);
            theme_error (theme_name, "Failed to read CSS file");
            return;
        }

        theme.set_css_content (css_content);
        apply_theme (theme);

        _current_theme = theme;
        _current_theme_name = theme_name;

        Logger.info ("ThemeManager: loaded theme " + theme_name);
        theme_loaded (theme_name);
        theme_changed (theme_name);

        update_monitors ();
    }

    /**
     * Read CSS content from a file.
     *
     * @param file_path the CSS file path
     * @return the CSS content, or null on error
     */
    private string? read_css_file (string file_path) {
        try {
            string content;
            GLib.FileUtils.get_contents (file_path, out content);
            return content;
        } catch (GLib.Error e) {
            Logger.error ("ThemeManager: failed to read file: " + e.message);
            return null;
        }
    }

    /**
     * Apply a theme to the GTK CSS provider.
     *
     * @param theme the theme to apply
     */
    private void apply_theme (Theme theme) {
        if (_css_provider == null)
            return;

        try {
            unowned uint8[] css_bytes = theme.get_css_content ().make_valid ().data;
            _css_provider.load_from_data (css_bytes);
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                _css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        } catch (GLib.Error e) {
            Logger.error ("ThemeManager: failed to apply CSS: " + e.message);
            theme_error (theme.name, "Failed to apply CSS: " + e.message);
        }
    }

    /**
     * Get the CSS provider for external use.
     *
     * @return the CSS provider, or null if not initialized
     */
    public Gtk.CssProvider? get_css_provider () {
        return _css_provider;
    }

    /**
     * Update file monitors for theme directories.
     */
    private void update_monitors () {
        stop_monitors ();

        if (!_auto_reload || !_initialized)
            return;

        foreach (string dir_path in _theme_directories) {
            if (!GLib.FileUtils.test (dir_path, GLib.FileTest.IS_DIR))
                continue;

            try {
                var monitor = GLib.File.new_for_path (dir_path).monitor (GLib.FileMonitorFlags.NONE);
                monitor.changed.connect ((file, other_file, event) => {
                    on_theme_directory_changed (dir_path, event);
                });
                _monitors.add (monitor);
            } catch (GLib.Error e) {
                Logger.warning ("ThemeManager: failed to monitor " + dir_path + ": " + e.message);
            }
        }
    }

    /**
     * Stop all file monitors.
     */
    private void stop_monitors () {
        foreach (var monitor in _monitors) {
            monitor.cancel ();
        }
        _monitors.clear ();
    }

    /**
     * Handle theme directory change events.
     *
     * @param dir_path the directory that changed
     * @param event the file change event
     */
    private void on_theme_directory_changed (string dir_path, GLib.FileMonitorEvent event) {
        if (event != GLib.FileMonitorEvent.CHANGED &&
            event != GLib.FileMonitorEvent.CREATED &&
            event != GLib.FileMonitorEvent.DELETED)
            return;

        Logger.debug ("ThemeManager: detected change in " + dir_path);

        discover_themes ();

        if (_current_theme_name != null && _themes.has_key (_current_theme_name)) {
            reload ();
        } else if (_themes.size > 0) {
            load_default_theme ();
        }
    }

}

}

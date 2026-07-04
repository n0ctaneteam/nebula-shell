namespace NebulaShell {

/**
 * Manages configuration loading, validation, and hot-reload.
 *
 * ConfigManager is a singleton manager that owns the configuration
 * lifecycle. It searches for Python configuration files in standard
 * locations, loads them via the Python interpreter, and provides
 * the resulting Config object to the rest of the framework.
 *
 * Configuration is always written in Python. No custom DSL.
 * No YAML. No JSON.
 *
 * ConfigManager follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * It is registered with the Kernel as "config".
 *
 * Example:
 *   var config_manager = ConfigManager.get_default();
 *   runtime.register_manager("config", config_manager);
 *   runtime.initialize();
 *
 *   var config = config_manager.get_config();
 *   var theme = config.get_string("general/theme");
 */
public class ConfigManager : GLib.Object, Manager {

    private static ConfigManager? _instance = null;

    private Config? _config;
    private Gee.ArrayList<string> _search_paths;
    private string? _config_path;
    private bool _initialized;

    /**
     * Signal emitted when configuration is reloaded.
     *
     * Connected components should re-read their values
     * from the new Config instance.
     */
    public signal void config_reloaded ();

    /**
     * Signal emitted when a configuration error occurs.
     *
     * @param key the key that caused the error
     * @param message the error description
     */
    public signal void config_error (string key, string message);

    /**
     * Get the default ConfigManager instance.
     *
     * @return the singleton config manager
     */
    public static ConfigManager get_default () {
        if (_instance == null)
            _instance = new ConfigManager ();

        return _instance;
    }

    private ConfigManager () {
        _config = null;
        _search_paths = new Gee.ArrayList<string> ();
        _config_path = null;
        _initialized = false;

        initialize_search_paths ();
    }

    /**
     * Initialize default configuration search paths.
     *
     * Search order (first found wins):
     * 1. ~/.config/nebula-shell/shell.py
     * 2. $XDG_CONFIG_HOME/nebula-shell/shell.py
     * 3. /etc/nebula-shell/shell.py
     */
    private void initialize_search_paths () {
        string home = GLib.Environment.get_variable ("HOME") ?? "";
        string xdg_config = GLib.Environment.get_variable ("XDG_CONFIG_HOME") ?? "";

        if (home.length > 0) {
            _search_paths.add (
                GLib.Path.build_filename (home, ".config", "nebula-shell", "shell.py")
            );
        }

        if (xdg_config.length > 0) {
            _search_paths.add (
                GLib.Path.build_filename (xdg_config, "nebula-shell", "shell.py")
            );
        }

        _search_paths.add (
            GLib.Path.build_filename ("/", "etc", "nebula-shell", "shell.py")
        );
    }

    /**
     * Add a custom search path for configuration files.
     *
     * Custom paths are prepended to the search list,
     * giving them higher priority.
     *
     * @param path absolute path to a Python config file
     */
    public void add_search_path (string path) {
        _search_paths.insert (0, path);
    }

    /**
     * Get all configured search paths.
     *
     * @return a read-only view of search paths
     */
    public Gee.List<string> get_search_paths () {
        return _search_paths.read_only_view;
    }

    /**
     * Set the explicit config file path.
     *
     * When set, this path is used instead of searching.
     *
     * @param path absolute path to a Python config file
     */
    public void set_config_path (string path) {
        _config_path = path;
    }

    /**
     * Get the current configuration.
     *
     * @return the loaded configuration, or null if not yet initialized
     */
    public Config? get_config () {
        return _config;
    }

    /**
     * Initialize the configuration manager.
     *
     * Loads the configuration from the first found search path.
     * This is called by the Kernel during framework startup.
     */
    public void initialize () {
        if (_initialized)
            return;

        Logger.info ("ConfigManager: initializing");

        _config = new Config ();
        load_config ();

        _initialized = true;
        Logger.info ("ConfigManager: initialized");
    }

    /**
     * Shut down the configuration manager.
     *
     * Releases the current configuration.
     * This is called by the Kernel during framework shutdown.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("ConfigManager: shutting down");

        _config = null;
        _config_path = null;
        _initialized = false;

        Logger.info ("ConfigManager: shut down");
    }

    /**
     * Reload the configuration from disk.
     *
     * Re-executes the Python config file and updates the Config object.
     * Emits config_reloaded signal when complete.
     * This is called by the Kernel during framework reload.
     */
    public void reload () {
        if (!_initialized)
            return;

        Logger.info ("ConfigManager: reloading configuration");

        var old_config = _config;
        _config = new Config ();

        bool success = load_config ();

        if (success) {
            Logger.info ("ConfigManager: configuration reloaded");
            config_reloaded ();
        } else {
            Logger.warning ("ConfigManager: reload failed, keeping previous config");
            _config = old_config;
        }
    }

    /**
     * Load configuration from the resolved config file path.
     *
     * @return true if configuration was loaded successfully
     */
    private bool load_config () {
        string path = resolve_config_path ();

        if (path == null) {
            Logger.warning ("ConfigManager: no configuration file found");
            emit_error ("config", "No configuration file found in search paths");
            return false;
        }

        Logger.debug ("ConfigManager: loading config from " + path);

        if (!validate_config_file (path)) {
            return false;
        }

        return execute_python_config (path);
    }

    /**
     * Resolve the config file path.
     *
     * If an explicit path is set, use it.
     * Otherwise, search through configured paths.
     *
     * @return the resolved path, or null if not found
     */
    private string? resolve_config_path () {
        if (_config_path != null && GLib.FileUtils.test (_config_path, GLib.FileTest.EXISTS)) {
            return _config_path;
        }

        foreach (string path in _search_paths) {
            if (GLib.FileUtils.test (path, GLib.FileTest.EXISTS)) {
                _config_path = path;
                return path;
            }
        }

        return null;
    }

    /**
     * Validate that a config file exists and is readable.
     *
     * @param path the path to validate
     * @return true if the file is valid
     */
    private bool validate_config_file (string path) {
        if (!GLib.FileUtils.test (path, GLib.FileTest.EXISTS)) {
            emit_error (path, "Configuration file does not exist");
            return false;
        }

        if (!GLib.FileUtils.test (path, GLib.FileTest.IS_REGULAR)) {
            emit_error (path, "Configuration path is not a regular file");
            return false;
        }

        return true;
    }

    /**
     * Execute a Python configuration file.
     *
     * Spawns the Python interpreter to execute the config file.
     * The config file should set configuration values using
     * the NebulaShell configuration API.
     *
     * @param path the path to the Python config file
     * @return true if execution succeeded
     */
    private bool execute_python_config (string path) {
        try {
            string python_path = find_python_interpreter ();
            if (python_path == null) {
                emit_error (path, "Python interpreter not found");
                return false;
            }

            string[] argv = { python_path, path };
            int exit_status;
            string std_out;
            string std_err;

            var process = new GLib.SubprocessLauncher (GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE);
            var subprocess = process.spawnv (argv);

            subprocess.communicate_utf8 (null, null, out std_out, out std_err);
            subprocess.wait ();

            exit_status = subprocess.get_exit_status ();

            if (exit_status != 0) {
                string error_msg = std_err.length > 0 ? std_err : "Python process exited with status %d".printf (exit_status);
                emit_error (path, error_msg);
                Logger.error ("ConfigManager: Python execution failed: " + error_msg);
                return false;
            }

            if (std_err.length > 0) {
                Logger.warning ("ConfigManager: Python warnings: " + std_err);
            }

            return true;

        } catch (GLib.Error e) {
            emit_error (path, e.message);
            Logger.error ("ConfigManager: failed to execute config: " + e.message);
            return false;
        }
    }

    /**
     * Find the Python interpreter.
     *
     * Searches standard locations for a Python 3 interpreter.
     *
     * @return the path to the interpreter, or null if not found
     */
    private string? find_python_interpreter () {
        string[] candidates = { "python3", "python" };

        foreach (string candidate in candidates) {
            try {
                string[] argv = { candidate, "--version" };
                var process = new GLib.SubprocessLauncher (GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE);
                var subprocess = process.spawnv (argv);
                subprocess.wait ();
                int status = subprocess.get_exit_status ();
                if (status == 0)
                    return candidate;
            } catch (GLib.Error e) {
                continue;
            }
        }

        return null;
    }

    /**
     * Emit a configuration error.
     *
     * Logs the error and emits the config_error signal.
     *
     * @param key the key or path that caused the error
     * @param message the error description
     */
    private void emit_error (string key, string message) {
        Logger.error ("ConfigManager: [" + key + "] " + message);

        if (_config != null) {
            _config.add_error (key, message);
        }

        config_error (key, message);
    }

}

}

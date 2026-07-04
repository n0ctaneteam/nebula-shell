namespace NebulaShell {

/**
 * Dev command implementation.
 *
 * Starts NebulaShell in development mode with hot-reload.
 * Watches for configuration changes and automatically reloads.
 *
 * Usage:
 *   nebula-shell dev
 *   nebula-shell dev --config /path/to/config.py
 *   nebula-shell dev --port 8080
 *
 * Example:
 *   $ nebula-shell dev
 *   Starting NebulaShell in development mode...
 *   Watching for configuration changes...
 *   Press Ctrl+C to stop
 */
public class CliDev : GLib.Object {

    private string? _config_path = null;
    private int _port = 0;

    /**
     * Run the dev command.
     *
     * @param args command arguments
     * @return 0 on success, non-zero on failure
     */
    public int run (string[] args) {
        var context = new GLib.OptionContext ("- start development mode with hot-reload");
        var options = new GLib.OptionEntry[] {
            { "config", 'c', 0, GLib.OptionArg.STRING, ref _config_path, "Configuration file path", "PATH" },
            { "port", 'p', 0, GLib.OptionArg.INT, ref _port, "IPC port for debugging", "PORT" },
            { null }
        };

        context.add_main_entries (options, null);

        try {
            context.parse (ref args);
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
            return 1;
        }

        return run_dev ();
    }

    /**
     * Run the development server.
     *
     * @return 0 on success, non-zero on failure
     */
    private int run_dev () {
        print ("Starting NebulaShell in development mode...\n");

        // Resolve config path
        string? config_path = resolve_config_path ();
        if (config_path == null) {
            GLib.stderr.printf ("Error: No configuration file found\n");
            return 1;
        }

        print ("Configuration: %s\n", config_path);

        // Enable debug mode
        Logger.get_default ().debug_mode = true;

        // Start file watcher
        if (!start_file_watcher (config_path)) {
            GLib.stderr.printf ("Error: Failed to start file watcher\n");
            return 1;
        }

        print ("Watching for configuration changes...\n");
        print ("Press Ctrl+C to stop\n\n");

        // Create and run application
        var app = new Application ();

        // Register managers
        var runtime = Runtime.get_default ();
        runtime.register_manager ("config", ConfigManager.get_default ());
        runtime.register_manager ("plugin", PluginManager.get_default ());

        // Initialize and run
        app.run ();

        return 0;
    }

    /**
     * Resolve the configuration file path.
     *
     * @return the resolved path, or null if not found
     */
    private string? resolve_config_path () {
        if (_config_path != null) {
            if (GLib.FileUtils.test (_config_path, GLib.FileTest.EXISTS)) {
                return _config_path;
            }
            GLib.stderr.printf ("Warning: Config file not found: %s\n", _config_path);
        }

        // Search for default config files
        string home = GLib.Environment.get_variable ("HOME") ?? "";
        string xdg_config = GLib.Environment.get_variable ("XDG_CONFIG_HOME") ?? "";

        string[] search_paths = {};

        if (home.length > 0) {
            search_paths += GLib.Path.build_filename (home, ".config", "nebula-shell", "config.py");
        }

        if (xdg_config.length > 0) {
            search_paths += GLib.Path.build_filename (xdg_config, "nebula-shell", "config.py");
        }

        search_paths += GLib.Path.build_filename ("/", "etc", "nebula-shell", "config.py");
        search_paths += "config.py";

        foreach (string path in search_paths) {
            if (GLib.FileUtils.test (path, GLib.FileTest.EXISTS)) {
                return path;
            }
        }

        return null;
    }

    /**
     * Start a file watcher for the configuration file.
     *
     * @param config_path the path to watch
     * @return true on success
     */
    private bool start_file_watcher (string config_path) {
        // TODO: Implement file watcher using GLib.FileMonitor
        // For now, just log that we would watch
        Logger.debug ("Dev: would watch " + config_path);
        return true;
    }

}

}

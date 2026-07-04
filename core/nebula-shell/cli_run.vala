namespace NebulaShell {

/**
 * Run command implementation.
 *
 * Runs a NebulaShell configuration file. Loads the specified
 * configuration or searches for a default config file.
 *
 * Usage:
 *   nebula-shell run
 *   nebula-shell run --config /path/to/shell.py
 *   nebula-shell run --debug
 *
 * Example:
 *   $ nebula-shell run --config my-shell.py
 *   Starting NebulaShell...
 *   Loading configuration from my-shell.py
 *   Running...
 */
public class CliRun : GLib.Object {

    private string? _config_path = null;
    private bool _debug = false;

    /**
     * Run the run command.
     *
     * @param args command arguments
     * @return 0 on success, non-zero on failure
     */
    public int run (string[] args) {
        var context = new GLib.OptionContext ("- run a NebulaShell configuration");
        var options = new GLib.OptionEntry[] {
            { "config", 'c', 0, GLib.OptionArg.STRING, ref _config_path, "Configuration file path", "PATH" },
            { "debug", 'd', 0, GLib.OptionArg.NONE, ref _debug, "Enable debug mode", null },
            { null }
        };

        context.add_main_entries (options, null);

        try {
            context.parse (ref args);
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
            return 1;
        }

        if (_debug) {
            Logger.get_default ().debug_mode = true;
        }

        return run_shell ();
    }

    /**
     * Run the NebulaShell application.
     *
     * @return 0 on success, non-zero on failure
     */
    private int run_shell () {
        // Resolve config path
        string? config_path = resolve_config_path ();
        if (config_path == null) {
            GLib.stderr.printf ("Error: No configuration file found\n");
            GLib.stderr.printf ("Use --config to specify a configuration file\n");
            return 1;
        }

        print ("Starting NebulaShell...\n");
        print ("Loading configuration from %s\n", config_path);

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
     * If an explicit path is set, use it.
     * Otherwise, search for default config files.
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
            search_paths += GLib.Path.build_filename (home, ".config", "nebula-shell", "shell.py");
        }

        if (xdg_config.length > 0) {
            search_paths += GLib.Path.build_filename (xdg_config, "nebula-shell", "shell.py");
        }

        search_paths += GLib.Path.build_filename ("/", "etc", "nebula-shell", "shell.py");

        // Also check current directory
        search_paths += "shell.py";

        foreach (string path in search_paths) {
            if (GLib.FileUtils.test (path, GLib.FileTest.EXISTS)) {
                return path;
            }
        }

        return null;
    }

}

}

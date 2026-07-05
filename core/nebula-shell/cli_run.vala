namespace NebulaShell {

/**
 * Run command implementation.
 *
 * Runs a NebulaShell configuration file. Loads the specified
 * configuration or searches for a default config file.
 *
 * Sets up the required environment for Python GI bindings:
 * - GI_TYPELIB_PATH: where to find NebulaShell-1.0.typelib
 * - PYTHONPATH: where to find the nebula_shell Python package
 * - LD_PRELOAD: gtk4-layer-shell for Wayland compositor
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
     * Spawns Python with the config script and required environment.
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

        // Find Python
        string? python = find_python ();
        if (python == null) {
            GLib.stderr.printf ("Error: Python 3 not found\n");
            return 1;
        }

        // Find the data directory (where shell.py lives)
        string data_dir = get_data_dir ();
        string bindings_dir = get_bindings_dir ();

        // Build environment
        var env = new GLib.GenericArray<string?> ();
        foreach (string? key in GLib.Environ.get ()) {
            env.add (key);
        }

        // Set GI_TYPELIB_PATH
        string typelib_dir = get_typelib_dir ();
        string? existing_gi = GLib.Environment.get_variable ("GI_TYPELIB_PATH");
        string gi_path = typelib_dir;
        if (existing_gi != null && existing_gi.length > 0) {
            gi_path = typelib_dir + ":" + existing_gi;
        }
        env.add ("GI_TYPELIB_PATH=" + gi_path);

        // Set PYTHONPATH
        string? existing_python = GLib.Environment.get_variable ("PYTHONPATH");
        string python_path = bindings_dir;
        if (existing_python != null && existing_python.length > 0) {
            python_path = bindings_dir + ":" + existing_python;
        }
        env.add ("PYTHONPATH=" + python_path);

        // Set LD_PRELOAD for gtk4-layer-shell
        string layer_so = find_layer_shell_lib ();
        if (layer_so != null) {
            string? existing_ld = GLib.Environment.get_variable ("LD_PRELOAD");
            string ld_path = layer_so;
            if (existing_ld != null && existing_ld.length > 0) {
                ld_path = layer_so + ":" + existing_ld;
            }
            env.add ("LD_PRELOAD=" + ld_path);
        }

        env.add (null);

        // Spawn Python with the config script
        string[] spawn_args = { python, config_path };
        int status = 0;

        try {
            GLib.Process.spawn_sync (
                null,            // working directory
                spawn_args,
                env.data,
                GLib.SpawnFlags.SEARCH_PATH,
                null,            // child setup
                null,            // stdout
                null,            // stderr
                out status
            );
        } catch (GLib.SpawnError e) {
            GLib.stderr.printf ("Error: Failed to run Python: %s\n", e.message);
            return 1;
        }

        return status;
    }

    /**
     * Find the Python 3 interpreter.
     */
    private string? find_python () {
        string[] candidates = { "python3", "python" };
        foreach (string candidate in candidates) {
            if (GLib.Environment.find_program_in_path (candidate) != null) {
                return candidate;
            }
        }
        return null;
    }

    /**
     * Find the gtk4-layer-shell shared library.
     */
    private string? find_layer_shell_lib () {
        string[] search_paths = {
            "/usr/lib/libgtk4-layer-shell.so",
            "/usr/lib64/libgtk4-layer-shell.so",
            "/usr/local/lib/libgtk4-layer-shell.so",
        };
        foreach (string path in search_paths) {
            if (GLib.FileUtils.test (path, GLib.FileTest.EXISTS)) {
                return path;
            }
        }
        return null;
    }

    /**
     * Get the directory where the typelib is installed.
     */
    private string get_typelib_dir () {
        // Check standard install location first
        string default_dir = "/usr/lib/girepository-1.0";
        if (GLib.FileUtils.test (default_dir + "/NebulaShell-1.0.typelib", GLib.FileTest.EXISTS)) {
            return default_dir;
        }

        // Check build directory
        string build_dir = "/tmp/nebula-build/core/nebula-shell";
        if (GLib.FileUtils.test (build_dir + "/NebulaShell-1.0.typelib", GLib.FileTest.EXISTS)) {
            return build_dir;
        }

        return default_dir;
    }

    /**
     * Get the directory containing the Python bindings.
     */
    private string get_bindings_dir () {
        // Check standard install location
        string site_dir = "/usr/lib/python3/site-packages";
        if (GLib.FileUtils.test (site_dir + "/nebula_shell", GLib.FileTest.IS_DIR)) {
            return site_dir;
        }

        // Check source tree
        string source_dir = GLib.Path.get_dirname (GLib.Path.get_dirname (get_data_dir ()));
        string bindings_dir = source_dir + "/bindings";
        if (GLib.FileUtils.test (bindings_dir + "/nebula_shell", GLib.FileTest.IS_DIR)) {
            return bindings_dir;
        }

        return site_dir;
    }

    /**
     * Get the data directory (where shell.py lives).
     */
    private string get_data_dir () {
        // Check installed location
        string installed = "/etc/nebula-shell";
        if (GLib.FileUtils.test (installed + "/shell.py", GLib.FileTest.EXISTS)) {
            return installed;
        }

        return installed;
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

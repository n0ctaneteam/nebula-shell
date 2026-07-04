namespace NebulaShell {

/**
 * Plugin command implementation.
 *
 * Manages NebulaShell plugins. Lists, enables, disables,
 * and provides information about installed plugins.
 *
 * Usage:
 *   nebula-shell plugin list
 *   nebula-shell plugin info <plugin-id>
 *   nebula-shell plugin enable <plugin-id>
 *   nebula-shell plugin disable <plugin-id>
 *   nebula-shell plugin paths
 *
 * Example:
 *   $ nebula-shell plugin list
 *   Loaded plugins:
 *   - my-plugin v1.0.0 [ENABLED]
 *   - another-plugin v0.5.0 [DISABLED]
 */
public class CliPlugin : GLib.Object {

    private string? _subcommand = null;
    private string? _plugin_id = null;

    /**
     * Run the plugin command.
     *
     * @param args command arguments
     * @return 0 on success, non-zero on failure
     */
    public int run (string[] args) {
        var context = new GLib.OptionContext ("- manage plugins");

        try {
            context.parse (ref args);
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
            return 1;
        }

        if (args.length > 0) {
            _subcommand = args[0];
        }

        if (args.length > 1) {
            _plugin_id = args[1];
        }

        return dispatch_subcommand ();
    }

    /**
     * Dispatch to the appropriate subcommand.
     *
     * @return 0 on success, non-zero on failure
     */
    private int dispatch_subcommand () {
        switch (_subcommand) {
            case "list":
                return list_plugins ();
            case "info":
                return show_plugin_info ();
            case "enable":
                return enable_plugin ();
            case "disable":
                return disable_plugin ();
            case "paths":
                return show_plugin_paths ();
            case null:
            case "--help":
            case "-h":
                print_help ();
                return 0;
            default:
                GLib.stderr.printf ("Unknown subcommand: %s\n\n", _subcommand);
                print_help ();
                return 1;
        }
    }

    /**
     * Print plugin command help.
     */
    private void print_help () {
        print ("Usage: nebula-shell plugin <subcommand> [options]\n");
        print ("\n");
        print ("Subcommands:\n");
        print ("  list               List loaded plugins\n");
        print ("  info <plugin-id>   Show plugin information\n");
        print ("  enable <plugin-id> Enable a plugin\n");
        print ("  disable <plugin-id> Disable a plugin\n");
        print ("  paths              Show plugin search paths\n");
        print ("\n");
        print ("Options:\n");
        print ("  --help, -h         Show this help message\n");
    }

    /**
     * List all loaded plugins.
     *
     * @return 0 on success
     */
    private int list_plugins () {
        var plugin_manager = PluginManager.get_default ();
        var plugin_ids = plugin_manager.get_plugin_ids ();

        if (plugin_ids.size == 0) {
            print ("No plugins loaded\n");
            return 0;
        }

        print ("Loaded plugins:\n");

        foreach (string id in plugin_ids) {
            var plugin = plugin_manager.get_plugin (id);
            var state = plugin_manager.get_plugin_state (id);

            if (plugin != null) {
                print ("  - %s v%s [%s]\n",
                    plugin.info.name,
                    plugin.info.version,
                    state != null ? state.to_string () : "UNKNOWN"
                );
                print ("    %s\n", plugin.info.description);
            }
        }

        return 0;
    }

    /**
     * Show information about a specific plugin.
     *
     * @return 0 on success, non-zero on failure
     */
    private int show_plugin_info () {
        if (_plugin_id == null) {
            GLib.stderr.printf ("Error: Plugin ID required\n");
            GLib.stderr.printf ("Usage: nebula-shell plugin info <plugin-id>\n");
            return 1;
        }

        var plugin_manager = PluginManager.get_default ();
        var plugin = plugin_manager.get_plugin (_plugin_id);

        if (plugin == null) {
            GLib.stderr.printf ("Error: Plugin not found: %s\n", _plugin_id);
            return 1;
        }

        var state = plugin_manager.get_plugin_state (_plugin_id);

        print ("Plugin: %s\n", plugin.info.name);
        print ("  ID: %s\n", plugin.info.id);
        print ("  Version: %s\n", plugin.info.version);
        print ("  Author: %s\n", plugin.info.author);
        print ("  Description: %s\n", plugin.info.description);
        print ("  API Version: %d\n", plugin.info.api_version);
        print ("  State: %s\n", state != null ? state.to_string () : "UNKNOWN");

        if (plugin.info.dependencies.size > 0) {
            print ("  Dependencies:\n");
            foreach (string dep in plugin.info.dependencies) {
                print ("    - %s\n", dep);
            }
        }

        return 0;
    }

    /**
     * Enable a plugin.
     *
     * @return 0 on success, non-zero on failure
     */
    private int enable_plugin () {
        if (_plugin_id == null) {
            GLib.stderr.printf ("Error: Plugin ID required\n");
            GLib.stderr.printf ("Usage: nebula-shell plugin enable <plugin-id>\n");
            return 1;
        }

        var plugin_manager = PluginManager.get_default ();

        try {
            plugin_manager.enable_plugin (_plugin_id);
            print ("Enabled plugin: %s\n", _plugin_id);
            return 0;
        } catch (PluginError e) {
            GLib.stderr.printf ("Error enabling plugin: %s\n", e.message);
            return 1;
        }
    }

    /**
     * Disable a plugin.
     *
     * @return 0 on success, non-zero on failure
     */
    private int disable_plugin () {
        if (_plugin_id == null) {
            GLib.stderr.printf ("Error: Plugin ID required\n");
            GLib.stderr.printf ("Usage: nebula-shell plugin disable <plugin-id>\n");
            return 1;
        }

        var plugin_manager = PluginManager.get_default ();

        try {
            plugin_manager.disable_plugin (_plugin_id);
            print ("Disabled plugin: %s\n", _plugin_id);
            return 0;
        } catch (PluginError e) {
            GLib.stderr.printf ("Error disabling plugin: %s\n", e.message);
            return 1;
        }
    }

    /**
     * Show plugin search paths.
     *
     * @return 0 on success
     */
    private int show_plugin_paths () {
        var plugin_manager = PluginManager.get_default ();
        var paths = plugin_manager.get_plugin_paths ();

        print ("Plugin search paths:\n");

        foreach (string path in paths) {
            bool exists = GLib.FileUtils.test (path, GLib.FileTest.EXISTS);
            print ("  %s %s\n", exists ? "[✓]" : "[ ]", path);
        }

        return 0;
    }

}

}

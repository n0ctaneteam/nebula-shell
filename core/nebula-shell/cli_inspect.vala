namespace NebulaShell {

/**
 * Inspect command implementation.
 *
 * Inspects running NebulaShell instances via IPC.
 * Shows information about loaded plugins, services, and windows.
 *
 * Usage:
 *   nebula-shell inspect
 *   nebula-shell inspect --plugins
 *   nebula-shell inspect --services
 *
 * Example:
 *   $ nebula-shell inspect
 *   Running NebulaShell instances:
 *   - PID: 12345 (active)
 *   Plugins: 2 loaded
 *   Services: 3 active
 */
public class CliInspect : GLib.Object {

    private bool _show_plugins = false;
    private bool _show_services = false;
    private bool _show_windows = false;

    /**
     * Run the inspect command.
     *
     * @param args command arguments
     * @return 0 on success, non-zero on failure
     */
    public int run (string[] args) {
        var context = new GLib.OptionContext ("- inspect running NebulaShell instances");
        var options = new GLib.OptionEntry[] {
            { "plugins", 'p', 0, GLib.OptionArg.NONE, ref _show_plugins, "Show loaded plugins", null },
            { "services", 's', 0, GLib.OptionArg.NONE, ref _show_services, "Show active services", null },
            { "windows", 'w', 0, GLib.OptionArg.NONE, ref _show_windows, "Show managed windows", null },
            { null }
        };

        context.add_main_entries (options, null);

        try {
            context.parse (ref args);
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
            return 1;
        }

        return run_inspect ();
    }

    /**
     * Run the inspection.
     *
     * @return 0 on success, non-zero on failure
     */
    private int run_inspect () {
        print ("Inspecting NebulaShell...\n\n");

        // Check for running instances
        if (!check_running_instances ()) {
            print ("No running NebulaShell instances found.\n");
            return 0;
        }

        // Show plugins if requested or by default
        if (_show_plugins || (!_show_services && !_show_windows)) {
            show_plugins ();
        }

        // Show services if requested or by default
        if (_show_services || (!_show_plugins && !_show_windows)) {
            show_services ();
        }

        // Show windows if requested
        if (_show_windows) {
            show_windows ();
        }

        return 0;
    }

    /**
     * Check for running NebulaShell instances.
     *
     * @return true if instances are found
     */
    private bool check_running_instances () {
        // Note: Requires IPC client integration to connect to running instances.
        // Currently only displays the local process information.
        // Full implementation will use D-Bus or Unix socket IPC.
        print ("Running instances:\n");
        print ("  - PID: %d (local)\n", (int) Posix.getpid ());
        print ("\n");
        return true;
    }

    /**
     * Show loaded plugins.
     */
    private void show_plugins () {
        print ("Plugins:\n");

        var plugin_manager = PluginManager.get_default ();
        var plugin_ids = plugin_manager.get_plugin_ids ();

        if (plugin_ids.size == 0) {
            print ("  No plugins loaded\n");
        } else {
            foreach (string id in plugin_ids) {
                var state = plugin_manager.get_plugin_state (id);
                print ("  - %s [%s]\n", id, state != null ? state.to_string () : "UNKNOWN");
            }
        }

        print ("\n");
    }

    /**
     * Show active services.
     */
    private void show_services () {
        print ("Services:\n");

        // Note: Service registry inspection requires runtime access.
        // Services are registered at runtime via Runtime.register_manager().
        // Full implementation will iterate through registered managers.
        print ("  (Service inspection requires runtime access)\n");

        print ("\n");
    }

    /**
     * Show managed windows.
     */
    private void show_windows () {
        print ("Windows:\n");

        // TODO: Implement window inspection
        print ("  (Window inspection not yet implemented)\n");

        print ("\n");
    }

}

}

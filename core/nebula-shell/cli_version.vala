namespace NebulaShell {

/**
 * Version command implementation.
 *
 * Shows version information about NebulaShell and its
 * dependencies.
 *
 * Usage:
 *   nebula-shell version
 *   nebula-shell version --verbose
 *
 * Example:
 *   $ nebula-shell version
 *   nebula-shell 0.1.0
 *   $ nebula-shell version --verbose
 *   nebula-shell 0.1.0
 *   GTK: 4.12.0
 *   Layer Shell: 0.1.0
 *   Python: 3.11.0
 */
public class VersionCommand : GLib.Object {

    private bool _verbose = false;

    /**
     * Run the version command.
     *
     * @param args command arguments
     * @return 0 on success
     */
    public int run (string[] args) {
        var context = new GLib.OptionContext ("- show version information");
        var options = new GLib.OptionEntry[] {
            { "verbose", 'V', 0, GLib.OptionArg.NONE, ref _verbose, "Show detailed version information", null },
            { null }
        };

        context.add_main_entries (options, null);

        try {
            context.parse (ref args);
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
            return 1;
        }

        return show_version ();
    }

    /**
     * Show version information.
     *
     * @return 0 on success
     */
    private int show_version () {
        print ("nebula-shell %s\n", NebulaShell.VERSION);

        if (_verbose) {
            print ("\n");
            print ("Dependencies:\n");
            print ("  GTK: %d.%d.%d\n",
                Gtk.MAJOR_VERSION,
                Gtk.MINOR_VERSION,
                Gtk.MICRO_VERSION
            );
            print ("  Layer Shell: compiled against gtk4-layer-shell\n");
            print ("  Python: %s\n", get_python_version ());
        }

        return 0;
    }

    /**
     * Get the Python interpreter version.
     *
     * @return version string, or "not found"
     */
    private string get_python_version () {
        string[] candidates = { "python3", "python" };

        foreach (string candidate in candidates) {
            try {
                string[] argv = { candidate, "--version" };
                var process = new GLib.SubprocessLauncher (GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE);
                var subprocess = process.spawnv (argv);
                string std_out;
                subprocess.communicate_utf8 (null, null, out std_out, null);
                subprocess.wait ();

                if (subprocess.get_exit_status () == 0 && std_out != null) {
                    // Parse "Python X.Y.Z" format
                    string version = std_out.strip ();
                    if (version.has_prefix ("Python ")) {
                        return version.substring (7);
                    }
                    return version;
                }
            } catch (GLib.Error e) {
                continue;
            }
        }

        return "not found";
    }

}

}

namespace NebulaShell {

/**
 * Init command implementation.
 *
 * Creates a new NebulaShell project in the current directory
 * or a specified directory. Generates a basic configuration
 * structure with a Python config file.
 *
 * Usage:
 *   nebula-shell init
 *   nebula-shell init --name my-shell
 *   nebula-shell init --path /path/to/project
 *
 * Example:
 *   $ nebula-shell init --name my-shell
 *   Initializing NebulaShell project 'my-shell'...
 *   Created: my-shell/
 *   Created: my-shell/shell.py
 *   Created: my-shell/style.css
 *   Project initialized successfully!
 */
public class CliInit : GLib.Object {

    private string _name = "nebula-shell-project";
    private string? _path = null;

    /**
     * Run the init command.
     *
     * @param args command arguments
     * @return 0 on success, non-zero on failure
     */
    public int run (string[] args) {
        var context = new GLib.OptionContext ("- initialize a new NebulaShell project");
        var options = new GLib.OptionEntry[] {
            { "name", 'n', 0, GLib.OptionArg.STRING, ref _name, "Project name", "NAME" },
            { "path", 'p', 0, GLib.OptionArg.STRING, ref _path, "Target directory", "PATH" },
            { null }
        };

        context.add_main_entries (options, null);

        try {
            context.parse (ref args);
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
            return 1;
        }

        if (_path == null) {
            _path = GLib.Path.get_basename (_name);
        }

        return create_project ();
    }

    /**
     * Create the project directory structure.
     *
     * @return 0 on success, non-zero on failure
     */
    private int create_project () {
        print ("Initializing NebulaShell project '%s'...\n", _name);

        // Create project directory
        if (!create_directory (_path)) {
            return 1;
        }

        // Create shell.py
        if (!create_config_file ()) {
            return 1;
        }

        // Create style.css
        if (!create_style_file ()) {
            return 1;
        }

        print ("Project initialized successfully!\n");
        print ("\nNext steps:\n");
        print ("  cd %s\n", _path);
        print ("  nebula-shell run\n");

        return 0;
    }

    /**
     * Create a directory.
     *
     * @param path directory path to create
     * @return true on success
     */
    private bool create_directory (string path) {
        try {
            if (GLib.FileUtils.test (path, GLib.FileTest.EXISTS)) {
                print ("Using existing: %s/\n", path);
                return true;
            }
            GLib.DirUtils.create_with_parents (path, 0755);
            print ("Created: %s/\n", path);
            return true;
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error creating directory: %s\n", e.message);
            return false;
        }
    }

    /**
     * Create the Python configuration file.
     *
     * @return true on success
     */
    private bool create_config_file () {
        string config_content = """from nebula_shell import *

app = Application()

# Create a panel
panel = Panel()
panel.show()

app.run()
""";

        string config_path = GLib.Path.build_filename (_path, "shell.py");

        try {
            GLib.FileUtils.set_contents (config_path, config_content);
            print ("Created: %s\n", config_path);
            return true;
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error creating config file: %s\n", e.message);
            return false;
        }
    }

    /**
     * Create the CSS style file.
     *
     * @return true on success
     */
    private bool create_style_file () {
        string style_content = """/* Nebula Shell Styles */

panel {
    background-color: rgba(0, 0, 0, 0.8);
    padding: 8px;
}
""";

        string style_path = GLib.Path.build_filename (_path, "style.css");

        try {
            GLib.FileUtils.set_contents (style_path, style_content);
            print ("Created: %s\n", style_path);
            return true;
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error creating style file: %s\n", e.message);
            return false;
        }
    }

}

}

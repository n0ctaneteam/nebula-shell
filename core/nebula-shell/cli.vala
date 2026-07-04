namespace NebulaShell {

/**
 * Main CLI entry point and command dispatcher.
 *
 * Cli parses command-line arguments and dispatches to the
 * appropriate command handler. It uses GLib.OptionContext
 * for argument parsing.
 *
 * Supported commands:
 *   init      - Initialize a new NebulaShell project
 *   run       - Run a NebulaShell configuration
 *   doctor    - Check system for common issues
 *   inspect   - Inspect running NebulaShell instances
 *   dev       - Start development mode with hot-reload
 *   format    - Format configuration files
 *   plugin    - Manage plugins
 *   version   - Show version information
 *
 * Example:
 *   nebula-shell init
 *   nebula-shell run
 *   nebula-shell doctor
 */
public class Cli : GLib.Object {

    private const string VERSION = "0.1.0";

    private string[] _args;

    /**
     * Create a new CLI instance.
     *
     * @param args command-line arguments
     */
    public Cli (string[] args) {
        _args = args;
    }

    /**
     * Run the CLI.
     *
     * Parses arguments and dispatches to the appropriate command.
     *
     * @return 0 on success, non-zero on failure
     */
    public int run () {
        if (_args.length < 2) {
            print_help ();
            return 1;
        }

        string command = _args[1];

        switch (command) {
            case "init":
                return execute_init ();
            case "run":
                return execute_run ();
            case "doctor":
                return execute_doctor ();
            case "inspect":
                return execute_inspect ();
            case "dev":
                return execute_dev ();
            case "format":
                return execute_format ();
            case "plugin":
                return execute_plugin ();
            case "version":
                return execute_version ();
            case "--help":
            case "-h":
                print_help ();
                return 0;
            case "--version":
            case "-v":
                print_version ();
                return 0;
            default:
                GLib.stderr.printf ("Unknown command: %s\n\n", command);
                print_help ();
                return 1;
        }
    }

    /**
     * Print the main help message.
     */
    private void print_help () {
        print ("Usage: nebula-shell <command> [options]\n");
        print ("\n");
        print ("Commands:\n");
        print ("  init       Initialize a new NebulaShell project\n");
        print ("  run        Run a NebulaShell configuration\n");
        print ("  doctor     Check system for common issues\n");
        print ("  inspect    Inspect running NebulaShell instances\n");
        print ("  dev        Start development mode with hot-reload\n");
        print ("  format     Format configuration files\n");
        print ("  plugin     Manage plugins\n");
        print ("  version    Show version information\n");
        print ("\n");
        print ("Options:\n");
        print ("  --help, -h     Show this help message\n");
        print ("  --version, -v  Show version information\n");
        print ("\n");
        print ("Run 'nebula-shell <command> --help' for command-specific help.\n");
    }

    /**
     * Print version information.
     */
    private void print_version () {
        print ("nebula-shell %s\n".printf (VERSION));
    }

    /**
     * Execute the init command.
     *
     * @return 0 on success, non-zero on failure
     */
    private int execute_init () {
        var init_cmd = new CliInit ();
        return init_cmd.run (get_command_args ());
    }

    /**
     * Execute the run command.
     *
     * @return 0 on success, non-zero on failure
     */
    private int execute_run () {
        var run_cmd = new CliRun ();
        return run_cmd.run (get_command_args ());
    }

    /**
     * Execute the doctor command.
     *
     * @return 0 on success, non-zero on failure
     */
    private int execute_doctor () {
        var doctor_cmd = new CliDoctor ();
        return doctor_cmd.run (get_command_args ());
    }

    /**
     * Execute the inspect command.
     *
     * @return 0 on success, non-zero on failure
     */
    private int execute_inspect () {
        var inspect_cmd = new CliInspect ();
        return inspect_cmd.run (get_command_args ());
    }

    /**
     * Execute the dev command.
     *
     * @return 0 on success, non-zero on failure
     */
    private int execute_dev () {
        var dev_cmd = new CliDev ();
        return dev_cmd.run (get_command_args ());
    }

    /**
     * Execute the format command.
     *
     * @return 0 on success, non-zero on failure
     */
    private int execute_format () {
        var format_cmd = new CliFormat ();
        return format_cmd.run (get_command_args ());
    }

    /**
     * Execute the plugin command.
     *
     * @return 0 on success, non-zero on failure
     */
    private int execute_plugin () {
        var plugin_cmd = new CliPlugin ();
        return plugin_cmd.run (get_command_args ());
    }

    /**
     * Execute the version command.
     *
     * @return 0 on success, non-zero on failure
     */
    private int execute_version () {
        var version_cmd = new VersionCommand ();
        return version_cmd.run (get_command_args ());
    }

    /**
     * Get arguments for the current command.
     *
     * Returns arguments after the command name.
     *
     * @return array of command arguments
     */
    private string[] get_command_args () {
        string[] cmd_args = {};
        for (int i = 2; i < _args.length; i++) {
            cmd_args += _args[i];
        }
        return cmd_args;
    }

}

}

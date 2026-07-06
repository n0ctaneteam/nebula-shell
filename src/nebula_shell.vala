int main(string[] args) {
    NebulaShell.Logger.init();

    if (args.length < 2) {
        NebulaShell.CLI.Commands.show_help();
        return 1;
    }

    string command = args[1];
    string[] command_args = {};
    if (args.length > 2) {
        command_args = args[2:args.length];
    }

    switch (command) {
        case "run":
            var app = new NebulaShell.Application();
            if (command_args.length > 0) {
                Environment.set_variable("NEBULA_CONFIG", command_args[0], true);
            }
            string[] app_args = new string[] { args[0] };
            return app.run(app_args);

        case "quit":
            string? runtime_dir = Environment.get_variable("XDG_RUNTIME_DIR");
            if (runtime_dir == null) runtime_dir = "/tmp";
            var pid_path = Path.build_filename(runtime_dir, "nebula-shell", "pid");
            try {
                string pid_str;
                GLib.FileUtils.get_contents(pid_path, out pid_str);
                int pid = int.parse(pid_str.strip());
                if (pid > 0) {
                    Posix.kill(pid, Posix.Signal.TERM);
                    stdout.printf("Sent quit signal to NebulaShell (PID: %d)\n", pid);
                    return 0;
                }
            } catch (Error e) {
                // fall through to error
            }
            stderr.printf("Error: NebulaShell is not running.\n");
            return 1;

        case "inspect":
            return NebulaShell.CLI.Inspector.run(command_args);

        case "schema":
            return NebulaShell.CLI.SchemaGen.run(command_args);

        case "help":
        case "--help":
        case "-h":
            NebulaShell.CLI.Commands.show_help();
            return 0;

        case "version":
        case "--version":
        case "-v":
            NebulaShell.CLI.Commands.show_version();
            return 0;

        default:
            stderr.printf("Unknown command: %s\n", command);
            NebulaShell.CLI.Commands.show_help();
            return 1;
    }
}

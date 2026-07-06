namespace NebulaShell.CLI {
    public class Main : Object {
        public static int start(string[] args) {
            Logger.init();

            if (args.length < 2) {
                Commands.show_help();
                return 0;
            }

            string command = args[1];
            string[] command_args = {};
            if (args.length > 2) {
                command_args = args[2:args.length];
            }

            switch (command) {
                case "run":
                    var app = new Application();
                    if (command_args.length > 0) {
                        Environment.set_variable("NEBULA_CONFIG", command_args[0], true);
                    }
                    return app.run(command_args);

                case "inspect":
                    return Inspector.run(command_args);

                case "schema":
                    return SchemaGen.run(command_args);

                case "help":
                case "--help":
                case "-h":
                    Commands.show_help();
                    return 0;

                case "version":
                case "--version":
                case "-v":
                    Commands.show_version();
                    return 0;

                default:
                    stderr.printf("Unknown command: %s\n", command);
                    Commands.show_help();
                    return 1;
            }
        }
    }
}

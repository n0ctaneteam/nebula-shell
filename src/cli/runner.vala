namespace NebulaShell.CLI {
    public class Runner : Object {
        public static int run(string[] args) {
            var app = new NebulaShell.Application();
            if (args.length > 0) {
                Environment.set_variable("NEBULA_CONFIG", args[0], true);
            }
            return app.run(args);
        }
    }
}

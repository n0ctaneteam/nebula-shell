namespace NebulaShell.CLI {
    public class Commands : Object {
        public static void show_help() {
            stdout.printf("""
NebulaShell - Lightweight Wayland Widget Framework

Usage:
  nebula-shell <command> [options]

Commands:
  run [config.yaml]        Run NebulaShell with optional custom config
  quit                     Quit a running NebulaShell instance
  inspect [options]        Inspect running widgets
  schema [options]         Generate JSON Schema for YAML intellisense
  help                     Show this help message
  version                  Show version information

Inspect Options:
  --id <id>                Show widget by ID
  --class <class>          Show widgets by CSS class
  --type <type>            Show widgets by GTK type
  --tree                   Show full GTK widget tree
  --json                   Output in JSON format
  --help                   Show inspect help

Schema Options:
  --output <path>          Write schema to file (default: stdout)
  --watch                  Watch for widget changes

Examples:
  nebula-shell run                         Run with default config
  nebula-shell run ~/myconfig.yaml         Run with custom config
  nebula-shell inspect                     Show all widgets
  nebula-shell inspect --id main_bar       Show specific widget
  nebula-shell inspect --class button      Show all buttons
  nebula-shell inspect --tree              Show full GTK tree
  nebula-shell inspect --json              JSON output

Documentation: https://n0ctaneteam.github.io/docs/nebula-shell
GitHub: https://github.com/n0ctaneteam/nebula-shell
License: Apache 2.0

""");
        }

        public static void show_version() {
            stdout.printf("NebulaShell v0.1.0\n");
            stdout.printf("License: Apache 2.0\n");
            stdout.printf("Owner: N0ctaneTeam\n");
            stdout.printf("GitHub: https://github.com/n0ctaneteam/nebula-shell\n");
        }
    }
}

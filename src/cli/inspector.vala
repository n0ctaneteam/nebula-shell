namespace NebulaShell.CLI {
    private class WidgetInfo {
        public string id;
        public string type;
        public string css_class;
        public string visible;
    }

    public class Inspector : Object {
        public static int run(string[] args) {
            bool show_tree = false;
            bool json_output = false;
            string? filter_id = null;
            string? filter_class = null;
            string? filter_type = null;

            for (int i = 0; i < args.length; i++) {
                switch (args[i]) {
                    case "--tree":
                        show_tree = true;
                        break;
                    case "--json":
                        json_output = true;
                        break;
                    case "--id":
                        if (i + 1 < args.length) {
                            filter_id = args[++i];
                        } else {
                            stderr.printf("Error: --id requires a value\n");
                            show_inspect_help();
                            return 1;
                        }
                        break;
                    case "--class":
                        if (i + 1 < args.length) {
                            filter_class = args[++i];
                        } else {
                            stderr.printf("Error: --class requires a value\n");
                            show_inspect_help();
                            return 1;
                        }
                        break;
                    case "--type":
                        if (i + 1 < args.length) {
                            filter_type = args[++i];
                        } else {
                            stderr.printf("Error: --type requires a value\n");
                            show_inspect_help();
                            return 1;
                        }
                        break;
                    case "--help":
                    case "-h":
                        show_inspect_help();
                        return 0;
                    default:
                        stderr.printf("Unknown option: %s\n", args[i]);
                        show_inspect_help();
                        return 1;
                }
            }

            try {
                string? runtime_dir = Environment.get_variable("XDG_RUNTIME_DIR");
                if (runtime_dir == null) runtime_dir = "/tmp";
                var ipc_path = Path.build_filename(runtime_dir, "nebula-shell", "widgets.dat");
                var file = File.new_for_path(ipc_path);
                if (!file.query_exists()) {
                    stderr.printf("Error: NebulaShell is not running.\n");
                    stderr.printf("Start NebulaShell first with: nebula-shell run\n");
                    return 1;
                }

                string content;
                GLib.FileUtils.get_contents(ipc_path, out content);
                var lines = content.split("\n");
                if (lines.length < 2) {
                    stdout.printf("No widgets found.\n");
                    return 0;
                }

                int count = int.parse(lines[0]);
                var matched_widgets = new List<WidgetInfo>();
                int matched = 0;

                for (int i = 1; i < lines.length && matched < count; i++) {
                    if (lines[i].strip() == "") continue;
                    var parts = lines[i].split("|");
                    if (parts.length < 4) continue;
                    string wid = parts[0];
                    string wtype = parts[1];
                    string wclass = parts[2];
                    string wvisible = parts[3];
                    matched++;

                    if (filter_id != null && wid != filter_id) continue;
                    if (filter_class != null && wclass.index_of(filter_class) == -1) continue;
                    if (filter_type != null && wtype != filter_type) continue;

                    var info = new WidgetInfo();
                    info.id = wid;
                    info.type = wtype;
                    info.css_class = wclass;
                    info.visible = wvisible;
                    matched_widgets.append(info);
                }

                if (json_output) {
                    output_json(matched_widgets, show_tree);
                } else {
                    output_text(matched_widgets, show_tree);
                }

            } catch (Error e) {
                stderr.printf("Error: Cannot connect to NebulaShell instance.\n");
                stderr.printf("Make sure nebula-shell is running.\n");
                stderr.printf("Details: %s\n", e.message);
                return 1;
            }

            return 0;
        }

        private static void output_text(List<WidgetInfo> widgets, bool show_tree) {
            if (widgets.length() == 0) {
                stdout.printf("No widgets found.\n");
                return;
            }

            stdout.printf("\x1b[1mNebulaShell Widget Inspector\x1b[0m\n");
            stdout.printf("==============================\n");
            stdout.printf("Found %d widget(s)\n\n", (int) widgets.length());

            foreach (var w in widgets) {
                stdout.printf("\x1b[36m\xe2\x97\x8f\x1b[0m \x1b[1m%s\x1b[0m\n", w.id);
                stdout.printf("  Type:    %s\n", w.type);
                if (w.css_class.length > 0) stdout.printf("  Class:   %s\n", w.css_class);
                stdout.printf("  Visible: %s\n", w.visible);
                stdout.printf("  ---\n");
            }
        }

        private static void output_json(List<WidgetInfo> widgets, bool show_tree) {
            stdout.printf("{\n");
            stdout.printf("  \"command\": \"inspect\",\n");
            stdout.printf("  \"count\": %d,\n", (int) widgets.length());
            stdout.printf("  \"widgets\": [\n");

            int i = 0;
            foreach (var w in widgets) {
                stdout.printf("    {\n");
                stdout.printf("      \"id\": \"%s\",\n", escape_json(w.id));
                stdout.printf("      \"type\": \"%s\",\n", escape_json(w.type));
                stdout.printf("      \"class\": \"%s\",\n", escape_json(w.css_class));
                stdout.printf("      \"visible\": %s\n", w.visible);
                stdout.printf("    }%s\n", (i < (int) widgets.length() - 1) ? "," : "");
                i++;
            }

            stdout.printf("  ]\n");
            stdout.printf("}\n");
        }

        private static string escape_json(string input) {
            var builder = new StringBuilder();
            int i = 0;
            unichar c;
            while (input.get_next_char(ref i, out c)) {
                switch (c) {
                    case '"':  builder.append("\\\""); break;
                    case '\\': builder.append("\\\\"); break;
                    case '\n': builder.append("\\n");  break;
                    case '\r': builder.append("\\r");  break;
                    case '\t': builder.append("\\t");  break;
                    default:
                        if (c < 0x20) {
                            builder.append_printf("\\u%04x", (int) c);
                        } else {
                            builder.append_unichar(c);
                        }
                        break;
                }
            }
            return builder.str;
        }

        private static void show_inspect_help() {
            stdout.printf("nebula-shell inspect - Inspect running widgets\n");
            stdout.printf("\n");
            stdout.printf("Usage:\n");
            stdout.printf("  nebula-shell inspect [options]\n");
            stdout.printf("\n");
            stdout.printf("Options:\n");
            stdout.printf("  --id <id>                Show widget by ID\n");
            stdout.printf("  --class <class>          Show widgets by CSS class\n");
            stdout.printf("  --type <type>            Show widgets by GTK type\n");
            stdout.printf("  --tree                   Show full GTK widget tree\n");
            stdout.printf("  --json                   Output in JSON format\n");
            stdout.printf("  --help, -h               Show this help\n");
            stdout.printf("\n");
            stdout.printf("Examples:\n");
            stdout.printf("  nebula-shell inspect                     Show all widgets\n");
            stdout.printf("  nebula-shell inspect --id main_bar       Show specific widget\n");
            stdout.printf("  nebula-shell inspect --class button      Show all buttons\n");
            stdout.printf("  nebula-shell inspect --tree              Show full GTK tree\n");
            stdout.printf("  nebula-shell inspect --json              JSON output\n");
            stdout.printf("\n");
        }
    }
}

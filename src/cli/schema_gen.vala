namespace NebulaShell.CLI {
    public class SchemaGen : Object {
        public static int run(string[] args) {
            string? output_path = null;

            for (int i = 0; i < args.length; i++) {
                switch (args[i]) {
                    case "--output":
                        if (i + 1 < args.length) {
                            output_path = args[++i];
                        } else {
                            stderr.printf("Error: --output requires a path\n");
                            return 1;
                        }
                        break;
                    case "--help":
                    case "-h":
                        show_schema_help();
                        return 0;
                    default:
                        stderr.printf("Unknown option: %s\n", args[i]);
                        show_schema_help();
                        return 1;
                }
            }

            string schema = generate_schema();

            if (output_path != null) {
                try {
                    var file = File.new_for_path(output_path);
                    file.replace_contents(schema.data, null, false,
                        FileCreateFlags.NONE, null, null);
                    stdout.printf("Schema written to: %s\n", output_path);
                } catch (Error e) {
                    stderr.printf("Error writing schema: %s\n", e.message);
                    return 1;
                }
            } else {
                stdout.printf("%s\n", schema);
            }

            return 0;
        }

        private static string generate_schema() {
            var sb = new StringBuilder();

            L(sb, "{");
            L(sb, "  \"$schema\": \"https://json-schema.org/draft-07/schema#\",");
            L(sb, "  \"$id\": \"https://n0ctaneteam.github.io/schemas/nebula-shell.json\",");
            L(sb, "  \"title\": \"NebulaShell Config\",");
            L(sb, "  \"description\": \"Schema for NebulaShell YAML widget configuration\",");
            L(sb, "  \"type\": \"object\",");
            L(sb, "  \"properties\": {");

            add_bar(sb);
            add_panel(sb);
            add_clock(sb);
            add_cpu(sb);
            add_button(sb);
            add_label(sb);
            add_box(sb);
            add_separator(sb);
            add_workspaces(sb);

            L(sb, "");
            L(sb, "  },");
            L(sb, "  \"additionalProperties\": {");
            L(sb, "    \"type\": \"object\",");
            L(sb, "    \"description\": \"Custom widget - define in ~/.config/nebula-shell/widgets/custom/\"");
            L(sb, "  }");
            L(sb, "}");

            return sb.str;
        }

        private static void L(StringBuilder sb, string s) {
            sb.append(s);
            sb.append_c('\n');
        }

        private static void P(StringBuilder sb, string indent, string name, string type, string desc) {
            L(sb, indent + "\"" + name + "\": {");
            L(sb, indent + "  \"type\": \"" + type + "\",");
            L(sb, indent + "  \"description\": \"" + desc + "\"");
            L(sb, indent + "}");
        }

        private static void block_start(StringBuilder sb, string indent, string name, string desc) {
            L(sb, indent + "\"" + name + "\": {");
            L(sb, indent + "  \"type\": \"object\",");
            L(sb, indent + "  \"description\": \"" + desc + "\",");
            L(sb, indent + "  \"properties\": {");
        }

        private static void block_end(StringBuilder sb, string indent, bool last) {
            L(sb, indent + "  },");
            L(sb, indent + "  \"additionalProperties\": false");
            L(sb, indent + "}" + (last ? "" : ","));
        }

        private static void prop_str(StringBuilder sb, string indent, string name, string desc, string def, string comma) {
            L(sb, indent + "\"" + name + "\": {");
            L(sb, indent + "  \"type\": \"string\",");
            L(sb, indent + "  \"description\": \"" + desc + "\",");
            L(sb, indent + "  \"default\": \"" + def + "\"");
            L(sb, indent + "}" + comma);
        }

        private static void prop_str_no_default(StringBuilder sb, string indent, string name, string desc, string comma) {
            L(sb, indent + "\"" + name + "\": {");
            L(sb, indent + "  \"type\": \"string\",");
            L(sb, indent + "  \"description\": \"" + desc + "\"");
            L(sb, indent + "}" + comma);
        }

        private static void prop_num(StringBuilder sb, string indent, string name, string desc, string def, string comma) {
            L(sb, indent + "\"" + name + "\": {");
            L(sb, indent + "  \"type\": \"number\",");
            L(sb, indent + "  \"description\": \"" + desc + "\",");
            L(sb, indent + "  \"default\": " + def);
            L(sb, indent + "}" + comma);
        }

        private static void prop_bool(StringBuilder sb, string indent, string name, string desc, string def, string comma) {
            L(sb, indent + "\"" + name + "\": {");
            L(sb, indent + "  \"type\": \"boolean\",");
            L(sb, indent + "  \"description\": \"" + desc + "\",");
            L(sb, indent + "  \"default\": " + def);
            L(sb, indent + "}" + comma);
        }

        private static void prop_enum(StringBuilder sb, string indent, string name, string desc, string def, string[] values, string comma) {
            L(sb, indent + "\"" + name + "\": {");
            L(sb, indent + "  \"type\": \"string\",");
            L(sb, indent + "  \"description\": \"" + desc + "\",");
            L(sb, indent + "  \"default\": \"" + def + "\",");
            string en = indent + "  \"enum\": [";
            for (int i = 0; i < values.length; i++) {
                en += "\"" + values[i] + "\"";
                if (i < values.length - 1) en += ", ";
            }
            en += "]";
            L(sb, en);
            L(sb, indent + "}" + comma);
        }

        private static void prop_array(StringBuilder sb, string indent, string name, string desc, string comma) {
            L(sb, indent + "\"" + name + "\": {");
            L(sb, indent + "  \"type\": \"array\",");
            L(sb, indent + "  \"description\": \"" + desc + "\"");
            L(sb, indent + "}" + comma);
        }

        private static void add_bar(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/bar", "Top or bottom bar panel");
            prop_str(sb, I + "    ", "id", "Widget unique identifier", "main_bar", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "bar", ",");
            prop_enum(sb, I + "    ", "anchor", "Screen edge to anchor to", "top", {"top", "bottom"}, ",");
            prop_num(sb, I + "    ", "height", "Window height in pixels", "32", ",");
            prop_array(sb, I + "    ", "children", "Child widget definitions", "");
            block_end(sb, I, false);
        }

        private static void add_panel(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/panel", "Toggleable panel window");
            prop_str(sb, I + "    ", "id", "Widget unique identifier", "main_panel", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "panel", ",");
            prop_bool(sb, I + "    ", "visible", "Initial visibility", "false", ",");
            prop_enum(sb, I + "    ", "anchor", "Screen edge to anchor to", "bottom", {"top", "bottom"}, ",");
            prop_num(sb, I + "    ", "height", "Window height in pixels", "300", ",");
            prop_array(sb, I + "    ", "children", "Child widget definitions", "");
            block_end(sb, I, false);
        }

        private static void add_clock(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/clock", "Time display with configurable format");
            prop_str_no_default(sb, I + "    ", "id", "Widget unique identifier", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "clock", ",");
            prop_str(sb, I + "    ", "format", "Time format (strftime)", "%H:%M:%S", ",");
            prop_num(sb, I + "    ", "interval", "Update interval in seconds", "1", ",");
            prop_str_no_default(sb, I + "    ", "on_click", "Event handler function name", "");
            block_end(sb, I, false);
        }

        private static void add_cpu(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/cpu", "CPU usage meter with progress bar");
            prop_str_no_default(sb, I + "    ", "id", "Widget unique identifier", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "cpu-bar", ",");
            prop_num(sb, I + "    ", "update_interval", "Polling interval in seconds", "2", ",");
            prop_num(sb, I + "    ", "warning_threshold", "Warning color at percentage", "70", ",");
            prop_num(sb, I + "    ", "critical_threshold", "Critical color at percentage", "90", "");
            block_end(sb, I, false);
        }

        private static void add_button(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/button", "Clickable button widget");
            prop_str_no_default(sb, I + "    ", "id", "Widget unique identifier", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "button", ",");
            prop_str(sb, I + "    ", "label", "Button label text", "Button", ",");
            prop_str_no_default(sb, I + "    ", "on_click", "Event handler function name", "");
            block_end(sb, I, false);
        }

        private static void add_label(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/label", "Static text label widget");
            prop_str_no_default(sb, I + "    ", "id", "Widget unique identifier", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "label", ",");
            prop_str(sb, I + "    ", "text", "Label text content", "", "");
            block_end(sb, I, false);
        }

        private static void add_box(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/box", "Container box for child widgets");
            prop_str_no_default(sb, I + "    ", "id", "Widget unique identifier", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "box", ",");
            prop_enum(sb, I + "    ", "orientation", "Layout orientation", "horizontal", {"horizontal", "vertical"}, ",");
            prop_num(sb, I + "    ", "spacing", "Spacing between children in pixels", "0", ",");
            prop_array(sb, I + "    ", "children", "Child widget definitions", "");
            block_end(sb, I, false);
        }

        private static void add_separator(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/separator", "Visual separator line");
            prop_str_no_default(sb, I + "    ", "id", "Widget unique identifier", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "separator", ",");
            prop_enum(sb, I + "    ", "orientation", "Separator orientation", "horizontal", {"horizontal", "vertical"}, "");
            block_end(sb, I, false);
        }

        private static void add_workspaces(StringBuilder sb) {
            string I = "    ";
            block_start(sb, I, "nebula/workspaces", "Hyprland workspace switcher");
            prop_str_no_default(sb, I + "    ", "id", "Widget unique identifier", ",");
            prop_str(sb, I + "    ", "style_class", "CSS class for styling", "workspaces", ",");
            prop_num(sb, I + "    ", "update_interval", "Polling interval in seconds", "0.5", "");
            block_end(sb, I, true);
        }

        private static void show_schema_help() {
            stdout.printf("nebula-shell schema - Generate JSON Schema for YAML intellisense\n");
            stdout.printf("\n");
            stdout.printf("Usage:\n");
            stdout.printf("  nebula-shell schema [options]\n");
            stdout.printf("\n");
            stdout.printf("Options:\n");
            stdout.printf("  --output <path>          Write schema to a file\n");
            stdout.printf("  --help, -h               Show this help\n");
            stdout.printf("\n");
            stdout.printf("Examples:\n");
            stdout.printf("  nebula-shell schema > ~/.config/nebula-shell/nebula-shell.schema.json\n");
            stdout.printf("  nebula-shell schema --output /usr/share/nebula-shell/schema.json\n");
            stdout.printf("\n");
        }
    }
}

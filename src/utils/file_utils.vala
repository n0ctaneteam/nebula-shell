namespace NebulaShell {
    public class FileUtils : Object {
        public static string? find_first(string[] paths) {
            foreach (var path in paths) {
                var file = File.new_for_path(path);
                if (file.query_exists()) {
                    return path;
                }
            }
            return null;
        }

        public static string? find_config(string name) {
            string? sysroot = Environment.get_variable("NEBULA_SYSROOT");
            if (sysroot != null) {
                string dev_path = Path.build_filename(sysroot, "etc", "nebula-shell", name);
                if (File.new_for_path(dev_path).query_exists())
                    return dev_path;
            }

            string user_path = Path.build_filename(
                Environment.get_user_config_dir(),
                "nebula-shell",
                name);

            string system_path = Path.build_filename(
                "/etc",
                "nebula-shell",
                name);

            return find_first({user_path, system_path});
        }

        public static string? find_widget(string widget_type) {
            var parts = widget_type.split("/");
            if (parts.length != 2) return null;

            string ns = parts[0];
            string name = parts[1];

            string? sysroot = Environment.get_variable("NEBULA_SYSROOT");
            if (sysroot != null) {
                string dev_path = Path.build_filename(
                    sysroot, "etc", "nebula-shell", "widgets", ns, name + ".lua");
                if (File.new_for_path(dev_path).query_exists())
                    return dev_path;
            }

            string user_path = Path.build_filename(
                Environment.get_user_config_dir(),
                "nebula-shell",
                "widgets",
                ns,
                name + ".lua");

            string system_path = Path.build_filename(
                "/etc",
                "nebula-shell",
                "widgets",
                ns,
                name + ".lua");

            string builtin_path = Path.build_filename(
                "/etc",
                "nebula-shell",
                "widgets",
                "nebula",
                name + ".lua");

            string[] paths;
            if (ns == "nebula") {
                paths = {user_path, system_path, builtin_path};
            } else {
                paths = {user_path, system_path};
            }

            return find_first(paths);
        }

        public static string find_user_dir(string subdir = "") {
            string base_path = Path.build_filename(
                Environment.get_user_config_dir(),
                "nebula-shell");
            if (subdir == "") return base_path;
            return Path.build_filename(base_path, subdir);
        }

        public static string find_system_dir(string subdir = "") {
            string base_path = "/etc/nebula-shell";
            if (subdir == "") return base_path;
            return Path.build_filename(base_path, subdir);
        }

        public static void ensure_user_dir(string subdir = "") {
            string path = find_user_dir(subdir);
            var dir = File.new_for_path(path);
            try {
                if (!dir.query_exists()) {
                    dir.make_directory_with_parents();
                }
            } catch (Error e) {
                Logger.warning(@"Failed to create directory $(path): $(e.message)");
            }
        }
    }
}

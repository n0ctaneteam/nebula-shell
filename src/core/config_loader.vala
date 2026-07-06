namespace NebulaShell {
    public class ConfigLoader : Object {
        private LuaBridge lua_bridge;

        public ConfigLoader(LuaBridge bridge) {
            lua_bridge = bridge;
        }

        public bool load() {
            string? yaml_path = FileUtils.find_config("widgets/yaml.lua");
            if (yaml_path == null) {
                Logger.error("yaml.lua parser not found");
                return false;
            }

            if (!lua_bridge.load_file(yaml_path)) {
                Logger.error("Failed to load YAML parser");
                return false;
            }
            lua_bridge.pop(); // pop yaml module table (kept alive by yaml_parse_file upvalue)

            string? config_path = resolve_config_path();
            if (config_path == null) {
                Logger.error("No config.yaml found");
                return false;
            }

            Logger.info(@"Loading config: $(config_path)");

            lua_bridge.push_string(config_path);
            if (!lua_bridge.call_function("yaml_parse_file", 1, 1)) {
                Logger.error("Failed to parse YAML config");
                return false;
            }

            if (!lua_bridge.is_table(-1)) {
                Logger.error("Config is not a valid widget tree");
                lua_bridge.pop();
                return false;
            }

            lua_bridge.set_global("_nebula_config");
            Logger.info("Config loaded successfully");
            return true;
        }

        private string? resolve_config_path() {
            string? env_path = Environment.get_variable("NEBULA_CONFIG");
            if (env_path != null) {
                var file = File.new_for_path(env_path);
                if (file.query_exists()) return env_path;
                Logger.warning(@"NEBULA_CONFIG path not found: $(env_path)");
            }

            string user_path = Path.build_filename(
                Environment.get_user_config_dir(),
                "nebula-shell",
                "config.yaml");
            var user_file = File.new_for_path(user_path);
            if (user_file.query_exists()) return user_path;

            return "/etc/nebula-shell/config.yaml";
        }

        public void load_widget_events() {
            string? events_path = FileUtils.find_config("events.lua");
            if (events_path == null) {
                Logger.warning("No events.lua found");
                return;
            }
            if (!lua_bridge.do_file(events_path)) {
                Logger.error("Failed to load events.lua - no event handlers available");
                return;
            }
            Logger.info(@"Loaded events: $(events_path)");
        }
    }
}

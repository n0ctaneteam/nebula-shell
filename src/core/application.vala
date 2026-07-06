namespace NebulaShell {
    public class Application : Gtk.Application {
        private LuaBridge lua_bridge;
        private ConfigLoader config_loader;
        private WidgetBuilder widget_builder;
        private CssManager css_manager;

        public Application() {
            Object(
                application_id: "com.n0ctaneteam.nebula.shell",
                flags: ApplicationFlags.DEFAULT_FLAGS
            );
        }

        protected override void activate() {
            Logger.info("NebulaShell starting...");

            Registry.init();

            lua_bridge = new LuaBridge();
            register_lua_functions();

            config_loader = new ConfigLoader(lua_bridge);
            if (!config_loader.load()) {
                Logger.error("Failed to load configuration");
                return;
            }

            config_loader.load_widget_events();

            widget_builder = new WidgetBuilder(lua_bridge);
            widget_builder.build_from_config();

            css_manager = new CssManager();
            css_manager.load();

            Registry.show_all();

            export_dbus_interface();

            Logger.info("NebulaShell started successfully");
        }

        private void export_dbus_interface() {
            save_widget_state();
        }

        private void save_widget_state() {
            try {
                var dir = File.new_for_path("/tmp/nebula-shell");
                if (!dir.query_exists()) {
                    dir.make_directory_with_parents();
                }

                var builder = new StringBuilder();
                var ids = Registry.get_all_ids();
                builder.append(@"$(ids.length)\n");
                foreach (var id in ids) {
                    var w = Registry.lookup(id);
                    if (w == null) continue;
                    var type = w.get_type().name();
                    var classes = string.joinv(" ", w.get_css_classes());
                    builder.append(@"$(id)|$(type)|$(classes)|$(w.get_visible().to_string())\n");
                }

                var file = File.new_for_path("/tmp/nebula-shell/widgets.dat");
                file.replace_contents(builder.str.data, null, false, FileCreateFlags.NONE, null);
                Logger.info("Widget state saved");
            } catch (Error e) {
                Logger.warning(@"Failed to save widget state: $(e.message)");
            }
        }

        protected override void shutdown() {
            Logger.info("NebulaShell shutting down...");
            Registry.cleanup();
            base.shutdown();
        }

        private void register_lua_functions() {
            lua_bridge.register_function("register_widget", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Lua.lua_getglobal(L, "_nebula_widget_configs");
                    if (Lua.lua_type(L, -1) == Lua.TNIL) {
                        Lua.lua_pop(L, 1);
                        Lua.lua_newtable(L);
                        Lua.lua_setglobal(L, "_nebula_widget_configs");
                        Lua.lua_getglobal(L, "_nebula_widget_configs");
                    }
                    Lua.lua_pushvalue(L, 2);
                    Lua.lua_setfield(L, -2, id);
                    Lua.lua_pop(L, 1);
                }
                return 0;
            });

            lua_bridge.register_function("get_widget_by_id", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null) {
                        Lua.lua_pushlightuserdata(L, widget);
                        return 1;
                    }
                }
                Lua.lua_pushnil(L);
                return 1;
            });

            lua_bridge.register_function("widget_set_visible", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null) {
                        bool visible = Lua.lua_toboolean(L, 2) != 0;
                        widget.set_visible(visible);
                    }
                }
                return 0;
            });

            lua_bridge.register_function("widget_get_visible", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null) {
                        Lua.lua_pushboolean(L, widget.get_visible() ? 1 : 0);
                        return 1;
                    }
                }
                Lua.lua_pushboolean(L, 0);
                return 1;
            });

            lua_bridge.register_function("widget_set_label", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null && widget is Gtk.Label) {
                        string label = Lua.lua_tostring(L, 2) ?? "";
                        ((Gtk.Label) widget).set_label(label);
                    }
                }
                return 0;
            });

            lua_bridge.register_function("widget_get_label", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null && widget is Gtk.Label) {
                        Lua.lua_pushstring(L, ((Gtk.Label) widget).get_label());
                        return 1;
                    }
                }
                Lua.lua_pushstring(L, "");
                return 1;
            });

            lua_bridge.register_function("widget_set_fraction", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null && widget is Gtk.ProgressBar) {
                        double fraction = Lua.lua_tonumber(L, 2);
                        ((Gtk.ProgressBar) widget).set_fraction(fraction);
                    }
                }
                return 0;
            });

            lua_bridge.register_function("widget_set_text", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null && widget is Gtk.ProgressBar) {
                        string text = Lua.lua_tostring(L, 2) ?? "";
                        ((Gtk.ProgressBar) widget).set_text(text);
                    }
                }
                return 0;
            });

            lua_bridge.register_function("widget_add_css_class", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null) {
                        string cls = Lua.lua_tostring(L, 2) ?? "";
                        widget.add_css_class(cls);
                    }
                }
                return 0;
            });

            lua_bridge.register_function("widget_remove_css_class", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null) {
                        string cls = Lua.lua_tostring(L, 2) ?? "";
                        widget.remove_css_class(cls);
                    }
                }
                return 0;
            });

            lua_bridge.register_function("log_info", (L) => {
                string? msg = Lua.lua_tostring(L, 1);
                if (msg != null) Logger.info(@"[Lua] $(msg)");
                return 0;
            });

            lua_bridge.register_function("log_error", (L) => {
                string? msg = Lua.lua_tostring(L, 1);
                if (msg != null) Logger.error(@"[Lua] $(msg)");
                return 0;
            });
        }
    }
}

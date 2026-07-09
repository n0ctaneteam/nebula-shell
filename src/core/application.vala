namespace NebulaShell {
    public class Application : Gtk.Application {
        private LuaBridge lua_bridge;
        private ConfigLoader config_loader;
        private WidgetBuilder widget_builder;
        private static WidgetBuilder? dialog_builder = null;
        private CssManager css_manager;

        public Application() {
            Object(
                application_id: "com.n0ctaneteam.nebula.shell",
                flags: ApplicationFlags.DEFAULT_FLAGS
            );
        }

        private static bool already_activated = false;

        protected override void activate() {
            if (already_activated) {
                Logger.warning("Ignoring duplicate activate() call");
                return;
            }
            already_activated = true;

            Logger.info("NebulaShell starting...");

            var display = Gdk.Display.get_default();
            if (display == null) {
                Logger.error("No Wayland display available. NebulaShell requires a Wayland compositor (e.g., Hyprland).");
                this.quit();
                return;
            }

            Registry.init();

            lua_bridge = new LuaBridge();
            register_lua_functions();

            config_loader = new ConfigLoader(lua_bridge);
            if (!config_loader.load()) {
                Logger.error("Failed to load configuration");
                return;
            }
            Logger.info("Config loaded, loading events...");

            config_loader.load_widget_events();
            Logger.info("Events loaded, building widgets...");

            css_manager = new CssManager();
            css_manager.load();

            widget_builder = new WidgetBuilder(lua_bridge);
            dialog_builder = widget_builder;
            widget_builder.build_from_config();
            register_dialog_functions();

            Registry.show_all();

            export_dbus_interface();
            save_pid();
            setup_toggle_handler();

            this.hold();
            Logger.info("NebulaShell started successfully");
        }

        private static string get_ipc_dir() {
            string? runtime_dir = Environment.get_variable("XDG_RUNTIME_DIR");
            if (runtime_dir == null) {
                runtime_dir = "/tmp";
            }
            return Path.build_filename(runtime_dir, "nebula-shell");
        }

        private void export_dbus_interface() {
            save_widget_state();
        }

        private void save_pid() {
            try {
                var dir = File.new_for_path(get_ipc_dir());
                if (!dir.query_exists()) {
                    dir.make_directory_with_parents();
                }
                var pid_path = Path.build_filename(get_ipc_dir(), "pid");
                string pid_str = ((int) Posix.getpid()).to_string() + "\n";
                var file = File.new_for_path(pid_path);
                file.replace_contents(pid_str.data, null, false, FileCreateFlags.NONE, null);
                Logger.info("PID saved");
            } catch (Error e) {
                Logger.warning(@"Failed to save PID: $(e.message)");
            }
        }

        private void setup_toggle_handler() {
            try {
                GLib.Unix.signal_add((int) Posix.Signal.USR1, () => {
                    string toggle_file = Path.build_filename(get_ipc_dir(), "toggle");
                    try {
                        string content;
                        GLib.FileUtils.get_contents(toggle_file, out content);
                        GLib.FileUtils.remove(toggle_file);
                        string widget_id = content.strip();
                        if (widget_id.length > 0) {
                            var widget = Registry.lookup(widget_id);
                            if (widget != null) {
                                widget.set_visible(!widget.get_visible());
                                Logger.info(@"Toggled widget: $(widget_id)");
                            } else {
                                Logger.warning(@"Toggle: widget not found: $(widget_id)");
                            }
                        }
                    } catch (Error e) {
                        Logger.warning(@"Toggle IPC error: $(e.message)");
                    }
                    return true;
                });
            } catch (GLib.Error e) {
                Logger.warning(@"Failed to set up toggle handler: $(e.message)");
            }
        }

        private static void cleanup_ipc() {
            try {
                var pid_path = Path.build_filename(get_ipc_dir(), "pid");
                var pid_file = File.new_for_path(pid_path);
                if (pid_file.query_exists()) {
                    pid_file.delete();
                }
                var widgets_path = Path.build_filename(get_ipc_dir(), "widgets.dat");
                var widgets_file = File.new_for_path(widgets_path);
                if (widgets_file.query_exists()) {
                    widgets_file.delete();
                }
                Logger.info("IPC files cleaned up");
            } catch (Error e) {
                Logger.warning(@"Failed to clean up IPC files: $(e.message)");
            }
        }

        private void save_widget_state() {
            try {
                var dir = File.new_for_path(get_ipc_dir());
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

                var file = File.new_for_path(Path.build_filename(get_ipc_dir(), "widgets.dat"));
                file.replace_contents(builder.str.data, null, false, FileCreateFlags.NONE, null);
                Logger.info("Widget state saved");
            } catch (Error e) {
                Logger.warning(@"Failed to save widget state: $(e.message)");
            }
        }

        protected override void shutdown() {
            Logger.info("NebulaShell shutting down...");
            Registry.cleanup();
            cleanup_ipc();
            this.release();
            base.shutdown();
        }

        private void register_dialog_functions() {
            lua_bridge.register_function("show_dialog", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null && dialog_builder != null) {
                    Gtk.Widget? dialog = dialog_builder.build_dialog_from_config("nebula/dialog", id);
                    dialog.set_visible(true);
                }
                return 0;
            });

            lua_bridge.register_function("toggle_dialog", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null && dialog_builder != null) {
                    var widget = Registry.lookup(id);
                    if (widget != null) {
                        Registry.remove(id);
                        Lua.lua_getglobal(L, "_nebula_widget_configs");
                        if (Lua.lua_type(L, -1) == Lua.TTABLE) {
                            Lua.lua_pushnil(L);
                            Lua.lua_setfield(L, -2, id);
                        }
                        Lua.lua_pop(L, 1);
                    } else {
                        Gtk.Widget? dialog = dialog_builder.build_dialog_from_config("nebula/dialog", id);
                        dialog.set_visible(true);
                    }
                }
                return 0;
            });

            lua_bridge.register_function("destroy_dialog", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Registry.remove(id);
                    Lua.lua_getglobal(L, "_nebula_widget_configs");
                    if (Lua.lua_type(L, -1) == Lua.TTABLE) {
                        Lua.lua_pushnil(L);
                        Lua.lua_setfield(L, -2, id);
                    }
                    Lua.lua_pop(L, 1);
                }
                return 0;
            });
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
                    if (widget != null) {
                        if (widget is Gtk.Label) {
                            ((Gtk.Label) widget).set_label(Lua.lua_tostring(L, 2) ?? "");
                        } else if (widget is Gtk.Button) {
                            ((Gtk.Button) widget).set_label(Lua.lua_tostring(L, 2) ?? "");
                        }
                    }
                }
                return 0;
            });

            lua_bridge.register_function("widget_get_label", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null) {
                        if (widget is Gtk.Label) {
                            Lua.lua_pushstring(L, ((Gtk.Label) widget).get_label());
                            return 1;
                        } else if (widget is Gtk.Button) {
                            Lua.lua_pushstring(L, ((Gtk.Button) widget).get_label());
                            return 1;
                        }
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

            lua_bridge.register_function("widget_set_parent", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                void* parent_ptr = Lua.lua_touserdata(L, 2);
                if (id != null && parent_ptr != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null) {
                        widget.set_parent((Gtk.Widget) parent_ptr);
                    }
                }
                return 0;
            });

            lua_bridge.register_function("popup_widget", (L) => {
                string? id = Lua.lua_tostring(L, 1);
                if (id != null) {
                    Gtk.Widget? widget = Registry.lookup(id);
                    if (widget != null && widget is Gtk.Popover) {
                        ((Gtk.Popover) widget).popup();
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

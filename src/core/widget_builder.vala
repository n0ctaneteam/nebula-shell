namespace NebulaShell {
    public class WidgetBuilder : Object {
        private LuaBridge lua_bridge;
        private HashTable<string, uint> timers;

        public WidgetBuilder(LuaBridge bridge) {
            lua_bridge = bridge;
            timers = new HashTable<string, uint>(str_hash, str_equal);
        }

        public void build_from_config() {
            if (!lua_bridge.get_global("_nebula_config")) {
                Logger.error("No config loaded");
                return;
            }

            if (!lua_bridge.is_table(-1)) {
                Logger.error("Config is not a table");
                lua_bridge.pop();
                return;
            }

            var keys = lua_bridge.get_table_keys();
            foreach (var key in keys) {
                if (key == null) continue;
                lua_bridge.get_field(-1, key);
                if (lua_bridge.is_table(-1)) {
                    Logger.info(@"Building widget: $(key)");
                    create_widget_from_lua(key, -1);
                }
                lua_bridge.pop();
            }

            lua_bridge.pop();
        }

        private void create_widget_from_lua(string widget_type, int props_index) {
            string? widget_path = FileUtils.find_widget(widget_type);
            if (widget_path == null) {
                Logger.error(@"Widget file not found: $(widget_type)");
                return;
            }

            if (props_index < 0) {
                props_index = lua_bridge.get_top() + props_index + 1;
            }

            if (!lua_bridge.load_file(widget_path)) {
                Logger.error(@"Failed to load widget: $(widget_type)");
                return;
            }

            if (!lua_bridge.get_field(-1, "create")) {
                Logger.error(@"Widget '$(widget_type)' has no create() function");
                lua_bridge.pop();
                lua_bridge.pop();
                return;
            }

            lua_bridge.push_value(props_index);

            if (!lua_bridge.get_global("_widget_event_handlers")) {
                lua_bridge.push_nil();
            }

            if (!lua_bridge.call(2, 1)) {
                Logger.error(@"Widget create() failed for: $(widget_type)");
                lua_bridge.pop();
                return;
            }

            if (!lua_bridge.is_table(-1)) {
                Logger.error("Widget create() must return a table");
                lua_bridge.pop();
                return;
            }

            string? id = get_lua_field_string("id");
            string? style_class = get_lua_field_string("style_class");
            string? widget_type_str = get_lua_field_string("_type");
            bool timer_enabled = get_lua_field_bool("_timer_enabled");
            double timer_interval = get_lua_field_double("_timer_interval");

            if (id == null) {
                id = "%s_%p".printf(widget_type.replace("/", "_"), this);
            }

            Gtk.Widget? widget = create_gtk_widget(id, widget_type_str);

            if (widget == null) {
                Logger.error(@"Failed to create GTK widget for type: $(widget_type_str ?? "nil")");
                lua_bridge.pop();
                return;
            }

            Registry.register(id, widget);

            if (style_class != null) {
                string[] classes = style_class.split(" ");
                foreach (var cls in classes) {
                    if (cls.strip().length > 0)
                        widget.add_css_class(cls.strip());
                }
            }

            if (widget is Gtk.Window) {
                string? anchor = get_lua_field_string("anchor");
                if (anchor != null) {
                    bool visible = !get_lua_field_bool("visible");
                    LayerShell.init_window((Gtk.Window) widget, anchor, visible);
                }
            }

            if (timer_enabled && timer_interval > 0) {
                setup_timer(id, timer_interval);
            }

            string? on_click_func_name = get_lua_field_string("on_click");
            if (on_click_func_name != null && widget is Gtk.Button) {
                var btn = (Gtk.Button) widget;
                setup_click_handler(btn, id, on_click_func_name);
            }

            bool has_children = lua_bridge.get_field(-1, "_children");
            if (has_children && lua_bridge.is_table(-1)) {
                if (widget is Gtk.Box) {
                    build_children((Gtk.Box) widget);
                } else if (widget is Gtk.Window) {
                    var win = (Gtk.Window) widget;
                    var child = win.get_child();
                    if (child is Gtk.Box) {
                        build_children((Gtk.Box) child);
                    }
                }
                lua_bridge.pop();
            } else if (has_children) {
                lua_bridge.pop();
            }

            lua_bridge.pop();
            Logger.info(@"Built widget: $(widget_type) (id: $(id))");
        }

        private Gtk.Widget? create_gtk_widget(string id, string? widget_type) {
            switch (widget_type) {
                case "button":
                    string? label = get_lua_field_string("_text");
                    return new Gtk.Button.with_label(label ?? "Button");

                case "label":
                    string? text = get_lua_field_string("_text");
                    return new Gtk.Label(text ?? "");

                case "box": {
                    string? orientation = get_lua_field_string("_orientation");
                    int spacing = (int) get_lua_field_double("_spacing");
                    Gtk.Orientation orient = (orientation == "vertical")
                        ? Gtk.Orientation.VERTICAL
                        : Gtk.Orientation.HORIZONTAL;
                    return new Gtk.Box(orient, spacing);
                }

                case "separator":
                    string? orient_str = get_lua_field_string("_orientation");
                    return new Gtk.Separator(
                        (orient_str == "vertical")
                            ? Gtk.Orientation.VERTICAL
                            : Gtk.Orientation.HORIZONTAL);

                case "progress_bar": {
                    var pb = new Gtk.ProgressBar();
                    pb.set_show_text(true);
                    pb.set_fraction(0.0);
                    pb.set_text("0%");
                    return pb;
                }

                case "window": {
                    var win = new Gtk.Window();
                    int height = (int) get_lua_field_double("height");
                    if (height > 0) win.set_default_size(800, height);

                    string? orient_str = get_lua_field_string("_orientation");
                    Gtk.Orientation orient = (orient_str == "vertical")
                        ? Gtk.Orientation.VERTICAL
                        : Gtk.Orientation.HORIZONTAL;
                    int spacing = (int) get_lua_field_double("_spacing");
                    var box = new Gtk.Box(orient, spacing > 0 ? spacing : 0);
                    win.set_child(box);
                    return win;
                }

                default:
                    Logger.error(@"Unknown widget type: $(widget_type ?? "nil")");
                    return null;
            }
        }

        private void setup_click_handler(Gtk.Button btn, string widget_id, string func_name) {
            btn.clicked.connect(() => {
                lua_bridge.get_global(func_name);
                if (lua_bridge.is_function(-1)) {
                    lua_bridge.push_string(widget_id);
                    lua_bridge.call(1, 0);
                } else {
                    lua_bridge.pop();
                }
            });
        }

        private void setup_timer(string widget_id, double interval_sec) {
            uint interval_ms = (uint)(interval_sec * 1000);
            uint timer_id = GLib.Timeout.add(interval_ms, () => {
                var widget = Registry.lookup(widget_id);
                if (widget == null) return false;
                return true;
            });
            timers.insert(widget_id, timer_id);
        }

        private void build_children(Gtk.Box parent_box) {
            if (!lua_bridge.is_table(-1)) return;

            var keys = lua_bridge.get_table_keys();
            if (keys.length == 0) return;

            foreach (var key in keys) {
                if (key == null) continue;
                lua_bridge.get_field(-1, key);
                if (lua_bridge.is_table(-1)) {
                    string child_type = key;
                    string child_id = "%s_%s".printf(parent_box.get_name(), child_type);
                    string? child_wtype = null;
                    if (lua_bridge.get_field(-1, "_type")) {
                        child_wtype = lua_bridge.get_string(-1);
                        lua_bridge.pop();
                    }
                    Gtk.Widget? child = create_gtk_widget(child_id, child_wtype);
                    if (child != null) {
                        parent_box.append(child);
                    }
                }
                lua_bridge.pop();
            }
        }

        private string? get_lua_field_string(string key) {
            if (!lua_bridge.get_field(-1, key)) return null;
            string? val = lua_bridge.get_string(-1);
            lua_bridge.pop();
            return val;
        }

        private double get_lua_field_double(string key) {
            if (!lua_bridge.get_field(-1, key)) return 0.0;
            double? val = lua_bridge.get_number(-1);
            lua_bridge.pop();
            return val ?? 0.0;
        }

        private bool get_lua_field_bool(string key) {
            if (!lua_bridge.get_field(-1, key)) return false;
            bool? val = lua_bridge.get_boolean(-1);
            lua_bridge.pop();
            return val ?? false;
        }
    }
}

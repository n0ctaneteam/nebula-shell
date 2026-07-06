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

        private Gtk.Widget? create_widget_from_lua(string widget_type, int props_index) {
            string? widget_path = FileUtils.find_widget(widget_type);
            if (widget_path == null && widget_type.index_of("/") < 0) {
                widget_path = FileUtils.find_widget(@"nebula/$(widget_type)");
            }
            if (widget_path == null) {
                Logger.error(@"Widget file not found: $(widget_type)");
                return null;
            }

            if (props_index < 0) {
                props_index = lua_bridge.get_top() + props_index + 1;
            }

            if (!lua_bridge.load_file(widget_path)) {
                Logger.error(@"Failed to load widget: $(widget_type)");
                return null;
            }

            // Stack: [module_table]

            if (!lua_bridge.get_field(-1, "create")) {
                Logger.error(@"Widget '$(widget_type)' has no create() function");
                lua_bridge.pop(2); // pop nil + module
                return null;
            }

            // Stack: [module_table, create_func]
            lua_bridge.push_value(props_index);

            lua_bridge.get_global("_widget_event_handlers");
            // nil pushed by get_global if global doesn't exist

            // Stack: [module_table, create_func, props, handlers]
            // Save module reference before pcall consumes it
            Lua.lua_pushvalue(lua_bridge.get_L(), -4); // copy module
            Lua.lua_insert(lua_bridge.get_L(), -5);    // move copy below everything
            // Stack: [module_copy, module_table, create_func, props, handlers]

            if (!lua_bridge.call(2, 1)) {
                Logger.error(@"Widget create() failed for: $(widget_type)");
                lua_bridge.pop(3); // pop error + module + module_copy
                return null;
            }

            // Stack: [module_copy, module_table, config_table]

            // Check if result is a table
            if (!lua_bridge.is_table(-1)) {
                Logger.error("Widget create() must return a table");
                lua_bridge.pop(3);
                return null;
            }

            // Store module reference in config for timer/dispatch callbacks
            Lua.lua_pushvalue(lua_bridge.get_L(), -2); // copy module_table
            Lua.lua_setfield(lua_bridge.get_L(), -2, "_module"); // config._module = module
            // Stack: [module_copy, module_table, config]

            lua_bridge.remove(-3); // remove module_copy
            lua_bridge.remove(-2); // remove module_table
            // Stack: [config]

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
                return null;
            }

            Registry.register(id, widget);

            if (style_class != null) {
                string[] classes = style_class.split(" ");
                foreach (var cls in classes) {
                    if (cls.strip().length > 0) {
                        widget.add_css_class(cls.strip());
                    }
                }
                // right-section boxes should push to the right in their parent
                if (widget is Gtk.Box && "right-section" in classes) {
                    ((Gtk.Box) widget).set_halign(Gtk.Align.END);
                }
            }

            if (widget is Gtk.Window) {
                string? anchor = get_lua_field_string("anchor");
                if (anchor != null) {
                    bool use_exclusive = get_lua_field_bool("visible");
                    LayerShell.init_window((Gtk.Window) widget, anchor, use_exclusive);
                }
            }

            if (timer_enabled && timer_interval > 0) {
                setup_timer(id, timer_interval);
            }

            string? on_click_func_name = get_lua_field_string("on_click");
            if (on_click_func_name != null && widget is Gtk.Button) {
                var btn = (Gtk.Button) widget;
                setup_click_handler(btn, id, on_click_func_name);
            } else if (widget is Gtk.Button) {
                // Check for _on_click Lua closure (used by programmatic widgets)
                lua_bridge.get_field(-1, "_on_click");
                if (lua_bridge.is_function(-1)) {
                    string captured_id = id;
                    var btn = (Gtk.Button) widget;
                    btn.clicked.connect(() => {
                        lua_bridge.get_global("_nebula_widget_configs");
                        if (lua_bridge.is_table(-1)) {
                            lua_bridge.get_field(-1, captured_id);
                            if (lua_bridge.is_table(-1)) {
                                lua_bridge.get_field(-1, "_on_click");
                                if (lua_bridge.is_function(-1)) {
                                    lua_bridge.push_string(captured_id);
                                    lua_bridge.call(1, 0);
                                } else {
                                    lua_bridge.pop();
                                }
                                lua_bridge.pop(); // pop config
                            } else {
                                lua_bridge.pop(); // pop nil
                            }
                            lua_bridge.pop(); // pop _nebula_widget_configs
                        } else {
                            lua_bridge.pop(); // pop nil
                        }
                    });
                }
                lua_bridge.pop(); // pop _on_click or nil
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
            } else {
                lua_bridge.pop(); // pop nil or non-table value
            }

            lua_bridge.pop();
            Logger.info(@"Built widget: $(widget_type) (id: $(id))");
            return widget;
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
                return timer_tick(widget_id);
            });
            timers.insert(widget_id, timer_id);
        }

        private bool timer_tick(string widget_id) {
            var widget = Registry.lookup(widget_id);
            if (widget == null) return false;

            lua_bridge.get_global("_nebula_widget_configs");
            if (!lua_bridge.is_table(-1)) {
                lua_bridge.pop();
                return true;
            }
            lua_bridge.get_field(-1, widget_id);
            if (!lua_bridge.is_table(-1)) {
                lua_bridge.pop(2);
                return true;
            }

            lua_bridge.get_field(-1, "_module");
            if (!lua_bridge.is_table(-1)) {
                lua_bridge.pop(3);
                return true;
            }

            lua_bridge.get_field(-1, "update");
            if (!lua_bridge.is_function(-1)) {
                lua_bridge.pop(4);
                return true;
            }

            Lua.lua_pushvalue(lua_bridge.get_L(), -3);
            lua_bridge.call(1, 0);

            lua_bridge.pop(3);
            return true;
        }

        private void build_children(Gtk.Box parent_box) {
            if (!lua_bridge.is_table(-1)) return;

            ulong raw_len = Lua.lua_rawlen(lua_bridge.get_L(), -1);
            int len = (int) raw_len;

            for (int i = 1; i <= len; i++) {
                Lua.lua_rawgeti(lua_bridge.get_L(), -1, i);

                if (!lua_bridge.is_table(-1)) {
                    Lua.lua_pop(lua_bridge.get_L(), 1);
                    continue;
                }

                // Two possible child entry formats:
                //   A) YAML-wrapped: { ["nebula/type"] = {props} }
                //   B) Programmatic flat: { _type="type", id="...", ... }
                // Try wrapped key first (case A).
                string? child_type = null;
                bool found_wrapped = false;
                Lua.lua_pushnil(lua_bridge.get_L());
                while (Lua.lua_next(lua_bridge.get_L(), -2) != 0) {
                    if (Lua.lua_type(lua_bridge.get_L(), -2) == Lua.TSTRING) {
                        string k = Lua.lua_tostring(lua_bridge.get_L(), -2);
                        if (k.index_of("/") >= 0) {
                            child_type = k;
                            found_wrapped = true;
                            Lua.lua_pushvalue(lua_bridge.get_L(), -1);
                            break;
                        }
                    }
                    Lua.lua_pop(lua_bridge.get_L(), 1);
                }

                if (found_wrapped) {
                    // Stack: [..., child_entry, key, val, val_copy]
                    Lua.lua_remove(lua_bridge.get_L(), -3); // remove val
                    Lua.lua_remove(lua_bridge.get_L(), -2); // remove key
                    // Stack: [..., child_entry, val_copy]
                } else {
                    // Lua 5.4: lua_next returning 0 pops key, pushes nothing.
                    // Stack is [..., child_entry].
                    child_type = get_lua_field_string("_type");
                    if (child_type != null) {
                        Lua.lua_pushvalue(lua_bridge.get_L(), -1);
                        // Stack: [..., child_entry, child_entry_copy]
                    }
                }

                if (child_type != null) {
                    Gtk.Widget? child = create_widget_from_lua(child_type, -1);
                    Lua.lua_pop(lua_bridge.get_L(), 1); // pop props copy

                    if (child != null) {
                        parent_box.append(child);
                    }
                }
                Lua.lua_pop(lua_bridge.get_L(), 1); // pop child_entry
            }
        }

        private string? get_lua_field_string(string key) {
            if (!lua_bridge.get_field(-1, key)) {
                lua_bridge.pop(); // pop the nil
                return null;
            }
            string? val = lua_bridge.get_string(-1);
            lua_bridge.pop();
            return val;
        }

        private double get_lua_field_double(string key) {
            if (!lua_bridge.get_field(-1, key)) {
                lua_bridge.pop(); // pop the nil
                return 0.0;
            }
            double? val = lua_bridge.get_number(-1);
            lua_bridge.pop();
            return val ?? 0.0;
        }

        private bool get_lua_field_bool(string key) {
            if (!lua_bridge.get_field(-1, key)) {
                lua_bridge.pop(); // pop the nil
                return false;
            }
            bool? val = lua_bridge.get_boolean(-1);
            lua_bridge.pop();
            return val ?? false;
        }
    }
}

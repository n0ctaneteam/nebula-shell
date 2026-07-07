namespace NebulaShell {
    public class WidgetBuilder : Object {
        private LuaBridge lua_bridge;
        private HashTable<string, uint> timers;
        private HashTable<string, Gtk.Window> backdrops;

        public WidgetBuilder(LuaBridge bridge) {
            lua_bridge = bridge;
            timers = new HashTable<string, uint>(str_hash, str_equal);
            backdrops = new HashTable<string, Gtk.Window>(str_hash, str_equal);
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

            if (!lua_bridge.get_field(-1, "create")) {
                Logger.error(@"Widget '$(widget_type)' has no create() function");
                lua_bridge.pop(2);
                return null;
            }

            lua_bridge.push_value(props_index);

            lua_bridge.get_global("_widget_event_handlers");

            Lua.lua_pushvalue(lua_bridge.get_L(), -4);
            Lua.lua_insert(lua_bridge.get_L(), -5);

            if (!lua_bridge.call(2, 1)) {
                Logger.error(@"Widget create() failed for: $(widget_type)");
                lua_bridge.pop(3);
                return null;
            }

            if (!lua_bridge.is_table(-1)) {
                Logger.error("Widget create() must return a table");
                lua_bridge.pop(3);
                return null;
            }

            Lua.lua_pushvalue(lua_bridge.get_L(), -2);
            Lua.lua_setfield(lua_bridge.get_L(), -2, "_module");

            lua_bridge.remove(-3);
            lua_bridge.remove(-2);

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
                if (widget is Gtk.Box && "right-section" in classes) {
                    ((Gtk.Box) widget).set_halign(Gtk.Align.END);
                }
            }

            // --- Container properties ---
            bool exclusive = get_lua_field_bool("exclusive");
            string[]? margin_edges = parse_margin_padding("margin");
            string[]? padding_edges = parse_margin_padding("padding");

            string[] anchors = parse_anchors();
            GtkLayerShell.Layer layer = parse_layer();
            string? size_mode = parse_size_mode();
            bool widget_visible = read_visible_field();

            if (widget is Gtk.Window) {
                // Always init layer-shell for window widgets (even with empty anchors, e.g. "center")
                if (!LayerShell.init_window((Gtk.Window) widget, anchors, exclusive, layer)) {
                    Logger.warning(@"Widget '$(id)': LayerShell not available, falling back to normal window");
                }

                // Apply margin (must happen AFTER init_window for layer-shell margins to work)
                if (margin_edges != null) {
                    GtkLayerShell.set_margin((Gtk.Window) widget, GtkLayerShell.Edge.TOP, int.parse(margin_edges[0]));
                    GtkLayerShell.set_margin((Gtk.Window) widget, GtkLayerShell.Edge.BOTTOM, int.parse(margin_edges[1]));
                    GtkLayerShell.set_margin((Gtk.Window) widget, GtkLayerShell.Edge.LEFT, int.parse(margin_edges[2]));
                    GtkLayerShell.set_margin((Gtk.Window) widget, GtkLayerShell.Edge.RIGHT, int.parse(margin_edges[3]));
                }

                // Apply size
                if (size_mode == "fill") {
                    // Fill: anchor to all 4 edges — already handled by anchors if [top,bottom,left,right]
                } else {
                    int? w = null, h = null;
                    parse_explicit_size(out w, out h);
                    if (w != null && h != null) {
                        ((Gtk.Window) widget).set_default_size(w, h);
                    } else if (h != null) {
                        ((Gtk.Window) widget).set_default_size(800, h);
                    }
                }

                // Popup overlay backdrop
                bool has_overlay = get_lua_field_bool("_has_overlay");
                if (has_overlay) {
                    create_popup_backdrop(id, (Gtk.Window) widget);
                }

                // Apply padding (for windows — use margin equivalent)
                if (padding_edges != null) {
                    GtkLayerShell.set_margin((Gtk.Window) widget, GtkLayerShell.Edge.TOP,
                        int.parse(padding_edges[0]));
                    GtkLayerShell.set_margin((Gtk.Window) widget, GtkLayerShell.Edge.BOTTOM,
                        int.parse(padding_edges[1]));
                    GtkLayerShell.set_margin((Gtk.Window) widget, GtkLayerShell.Edge.LEFT,
                        int.parse(padding_edges[2]));
                    GtkLayerShell.set_margin((Gtk.Window) widget, GtkLayerShell.Edge.RIGHT,
                        int.parse(padding_edges[3]));
                }
            } else {
                // Apply margin and padding to non-window widgets
                if (margin_edges != null) {
                    widget.set_margin_top(int.parse(margin_edges[0]));
                    widget.set_margin_bottom(int.parse(margin_edges[1]));
                    widget.set_margin_start(int.parse(margin_edges[2]));
                    widget.set_margin_end(int.parse(margin_edges[3]));
                }
                if (padding_edges != null) {
                    widget.set_margin_top(int.parse(padding_edges[0]) + (margin_edges != null ? int.parse(margin_edges[0]) : 0));
                    widget.set_margin_bottom(int.parse(padding_edges[1]) + (margin_edges != null ? int.parse(margin_edges[1]) : 0));
                    widget.set_margin_start(int.parse(padding_edges[2]) + (margin_edges != null ? int.parse(margin_edges[2]) : 0));
                    widget.set_margin_end(int.parse(padding_edges[3]) + (margin_edges != null ? int.parse(margin_edges[3]) : 0));
                }
            }
            // --- end container properties ---

            // Apply initial visibility from config
            widget.set_visible(widget_visible);

            if (timer_enabled && timer_interval > 0) {
                setup_timer(id, timer_interval);
            }

            string? on_click_func_name = get_lua_field_string("on_click");
            if (on_click_func_name != null && widget is Gtk.Button) {
                var btn = (Gtk.Button) widget;
                setup_click_handler(btn, id, on_click_func_name);
            } else if (widget is Gtk.Button) {
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
                                lua_bridge.pop();
                            } else {
                                lua_bridge.pop();
                            }
                            lua_bridge.pop();
                        } else {
                            lua_bridge.pop();
                        }
                    });
                }
                lua_bridge.pop();
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
                lua_bridge.pop();
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

        // --- Container property helpers ---

        private string[] parse_anchors() {
            // Try Lua table first: anchor = { "top", "bottom" }
            lua_bridge.get_field(-1, "anchor");
            if (lua_bridge.is_table(-1)) {
                var list = new List<string>();
                ulong raw_len = Lua.lua_rawlen(lua_bridge.get_L(), -1);
                for (int i = 1; i <= (int) raw_len; i++) {
                    Lua.lua_rawgeti(lua_bridge.get_L(), -1, i);
                    string? v = lua_bridge.get_string(-1);
                    if (v != null) list.append(v);
                    lua_bridge.pop();
                }
                lua_bridge.pop();
                string[] res = {};
                foreach (var a in list) {
                    if (a.down() == "center") {
                        // Center alone — return empty array (no anchors)
                        return {};
                    }
                    res += a;
                }
                return res;
            }
            // Try string: "top", "center", or YAML inline list "[top]" / "[top, bottom]"
            string? anchor_str = lua_bridge.get_string(-1);
            lua_bridge.pop();
            if (anchor_str != null && anchor_str.length > 0) {
                // Handle YAML inline list: [top] or [top, bottom]
                if (anchor_str.has_prefix("[") && anchor_str.has_suffix("]")) {
                    string inner = anchor_str.substring(1, anchor_str.length - 2);
                    string[] parts = inner.split(",");
                    string[] res = {};
                    foreach (var part in parts) {
                        string trimmed = part.strip();
                        if (trimmed.length > 0) {
                            if (trimmed.down() == "center") return {};
                            res += trimmed;
                        }
                    }
                    return res;
                }
                if (anchor_str.down() == "center") return {};
                return { anchor_str };
            }
            return {};
        }

        private GtkLayerShell.Layer parse_layer() {
            string? layer_str = get_lua_field_string("_layer");
            if (layer_str == null) return GtkLayerShell.Layer.TOP;
            switch (layer_str.down()) {
                case "background": return GtkLayerShell.Layer.BACKGROUND;
                case "bottom":     return GtkLayerShell.Layer.BOTTOM;
                case "overlay":    return GtkLayerShell.Layer.OVERLAY;
                default:           return GtkLayerShell.Layer.TOP;
            }
        }

        private string? parse_size_mode() {
            lua_bridge.get_field(-1, "size");
            string? s = lua_bridge.get_string(-1);
            if (s != null) {
                lua_bridge.pop();
                return s;
            }
            if (lua_bridge.is_table(-1)) {
                // Explicit {w: 400, h: 300}
                lua_bridge.pop();
                return "explicit";
            }
            lua_bridge.pop();
            return "auto";
        }

        private void parse_explicit_size(out int? w, out int? h) {
            w = null; h = null;
            lua_bridge.get_field(-1, "size");
            if (lua_bridge.is_table(-1)) {
                lua_bridge.get_field(-1, "w");
                w = (int?) lua_bridge.get_number(-1) ?? null;
                lua_bridge.pop();
                lua_bridge.get_field(-1, "h");
                h = (int?) lua_bridge.get_number(-1) ?? null;
                lua_bridge.pop();
            }
            lua_bridge.pop();
        }

        private string[]? parse_margin_padding(string key) {
            lua_bridge.get_field(-1, key);
            if (!lua_bridge.is_table(-1)) {
                lua_bridge.pop();
                return null;
            }

            // Defaults
            int top = 0, bottom = 0, left = 0, right = 0;

            // Iterate the table (insertion order — last wins)
            Lua.lua_pushnil(lua_bridge.get_L());
            while (Lua.lua_next(lua_bridge.get_L(), -2) != 0) {
                if (Lua.lua_type(lua_bridge.get_L(), -2) == Lua.TSTRING) {
                    string k = Lua.lua_tostring(lua_bridge.get_L(), -2);
                    int v = (int) Lua.lua_tonumber(lua_bridge.get_L(), -1);
                    switch (k) {
                        case "top":        top = v; break;
                        case "bottom":     bottom = v; break;
                        case "left":       left = v; break;
                        case "right":      right = v; break;
                        case "horizontal": left = v; right = v; break;
                        case "vertical":   top = v; bottom = v; break;
                        case "all":        top = v; bottom = v; left = v; right = v; break;
                    }
                }
                Lua.lua_pop(lua_bridge.get_L(), 1);
            }

            lua_bridge.pop(); // pop margin/padding table
            return { top.to_string(), bottom.to_string(), left.to_string(), right.to_string() };
        }

        private Gtk.Window? create_popup_backdrop(string popup_id, Gtk.Window popup_window) {
            string backdrop_id = @"$(popup_id)_backdrop";
            var backdrop = new Gtk.Window();
            backdrop.set_child(new Gtk.Label("")); // empty content
            backdrop.add_css_class("popup-overlay");

            // Anchor to all 4 edges = full screen
            var anchors = new string[] { "top", "bottom", "left", "right" };
            if (!LayerShell.init_window(backdrop, anchors, false, GtkLayerShell.Layer.TOP)) {
                Logger.warning("Cannot create popup backdrop — LayerShell unavailable");
                return null;
            }

            // Get intensity from config
            lua_bridge.get_field(-1, "overlay");
            if (lua_bridge.is_table(-1)) {
                lua_bridge.get_field(-1, "intensity");
                double intensity = lua_bridge.get_number(-1) ?? 4.0;
                lua_bridge.pop();
                lua_bridge.pop();
                double opacity = 0.1 * intensity;
                string css_id = @"overlay-$(popup_id)";
                backdrop.add_css_class(css_id);
                apply_css(backdrop, @"opacity: $(opacity); background: rgba(0,0,0,$((int)(opacity * 255)));", css_id);
            } else {
                lua_bridge.pop();
            }

            // Sync visibility with popup
            backdrop.set_visible(popup_window.get_visible());
            popup_window.notify["visible"].connect(() => {
                backdrop.set_visible(popup_window.get_visible());
            });

            // Close backdrop when popup closes
            popup_window.close_request.connect(() => {
                backdrop.set_visible(false);
                backdrop.destroy();
                return false;
            });

            Registry.register(backdrop_id, backdrop);
            backdrops.insert(popup_id, backdrop);
            return backdrop;
        }

        public void destroy_backdrop(string popup_id) {
            var bd = backdrops.lookup(popup_id);
            if (bd != null) {
                bd.set_visible(false);
                bd.destroy();
                backdrops.remove(popup_id);
            }
        }

        private void apply_css(Gtk.Widget widget, string css_text, string class_name) {
            try {
                var provider = new Gtk.CssProvider();
                widget.add_css_class(class_name);
                string rule = ".%s { %s }".printf(class_name, css_text);
                provider.load_from_data(rule.data);
                var display = widget.get_display();
                if (display != null) {
                    Gtk.StyleContext.add_provider_for_display(display, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                }
            } catch (Error e) {
                Logger.warning(@"Failed to apply CSS: $(e.message)");
            }
        }

        // --- Click handler ---

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
                    Lua.lua_remove(lua_bridge.get_L(), -3);
                    Lua.lua_remove(lua_bridge.get_L(), -2);
                } else {
                    child_type = get_lua_field_string("_type");
                    if (child_type != null) {
                        Lua.lua_pushvalue(lua_bridge.get_L(), -1);
                    }
                }

                if (child_type != null) {
                    Gtk.Widget? child = create_widget_from_lua(child_type, -1);
                    Lua.lua_pop(lua_bridge.get_L(), 1);

                    if (child != null) {
                        parent_box.append(child);
                    }
                }
                Lua.lua_pop(lua_bridge.get_L(), 1);
            }
        }

        private string? get_lua_field_string(string key) {
            if (!lua_bridge.get_field(-1, key)) {
                lua_bridge.pop();
                return null;
            }
            string? val = lua_bridge.get_string(-1);
            lua_bridge.pop();
            return val;
        }

        private double get_lua_field_double(string key) {
            if (!lua_bridge.get_field(-1, key)) {
                lua_bridge.pop();
                return 0.0;
            }
            double? val = lua_bridge.get_number(-1);
            lua_bridge.pop();
            return val ?? 0.0;
        }

        private bool get_lua_field_bool(string key) {
            if (!lua_bridge.get_field(-1, key)) {
                lua_bridge.pop();
                return false;
            }
            bool? val = lua_bridge.get_boolean(-1);
            lua_bridge.pop();
            return val ?? false;
        }

        private bool read_visible_field() {
            // Default to true if not specified or not a boolean
            lua_bridge.get_field(-1, "visible");
            bool? val = lua_bridge.get_boolean(-1);
            lua_bridge.pop();
            return val ?? true;
        }
    }
}

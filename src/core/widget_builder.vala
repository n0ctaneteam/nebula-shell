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
                    // Skip dialogs — built on-demand via show_dialog()
                    if (key.has_suffix("/dialog")) {
                        Logger.info(@"Deferred dialog: $(key)");
                        lua_bridge.pop();
                        continue;
                    }
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

            // Store config in _nebula_widget_configs for lifecycle management
            lua_bridge.get_global("register_widget");
            lua_bridge.push_string(id);
            lua_bridge.push_value(-3);
            lua_bridge.call(2, 0);

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
                var win = (Gtk.Window) widget;
                bool is_dialog = win.get_data<bool>("_is_dialog");
                bool no_layer = !is_dialog && win.get_data<Gtk.Window>("no-layer") != null;

                if (is_dialog) {
                    // Dialog handles its own container properties in its case block
                } else if (no_layer) {
                    // Regular window — apply margins as widget margins, skip layer-shell
                    if (margin_edges != null) {
                        win.set_margin_top(int.parse(margin_edges[0]));
                        win.set_margin_bottom(int.parse(margin_edges[1]));
                        win.set_margin_start(int.parse(margin_edges[2]));
                        win.set_margin_end(int.parse(margin_edges[3]));
                    }
                    if (padding_edges != null) {
                        win.set_margin_top(int.parse(padding_edges[0]) + (margin_edges != null ? int.parse(margin_edges[0]) : 0));
                        win.set_margin_bottom(int.parse(padding_edges[1]) + (margin_edges != null ? int.parse(margin_edges[1]) : 0));
                        win.set_margin_start(int.parse(padding_edges[2]) + (margin_edges != null ? int.parse(margin_edges[2]) : 0));
                        win.set_margin_end(int.parse(padding_edges[3]) + (margin_edges != null ? int.parse(margin_edges[3]) : 0));
                    }
                } else {
                    if (!LayerShell.init_window(win, anchors, exclusive, layer)) {
                        Logger.warning(@"Widget '$(id)': LayerShell not available, falling back to normal window");
                    }

                    // Apply margin (must happen AFTER init_window for layer-shell margins to work)
                    if (margin_edges != null) {
                        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.TOP, int.parse(margin_edges[0]));
                        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.BOTTOM, int.parse(margin_edges[1]));
                        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.LEFT, int.parse(margin_edges[2]));
                        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.RIGHT, int.parse(margin_edges[3]));
                    }

                    // Apply padding (for windows — use margin equivalent)
                    if (padding_edges != null) {
                        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.TOP, int.parse(padding_edges[0]));
                        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.BOTTOM, int.parse(padding_edges[1]));
                        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.LEFT, int.parse(padding_edges[2]));
                        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.RIGHT, int.parse(padding_edges[3]));
                    }
                }

                // Apply size — skip for dialogs (handled in case block)
                if (!is_dialog) {
                    if (size_mode == "fill") {
                    } else {
                        int? w = null, h = null;
                        parse_explicit_size(out w, out h);
                        if (w != null && h != null) {
                            win.set_default_size(w, h);
                        } else if (h != null) {
                            win.set_default_size(800, h);
                        }
                    }
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

            // Multi-type command handler — supports events[], lua[], bash[] and backward compat
            var event_cmds = parse_commands("on_click");
            if (event_cmds.length > 0 && widget is Gtk.Button) {
                string captured_id = id;
                var btn = (Gtk.Button) widget;
                btn.clicked.connect(() => {
                    execute_commands(event_cmds, captured_id);
                });
            } else if (widget is Gtk.Button) {
                // Fallback: Lua closure dispatch (_on_click from programmatic widgets)
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
                    // Check if it's a dialog with a stored dialog-box
                    var dialog_box = win.get_data<Gtk.Box>("dialog-box");
                    if (dialog_box != null) {
                        build_children(dialog_box);
                    } else {
                        var child = win.get_child();
                        if (child is Gtk.Box) {
                            build_children((Gtk.Box) child);
                        }
                    }
                } else if (widget is Gtk.Popover) {
                    var popover = (Gtk.Popover) widget;
                    var child_widget = popover.get_child();
                    if (child_widget is Gtk.Box) {
                        build_children((Gtk.Box) child_widget);
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

        public Gtk.Widget? build_widget_from_config(string widget_type, string widget_id) {
            lua_bridge.get_global("_nebula_widget_configs");
            if (!lua_bridge.is_table(-1)) {
                lua_bridge.pop();
                return null;
            }

            lua_bridge.get_field(-1, widget_id);
            if (!lua_bridge.is_table(-1)) {
                lua_bridge.pop(2);
                return null;
            }

            // Config is at -1, _nebula_widget_configs at -2
            // Verify type matches
            string? config_type = null;
            lua_bridge.get_field(-1, "_type");
            config_type = lua_bridge.get_string(-1);
            lua_bridge.pop();

            if (config_type != widget_type) {
                lua_bridge.pop(2);
                Logger.warning(@"build_widget_from_config: type mismatch for '$(widget_id)'");
                return null;
            }

            Gtk.Widget? widget = create_gtk_widget(widget_id, config_type);
            if (widget == null) {
                Logger.error(@"build_widget_from_config: failed to create GTK widget for '$(widget_id)'");
                lua_bridge.pop(2);
                return null;
            }

            Registry.register(widget_id, widget);

            // Apply CSS classes
            string? style_class = get_lua_field_string("style_class");
            if (style_class != null) {
                string[] classes = style_class.split(" ");
                foreach (var cls in classes) {
                    if (cls.strip().length > 0) {
                        widget.add_css_class(cls.strip());
                    }
                }
            }

            widget.set_visible(true);

            lua_bridge.pop(2); // pop config + _nebula_widget_configs
            Logger.info(@"Runtime built widget: $(widget_type) (id: $(widget_id))");
            return widget;
        }

        public Gtk.Widget? build_dialog_from_config(string widget_type, string widget_id) {
            if (!lua_bridge.get_global("_nebula_config")) return null;

            lua_bridge.get_field(-1, widget_type);
            if (!lua_bridge.is_table(-1)) {
                lua_bridge.pop(2);
                Logger.warning(@"build_dialog_from_config: no config for '$(widget_type)'");
                return null;
            }

            Gtk.Widget? widget = create_widget_from_lua(widget_type, -1);
            if (widget == null) {
                Logger.error(@"build_dialog_from_config: failed to create widget for '$(widget_id)'");
                lua_bridge.pop(2);
                return null;
            }

            lua_bridge.pop(); // pop _nebula_config
            Logger.info(@"Runtime built dialog: $(widget_type) (id: $(widget_id))");
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

                case "dialog": {
                    var win = new Gtk.Window();
                    win.set_decorated(false);
                    string captured_id = id;

                    // Parse fields
                    string title_text = get_lua_field_string("title") ?? "";
                    string content_text = get_lua_field_string("content") ?? "";
                    bool block_input = get_lua_field_bool("blockInput");

                    // Backdrop + overlay for centered dialog-surface
                    var overlay = new Gtk.Overlay();

                    // Backdrop — captures clicks outside the dialog surface
                    var backdrop = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
                    backdrop.set_hexpand(true);
                    backdrop.set_vexpand(true);

                    if (block_input) {
                        var click_ctrl = new Gtk.GestureClick();
                        click_ctrl.set_button(0);
                        click_ctrl.pressed.connect(() => {
                            click_ctrl.set_state(Gtk.EventSequenceState.CLAIMED);
                        });
                        backdrop.add_controller(click_ctrl);
                    }

                    overlay.set_child(backdrop);

                    // Dialog surface (centered popup box)
                    var dialog_surface = new Gtk.Box(Gtk.Orientation.VERTICAL, 8);
                    dialog_surface.set_halign(Gtk.Align.CENTER);
                    dialog_surface.set_valign(Gtk.Align.CENTER);
                    dialog_surface.add_css_class("dialog-box");

                    // Title
                    var title_label = new Gtk.Label(title_text);
                    title_label.add_css_class("dialog-title");
                    title_label.set_xalign(0.0f);

                    // Content
                    var content_label = new Gtk.Label(content_text);
                    content_label.add_css_class("dialog-content");
                    content_label.set_wrap(true);
                    content_label.set_xalign(0.0f);
                    content_label.set_max_width_chars(60);

                    // Button row
                    var button_row = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 8);
                    button_row.set_halign(Gtk.Align.END);
                    button_row.add_css_class("dialog-buttons");

                    // Parse buttons
                    lua_bridge.get_field(-1, "buttons");
                    if (lua_bridge.is_table(-1)) {
                        unowned var L = lua_bridge.get_L();
                        ulong btn_count = Lua.lua_rawlen(L, -1);
                        for (int i = 1; i <= (int) btn_count; i++) {
                            Lua.lua_rawgeti(L, -1, i);
                            if (Lua.lua_type(L, -1) == Lua.TTABLE) {
                                Lua.lua_pushnil(L);
                                while (Lua.lua_next(L, -2) != 0) {
                                    string? btn_id = Lua.lua_tostring(L, -2);
                                    if (btn_id == null || Lua.lua_type(L, -1) != Lua.TTABLE) {
                                        Lua.lua_pop(L, 1);
                                        continue;
                                    }

                                    string btn_label = btn_id;
                                    Lua.lua_getfield(L, -1, "label");
                                    string? lbl = Lua.lua_tostring(L, -1);
                                    if (lbl != null) btn_label = lbl;
                                    Lua.lua_pop(L, 1);

                                    bool is_critical = (btn_id == "cancel");
                                    Lua.lua_getfield(L, -1, "isCritical");
                                    if (Lua.lua_type(L, -1) == Lua.TBOOLEAN) {
                                        is_critical = Lua.lua_toboolean(L, -1) != 0;
                                    }
                                    Lua.lua_pop(L, 1);

                                    bool has_explicit_onclick = false;
                                    Lua.lua_getfield(L, -1, "on_click");
                                    has_explicit_onclick = Lua.lua_type(L, -1) != Lua.TNIL;
                                    Lua.lua_pop(L, 1);

                                    var btn = new Gtk.Button.with_label(btn_label);
                                    btn.add_css_class("dialog-button");
                                    btn.add_css_class(btn_id);
                                    if (is_critical) {
                                        btn.add_css_class("critical");
                                    }

                                    string captured_btn_id = captured_id;
                                    if (btn_id == "cancel" && !has_explicit_onclick) {
                                        btn.clicked.connect(() => {
                                            Registry.remove(captured_btn_id);
                                            Lua.lua_getglobal(L, "_nebula_widget_configs");
                                            if (Lua.lua_type(L, -1) == Lua.TTABLE) {
                                                Lua.lua_pushnil(L);
                                                Lua.lua_setfield(L, -2, captured_btn_id);
                                            }
                                            Lua.lua_pop(L, 1);
                                        });
                                    } else {
                                        var cmds = parse_commands("on_click");
                                        if (cmds.length > 0) {
                                            btn.clicked.connect(() => {
                                                execute_commands(cmds, captured_btn_id);
                                            });
                                        }
                                    }

                                    button_row.append(btn);
                                    Lua.lua_pop(L, 1); // pop value
                                }
                            }
                            Lua.lua_pop(L, 1); // pop entry table
                        }
                    }
                    lua_bridge.pop(); // pop buttons table

                    // Size and padding use inner wrapper; margin applies to dialog-surface
                    string[]? margin_edges = parse_margin_padding("margin");
                    string[]? padding_edges = parse_margin_padding("padding");

                    var content_wrap = new Gtk.Box(Gtk.Orientation.VERTICAL, 8);
                    content_wrap.append(title_label);
                    content_wrap.append(content_label);
                    content_wrap.append(button_row);

                    if (padding_edges != null) {
                        content_wrap.set_margin_top(int.parse(padding_edges[0]));
                        content_wrap.set_margin_bottom(int.parse(padding_edges[1]));
                        content_wrap.set_margin_start(int.parse(padding_edges[2]));
                        content_wrap.set_margin_end(int.parse(padding_edges[3]));
                    }

                    dialog_surface.append(content_wrap);

                    if (margin_edges != null) {
                        dialog_surface.set_margin_top(int.parse(margin_edges[0]));
                        dialog_surface.set_margin_bottom(int.parse(margin_edges[1]));
                        dialog_surface.set_margin_start(int.parse(margin_edges[2]));
                        dialog_surface.set_margin_end(int.parse(margin_edges[3]));
                    }

                    overlay.add_overlay(dialog_surface);
                    win.set_child(overlay);

                    // Mark as dialog so generic container properties skip
                    win.set_data("_is_dialog", true);

                    // Apply size to dialog-surface (not window)
                    lua_bridge.get_field(-1, "size");
                    if (lua_bridge.is_table(-1)) {
                        Lua.lua_getfield(lua_bridge.get_L(), -1, "w");
                        int? sw = (int?) lua_bridge.get_number(-1) ?? null;
                        Lua.lua_pop(lua_bridge.get_L(), 1);
                        Lua.lua_getfield(lua_bridge.get_L(), -1, "h");
                        int? sh = (int?) lua_bridge.get_number(-1) ?? null;
                        Lua.lua_pop(lua_bridge.get_L(), 1);
                        if (sw != null && sh != null) {
                            dialog_surface.set_size_request(sw, sh);
                        }
                    }
                    lua_bridge.pop(); // pop size

                    // Layer-shell: full-screen (defaults to overlay)
                    string[] full_anchors = { "top", "bottom", "left", "right" };
                    GtkLayerShell.Layer dialog_layer = parse_layer();
                    LayerShell.init_window(win, full_anchors, false, dialog_layer);
                    GtkLayerShell.set_margin(win, GtkLayerShell.Edge.TOP, 0);
                    GtkLayerShell.set_margin(win, GtkLayerShell.Edge.BOTTOM, 0);
                    GtkLayerShell.set_margin(win, GtkLayerShell.Edge.LEFT, 0);
                    GtkLayerShell.set_margin(win, GtkLayerShell.Edge.RIGHT, 0);

                    return win;
                }

                case "popover": {
                    var popover = new Gtk.Popover();
                    popover.set_has_arrow(get_lua_field_bool("showPointer"));

                    bool hovered = false;
                    var motion_ctrl = new Gtk.EventControllerMotion();
                    double autohide = get_lua_field_double("autohide");
                    uint? pending_timer = null;

                    GLib.SourceFunc schedule_autohide = () => {
                        if (pending_timer != null) {
                            GLib.Source.remove(pending_timer);
                            pending_timer = null;
                        }
                        if (autohide > 0 && popover.get_visible()) {
                            uint timeout_ms = (uint)(autohide * 1000);
                            pending_timer = GLib.Timeout.add(timeout_ms, () => {
                                pending_timer = null;
                                if (!hovered) {
                                    popover.popdown();
                                }
                                return false;
                            });
                        }
                        return false;
                    };

                    motion_ctrl.enter.connect(() => {
                        hovered = true;
                        if (pending_timer != null) {
                            GLib.Source.remove(pending_timer);
                            pending_timer = null;
                        }
                    });
                    motion_ctrl.leave.connect(() => {
                        hovered = false;
                        schedule_autohide();
                    });
                    ((Gtk.Widget) popover).add_controller(motion_ctrl);

                    if (autohide > 0) {
                        popover.notify["visible"].connect(() => {
                            if (popover.get_visible()) {
                                schedule_autohide();
                            }
                        });

                        popover.destroy.connect(() => {
                            if (pending_timer != null) {
                                GLib.Source.remove(pending_timer);
                                pending_timer = null;
                            }
                        });
                    }

                    int spacing = (int) get_lua_field_double("_spacing");
                    string? orient_str = get_lua_field_string("_orientation");
                    Gtk.Orientation orient = (orient_str == "vertical")
                        ? Gtk.Orientation.VERTICAL
                        : Gtk.Orientation.HORIZONTAL;
                    var popover_box = new Gtk.Box(orient, spacing > 0 ? spacing : 0);
                    popover.set_child(popover_box);
                    return popover;
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

        private struct Command {
            string type;
            string body;
        }

        private Command[] parse_commands(string field_name) {
            Command[] result = {};
            unowned var L = lua_bridge.get_L();

            if (!lua_bridge.get_field(-1, field_name)) {
                lua_bridge.pop();
                return result;
            }

            int type = Lua.lua_type(L, -1);
            if (type == Lua.TSTRING) {
                string? str_val = lua_bridge.get_string(-1);
                lua_bridge.pop();
                if (str_val != null && str_val.length > 0) {
                    var cmds = parse_entry(str_val);
                    foreach (var c in cmds) {
                        result += c;
                    }
                }
                return result;
            }

            if (type == Lua.TTABLE) {
                ulong raw_len = Lua.lua_rawlen(L, -1);
                for (int i = 1; i <= (int) raw_len; i++) {
                    Lua.lua_rawgeti(L, -1, i);
                    string? entry = lua_bridge.get_string(-1);
                    if (entry != null && entry.length > 0) {
                        var cmds = parse_entry(entry);
                        foreach (var c in cmds) {
                            result += c;
                        }
                    }
                    lua_bridge.pop();
                }
            }

            lua_bridge.pop();
            return result;
        }

        private static GLib.Regex? command_regex = null;

        private Command[] parse_entry(string entry) {
            try {
                if (command_regex == null) {
                    command_regex = new GLib.Regex("""^(\w+)\[(.*)\]$""", GLib.RegexCompileFlags.DOTALL);
                }
                GLib.MatchInfo match_info;
                if (command_regex.match(entry, 0, out match_info) && match_info.matches()) {
                    string cmd_type = match_info.fetch(1);
                    string body = match_info.fetch(2);
                    string[] parts = split_body(body);
                    Command[] cmds = {};
                    foreach (var part in parts) {
                        string trimmed = part.strip();
                        if (trimmed.length > 0) {
                            cmds += Command() { type = cmd_type, body = trimmed };
                        }
                    }
                    return cmds;
                }
            } catch (GLib.RegexError e) {
                // fallthrough
            }
            // Plain string — backward compat, treat as events[func_name]
            return { Command() { type = "events", body = entry.strip() } };
        }

        private string[] split_body(string body) {
            string[] parts = {};
            int depth = 0;
            bool in_single_quote = false;
            bool in_double_quote = false;
            var current = new StringBuilder.sized(body.length);

            unowned string remaining = body;
            while (remaining != "") {
                unichar c = remaining.get_char_validated();
                if (c == (unichar)(-1) || c == (unichar)(-2)) break;

                if (c == '\'' && !in_double_quote) {
                    in_single_quote = !in_single_quote;
                    current.append_unichar(c);
                } else if (c == '"' && !in_single_quote) {
                    in_double_quote = !in_double_quote;
                    current.append_unichar(c);
                } else if (!in_single_quote && !in_double_quote) {
                    if (c == '(' || c == '[' || c == '{') {
                        depth++;
                        current.append_unichar(c);
                    } else if (c == ')' || c == ']' || c == '}') {
                        if (depth > 0) depth--;
                        current.append_unichar(c);
                    } else if (c == ',' && depth == 0) {
                        string part = current.str.strip();
                        if (part.length > 0) {
                            parts += part;
                        }
                        current = new StringBuilder.sized(body.length);
                    } else {
                        current.append_unichar(c);
                    }
                } else {
                    current.append_unichar(c);
                }
                remaining = remaining.next_char();
            }

            string last_part = current.str.strip();
            if (last_part.length > 0) {
                parts += last_part;
            }

            return parts;
        }

        private void execute_commands(Command[] commands, string source_id) {
            foreach (var cmd in commands) {
                switch (cmd.type) {
                    case "events":
                        lua_bridge.get_global(cmd.body);
                        if (lua_bridge.is_function(-1)) {
                            lua_bridge.push_string(source_id);
                            lua_bridge.call(1, 0);
                        } else {
                            lua_bridge.pop();
                            Logger.warning(@"Command 'events[$(cmd.body)]': function not found");
                        }
                        break;

                    case "lua":
                        if (!lua_bridge.do_string(cmd.body)) {
                            Logger.warning(@"Command 'lua[$(cmd.body)]' failed");
                        }
                        break;

                    case "bash":
                        try {
                            string escaped = cmd.body.replace("'", "'\\''");
                            string full_cmd = @"bash -c '$(escaped)'";
                            GLib.Process.spawn_command_line_async(full_cmd);
                        } catch (GLib.Error e) {
                            Logger.warning(@"Command 'bash[$(cmd.body)]' failed: $(e.message)");
                        }
                        break;

                    default:
                        Logger.warning(@"Unknown command type: '$(cmd.type)'");
                        break;
                }
            }
        }

        // --- Timer ---

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

namespace NebulaShell {
    public class Registry : Object {
        private static HashTable<string, Gtk.Widget> widget_map;
        private static Gtk.Widget[] widget_list;

        public static void init() {
            widget_map = new HashTable<string, Gtk.Widget>(str_hash, str_equal);
            widget_list = {};
            Logger.debug("Registry initialized");
        }

        public static void register(string id, Gtk.Widget widget) {
            if (id == null || id.length == 0) return;
            widget_map.insert(id, widget);
            bool found = false;
            foreach (var w in widget_list) {
                if (w == widget) { found = true; break; }
            }
            if (!found) {
                widget_list += widget;
            }
            Logger.debug(@"Registered widget: $(id)");
        }

        public static Gtk.Widget? lookup(string id) {
            return widget_map.lookup(id);
        }

        public static Gtk.Widget[] get_all() {
            return widget_list;
        }

        public static Gtk.Widget[] get_by_class(string css_class) {
            Gtk.Widget[] result = {};
            foreach (var widget in widget_list) {
                var classes = widget.get_css_classes();
                if (css_class in classes) {
                    result += widget;
                }
            }
            return result;
        }

        public static Gtk.Widget[] get_by_type(string type_name) {
            Gtk.Widget[] result = {};
            Type target = Type.from_name(type_name);
            if (target == Type.INVALID) return result;
            foreach (var widget in widget_list) {
                if (widget.get_type().is_a(target)) {
                    result += widget;
                }
            }
            return result;
        }

        public static string[] get_all_ids() {
            string[] ids = {};
            widget_map.foreach((key, val) => { ids += key; });
            return ids;
        }

        public static void show_all() {
            foreach (var widget in widget_list) {
                if (widget is Gtk.Window) {
                    var win = (Gtk.Window) widget;
                    win.present();
                } else {
                    widget.set_visible(true);
                }
            }
            Logger.info("All widgets shown");
        }

        public static void cleanup() {
            widget_map.remove_all();
            widget_list = {};
            Logger.info("Registry cleaned up");
        }
    }
}

namespace NebulaShell {
    public class CssManager : Object {
        private Gtk.CssProvider provider;

        public CssManager() {
            provider = new Gtk.CssProvider();
        }

        public void load() {
            string? sysroot = Environment.get_variable("NEBULA_SYSROOT");
            if (sysroot != null) {
                string dev_css = Path.build_filename(sysroot, "etc", "nebula-shell", "styles", "style.css");
                var dev_file = File.new_for_path(dev_css);
                if (dev_file.query_exists()) {
                    load_from_file(dev_file);
                    Logger.info(@"Loaded dev styles: $(dev_css)");
                    return;
                }
            }

            string system_css = FileUtils.find_system_dir("styles/style.css");
            string user_css = FileUtils.find_user_dir("styles/style.css");

            var user_file = File.new_for_path(user_css);
            var system_file = File.new_for_path(system_css);

            if (user_file.query_exists()) {
                load_from_file(user_file);
                Logger.info(@"Loaded user styles: $(user_css)");
            } else if (system_file.query_exists()) {
                load_from_file(system_file);
                Logger.info(@"Loaded system styles: $(system_css)");
            } else {
                Logger.warning("No style.css found");
            }
        }

        private void load_from_file(File file) {
            try {
                provider.load_from_file(file);
                apply();
            } catch (Error e) {
                Logger.warning(@"Failed to load CSS: $(e.message)");
            }
        }

        private void apply() {
            var display = Gdk.Display.get_default();
            if (display != null) {
                Gtk.StyleContext.add_provider_for_display(
                    display,
                    provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_USER
                );
            }
        }
    }
}

namespace NebulaShell {

/**
 * Internal record for tracking a loaded plugin.
 */
internal class PluginEntry : GLib.Object {

    public Plugin plugin { get; construct; }
    public string path { get; construct; }
    public PluginState state { get; set; default = PluginState.LOADING; }

    public PluginEntry (Plugin plugin, string path) {
        GLib.Object (
            plugin: plugin,
            path: path
        );
    }

}

/**
 * Manages plugin lifecycle, discovery, loading, and dependency resolution.
 *
 * PluginManager is a singleton manager that owns the full plugin lifecycle.
 * It discovers plugins in configurable directories, loads their shared
 * libraries, resolves dependencies, and manages enable/disable/unload.
 *
 * Plugins extend the framework through public APIs only.
 * Plugins cannot modify internal runtime state directly.
 * Plugin API is versioned.
 *
 * PluginManager follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * It is registered with the Kernel as "plugin".
 *
 * Lifecycle:
 * load → enable → disable → unload
 *
 * Example:
 *   var plugin_manager = PluginManager.get_default();
 *   plugin_manager.add_plugin_path("/usr/lib/nebula-shell/plugins");
 *   runtime.register_manager("plugin", plugin_manager);
 *   runtime.initialize();
 *
 *   plugin_manager.enable_plugin("my-plugin");
 *   plugin_manager.disable_plugin("my-plugin");
 */
public class PluginManager : GLib.Object, Manager {

    private static PluginManager? _instance = null;

    private Gee.HashMap<string, PluginEntry> _plugins;
    private Gee.HashMap<string, void*> _modules;
    private Gee.ArrayList<string> _search_paths;
    private Gee.ArrayList<string> _load_order;
    private bool _initialized;

    /**
     * Signal emitted when a plugin is loaded.
     *
     * @param plugin_id the ID of the loaded plugin
     */
    public signal void plugin_loaded (string plugin_id);

    /**
     * Signal emitted when a plugin is enabled.
     *
     * @param plugin_id the ID of the enabled plugin
     */
    public signal void plugin_enabled (string plugin_id);

    /**
     * Signal emitted when a plugin is disabled.
     *
     * @param plugin_id the ID of the disabled plugin
     */
    public signal void plugin_disabled (string plugin_id);

    /**
     * Signal emitted when a plugin is unloaded.
     *
     * @param plugin_id the ID of the unloaded plugin
     */
    public signal void plugin_unloaded (string plugin_id);

    /**
     * Signal emitted when a plugin error occurs.
     *
     * @param plugin_id the plugin that caused the error
     * @param message the error description
     */
    public signal void plugin_error (string plugin_id, string message);

    /**
     * Get the default PluginManager instance.
     *
     * @return the singleton plugin manager
     */
    public static PluginManager get_default () {
        if (_instance == null)
            _instance = new PluginManager ();

        return _instance;
    }

    private PluginManager () {
        _plugins = new Gee.HashMap<string, PluginEntry> ();
        _modules = new Gee.HashMap<string, void*> ();
        _search_paths = new Gee.ArrayList<string> ();
        _load_order = new Gee.ArrayList<string> ();
        _initialized = false;

        initialize_search_paths ();
    }

    /**
     * Initialize default plugin search paths.
     *
     * Search order:
     * 1. ~/.local/lib/nebula-shell/plugins
     * 2. $LIBDIR/nebula-shell/plugins
     */
    private void initialize_search_paths () {
        string home = GLib.Environment.get_variable ("HOME") ?? "";

        if (home.length > 0) {
            _search_paths.add (
                GLib.Path.build_filename (home, ".local", "lib", "nebula-shell", "plugins")
            );
        }

        string libdir = GLib.Environment.get_variable ("LIBDIR") ?? "/usr/lib";
        _search_paths.add (
            GLib.Path.build_filename (libdir, "nebula-shell", "plugins")
        );
    }

    /**
     * Add a custom plugin search directory.
     *
     * Custom paths are prepended to the search list,
     * giving them higher priority.
     *
     * @param path absolute path to a plugin directory
     */
    public void add_plugin_path (string path) {
        _search_paths.insert (0, path);
    }

    /**
     * Get all configured plugin search paths.
     *
     * @return a read-only view of search paths
     */
    public Gee.List<string> get_plugin_paths () {
        return _search_paths.read_only_view;
    }

    /**
     * Get the number of loaded plugins.
     */
    public int plugin_count {
        get { return _plugins.size; }
    }

    /**
     * Check if a plugin with the given ID is loaded.
     *
     * @param plugin_id the plugin ID to check
     * @return true if the plugin is loaded
     */
    public bool has_plugin (string plugin_id) {
        return _plugins.has_key (plugin_id);
    }

    /**
     * Get the state of a loaded plugin.
     *
     * @param plugin_id the plugin ID
     * @return the plugin state, or null if not found
     */
    public PluginState? get_plugin_state (string plugin_id) {
        var entry = _plugins.get (plugin_id);
        if (entry != null)
            return entry.state;
        return null;
    }

    /**
     * Get a loaded plugin by ID.
     *
     * @param plugin_id the plugin ID
     * @return the plugin instance, or null if not found
     */
    public Plugin? get_plugin (string plugin_id) {
        var entry = _plugins.get (plugin_id);
        if (entry != null)
            return entry.plugin;
        return null;
    }

    /**
     * Get all loaded plugin IDs.
     *
     * @return a read-only view of plugin IDs
     */
    public Gee.Set<string> get_plugin_ids () {
        return _plugins.keys.read_only_view;
    }

    /**
     * Initialize the plugin manager.
     *
     * Discovers and loads all plugins in the search directories.
     * This is called by the Kernel during framework startup.
     */
    public void initialize () {
        if (_initialized)
            return;

        Logger.info ("PluginManager: initializing");

        discover_and_load_all ();

        _initialized = true;
        Logger.info ("PluginManager: initialized with %d plugins".printf (_plugins.size));
    }

    /**
     * Shut down the plugin manager.
     *
     * Disables and unloads all plugins in reverse load order.
     * This is called by the Kernel during framework shutdown.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("PluginManager: shutting down");

        for (int i = _load_order.size - 1; i >= 0; i--) {
            string id = _load_order[i];
            var entry = _plugins.get (id);
            if (entry != null) {
                safe_disable (entry);
                safe_unload (entry);
            }
        }

        _plugins.clear ();
        _modules.clear ();
        _load_order.clear ();
        _initialized = false;

        Logger.info ("PluginManager: shut down");
    }

    /**
     * Reload all plugins.
     *
     * Disables and unloads all plugins, then re-discovers
     * and loads them from the search directories.
     * This is called by the Kernel during framework reload.
     */
    public void reload () {
        if (!_initialized)
            return;

        Logger.info ("PluginManager: reloading plugins");

        // Disable and unload in reverse order
        for (int i = _load_order.size - 1; i >= 0; i--) {
            string id = _load_order[i];
            var entry = _plugins.get (id);
            if (entry != null) {
                safe_disable (entry);
                safe_unload (entry);
            }
        }

        _plugins.clear ();
        _modules.clear ();
        _load_order.clear ();

        // Re-discover and load
        discover_and_load_all ();

        Logger.info ("PluginManager: reloaded with %d plugins".printf (_plugins.size));
    }

    /**
     * Discover and load all plugins from search directories.
     */
    private void discover_and_load_all () {
        Gee.ArrayList<string> discovered = new Gee.ArrayList<string> ();

        foreach (string path in _search_paths) {
            discover_plugins_in (path, discovered);
        }

        // Resolve dependency order
        var sorted = resolve_dependency_order (discovered);

        // Load plugins in dependency order
        foreach (string plugin_path in sorted) {
            load_plugin_from_path (plugin_path);
        }

        // Enable all loaded plugins in order
        foreach (string id in _load_order) {
            var entry = _plugins.get (id);
            if (entry != null && entry.state == PluginState.LOADED) {
                safe_enable (entry);
            }
        }
    }

    /**
     * Discover plugin shared libraries in a directory.
     *
     * @param dir_path the directory to scan
     * @param discovered list to add discovered paths to
     */
    private void discover_plugins_in (string dir_path, Gee.ArrayList<string> discovered) {
        try {
            var dir = GLib.Dir.open (dir_path);
            if (dir == null)
                return;

            string? name;
            while ((name = dir.read_name ()) != null) {
                if (!name.has_suffix (".so"))
                    continue;

                string full_path = GLib.Path.build_filename (dir_path, name);
                discovered.add (full_path);
            }
        } catch (GLib.Error e) {
            Logger.debug ("PluginManager: cannot scan directory " + dir_path + ": " + e.message);
        }
    }

    /**
     * Load a plugin from a shared library path.
     *
     * @param path absolute path to the .so file
     * @return true if the plugin was loaded successfully
     */
    private bool load_plugin_from_path (string path) {
        Logger.debug ("PluginManager: loading plugin from " + path);

        GLib.Module? module = GLib.Module.open (path, GLib.ModuleFlags.LAZY);
        if (module == null) {
            emit_error (path, "Failed to load module: " + GLib.Module.error ());
            return false;
        }

        void* symbol;
        if (!module.symbol ("plugin_init", out symbol)) {
            emit_error (path, "Missing plugin_init symbol");
            module.close ();
            return false;
        }

        unowned PluginInitFunc factory = (PluginInitFunc) symbol;
        Type plugin_type = factory ();

        if (plugin_type == Type.INVALID) {
            emit_error (path, "plugin_init returned invalid type");
            module.close ();
            return false;
        }

        GLib.Object obj = GLib.Object.new (plugin_type);
        if (!(obj is Plugin)) {
            emit_error (path, "Plugin does not implement Plugin interface");
            module.close ();
            return false;
        }

        Plugin plugin = (Plugin) obj;

        // Check API version
        if (plugin.info.api_version != PLUGIN_API_VERSION) {
            emit_error (plugin.info.id, "API version mismatch: requires %d, got %d".printf (
                plugin.info.api_version, PLUGIN_API_VERSION
            ));
            module.close ();
            return false;
        }

        // Check if already loaded
        if (_plugins.has_key (plugin.info.id)) {
            emit_error (plugin.info.id, "Plugin already loaded");
            module.close ();
            return false;
        }

        var entry = new PluginEntry (plugin, path);
        entry.state = PluginState.LOADED;

        _plugins.set (plugin.info.id, entry);
        _modules.set (plugin.info.id, (void*) module);
        _load_order.add (plugin.info.id);

        // Load the plugin
        try {
            plugin.load ();
        } catch (PluginError e) {
            emit_error (plugin.info.id, "Failed to load: " + e.message);
            module.close ();
            _plugins.unset (plugin.info.id);
            _modules.unset (plugin.info.id);
            _load_order.remove (plugin.info.id);
            return false;
        }
        plugin_loaded (plugin.info.id);

        Logger.info ("PluginManager: loaded plugin " + plugin.info.id + " v" + plugin.info.version);
        return true;
    }

    /**
     * Enable a loaded plugin.
     *
     * The plugin's enable() method is called and its state
     * transitions from LOADED or DISABLED to ENABLED.
     *
     * @param plugin_id the plugin ID to enable
     * @throws PluginError.NOT_FOUND if the plugin is not found
     * @throws PluginError.ENABLE_FAILED if enable fails
     */
    public void enable_plugin (string plugin_id) throws PluginError {
        var entry = _plugins.get (plugin_id);
        if (entry == null) {
            throw new PluginError.NOT_FOUND ("Plugin not found: " + plugin_id);
        }

        if (entry.state == PluginState.ENABLED) {
            return;
        }

        safe_enable (entry);
    }

    /**
     * Disable an enabled plugin.
     *
     * The plugin's disable() method is called and its state
     * transitions to DISABLED.
     *
     * @param plugin_id the plugin ID to disable
     * @throws PluginError.NOT_FOUND if the plugin is not found
     * @throws PluginError.DISABLE_FAILED if disable fails
     */
    public void disable_plugin (string plugin_id) throws PluginError {
        var entry = _plugins.get (plugin_id);
        if (entry == null) {
            throw new PluginError.NOT_FOUND ("Plugin not found: " + plugin_id);
        }

        if (entry.state != PluginState.ENABLED) {
            return;
        }

        safe_disable (entry);
    }

    /**
     * Unload a plugin completely.
     *
     * The plugin is disabled if active, then unloaded.
     * Dependencies are checked to ensure safe unloading.
     *
     * @param plugin_id the plugin ID to unload
     * @throws PluginError.NOT_FOUND if the plugin is not found
     * @throws PluginError.DEPENDENCY_CONFLICT if another plugin depends on it
     * @throws PluginError.UNLOAD_FAILED if unload fails
     */
    public void unload_plugin (string plugin_id) throws PluginError {
        var entry = _plugins.get (plugin_id);
        if (entry == null) {
            throw new PluginError.NOT_FOUND ("Plugin not found: " + plugin_id);
        }

        // Check if other plugins depend on this one
        foreach (string other_id in _load_order) {
            if (other_id == plugin_id)
                continue;

            var other_entry = _plugins.get (other_id);
            if (other_entry != null && other_entry.state != PluginState.UNLOADED) {
                if (other_entry.plugin.info.dependencies.contains (plugin_id)) {
                    throw new PluginError.DEPENDENCY_CONFLICT (
                        "Cannot unload " + plugin_id + ": " + other_id + " depends on it"
                    );
                }
            }
        }

        safe_disable (entry);
        safe_unload (entry);

        _plugins.unset (plugin_id);
        _modules.unset (plugin_id);
        _load_order.remove (plugin_id);
    }

    /**
     * Reload a specific plugin.
     *
     * The plugin is disabled and unloaded, then re-loaded
     * and re-enabled.
     *
     * @param plugin_id the plugin ID to reload
     * @throws PluginError.NOT_FOUND if the plugin is not found
     */
    public void reload_plugin (string plugin_id) throws PluginError {
        var entry = _plugins.get (plugin_id);
        if (entry == null) {
            throw new PluginError.NOT_FOUND ("Plugin not found: " + plugin_id);
        }

        string path = entry.path;
        PluginState old_state = entry.state;

        safe_disable (entry);
        safe_unload (entry);

        _plugins.unset (plugin_id);
        _modules.unset (plugin_id);
        _load_order.remove (plugin_id);

        load_plugin_from_path (path);

        if (old_state == PluginState.ENABLED) {
            var new_entry = _plugins.get (plugin_id);
            if (new_entry != null && new_entry.state == PluginState.LOADED) {
                safe_enable (new_entry);
            }
        }
    }

    /**
     * Safely enable a plugin entry.
     *
     * @param entry the plugin entry to enable
     */
    private void safe_enable (PluginEntry entry) {
        try {
            entry.state = PluginState.ENABLED;
            entry.plugin.enable ();
            plugin_enabled (entry.plugin.info.id);
            Logger.info ("PluginManager: enabled plugin " + entry.plugin.info.id);
        } catch (PluginError e) {
            entry.state = PluginState.LOADED;
            emit_error (entry.plugin.info.id, "Failed to enable: " + e.message);
        }
    }

    /**
     * Safely disable a plugin entry.
     *
     * @param entry the plugin entry to disable
     */
    private void safe_disable (PluginEntry entry) {
        try {
            entry.state = PluginState.DISABLED;
            entry.plugin.disable ();
            plugin_disabled (entry.plugin.info.id);
            Logger.info ("PluginManager: disabled plugin " + entry.plugin.info.id);
        } catch (PluginError e) {
            emit_error (entry.plugin.info.id, "Failed to disable: " + e.message);
        }
    }

    /**
     * Safely unload a plugin entry.
     *
     * @param entry the plugin entry to unload
     */
    private void safe_unload (PluginEntry entry) {
        try {
            entry.state = PluginState.UNLOADED;
            entry.plugin.unload ();
            unowned void* module_handle = _modules.get (entry.plugin.info.id);
            if (module_handle != null) {
                unowned GLib.Module module = (GLib.Module) module_handle;
                module.close ();
                _modules.unset (entry.plugin.info.id);
            }
            plugin_unloaded (entry.plugin.info.id);
            Logger.info ("PluginManager: unloaded plugin " + entry.plugin.info.id);
        } catch (PluginError e) {
            emit_error (entry.plugin.info.id, "Failed to unload: " + e.message);
        }
    }

    /**
     * Emit a plugin error.
     *
     * @param plugin_id the plugin that caused the error
     * @param message the error description
     */
    private void emit_error (string plugin_id, string message) {
        Logger.error ("PluginManager: [" + plugin_id + "] " + message);
        plugin_error (plugin_id, message);
    }

    /**
     * Resolve the load order for plugins based on their dependencies.
     *
     * Uses topological sort to ensure dependencies are loaded
     * before the plugins that depend on them.
     *
     * @param paths list of plugin shared library paths
     * @return sorted list of paths in dependency order
     */
    private Gee.ArrayList<string> resolve_dependency_order (Gee.ArrayList<string> paths) {
        // Map from plugin ID to path
        var id_to_path = new Gee.HashMap<string, string> ();
        var path_to_id = new Gee.HashMap<string, string> ();

        // First pass: extract plugin IDs from each .so
        foreach (string path in paths) {
            string? id = extract_plugin_id (path);
            if (id != null) {
                id_to_path.set (id, path);
                path_to_id.set (path, id);
            }
        }

        // Build dependency graph (ID -> list of dependency IDs)
        var deps = new Gee.HashMap<string, Gee.ArrayList<string>> ();
        foreach (string id in id_to_path.keys) {
            deps.set (id, new Gee.ArrayList<string> ());
        }

        // Second pass: extract dependencies
        foreach (string path in paths) {
            string? id = path_to_id.get (path);
            if (id == null) continue;

            var dep_ids = extract_plugin_dependencies (path);
            if (dep_ids != null) {
                foreach (string dep_id in dep_ids) {
                    if (deps.has_key (dep_id)) {
                        deps.get (id).add (dep_id);
                    }
                }
            }
        }

        // Topological sort (Kahn's algorithm)
        var in_degree = new Gee.HashMap<string, int> ();
        var adj = new Gee.HashMap<string, Gee.ArrayList<string>> ();

        foreach (string id in id_to_path.keys) {
            in_degree.set (id, 0);
            adj.set (id, new Gee.ArrayList<string> ());
        }

        foreach (string id in deps.keys) {
            foreach (string dep in deps.get (id)) {
                if (adj.has_key (dep)) {
                    adj.get (dep).add (id);
                    in_degree.set (id, in_degree.get (id) + 1);
                }
            }
        }

        var queue = new Gee.ArrayQueue<string> ();
        foreach (string id in in_degree.keys) {
            if (in_degree.get (id) == 0)
                queue.add (id);
        }

        var sorted = new Gee.ArrayList<string> ();
        while (!queue.is_empty) {
            string current = queue.poll_head ();
            sorted.add (id_to_path.get (current));

            foreach (string neighbor in adj.get (current)) {
                int new_degree = in_degree.get (neighbor) - 1;
                in_degree.set (neighbor, new_degree);
                if (new_degree == 0)
                    queue.add (neighbor);
            }
        }

        // Check for cycles
        if (sorted.size != paths.size) {
            Logger.warning ("PluginManager: dependency cycle detected, falling back to file order");
            return paths;
        }

        return sorted;
    }

    /**
     * Extract a plugin ID from a shared library by calling its
     * info function without fully instantiating the plugin.
     *
     * @param path the path to the shared library
     * @return the plugin ID, or null if extraction fails
     */
    private string? extract_plugin_id (string path) {
        GLib.Module? module = GLib.Module.open (path, GLib.ModuleFlags.LAZY);
        if (module == null)
            return null;

        void* symbol;
        if (!module.symbol ("plugin_init", out symbol)) {
            module.close ();
            return null;
        }

        unowned PluginInitFunc factory = (PluginInitFunc) symbol;
        Type plugin_type = factory ();

        if (plugin_type == Type.INVALID) {
            module.close ();
            return null;
        }

        GLib.Object obj = GLib.Object.new (plugin_type);
        if (obj is Plugin) {
            string id = ((Plugin) obj).info.id;
            module.close ();
            return id;
        }

        module.close ();
        return null;
    }

    /**
     * Extract plugin dependencies from a shared library.
     *
     * @param path the path to the shared library
     * @return list of dependency IDs, or null if extraction fails
     */
    private Gee.ArrayList<string>? extract_plugin_dependencies (string path) {
        GLib.Module? module = GLib.Module.open (path, GLib.ModuleFlags.LAZY);
        if (module == null)
            return null;

        void* symbol;
        if (!module.symbol ("plugin_init", out symbol)) {
            module.close ();
            return null;
        }

        unowned PluginInitFunc factory = (PluginInitFunc) symbol;
        Type plugin_type = factory ();

        if (plugin_type == Type.INVALID) {
            module.close ();
            return null;
        }

        GLib.Object obj = GLib.Object.new (plugin_type);
        if (obj is Plugin) {
            var deps = ((Plugin) obj).info.dependencies;
            var result = new Gee.ArrayList<string> ();
            result.add_all (deps);
            module.close ();
            return result;
        }

        module.close ();
        return null;
    }

}

/**
 * Function signature for plugin initialization.
 *
 * Every plugin shared library must export a function with
 * this signature that returns the GType of the plugin class.
 */
public delegate Type PluginInitFunc ();

}

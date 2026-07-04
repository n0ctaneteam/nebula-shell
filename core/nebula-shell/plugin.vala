namespace NebulaShell {

/**
 * Plugin API version.
 *
 * Plugins must declare compatibility with this version.
 * Major version bumps indicate breaking API changes.
 */
public const int PLUGIN_API_VERSION = 1;

/**
 * Error domain for plugin operations.
 */
public errordomain PluginError {
    NOT_FOUND,
    ALREADY_LOADED,
    DEPENDENCY_CONFLICT,
    LOAD_FAILED,
    ENABLE_FAILED,
    DISABLE_FAILED,
    UNLOAD_FAILED,
    API_MISMATCH
}

/**
 * Plugin lifecycle states.
 *
 * Plugins transition through these states during their lifetime:
 * LOADING → LOADED → ENABLED → DISABLED → UNLOADED
 */
public enum PluginState {
    /**
     * Plugin is being loaded from disk.
     */
    LOADING,

    /**
     * Plugin module is loaded but not yet active.
     */
    LOADED,

    /**
     * Plugin is active and running.
     */
    ENABLED,

    /**
     * Plugin is paused but still loaded.
     */
    DISABLED,

    /**
     * Plugin has been fully unloaded.
     */
    UNLOADED;

    public string to_string () {
        switch (this) {
            case PluginState.LOADING:  return "LOADING";
            case PluginState.LOADED:   return "LOADED";
            case PluginState.ENABLED:  return "ENABLED";
            case PluginState.DISABLED: return "DISABLED";
            case PluginState.UNLOADED: return "UNLOADED";
            default:                   return "UNKNOWN";
        }
    }
}

/**
 * Metadata describing a plugin.
 *
 * PluginInfo is immutable and holds the static metadata
 * declared by a plugin in its manifest.
 */
public class PluginInfo : GLib.Object {

    /**
     * Unique identifier for the plugin.
     */
    public string id { get; construct; }

    /**
     * Human-readable name.
     */
    public string name { get; construct; }

    /**
     * Semantic version string.
     */
    public string version { get; construct; }

    /**
     * Plugin author or organization.
     */
    public string author { get; construct; }

    /**
     * Short description of the plugin.
     */
    public string description { get; construct; }

    /**
     * Required NebulaShell plugin API version.
     */
    public int api_version { get; construct; }

    /**
     * List of plugin IDs this plugin depends on.
     */
    public Gee.List<string> dependencies { get; set; }

    /**
     * Create plugin info from a set of metadata values.
     *
     * @param id unique plugin identifier
     * @param name human-readable name
     * @param version semantic version string
     * @param author plugin author
     * @param description short description
     * @param api_version required API version
     * @param dependencies list of required plugin IDs
     */
    public PluginInfo (
        string id,
        string name,
        string version,
        string author,
        string description,
        int api_version,
        owned Gee.List<string>? dependencies
    ) {
        GLib.Object (
            id: id,
            name: name,
            version: version,
            author: author,
            description: description,
            api_version: api_version
        );

        if (dependencies != null)
            this.dependencies = dependencies;
        else
            this.dependencies = new Gee.ArrayList<string> ();
    }

}

/**
 * Interface for all NebulaShell plugins.
 *
 * Plugins extend the framework through public APIs only.
 * Plugins cannot modify internal runtime state directly.
 *
 * Every plugin must implement this interface and export
 * a factory function that PluginManager can call to create
 * the plugin instance.
 *
 * Lifecycle:
 * load() → enable() → disable() → unload()
 *
 * Example:
 *   public class MyPlugin : GLib.Object, Plugin {
 *       public PluginInfo info { get { return _info; } }
 *       private PluginInfo _info;
 *
 *       public void load () throws GLib.Error { }
 *       public void enable () throws GLib.Error { }
 *       public void disable () throws GLib.Error { }
 *       public void unload () throws GLib.Error { }
 *   }
 *
 *   [ModuleInit]
 *   public Type plugin_init () {
 *       return typeof (MyPlugin);
 *   }
 */
public interface Plugin : GLib.Object {

    /**
     * Metadata describing this plugin.
     */
    public abstract PluginInfo info { get; }

    /**
     * Initialize the plugin.
     *
     * Called when the plugin module is loaded.
     * Use this for heavy initialization that requires
     * the plugin to be fully constructed.
     *
     * @throws PluginError.LOAD_FAILED if initialization fails
     */
    public abstract void load () throws PluginError;

    /**
     * Activate the plugin.
     *
     * Called after load() or when re-enabling a disabled plugin.
     * The plugin should register services, hooks, and widgets here.
     *
     * @throws PluginError.ENABLE_FAILED if activation fails
     */
    public abstract void enable () throws PluginError;

    /**
     * Deactivate the plugin.
     *
     * Called before unload() or when temporarily disabling.
     * The plugin should release external resources here.
     *
     * @throws PluginError.DISABLE_FAILED if deactivation fails
     */
    public abstract void disable () throws PluginError;

    /**
     * Clean up and release all resources.
     *
     * Called when the plugin is being removed from memory.
     * After this, the plugin instance should not be used.
     *
     * @throws PluginError.UNLOAD_FAILED if cleanup fails
     */
    public abstract void unload () throws PluginError;

}

}

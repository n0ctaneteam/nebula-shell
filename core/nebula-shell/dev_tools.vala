namespace NebulaShell {

/**
 * Manages all development tools for NebulaShell.
 *
 * DevTools is a singleton manager that coordinates hot reload,
 * live CSS, config reload, widget inspection, performance overlay,
 * and frame timing diagnostics.
 *
 * DevTools is only active during development mode.
 * It should never affect production performance.
 *
 * DevTools follows the Manager lifecycle:
 * initialize() → run → shutdown()
 *
 * Example:
 *   var dev_tools = DevTools.get_default();
 *   dev_tools.set_enabled(true);
 *   dev_tools.initialize();
 */
public class DevTools : GLib.Object, Manager {

    private static DevTools? _instance = null;

    private bool _enabled;
    private bool _initialized;
    private HotReload? _hot_reload;
    private LiveCss? _live_css;
    private ConfigReload? _config_reload;
    private WidgetInspector? _widget_inspector;
    private PerformanceOverlay? _performance_overlay;
    private FrameTiming? _frame_timing;

    /**
     * Signal emitted when dev tools are enabled or disabled.
     */
    public signal void enabled_changed (bool enabled);

    /**
     * Get the default DevTools instance.
     *
     * @return the singleton dev tools manager
     */
    public static DevTools get_default () {
        if (_instance == null)
            _instance = new DevTools ();

        return _instance;
    }

    private DevTools () {
        _enabled = false;
        _initialized = false;
        _hot_reload = null;
        _live_css = null;
        _config_reload = null;
        _widget_inspector = null;
        _performance_overlay = null;
        _frame_timing = null;
    }

    /**
     * Whether dev tools are enabled.
     */
    public bool enabled {
        get { return _enabled; }
    }

    /**
     * Enable or disable dev tools.
     *
     * Must be called before initialize().
     *
     * @param value true to enable dev tools
     */
    public void set_enabled (bool value) {
        _enabled = value;
        enabled_changed (value);
    }

    /**
     * Get the hot reload manager.
     *
     * @return the hot reload manager, or null if not initialized
     */
    public HotReload? get_hot_reload () {
        return _hot_reload;
    }

    /**
     * Get the live CSS manager.
     *
     * @return the live CSS manager, or null if not initialized
     */
    public LiveCss? get_live_css () {
        return _live_css;
    }

    /**
     * Get the config reload manager.
     *
     * @return the config reload manager, or null if not initialized
     */
    public ConfigReload? get_config_reload () {
        return _config_reload;
    }

    /**
     * Get the widget inspector.
     *
     * @return the widget inspector, or null if not initialized
     */
    public WidgetInspector? get_widget_inspector () {
        return _widget_inspector;
    }

    /**
     * Get the performance overlay.
     *
     * @return the performance overlay, or null if not initialized
     */
    public PerformanceOverlay? get_performance_overlay () {
        return _performance_overlay;
    }

    /**
     * Get the frame timing diagnostics.
     *
     * @return the frame timing diagnostics, or null if not initialized
     */
    public FrameTiming? get_frame_timing () {
        return _frame_timing;
    }

    /**
     * Initialize all dev tools.
     *
     * Only initializes if dev tools are enabled.
     */
    public void initialize () {
        if (_initialized)
            return;

        if (!_enabled) {
            Logger.debug ("DevTools: disabled, skipping initialization");
            return;
        }

        Logger.info ("DevTools: initializing");

        _hot_reload = new HotReload ();
        _live_css = new LiveCss ();
        _config_reload = new ConfigReload ();
        _widget_inspector = new WidgetInspector ();
        _performance_overlay = new PerformanceOverlay ();
        _frame_timing = new FrameTiming ();

        _hot_reload.initialize ();
        _live_css.initialize ();
        _config_reload.initialize ();
        _widget_inspector.initialize ();
        _performance_overlay.initialize ();
        _frame_timing.initialize ();

        _initialized = true;
        Logger.info ("DevTools: initialized");
    }

    /**
     * Shut down all dev tools.
     */
    public void shutdown () {
        if (!_initialized)
            return;

        Logger.info ("DevTools: shutting down");

        _frame_timing.shutdown ();
        _performance_overlay.shutdown ();
        _widget_inspector.shutdown ();
        _config_reload.shutdown ();
        _live_css.shutdown ();
        _hot_reload.shutdown ();

        _frame_timing = null;
        _performance_overlay = null;
        _widget_inspector = null;
        _config_reload = null;
        _live_css = null;
        _hot_reload = null;

        _initialized = false;
        Logger.info ("DevTools: shut down");
    }

    /**
     * Reload all dev tools state.
     */
    public void reload () {
        if (!_initialized)
            return;

        Logger.info ("DevTools: reloading");

        if (_hot_reload != null) _hot_reload.reload ();
        if (_live_css != null) _live_css.reload ();
        if (_config_reload != null) _config_reload.reload ();
        if (_widget_inspector != null) _widget_inspector.reload ();
        if (_performance_overlay != null) _performance_overlay.reload ();
        if (_frame_timing != null) _frame_timing.reload ();
    }

}

}

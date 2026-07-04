namespace NebulaShell {

/**
 * Interface for compositor backends.
 *
 * Compositor provides an abstraction over different Wayland compositors.
 * Each compositor backend implements this interface to expose compositor
 * state to the framework in a unified way.
 *
 * Compositor-specific code belongs inside compositor adapters.
 * Never scatter compositor checks across the codebase.
 *
 * The framework uses the Compositor interface to access:
 * - Workspace state and events
 * - Window state and events
 * - Monitor state and events
 * - Focused workspace tracking
 *
 * wlroots compositors should work without compositor-specific code
 * whenever possible. Hyprland receives first-class support through
 * the HyprlandBackend implementation.
 *
 * Example:
 *   var compositor = Compositor.get_default ();
 *   compositor.initialize ();
 *   var workspaces = compositor.get_workspaces ();
 */
public interface Compositor : GLib.Object {

    /**
     * Emitted when a workspace is created.
     *
     * @param workspace the new workspace
     */
    public signal void workspace_created (Workspace workspace);

    /**
     * Emitted when a workspace is destroyed.
     *
     * @param workspace the workspace being destroyed
     */
    public signal void workspace_destroyed (Workspace workspace);

    /**
     * Emitted when a workspace is focused.
     *
     * @param workspace the newly focused workspace
     */
    public signal void workspace_focused (Workspace workspace);

    /**
     * Emitted when workspace state changes.
     *
     * @param workspace the workspace that changed
     */
    public signal void workspace_changed (Workspace workspace);

    /**
     * Emitted when a window is created.
     *
     * @param window the new window
     */
    public signal void window_created (WindowInfo window);

    /**
     * Emitted when a window is destroyed.
     *
     * @param window the window being destroyed
     */
    public signal void window_destroyed (WindowInfo window);

    /**
     * Emitted when a window is focused.
     *
     * @param window the newly focused window
     */
    public signal void window_focused (WindowInfo window);

    /**
     * Emitted when window state changes.
     *
     * @param window the window that changed
     */
    public signal void window_changed (WindowInfo window);

    /**
     * Emitted when a monitor is added.
     *
     * @param monitor the new monitor
     */
    public signal void monitor_added (MonitorInfo monitor);

    /**
     * Emitted when a monitor is removed.
     *
     * @param monitor the monitor being removed
     */
    public signal void monitor_removed (MonitorInfo monitor);

    /**
     * Emitted when monitor state changes.
     *
     * @param monitor the monitor that changed
     */
    public signal void monitor_changed (MonitorInfo monitor);

    /**
     * Emitted when the focused workspace changes.
     *
     * @param workspace the newly focused workspace
     */
    public signal void focused_workspace_changed (Workspace workspace);

    /**
     * Emitted when the focused window changes.
     *
     * @param window the newly focused window, or null if none
     */
    public signal void focused_window_changed (WindowInfo? window);

    /**
     * Initialize the compositor backend.
     *
     * Heavy initialization belongs here, not in constructors.
     * Subclasses must override this to set up their resources.
     */
    public abstract void initialize ();

    /**
     * Shut down the compositor backend.
     *
     * Must mirror initialize() in reverse order.
     * Subclasses must override this to release their resources.
     */
    public abstract void shutdown ();

    /**
     * Reload the compositor backend state.
     *
     * Subclasses should override this to refresh their state.
     */
    public abstract void reload ();

    /**
     * Get the name of this compositor backend.
     *
     * @return the compositor name (e.g., "hyprland", "sway")
     */
    public abstract string get_compositor_name ();

    /**
     * Get all workspaces.
     *
     * @return list of all workspaces
     */
    public abstract Workspace[] get_workspaces ();

    /**
     * Get the currently focused workspace.
     *
     * @return the focused workspace, or null if none
     */
    public abstract Workspace? get_focused_workspace ();

    /**
     * Get all windows.
     *
     * @return list of all windows
     */
    public abstract WindowInfo[] get_windows ();

    /**
     * Get the currently focused window.
     *
     * @return the focused window, or null if none
     */
    public abstract WindowInfo? get_focused_window ();

    /**
     * Get all monitors.
     *
     * @return list of all monitors
     */
    public abstract MonitorInfo[] get_monitors ();

    /**
     * Get the currently focused monitor.
     *
     * @return the focused monitor, or null if none
     */
    public abstract MonitorInfo? get_focused_monitor ();

    /**
     * Dispatch a request to the compositor.
     *
     * This is used for sending IPC commands to the compositor.
     *
     * @param method the request method
     * @param payload the request payload, or null
     * @return the response payload, or null
     */
    public abstract string? dispatch (string method, string? payload);

    /**
     * Whether the compositor backend is currently connected.
     */
    public abstract bool is_connected { get; }

}

}

namespace NebulaShell {

/**
 * Application lifecycle manager.
 *
 * Application owns the GLib main loop and coordinates
 * framework initialization and shutdown.
 *
 * Windows are independent of the application and can be
 * created and shown before or after run().
 *
 * Example:
 *   var app = new Application ();
 *   var panel = new Panel ();
 *   panel.show ();
 *   app.run ();
 */
public class Application : NebulaShell.Object {

    private GLib.MainLoop main_loop;
    private Runtime runtime;
    private bool _is_running;

    construct {
        // Initialize GTK4 before anything else.
        // This opens the Wayland display and attaches GDK event sources
        // to the default GLib main context. Without this, Wayland events
        // arrive after main_loop.run() but GTK4's internal state (display,
        // event dispatch chain) is not set up, causing a segfault.
        Gtk.init ();
        main_loop = new GLib.MainLoop ();
        runtime = Runtime.get_default ();
        _is_running = false;
    }

    /**
     * Start the application event loop.
     *
     * Initializes the runtime and enters the main loop.
     * This method blocks until quit() is called.
     */
    public void run () {
        if (_is_running) return;

        _is_running = true;
        runtime.initialize ();
        main_loop.run ();
    }

    /**
     * Quit the application immediately.
     *
     * Shuts down the runtime and exits the main loop.
     */
    public void quit () {
        if (!_is_running) return;

        runtime.shutdown ();
        main_loop.quit ();
        _is_running = false;
    }

    /**
     * Reload the application configuration and plugins.
     */
    public void reload () {
        runtime.reload ();
    }

    /**
     * Whether the application is currently running.
     */
    public bool get_is_running () {
        return _is_running;
    }

}

}

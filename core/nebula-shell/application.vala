namespace NebulaShell {

public class Application : NebulaShell.Object {

    private Gtk.Application _gtk_app;
    private Runtime runtime;

    public Application () {

        base.with_name ("application");

        _gtk_app = new Gtk.Application (

            "io.github.n0ctaneteam.NebulaShell",

            ApplicationFlags.DEFAULT_FLAGS
        );

        _gtk_app.activate.connect (on_activate);
        _gtk_app.shutdown.connect (on_shutdown);

        runtime = Runtime.get_default();
    }

    private void on_activate () {

        runtime.initialize();
    }

    private void on_shutdown () {

        runtime.shutdown();
    }

    public void run () {

        _gtk_app.run (null);
    }

    public void quit () {

        _gtk_app.quit ();
    }

    public void reload () {

        runtime.reload();
    }

    public bool get_is_running () {

        return _gtk_app.get_is_registered ();
    }

}

}

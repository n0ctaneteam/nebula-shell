namespace NebulaShell {

public class Application : Gtk.Application {

    private Runtime runtime;

    public Application () {

        GLib.Object(

            application_id: "io.github.n0ctaneteam.NebulaShell",

            flags: ApplicationFlags.DEFAULT_FLAGS
        );

        runtime = Runtime.get_default();
    }

    protected override void activate () {

        runtime.initialize();
    }

    public override void shutdown () {

        runtime.shutdown();

        base.shutdown();
    }

}

}

using NebulaShell;

public class TestManager : GLib.Object, Manager {
    public bool initialized = false;
    public bool shutdown_called = false;
    public bool reload_called = false;

    public void initialize () {
        initialized = true;
    }

    public void shutdown () {
        shutdown_called = true;
    }

    public void reload () {
        reload_called = true;
    }
}

public void test_kernel_creation () {
    var kernel = new Kernel ();
    assert (kernel.name == "kernel");
}

public void test_kernel_register_manager () {
    var kernel = new Kernel ();
    var manager = new TestManager ();

    kernel.register ("test", manager);
    assert (kernel.has_manager ("test"));
    assert (kernel.get_manager ("test") == manager);
}

public void test_kernel_boot () {
    var kernel = new Kernel ();
    var manager = new TestManager ();

    kernel.register ("test", manager);
    kernel.boot ();

    assert (manager.initialized);
}

public void test_kernel_halt () {
    var kernel = new Kernel ();
    var manager = new TestManager ();

    kernel.register ("test", manager);
    kernel.boot ();
    kernel.halt ();

    assert (manager.shutdown_called);
}

public void test_kernel_reload_all () {
    var kernel = new Kernel ();
    var manager = new TestManager ();

    kernel.register ("test", manager);
    kernel.boot ();
    kernel.reload_all ();

    assert (manager.reload_called);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/kernel/creation", test_kernel_creation);
    Test.add_func ("/kernel/register_manager", test_kernel_register_manager);
    Test.add_func ("/kernel/boot", test_kernel_boot);
    Test.add_func ("/kernel/halt", test_kernel_halt);
    Test.add_func ("/kernel/reload_all", test_kernel_reload_all);

    return Test.run ();
}
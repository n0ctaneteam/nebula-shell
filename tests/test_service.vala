using NebulaShell;

public class TestService : Service {
    public int counter = 0;

    public TestService () {
        base ("test_service");
    }

    protected override void on_initialize () {
        counter = 1;
    }

    protected override void on_shutdown () {
        counter = 0;
    }

    protected override void on_reload () {
        counter = 2;
    }
}

public void test_service_creation () {
    var service = new TestService ();
    assert (service.service_name == "test_service");
    assert (!service.is_initialized);
}

public void test_service_initialize () {
    var service = new TestService ();
    bool signal_emitted = false;

    service.service_initialized.connect (() => {
        signal_emitted = true;
    });

    service.initialize ();
    assert (service.is_initialized);
    assert (service.counter == 1);
    assert (signal_emitted);
}

public void test_service_shutdown () {
    var service = new TestService ();
    service.initialize ();
    bool signal_emitted = false;

    service.service_shutdown.connect (() => {
        signal_emitted = true;
    });

    service.shutdown ();
    assert (!service.is_initialized);
    assert (service.counter == 0);
    assert (signal_emitted);
}

public void test_service_reload () {
    var service = new TestService ();
    service.initialize ();
    bool signal_emitted = false;

    service.service_reloaded.connect (() => {
        signal_emitted = true;
    });

    service.reload ();
    assert (service.counter == 2);
    assert (signal_emitted);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/service/creation", test_service_creation);
    Test.add_func ("/service/initialize", test_service_initialize);
    Test.add_func ("/service/shutdown", test_service_shutdown);
    Test.add_func ("/service/reload", test_service_reload);

    return Test.run ();
}
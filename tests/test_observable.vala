using NebulaShell;

public class TestObservable : Observable {
    public void emit_changed (string property_name) {
        notify_changed (property_name);
    }
}

public void test_observable_changed_signal () {
    var observable = new TestObservable ();
    bool signal_emitted = false;
    string emitted_property = "";

    observable.changed.connect ((name) => {
        signal_emitted = true;
        emitted_property = name;
    });

    observable.emit_changed ("test_property");
    assert (signal_emitted);
    assert (emitted_property == "test_property");
}

public void test_observable_state_changed_signal () {
    var observable = new TestObservable ();
    bool signal_emitted = false;

    observable.state_changed.connect (() => {
        signal_emitted = true;
    });

    observable.emit_changed ("test_property");
    assert (signal_emitted);
}

public void test_observable_freeze_thaw () {
    var observable = new TestObservable ();
    bool changed_emitted = false;
    bool state_emitted = false;

    observable.changed.connect ((name) => {
        changed_emitted = true;
    });

    observable.state_changed.connect (() => {
        state_emitted = true;
    });

    observable.freeze ();
    observable.emit_changed ("test_property");
    assert (!changed_emitted);
    assert (!state_emitted);

    observable.thaw ();
    assert (state_emitted);
}

public void test_observable_nested_freeze () {
    var observable = new TestObservable ();
    int state_count = 0;

    observable.state_changed.connect (() => {
        state_count++;
    });

    observable.freeze ();
    observable.freeze ();
    observable.emit_changed ("test_property");
    observable.thaw ();
    assert (state_count == 1);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/observable/changed_signal", test_observable_changed_signal);
    Test.add_func ("/observable/state_changed_signal", test_observable_state_changed_signal);
    Test.add_func ("/observable/freeze_thaw", test_observable_freeze_thaw);
    Test.add_func ("/observable/nested_freeze", test_observable_nested_freeze);

    return Test.run ();
}
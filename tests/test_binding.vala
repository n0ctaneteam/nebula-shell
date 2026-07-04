using NebulaShell;

public void test_binding_creation () {
    var source = new Property<int> ("source", 0);
    var target = new Property<int> ("target", 0);

    var binding = new NebulaShell.Binding (source, target, false);
    assert (binding.source == source);
    assert (binding.target == target);
    assert (!binding.is_two_way);
}

public void test_binding_synchronization () {
    var source = new Property<int> ("source", 0);
    var target = new Property<int> ("target", 0);
    bool sync_emitted = false;

    var binding = new NebulaShell.Binding (source, target, false);
    binding.synchronized.connect (() => {
        sync_emitted = true;
    });

    source.value = 42;
    assert (sync_emitted);
}

public void test_binding_unbind () {
    var source = new Property<int> ("source", 0);
    var target = new Property<int> ("target", 0);

    var binding = new NebulaShell.Binding (source, target, false);
    binding.unbind ();

    bool signal_emitted = false;
    binding.synchronized.connect (() => {
        signal_emitted = true;
    });

    source.value = 42;
    assert (!signal_emitted);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/binding/creation", test_binding_creation);
    Test.add_func ("/binding/synchronization", test_binding_synchronization);
    Test.add_func ("/binding/unbind", test_binding_unbind);

    return Test.run ();
}
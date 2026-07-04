using NebulaShell;

public void test_property_creation () {
    var prop = new Property<int> ("test", 42);
    assert (prop.name == "test");
    assert (prop.value == 42);
}

public void test_property_value_changed () {
    var prop = new Property<int> ("test", 0);
    bool signal_emitted = false;
    int emitted_value = 0;

    prop.value_changed.connect ((name, value) => {
        signal_emitted = true;
        emitted_value = value;
    });

    prop.value = 100;
    assert (signal_emitted);
    assert (emitted_value == 100);
}

public void test_property_no_change_on_same_value () {
    var prop = new Property<int> ("test", 42);
    bool signal_emitted = false;

    prop.value_changed.connect ((name, value) => {
        signal_emitted = true;
    });

    prop.value = 42;
    assert (!signal_emitted);
}

public void test_property_bind_to () {
    var source = new Property<int> ("source", 0);
    var target = new Property<int> ("target", 0);

    source.bind_to (target);
    source.value = 50;

    assert (target.value == 50);
}

public void test_property_bind_two_way () {
    var prop_a = new Property<int> ("a", 0);
    var prop_b = new Property<int> ("b", 0);

    prop_a.bind_two_way (prop_b);
    prop_a.value = 10;
    assert (prop_b.value == 10);

    prop_b.value = 20;
    assert (prop_a.value == 20);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/property/creation", test_property_creation);
    Test.add_func ("/property/value_changed", test_property_value_changed);
    Test.add_func ("/property/no_change_on_same_value", test_property_no_change_on_same_value);
    Test.add_func ("/property/bind_to", test_property_bind_to);
    Test.add_func ("/property/bind_two_way", test_property_bind_two_way);

    return Test.run ();
}
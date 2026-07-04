using NebulaShell;

public void test_registry_register () {
    var registry = new ObjectRegistry<string> ();
    registry.register ("test", "hello");
    assert (registry.has ("test"));
    assert (registry.get ("test") == "hello");
}

public void test_registry_get_nonexistent () {
    var registry = new ObjectRegistry<string> ();
    assert (registry.get ("nonexistent") == null);
}

public void test_registry_unregister () {
    var registry = new ObjectRegistry<string> ();
    registry.register ("test", "hello");
    registry.unregister ("test");
    assert (!registry.has ("test"));
}

public void test_registry_clear () {
    var registry = new ObjectRegistry<string> ();
    registry.register ("a", "1");
    registry.register ("b", "2");
    registry.clear ();
    assert (registry.size == 0);
}

public void test_registry_replace () {
    var registry = new ObjectRegistry<string> ();
    registry.register ("test", "first");
    registry.register ("test", "second");
    assert (registry.get ("test") == "second");
    assert (registry.size == 1);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/registry/register", test_registry_register);
    Test.add_func ("/registry/get_nonexistent", test_registry_get_nonexistent);
    Test.add_func ("/registry/unregister", test_registry_unregister);
    Test.add_func ("/registry/clear", test_registry_clear);
    Test.add_func ("/registry/replace", test_registry_replace);

    return Test.run ();
}
using NebulaShell;

public void test_config_creation () {
    var config = new Config ();
    assert (config.size == 0);
    assert (!config.has_errors);
}

public void test_config_set_get_string () {
    var config = new Config ();
    config.set ("name", "Nebula");
    assert (config.get_string ("name") == "Nebula");
}

public void test_config_set_get_int () {
    var config = new Config ();
    config.set ("count", 42);
    assert (config.get_int ("count") == 42);
}

public void test_config_set_get_bool () {
    var config = new Config ();
    config.set ("enabled", true);
    assert (config.get_bool ("enabled") == true);
}

public void test_config_set_get_double () {
    var config = new Config ();
    config.set ("ratio", 3.14);
    assert (config.get_double ("ratio") == 3.14);
}

public void test_config_has () {
    var config = new Config ();
    assert (!config.has ("key"));
    config.set ("key", "value");
    assert (config.has ("key"));
}

public void test_config_get_keys () {
    var config = new Config ();
    config.set ("a", 1);
    config.set ("b", 2);
    var keys = config.get_keys ();
    assert (keys.size == 2);
    assert (keys.contains ("a"));
    assert (keys.contains ("b"));
}

public void test_config_errors () {
    var config = new Config ();
    assert (!config.has_errors);

    config.add_error ("key", "error message");
    assert (config.has_errors);
    assert (config.get_errors ().size == 1);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/config/creation", test_config_creation);
    Test.add_func ("/config/set_get_string", test_config_set_get_string);
    Test.add_func ("/config/set_get_int", test_config_set_get_int);
    Test.add_func ("/config/set_get_bool", test_config_set_get_bool);
    Test.add_func ("/config/set_get_double", test_config_set_get_double);
    Test.add_func ("/config/has", test_config_has);
    Test.add_func ("/config/get_keys", test_config_get_keys);
    Test.add_func ("/config/errors", test_config_errors);

    return Test.run ();
}
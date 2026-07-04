using NebulaShell;

public void test_object_creation () {
    var obj = new NebulaShell.Object ();
    assert (obj.name == "");
}

public void test_object_creation_with_name () {
    var obj = new NebulaShell.Object.with_name ("test");
    assert (obj.name == "test");
}

public void test_object_name_setter () {
    var obj = new NebulaShell.Object ();
    obj.name = "my_object";
    assert (obj.name == "my_object");
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/object/creation", test_object_creation);
    Test.add_func ("/object/creation_with_name", test_object_creation_with_name);
    Test.add_func ("/object/name_setter", test_object_name_setter);

    return Test.run ();
}
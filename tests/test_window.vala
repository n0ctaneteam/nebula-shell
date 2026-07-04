using NebulaShell;

public class TestWindow : Window {
    public TestWindow () {
        base ("test_window");
    }
}

public void test_window_creation () {
    var window = new TestWindow ();
    assert (window.name == "test_window");
    assert (!window.visible);
}

public void test_window_size () {
    var window = new TestWindow ();
    window.width = 1024;
    window.height = 768;
    assert (window.width == 1024);
    assert (window.height == 768);
}

public void test_window_size_rejects_negative () {
    var window = new TestWindow ();
    window.width = -100;
    assert (window.width == 800);
}

public void test_window_set_size () {
    var window = new TestWindow ();
    window.set_size (1920, 1080);
    assert (window.width == 1920);
    assert (window.height == 1080);
}

public void test_window_anchor () {
    var window = new TestWindow ();
    window.anchor = Anchor.TOP;
    assert (window.anchor == Anchor.TOP);
}

public void test_window_layer () {
    var window = new TestWindow ();
    window.layer = Layer.TOP;
    assert (window.layer == Layer.TOP);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/window/creation", test_window_creation);
    Test.add_func ("/window/size", test_window_size);
    Test.add_func ("/window/size_rejects_negative", test_window_size_rejects_negative);
    Test.add_func ("/window/set_size", test_window_set_size);
    Test.add_func ("/window/anchor", test_window_anchor);
    Test.add_func ("/window/layer", test_window_layer);

    return Test.run ();
}
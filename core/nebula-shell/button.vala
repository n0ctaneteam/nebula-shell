namespace NebulaShell {

/**
 * Button widget with click handling.
 *
 * Button renders a clickable element that can contain a child widget.
 * It emits a signal when pressed, enabling user interaction.
 *
 * Button is a container widget that accepts a single child.
 *
 * Example:
 *   var button = new Button ();
 *   button.child = new Label ("Click me");
 *   button.clicked.connect (() => {
 *       print ("Button pressed\n");
 *   });
 */
public class Button : NebulaShell.Widget {

    private Widget? _child = null;
    private bool _enabled = true;
    private string _label_text = "";

    /**
     * Emitted when the button is pressed.
     */
    public signal void clicked ();

    /**
     * The child widget displayed inside the button.
     *
     * When set, the previous child is destroyed.
     * Default is null (no child).
     */
    public Widget? child {
        get { return _child; }
        set {
            if (_child == value) return;
            if (_child != null) {
                _child.parent = null;
                _child.destroy ();
            }
            _child = value;
            if (_child != null) {
                _child.parent = this;
            }
        }
    }

    /**
     * Whether the button is enabled and can be clicked.
     *
     * When false, the button does not emit clicked signals.
     * Default is true.
     */
    public bool enabled {
        get { return _enabled; }
        set { _enabled = value; }
    }

    /**
     * Convenience text label for the button.
     *
     * If set, this creates a Label child with the given text.
     * When read, returns the text of the current Label child,
     * or an empty string if no Label child is set.
     */
    public string label_text {
        get { return _label_text; }
        set {
            _label_text = value;
            child = new Label.with_text (value);
        }
    }

    /**
     * Create a new button.
     */
    public Button () {
        base ();
    }

    /**
     * Create a new button with a label.
     *
     * @param label_text the button text
     */
    public Button.with_label (string label_text) {
        base ();
        _label_text = label_text;
        child = new Label.with_text (label_text);
    }

    /**
     * Create a new button with a name and label.
     *
     * @param name human-readable identifier
     * @param label_text the button text
     */
    public Button.with_name_and_label (string name, string label_text) {
        base.with_name (name);
        _label_text = label_text;
        child = new Label.with_text (label_text);
    }

    /**
     * Emit the clicked signal.
     *
     * Only emits if the button is enabled.
     */
    public void press () {
        if (!_enabled) return;
        clicked ();
    }

}

}

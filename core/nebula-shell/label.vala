namespace NebulaShell {

/**
 * Label widget for displaying text.
 *
 * Label renders a single line or multi-line text string.
 * It supports text content, font styling, alignment, and wrapping.
 *
 * Label is a leaf widget and does not accept children.
 *
 * Example:
 *   var label = new Label ("Hello, World!");
 *   label.text = "Updated text";
 *   label.wrap = true;
 */
public class Label : NebulaShell.Widget {

    private string _text = "";
    private bool _wrap = false;
    private int _max_width = -1;
    private string _xalign = "start";

    /**
     * Emitted when the text content changes.
     *
     * @param new_text the new text value
     */
    public signal void text_changed (string new_text);

    /**
     * The text content displayed by this label.
     *
     * Can be empty. Default is an empty string.
     */
    public string text {
        get { return _text; }
        set {
            if (_text == value) return;
            _text = value;
            text_changed (_text);
        }
    }

    /**
     * Whether the label text wraps to multiple lines.
     *
     * When true, long text will wrap at word boundaries.
     * When false, text is displayed on a single line.
     * Default is false.
     */
    public bool wrap {
        get { return _wrap; }
        set { _wrap = value; }
    }

    /**
     * Maximum width in pixels before text wraps.
     *
     * Only effective when wrap is true.
     * A value of -1 means no limit.
     * Default is -1.
     */
    public int max_width {
        get { return _max_width; }
        set { _max_width = value; }
    }

    /**
     * Horizontal alignment of the label text.
     *
     * Valid values: "start", "center", "end".
     * Default is "start".
     */
    public string xalign {
        get { return _xalign; }
        set { _xalign = value; }
    }

    /**
     * Create a new empty label.
     */
    public Label () {
        base ();
    }

    /**
     * Create a new label with text.
     *
     * @param text the initial text content
     */
    public Label.with_text (string text) {
        base ();
        _text = text;
    }

    /**
     * Create a new label with a name and text.
     *
     * @param name human-readable identifier
     * @param text the initial text content
     */
    public Label.with_name_and_text (string name, string text) {
        base.with_name (name);
        _text = text;
    }

}

}

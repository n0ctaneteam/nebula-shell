namespace NebulaShell {

/**
 * Entry widget for text input.
 *
 * Entry renders a single-line text input field.
 * It supports text content, placeholder text, and edit mode.
 *
 * Entry is a leaf widget and does not accept children.
 *
 * Example:
 *   var entry = new Entry ();
 *   entry.placeholder = "Type here...";
 *   entry.text_changed.connect ((text) => {
 *       print ("Input: " + text + "\n");
 *   });
 */
public class Entry : NebulaShell.Widget {

    private string _text = "";
    private string _placeholder = "";
    private bool _editable = true;
    private int _max_length = -1;

    /**
     * Emitted when the text content changes.
     *
     * @param new_text the new text value
     */
    public signal void text_changed (string new_text);

    /**
     * Emitted when the user presses Enter.
     *
     * @param text the current text value
     */
    public signal void activated (string text);

    /**
     * The current text content of the entry.
     *
     * Default is an empty string.
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
     * Placeholder text shown when the entry is empty.
     *
     * Default is an empty string (no placeholder).
     */
    public string placeholder {
        get { return _placeholder; }
        set { _placeholder = value; }
    }

    /**
     * Whether the entry is editable by the user.
     *
     * When false, the user cannot modify the text.
     * Default is true.
     */
    public bool editable {
        get { return _editable; }
        set { _editable = value; }
    }

    /**
     * Maximum number of characters allowed.
     *
     * A value of -1 means no limit.
     * Default is -1.
     */
    public int max_length {
        get { return _max_length; }
        set { _max_length = value; }
    }

    /**
     * Create a new empty entry.
     */
    public Entry () {
        base ();
    }

    /**
     * Create a new entry with initial text.
     *
     * @param text the initial text content
     */
    public Entry.with_text (string text) {
        base ();
        _text = text;
    }

    /**
     * Create a new entry with text and placeholder.
     *
     * @param text the initial text content
     * @param placeholder the placeholder text
     */
    public Entry.with_text_and_placeholder (string text, string placeholder) {
        base ();
        _text = text;
        _placeholder = placeholder;
    }

}

}

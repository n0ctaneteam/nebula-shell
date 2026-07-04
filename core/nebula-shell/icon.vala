namespace NebulaShell {

/**
 * Icon widget for displaying named icons.
 *
 * Icon renders an icon by its theme name. Icons are resolved
 * from the current icon theme at display time.
 *
 * Icon is a leaf widget and does not accept children.
 *
 * Example:
 *   var icon = new Icon ();
 *   icon.icon_name = "weather-clear";
 *   icon.pixel_size = 32;
 */
public class Icon : NebulaShell.Widget {

    private string _icon_name = "";
    private int _pixel_size = -1;

    /**
     * Emitted when the icon name changes.
     *
     * @param new_name the new icon theme name
     */
    public signal void icon_name_changed (string new_name);

    /**
     * The icon theme name to display.
     *
     * Must be a valid icon name from the current theme.
     * Default is an empty string (no icon).
     */
    public string icon_name {
        get { return _icon_name; }
        set {
            if (_icon_name == value) return;
            _icon_name = value;
            icon_name_changed (_icon_name);
        }
    }

    /**
     * The pixel size for the rendered icon.
     *
     * Controls the width and height of the displayed icon.
     * A value of -1 uses the icon's default size.
     * Default is -1.
     */
    public int pixel_size {
        get { return _pixel_size; }
        set { _pixel_size = value; }
    }

    /**
     * Create a new empty icon widget.
     */
    public Icon () {
        base ();
    }

    /**
     * Create a new icon widget with an icon name.
     *
     * @param icon_name the icon theme name
     */
    public Icon.with_name (string icon_name) {
        base ();
        _icon_name = icon_name;
    }

    /**
     * Create a new icon widget with an icon name and size.
     *
     * @param icon_name the icon theme name
     * @param pixel_size the rendered size in pixels
     */
    public Icon.with_name_and_size (string icon_name, int pixel_size) {
        base ();
        _icon_name = icon_name;
        _pixel_size = pixel_size;
    }

}

}

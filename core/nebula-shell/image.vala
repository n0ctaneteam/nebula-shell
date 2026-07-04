namespace NebulaShell {

/**
 * Image widget for displaying images from file paths.
 *
 * Image loads and renders an image file from a given path.
 * It supports sizing, scaling, and aspect ratio preservation.
 *
 * Image is a leaf widget and does not accept children.
 *
 * Example:
 *   var image = new Image ();
 *   image.path = "/usr/share/icons/hicolor/48x48/apps/firefox.png";
 *   image.pixel_size = 48;
 */
public class Image : NebulaShell.Widget {

    private string _path = "";
    private int _pixel_size = -1;
    private bool _keep_aspect = true;

    /**
     * Emitted when the image path changes.
     *
     * @param new_path the new image file path
     */
    public signal void path_changed (string new_path);

    /**
     * The file path of the image to display.
     *
     * Must point to a valid image file on disk.
     * Default is an empty string (no image).
     */
    public string path {
        get { return _path; }
        set {
            if (_path == value) return;
            _path = value;
            path_changed (_path);
        }
    }

    /**
     * The pixel size for the rendered image.
     *
     * Controls the width and height of the displayed image.
     * A value of -1 uses the image's natural size.
     * Default is -1.
     */
    public int pixel_size {
        get { return _pixel_size; }
        set { _pixel_size = value; }
    }

    /**
     * Whether to preserve the image's aspect ratio.
     *
     * When true, the image is scaled uniformly.
     * When false, the image may be stretched.
     * Default is true.
     */
    public bool keep_aspect {
        get { return _keep_aspect; }
        set { _keep_aspect = value; }
    }

    /**
     * Create a new empty image widget.
     */
    public Image () {
        base ();
    }

    /**
     * Create a new image widget with a file path.
     *
     * @param path the image file path to display
     */
    public Image.with_path (string path) {
        base ();
        _path = path;
    }

    /**
     * Create a new image widget with a path and pixel size.
     *
     * @param path the image file path to display
     * @param pixel_size the rendered size in pixels
     */
    public Image.with_path_and_size (string path, int pixel_size) {
        base ();
        _path = path;
        _pixel_size = pixel_size;
    }

}

}

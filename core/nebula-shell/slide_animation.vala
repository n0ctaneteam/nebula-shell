namespace NebulaShell {

/**
 * Direction for slide animations.
 */
public enum SlideDirection {
    /**
     * Slide from left to right.
     */
    LEFT,

    /**
     * Slide from right to left.
     */
    RIGHT,

    /**
     * Slide from top to bottom.
     */
    UP,

    /**
     * Slide from bottom to top.
     */
    DOWN
}

/**
 * Animates position between two points.
 *
 * SlideAnimation transitions x and y coordinates from a start
 * position to an end position over a specified duration.
 *
 * Supports directional sliding with configurable offsets.
 *
 * Example:
 *   var slide = new SlideAnimation (widget, SlideDirection.LEFT);
 *   slide.duration = 250;
 *   slide.offset = 100;
 *   slide.start ();
 */
public class SlideAnimation : Animation {

    private double _from_x;
    private double _from_y;
    private double _to_x;
    private double _to_y;
    private double _current_x;
    private double _current_y;
    private double _delta_x;
    private double _delta_y;
    private SlideDirection _direction;

    /**
     * The slide direction.
     */
    public SlideDirection direction {
        get { return _direction; }
    }

    /**
     * The starting X position.
     */
    public double from_x {
        get { return _from_x; }
    }

    /**
     * The starting Y position.
     */
    public double from_y {
        get { return _from_y; }
    }

    /**
     * The ending X position.
     */
    public double to_x {
        get { return _to_x; }
    }

    /**
     * The ending Y position.
     */
    public double to_y {
        get { return _to_y; }
    }

    /**
     * The current interpolated X position.
     */
    public double current_x {
        get { return _current_x; }
    }

    /**
     * The current interpolated Y position.
     */
    public double current_y {
        get { return _current_y; }
    }

    /**
     * Create a new slide animation between two points.
     *
     * @param name human-readable identifier
     * @param from_x starting X position
     * @param from_y starting Y position
     * @param to_x ending X position
     * @param to_y ending Y position
     */
    public SlideAnimation.from_points (string name,
                                       double from_x, double from_y,
                                       double to_x, double to_y) {
        base (name);
        _from_x = from_x;
        _from_y = from_y;
        _to_x = to_x;
        _to_y = to_y;
        _current_x = from_x;
        _current_y = from_y;
        _delta_x = to_x - from_x;
        _delta_y = to_y - from_y;
        _direction = SlideDirection.LEFT;
    }

    /**
     * Create a new directional slide animation.
     *
     * The element slides from the specified direction toward
     * the origin (0, 0).
     *
     * @param name human-readable identifier
     * @param direction the direction to slide from
     */
    public SlideAnimation (string name, SlideDirection direction) {
        base (name);
        _direction = direction;

        switch (direction) {
            case SlideDirection.LEFT:
                _from_x = -100;
                _from_y = 0;
                break;
            case SlideDirection.RIGHT:
                _from_x = 100;
                _from_y = 0;
                break;
            case SlideDirection.UP:
                _from_x = 0;
                _from_y = -100;
                break;
            case SlideDirection.DOWN:
                _from_x = 0;
                _from_y = 100;
                break;
        }

        _to_x = 0;
        _to_y = 0;
        _current_x = _from_x;
        _current_y = _from_y;
        _delta_x = _to_x - _from_x;
        _delta_y = _to_y - _from_y;
    }

    /**
     * Set the slide offset for directional animations.
     *
     * @param offset the distance to slide in pixels
     */
    public void set_offset (double offset) {
        switch (_direction) {
            case SlideDirection.LEFT:
                _from_x = -offset;
                break;
            case SlideDirection.RIGHT:
                _from_x = offset;
                break;
            case SlideDirection.UP:
                _from_y = -offset;
                break;
            case SlideDirection.DOWN:
                _from_y = offset;
                break;
        }

        _delta_x = _to_x - _from_x;
        _delta_y = _to_y - _from_y;
    }

    protected override void on_start () {
        _current_x = _from_x;
        _current_y = _from_y;
    }

    protected override void on_update (double progress) {
        _current_x = _from_x + _delta_x * progress;
        _current_y = _from_y + _delta_y * progress;
    }

    protected override void on_cancel () {
        _current_x = _from_x;
        _current_y = _from_y;
    }

}

}

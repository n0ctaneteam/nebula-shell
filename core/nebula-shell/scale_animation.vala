namespace NebulaShell {

/**
 * Animates scale between two factors.
 *
 * ScaleAnimation transitions scale values from a start factor
 * to an end factor over a specified duration. Supports uniform
 * scaling (same factor for both axes) or independent x/y scaling.
 *
 * Example:
 *   var scale = new ScaleAnimation (widget, 0.0, 1.0);
 *   scale.duration = 200;
 *   scale.easing = Easing.ease_out;
 *   scale.start ();
 */
public class ScaleAnimation : Animation {

    private double _from_x;
    private double _from_y;
    private double _to_x;
    private double _to_y;
    private double _current_x;
    private double _current_y;
    private double _delta_x;
    private double _delta_y;

    /**
     * The starting scale factor for X axis.
     */
    public double from_x {
        get { return _from_x; }
    }

    /**
     * The starting scale factor for Y axis.
     */
    public double from_y {
        get { return _from_y; }
    }

    /**
     * The ending scale factor for X axis.
     */
    public double to_x {
        get { return _to_x; }
    }

    /**
     * The ending scale factor for Y axis.
     */
    public double to_y {
        get { return _to_y; }
    }

    /**
     * The current interpolated X scale factor.
     */
    public double current_x {
        get { return _current_x; }
    }

    /**
     * The current interpolated Y scale factor.
     */
    public double current_y {
        get { return _current_y; }
    }

    /**
     * Create a uniform scale animation.
     *
     * Both axes use the same scale factor.
     *
     * @param name human-readable identifier
     * @param from starting scale factor
     * @param to ending scale factor
     */
    public ScaleAnimation (string name, double from, double to) {
        base (name);
        _from_x = from;
        _from_y = from;
        _to_x = to;
        _to_y = to;
        _current_x = from;
        _current_y = from;
        _delta_x = to - from;
        _delta_y = to - from;
    }

    /**
     * Create a scale animation with independent axis factors.
     *
     * @param name human-readable identifier
     * @param from_x starting X scale factor
     * @param from_y starting Y scale factor
     * @param to_x ending X scale factor
     * @param to_y ending Y scale factor
     */
    public ScaleAnimation.from_points (string name,
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
    }

    /**
     * Create a scale-in animation (0 to 1).
     *
     * Convenience constructor for scaling from invisible to full size.
     *
     * @param name human-readable identifier
     * @return a new ScaleAnimation
     */
    public static ScaleAnimation scale_in (string name) {
        return new ScaleAnimation (name, 0.0, 1.0);
    }

    /**
     * Create a scale-out animation (1 to 0).
     *
     * Convenience constructor for scaling from full size to invisible.
     *
     * @param name human-readable identifier
     * @return a new ScaleAnimation
     */
    public static ScaleAnimation scale_out (string name) {
        return new ScaleAnimation (name, 1.0, 0.0);
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

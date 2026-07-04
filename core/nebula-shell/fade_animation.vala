namespace NebulaShell {

/**
 * Animates opacity between two values.
 *
 * FadeAnimation transitions a numeric property (typically opacity)
 * from a start value to an end value over a specified duration.
 *
 * This animation is declarative — it describes WHAT to animate,
 * not HOW to render it. The animation engine handles timing.
 *
 * Example:
 *   var fade = new FadeAnimation (widget, 0.0, 1.0);
 *   fade.duration = 300;
 *   fade.easing = Easing.ease_out;
 *   fade.start ();
 */
public class FadeAnimation : Animation {

    private double _from;
    private double _to;
    private double _current;
    private double _delta;

    /**
     * The starting opacity value.
     */
    public double from {
        get { return _from; }
    }

    /**
     * The ending opacity value.
     */
    public double to {
        get { return _to; }
    }

    /**
     * The current interpolated opacity value.
     *
     * Updated each frame during animation.
     */
    public double current {
        get { return _current; }
    }

    /**
     * Create a new fade animation.
     *
     * @param name human-readable identifier
     * @param from starting opacity (typically 0.0)
     * @param to ending opacity (typically 1.0)
     */
    public FadeAnimation (string name, double from, double to) {
        base (name);
        _from = from;
        _to = to;
        _current = from;
        _delta = to - from;
    }

    /**
     * Create a new fade-in animation.
     *
     * Convenience constructor for fading from invisible to visible.
     *
     * @param name human-readable identifier
     * @return a new FadeAnimation
     */
    public static FadeAnimation fade_in (string name) {
        return new FadeAnimation (name, 0.0, 1.0);
    }

    /**
     * Create a new fade-out animation.
     *
     * Convenience constructor for fading from visible to invisible.
     *
     * @param name human-readable identifier
     * @return a new FadeAnimation
     */
    public static FadeAnimation fade_out (string name) {
        return new FadeAnimation (name, 1.0, 0.0);
    }

    protected override void on_start () {
        _current = _from;
    }

    protected override void on_update (double progress) {
        _current = _from + _delta * progress;
    }

    protected override void on_cancel () {
        _current = _from;
    }

}

}

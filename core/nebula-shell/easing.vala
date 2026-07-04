namespace NebulaShell {

/**
 * Easing functions for animation curves.
 *
 * Each function maps a normalized time value [0, 1] to an
 * eased output value. These functions control the acceleration
 * and deceleration of animations.
 *
 * Example:
 *   var animation = new FadeAnimation (widget, 0.0, 1.0);
 *   animation.easing = Easing.ease_out;
 */
public class Easing : NebulaShell.Object {

    /**
     * Linear easing — no acceleration.
     *
     * Output equals input. Used for constant-speed animations.
     *
     * @param t normalized time [0, 1]
     * @return eased value [0, 1]
     */
    public static double linear (double t) {
        return t;
    }

    /**
     * Ease-in — slow start, fast end.
     *
     * Accelerates gradually. Good for elements entering view.
     *
     * @param t normalized time [0, 1]
     * @return eased value [0, 1]
     */
    public static double ease_in (double t) {
        return t * t;
    }

    /**
     * Ease-out — fast start, slow end.
     *
     * Decelerates gradually. Good for elements settling into place.
     *
     * @param t normalized time [0, 1]
     * @return eased value [0, 1]
     */
    public static double ease_out (double t) {
        return t * (2.0 - t);
    }

    /**
     * Ease-in-out — slow start and end.
     *
     * Symmetric acceleration. Good for elements moving between states.
     *
     * @param t normalized time [0, 1]
     * @return eased value [0, 1]
     */
    public static double ease_in_out (double t) {
        if (t < 0.5) {
            return 2.0 * t * t;
        }
        return -1.0 + (4.0 - 2.0 * t) * t;
    }

    /**
     * Bounce easing — simulates bouncing.
     *
     * Overshoots and settles. Good for playful, bouncy effects.
     *
     * @param t normalized time [0, 1]
     * @return eased value [0, 1]
     */
    public static double bounce (double t) {
        if (t < 1.0 / 2.75) {
            return 7.5625 * t * t;
        } else if (t < 2.0 / 2.75) {
            t -= 1.5 / 2.75;
            return 7.5625 * t * t + 0.75;
        } else if (t < 2.5 / 2.75) {
            t -= 2.25 / 2.75;
            return 7.5625 * t * t + 0.9375;
        } else {
            t -= 2.625 / 2.75;
            return 7.5625 * t * t + 0.984375;
        }
    }

    /**
     * Elastic easing — simulates elastic spring.
     *
     * Oscillates around the target. Good for spring-like effects.
     *
     * @param t normalized time [0, 1]
     * @return eased value [0, 1]
     */
    public static double elastic (double t) {
        if (t == 0.0 || t == 1.0) return t;

        double p = 0.3;
        double s = p / 4.0;
        double post = Math.pow (2.0, -10.0 * t) * Math.sin ((t - s) * (2.0 * Math.PI) / p) + 1.0;
        return post;
    }

    /**
     * Create a new easing instance.
     */
    public Easing () {
        base.with_name ("easing");
    }

}

}

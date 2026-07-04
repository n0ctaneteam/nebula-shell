namespace NebulaShell {

/**
 * Event for scroll interactions.
 *
 * ScrollEvent carries data about a scroll action on a widget.
 * It includes the coordinates, scroll deltas, and direction.
 *
 * ScrollEvent is emitted by widgets when the user scrolls
 * over them.
 *
 * Example:
 *   widget.event_received.connect ((event) => {
 *       if (event is ScrollEvent) {
 *           var scroll = (ScrollEvent) event;
 *           print ("Scroll delta: " + scroll.delta_y.to_string () + "\n");
 *       }
 *   });
 */
public class ScrollEvent : Event {

    private double _x;
    private double _y;
    private double _delta_x;
    private double _delta_y;
    private ScrollDirection _direction;

    /**
     * The x coordinate of the scroll.
     */
    public double x {
        get { return _x; }
    }

    /**
     * The y coordinate of the scroll.
     */
    public double y {
        get { return _y; }
    }

    /**
     * The horizontal scroll delta.
     *
     * Positive values scroll right, negative values scroll left.
     */
    public double delta_x {
        get { return _delta_x; }
    }

    /**
     * The vertical scroll delta.
     *
     * Positive values scroll down, negative values scroll up.
     */
    public double delta_y {
        get { return _delta_y; }
    }

    /**
     * The scroll direction.
     */
    public ScrollDirection direction {
        get { return _direction; }
    }

    /**
     * Create a new scroll event.
     *
     * @param source the widget that was scrolled
     * @param x the x coordinate of the scroll
     * @param y the y coordinate of the scroll
     * @param delta_x the horizontal scroll delta
     * @param delta_y the vertical scroll delta
     * @param direction the scroll direction
     */
    public ScrollEvent (Widget source, double x, double y,
                        double delta_x, double delta_y,
                        ScrollDirection direction) {
        base (EventType.SCROLL, source);
        _x = x;
        _y = y;
        _delta_x = delta_x;
        _delta_y = delta_y;
        _direction = direction;
    }

}

}